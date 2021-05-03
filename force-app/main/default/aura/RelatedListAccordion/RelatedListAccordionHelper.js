({
    fetchRelatedList : function(component,event,helper,showList) {
        var query = component.get("v.ObjectQuery");
        if(query!=undefined && query!='') query = query.replace(/ {1,}/g, ' ');
       // let geticon = (component.get("v.imageUrl") == ''); commented by shashank, icon will be fetched for all cases
        var action = component.get("c.fetchRelatedList");
        var sdgName = component.get("v.sdgRedirectName");
        var querylimit = component.get("v.listOffset");
        console.log('sObjectName'+component.get("v.sObjectName"));
        action.setParams({
            objectQuery: query,
            getIcon : true,
            CurrentPageObject: component.get("v.sObjectName"),
            recordId: component.get("v.recordId") == undefined?'':component.get("v.recordId"),
            sdgName: sdgName,
            querylimit: querylimit
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result -> '+JSON.stringify(result));
                if(result.serverStatus == 'success'){
                    let fullList = [];
                    if(result.resultData.length>0){
                        fullList = helper.dataprocessor(component,JSON.parse(JSON.stringify(response.getReturnValue())));    
                        component.set("v.fullRelatedList",fullList);
                        var offset = component.get("v.listOffset");
                        fullList = fullList.slice(0,offset);
                        component.set("v.RelatedList",fullList);
                        component.set("v.currentLoadCount",fullList.length);
                        component.set("v.isIcon",response.getReturnValue().iconExist);
                        
                        
                    }else if(component.get("v.sdgRedirectName")!='' && component.get("v.ObjectQuery")=='')
                    {
                        component.set("v.isSdgMode",true);
                        //component.set("v.NewButtonFieldApi",result.parentField);
                    }
                    component.set("v.showList",showList);
                    component.set("v.HeaderIcon",response.getReturnValue().objectIcon)
                    component.set("v.relatedObjName",response.getReturnValue().sobjectName);
                }else{
                    helper.showToast(result.serverStatus,'Error!','error');
                    
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                        helper.showToast(errors[0].message,'Error!','error');
                        
                    }
                }
            }
            component.set("v.loaded",false);
            
        });
        $A.enqueueAction(action);
    },
    dataprocessor : function(component,resultWrapper){
        let rows = [];
        try{
        let fdata = resultWrapper.resultData;
        let imageFieldApiName = component.get("v.imageUrl")!=undefined?component.get("v.imageUrl"):'';
        if(imageFieldApiName==''){
            component.set("v.showIcon",false);   
        }
        resultWrapper.fStruct.push({'apiName':'Id','fieldType':'REFERENCE','label':'default Id','objName':''});  
        for(let index in fdata ){
            let imageUrl;
            let actualId;
            let fieldList = [];
            for(let field of resultWrapper.fStruct){
                let isImage = false;
                let isId = false;
                let rowdata = JSON.parse(JSON.stringify(field));
                let fields = field.apiName.split('.');
                if (fields.length >= 1) {
                    switch (fields.length) {
                        case 1:
                            var rowDataVal =(fdata[index] || {})[fields];
                            rowDataVal = rowDataVal!=undefined? rowDataVal :''; 
                            if(fields == 'Id' && field.label == 'default Id'){
                                actualId = rowDataVal;
                                isId = true;
                            }else{
                               if (imageFieldApiName!='' && field.apiName.toLowerCase().includes(imageFieldApiName.toLowerCase())){
                                imageUrl = rowDataVal;
                                isImage = true;
                            }else{
                                rowdata.value = rowDataVal;
                            } 
                            }
                            break;
                        case 2:
                            var rowDataVal =(fdata[index][fields[0]] || {})[fields[1]];
                            rowDataVal = rowDataVal!=undefined? rowDataVal :''; 
                            if (imageFieldApiName!='' && field.apiName.toLowerCase().includes(imageFieldApiName.toLowerCase())){
                                imageUrl = rowDataVal;
                                isImage = true;
                            }else{
                                rowdata.value = rowDataVal;
                            }
                            break;
                        case 3:
                            var rowDataVal =(fdata[index][fields[0]] || {})[fields[1]];
                            rowDataVal = (rowDataVal || {})[fields[2]];
                            rowDataVal = rowDataVal!=undefined? rowDataVal :''; 
                            if (imageFieldApiName!='' && field.apiName.toLowerCase().includes(imageFieldApiName.toLowerCase())){
                                imageUrl = rowDataVal;
                                isImage = true;
                            }else{
                                rowdata.value = rowDataVal;
                            }
                            break;
                        case 4:
                            var rowDataVal =(fdata[index][fields[0]] || {})[fields[1]];
                            rowDataVal = (rowDataVal || {})[fields[2]];
                            rowDataVal = (rowDataVal || {})[fields[3]];
                            
                            rowDataVal = rowDataVal!=undefined? rowDataVal :'';
                            if (imageFieldApiName!='' && field.apiName.toLowerCase().includes(imageFieldApiName.toLowerCase())){
                                imageUrl = rowDataVal;
                                isImage = true;
                            }else{
                                rowdata.value = rowDataVal;
                            }
                            break;
                    }
                    if(rowdata.value!='' && field.fieldType.includes('DATE')) 
                        rowdata.value = new Date(rowdata.value).toLocaleDateString();
                }
                if(isImage == false && isId == false) fieldList.push(rowdata);
                
            }
            if(fieldList.length>=2 && fieldList[0].value!='' && fieldList[1].value!='' && fieldList[0].value!=component.get("v.recordId")){
                rows.push({id:fieldList[0].value,
                           name: fieldList[1].value,
                           actualId: actualId,
                           rows: fieldList.slice(2,fieldList.length),
                           imageUrl: imageUrl
                          });  
            }
           
        }
              console.log('rows -->'+JSON.stringify(rows));
            }catch(err){
            console.log('exception'+err.message);
        }
        return rows;
    },
    redirectToSDG: function(component,event,helper){
        component.set("v.showSdg",true);
    }/*,
    handleCreateRecord  : function(component,event,helper){
        var objName = component.get("v.NewbuttonObj");
        objName = (objName== undefined|| objName == '')?component.get("v.relatedObjName"):objName;
        
        var createRecordEvent = $A.get("e.force:createRecord");
        if(createRecordEvent){
            var childCmp = component.find("newRecordCmp");
            let newObj = { 
                "entityApiName": objName,
                "navigationLocation" : "LOOKUP",
                "defaultFieldValues":{},
                "panelOnDestroyCallback": function(event) {
                    console.log('event'+event);
                    var compEvent = component.getEvent("relatedListcmp");
                    compEvent.fire();
                }
            };
            var fieldname = component.get("v.NewButtonFieldApi");
            if(fieldname!= undefined && fieldname!=''){
                newObj.defaultFieldValues[fieldname] = component.get("v.recordId");    
            }
            var auraMethodResult = childCmp.openNewRecordPopup(newObj,'','');  
        }else{
            alert('Record Creation not allowed here');
        }      
    }*/,
    showToast : function(message,title,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type":type,
            "mode": 'dismissible'
        });
        toastEvent.fire();
    }
    
})