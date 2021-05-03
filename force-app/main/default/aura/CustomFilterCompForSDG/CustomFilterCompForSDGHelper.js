({
    getAllCustomFields : function(component, event) {
        var action3 = component.get("c.getFieldValues"); 
        action3.setParams({
            query1: component.get("v.query1"),
            query2: component.get("v.query2"),
            query3: component.get("v.query3"),
            query4: component.get("v.query4")
            
        })
        action3.setCallback(this, function(res){
            var filterCount = 0;
            if(component.get("v.showMyRecords")){
                filterCount++;
            }
            var state = res.getState();
            if(state === "SUCCESS"){
                
                var wrappers = res.getReturnValue();
                var blankval={'label':'All', 'value':''};
                var picklist1 =[];
                var picklist2 =[];
                var picklist3 =[];
                var picklist4 =[];
                picklist1.push(blankval);
                picklist2.push(blankval);
                picklist3.push(blankval);
                picklist4.push(blankval);
                if(wrappers.picklist1.length > 0){
                    filterCount++;
                    for(var wr in wrappers.picklist1){
                    	var list1 = {};    
                        list1['label'] = wrappers.picklist1[wr];
                        list1['value'] = wrappers.picklist1[wr];
                        picklist1.push(list1);
                    }
                	component.set("v.picklist1",picklist1);
                }
                
                if(wrappers.picklist2.length > 0){
                    filterCount++;
                    for(var wr in wrappers.picklist2){
                       var list2 = {}; 
                        list2['label'] = wrappers.picklist2[wr];
                        list2['value'] = wrappers.picklist2[wr];
                        picklist2.push(list2);
                    }
                	component.set("v.picklist2",picklist2);
                }
                
                if(wrappers.picklist3.length > 0){
                    filterCount++;
                    for(var wr in wrappers.picklist3){
                        var list3 = {}; 
                        list3['label'] = wrappers.picklist3[wr];
                        list3['value'] = wrappers.picklist3[wr];
                        picklist3.push(list3);
                    }
                    component.set("v.picklist3",picklist3);
                }
                
                if(wrappers.picklist4.length > 0){
                    filterCount++;
                    for(var wr in wrappers.picklist4){
                        var list4 = {}; 
                        list4['label'] = wrappers.picklist4[wr];
                        list4['value'] = wrappers.picklist4[wr];
                        picklist4.push(list4);
                    }
                    component.set("v.picklist4",picklist4);
                }
                
                component.set("v.filterCount",filterCount);
                
                
                var RecordPicklist = [
                    { label: "All Records", value: "All Records" },
                    { label: "My Records", value: "My Records" },
                    { label: "My Team's Records", value: "My Teams Records" }
                ];
                component.set("v.RecordPicklist", RecordPicklist);
            }else if (state === "ERROR") {
                if(errors) {
                    $('.div_a').show();
                    if(errors[0] && errors[0].message) {
                        console.log("Error message: " +errors[0].message);
                    }else {
                        console.log("Unknown error");
                    }
                }
            }
        });
        $A.enqueueAction(action3);
    }
})