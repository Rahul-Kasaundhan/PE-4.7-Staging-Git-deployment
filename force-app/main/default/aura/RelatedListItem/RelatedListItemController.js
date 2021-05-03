({
    loadData : function(component,event,helper){
        if(component.get("v.record.imageUrl")){
            helper.imageExists(component, helper,component.get("v.record.imageUrl"), function (exists) {
                if (!exists) {
                    component.set("v.record.imageUrl", undefined);
                }
            });   
        }
        if(component.get("v.record.actualId").substring(0,3)!='005'){
            component.set("v.enableDelete",true);
        }
        //Added by Shashank For Object Icon Check
        if(component.get("v.record.id").substring(0,3)=='003'){
            component.set("v.isPrimary",true);
        }
    },
    /*handleSelect : function(component, event, helper) {
        var selectedMenuItemValue = event.getParam("value");
        if(selectedMenuItemValue == 'Edit'){            
            var editRecordEvent = $A.get("e.force:editRecord");
            editRecordEvent.setParams({
                "recordId": component.get("v.record.actualId")
            });
            editRecordEvent.fire();
        }else {
            component.set("v.showDelModal",true);
        }
    },
    closeModel : function(component, event, helper) {
        component.set("v.showDelModal",false);
    },
    onRecorddelete: function(component,event,helper){
        helper.deleteRecord(component,event,helper);
    }  */  
})