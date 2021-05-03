({
	getData : function(component, event, helper) {
        component.set("v.showPopup",true);
		//Call method to get related ids
        var params = event.getParam('arguments');
        if (params) {
            //call apex method
            debugger;
            var getRelatedIdsData = component.get("c.getRelatedAssociations");
            getRelatedIdsData.setParams({taskId : params.taskId});
            getRelatedIdsData.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set('v.relatedAssociations',response.getReturnValue());
                    component.set('v.showSpinner',false);
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
            }
                
            })
            $A.enqueueAction(getRelatedIdsData);
        }
	},
    closeModal : function(component){
        component.set("v.showPopup",false);
        component.set("v.relatedAssociations",'');
        component.set('v.showSpinner',true);
    }
    
})