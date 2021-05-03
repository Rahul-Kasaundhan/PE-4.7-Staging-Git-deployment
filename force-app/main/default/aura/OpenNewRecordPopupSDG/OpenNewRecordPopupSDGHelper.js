({
    setRecordTypeList : function(component, event, helper) {
        
        // Get Sobject label
        var SObjectLabelAction = component.get("c.getSObjectLabel");
        SObjectLabelAction.setParams({
            objectName : component.get("v.objectApi")
        });
        SObjectLabelAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.objectName", response.getReturnValue());
                $A.enqueueAction(recordTypeListAction);
            }
        });    
        $A.enqueueAction(SObjectLabelAction);
        // Ends
        
        // Get Record Type List
        var recordTypeListAction = component.get("c.getRecordTypeList");
        recordTypeListAction.setParams({ 
            objectName : component.get("v.objectApi")
        });
        recordTypeListAction.setCallback(this, function(response) {
            
            var state = response.getState();
            var recordtypeNameToId = [];
            var recordTypes ;
            if (state === "SUCCESS") {
                recordTypes = response.getReturnValue();
                for(var i = 0; i < recordTypes.length; i++){
                    recordtypeNameToId.push({name:recordTypes[i].split('¤')[0], id:recordTypes[i].split('¤')[1], desc:recordTypes[i].split('¤')[2]});                    
                }
                component.set("v.recordTypeList",recordtypeNameToId);
                if(recordTypes.length > 1){
                    component.set("v.recordTypeId",recordTypes[0].split('¤')[1])
                    component.set("v.showRecordTypePopup",true); 
                    if(component.get("v.applyCSSFlg")){ 
                    jQuery(document).ready(function() {
                                setTimeout(function(){
                                        var centerPopup = document.getElementById('ContainerID');
                                        var centerPopupBody = document.getElementById('containerBodyID');
                                        var popupHeight = centerPopupBody.clientHeight;
                                        var popupWidth = centerPopup.clientWidth;
                                        var windowWidth = window.innerWidth;
                                        var windowHeight = window.screen.availHeight;
                                        var remainingHeight = windowHeight - component.get("v.panelHeight");
                                        centerPopup.style.top = (windowHeight/2-popupHeight/2)-remainingHeight+"px",
                                        centerPopup.style.left= (windowWidth/2-popupWidth/2)+"px",
                                        centerPopup.style.position = "fixed";
                                    	//To set focus on default radion button
                                        jQuery("#recordType0").focus(); 
                                }, 0);
                            });
                }
                    
                }else{
                    this.openNewRecordHelper(component, event, helper);
                }
            }
        });
        // Ends
    },
    openNewRecordHelper : function(component, event, helper) {
        
        var paramObj = component.get("v.eventParameters");
        var objectType = "";
        if(component.get("v.objectApi")){
             objectType = component.get("v.objectApi");
        }
       
        if(objectType != ''){
            var createRecordEvent = $A.get("e.force:createRecord");
            if(component.get("v.recordTypeId")){
                paramObj["recordTypeId"] = component.get("v.recordTypeId");
                createRecordEvent.setParams(paramObj);
            }else{
                createRecordEvent.setParams(paramObj);
            }
            component.set('v.recordTypeId','');
            createRecordEvent.fire();
        }
    }
})