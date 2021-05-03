({
	CheckSDG_FieldPermission: function (component) {
		var action = component.get("c.CheckSDG_FieldPermission");
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set("v.sdgFieldPermission", response.getReturnValue());
			}
			else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
	},
	addRequiredParameters: function (field, path) {
		field.ID = "Dynamic_" + Math.floor(Math.random() * 100000);
		field.Label = field.label;
		field.ColumnName = path;
		return field;
	},
	getSelectedField: function (component) {
		var allFieldsFromPicklist = component.get("v.sObjectFields");
		var selectedField = component.get("v.selectedPath");
		var splittedPath = selectedField.split(".");
		var fieldObj = allFieldsFromPicklist.find(
			o => o.fieldname === splittedPath[splittedPath.length - 1]
		);
		fieldObj = this.addRequiredParameters(fieldObj, selectedField);
		return fieldObj;
	},
	addFieldToList: function (component, fieldObj) {
		component.set("v.errorMessage", "");
		var existingFields = component.get("v.fields");
		
		if (existingFields) {
			let found  = existingFields.some(other => other.fieldname===fieldObj.fieldname || other.ColumnName===fieldObj.fieldname);
        	if (!found )		
				existingFields.push(fieldObj);
			else
			this.showError("'"+fieldObj.Label +"' field already added."); // error message updated by Aditya PEv4.7 29 April 2021
			//component.set("v.errorMessage", "Selected value already added.");
		} 
		else {
			existingFields = [];
			existingFields.push(fieldObj);
		}
		component.set("v.selectedFieldId", fieldObj.ID);
		component.set("v.fields", existingFields);
	},
	removeFieldHelper: function (component, fieldId) {
		var allFields = component.get("v.fields");
		var fieldIdsToRemove = component.get("v.fieldIdsToRemove");
		allFields = allFields.filter(function (obj) {
			return obj.ID !== fieldId;
		});
		if (fieldIdsToRemove && fieldId && !fieldId.startsWith("Dynamic_")) {
			fieldIdsToRemove.push(fieldId);
		}
		component.set("v.fields", allFields);
		component.set("v.fieldIdsToRemove", fieldIdsToRemove);
	},
	moveFieldHelper: function (component, direction) {
		var allFields = component.get("v.fields");
		var selectedNode = component.get("v.selectedFieldId");
		if (allFields && selectedNode) {
			var tempField;
			var nodeIndexToSwap;
			for (var i = 0; i < allFields.length; i++) {
				if (allFields[i].ID == selectedNode) {
					tempField = allFields[i];
					nodeIndexToSwap = i;
					break;
				}
			}
			var iota = 1;
			if (direction === "up") {
				iota *= -1;
			}
			if (typeof allFields[nodeIndexToSwap + iota] != "undefined") {
				allFields[nodeIndexToSwap] = allFields[nodeIndexToSwap + iota];
				allFields[nodeIndexToSwap + iota] = tempField;
				component.set("v.fields", allFields);
			}
		}
	},
	updateFieldHelper: function (component) {
		debugger;
		var sdgFieldPermission = component.get("v.sdgFieldPermission");
		if (sdgFieldPermission) {
			var allFields = component.get("v.fields");
			var updateAction = component.get("c.updateFieldsAndOrder");
			updateAction.setParams({
				jsonStr: JSON.stringify(allFields),
				sdgId: component.get("v.recordId"),
				idsToDelete: component.get("v.fieldIdsToRemove")
			});
			updateAction.setCallback(this, function (response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					var evtRefresh = component.getEvent("refreshSdgColumns");
					evtRefresh.fire();
					component.destroy();
				} else if (state === "ERROR") {
					var errors = response.getError();
					if (errors) {
						if (errors[0] && errors[0].message) {
							component.set("v.errorMessage", errors[0].message);
						} else {
							component.set("v.errorMessage", "An unexpected error has occurred. Please contact your Navatar Administrator."); // error message updated by Aditya PEv4.7 29 April 2021
						}
					} else {
						component.set("v.errorMessage", "An unexpected error has occurred. Please contact your Navatar Administrator."); // error message updated by Aditya PEv4.7 29 April 2021
					}
				}
			});
			$A.enqueueAction(updateAction);
		}
		else
		{
			component.set("v.errorMessage", "You do not have permission to edit this information. Please contact your Navatar Administrator."); // error message updated by Aditya PEv4.7 29 April 2021
		}
	},
	showError : function(message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message:message,
            duration:' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
		toastEvent.fire();     
    }
	
});