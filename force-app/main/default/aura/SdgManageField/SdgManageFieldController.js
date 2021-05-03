({
	doInit : function(component, event, helper) {
        debugger;
        helper.CheckSDG_FieldPermission(component);
    },
	clearSelection : function (component){
		component.find('picker').clearselection();
	},
	closeComponent : function (component){
		component.destroy();
	},
	addField : function (component,event,helper){
		var fieldObj = helper.getSelectedField(component);
		helper.addFieldToList(component,fieldObj);
		component.find('picker').clearselection();
	},
	removeField : function (component,event,helper){
		helper.removeFieldHelper(component,event.getSource().get("v.value"));
	},
	selectField : function (component, event, helper){
		if(event.currentTarget && event.currentTarget.id){
			component.set("v.selectedFieldId",event.currentTarget.id);
		}
	},
	moveField : function (component,event,helper){
		var direction = event.getSource().get("v.name");
		helper.moveFieldHelper(component,direction);
	},
	updateFields : function (component,event,helper){
		helper.updateFieldHelper(component);

	},
	// this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
		// make Spinner attribute true for display loading spinner 
		 component.set("v.Spinner", true); 
	},
	 
  // this function automatic call by aura:doneWaiting event 
	 hideSpinner : function(component,event,helper){
	  // make Spinner attribute to false for hide loading spinner    
		component.set("v.Spinner", false);
	 }
	
});