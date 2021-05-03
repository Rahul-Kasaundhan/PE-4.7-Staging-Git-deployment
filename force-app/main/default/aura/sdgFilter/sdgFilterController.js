/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
({
    doInit: function(component, event, helper) {
        var FieldType = component.get("v.SDGField").FieldType;
        
        var pref = component.get("v.SDGField").Preferences;
        //suppress any exceptions during preference setting:
        try {
            if (pref !== null) {
                component.set("v.FilterOperatorPreference", pref.FilterOperator);
                component.set("v.FilterValuePreference", pref.FilterValue);
                if (FieldType === "DATE" || FieldType === "DATETIME") {
                    if (pref.FilterValue !== "")
                        component.set("v.DateValue", pref.FilterValue);
                }
            } else {
                component.set("v.FilterValuePreference", null);
            }
        } catch (err) {
            //Suppress errors in setting preferences
        }
        
        if (FieldType === "DATE" || FieldType === "DATETIME") {
            component.set("v.isDate", true);
            component.set("v.canFilter", true);
        }
        if (
            FieldType === "INTEGER" ||
            FieldType === "DOUBLE" ||
            FieldType === "CURRENCY" ||
            FieldType === "PERCENT"
        ) {
            component.set("v.isNumber", true);
            component.set("v.canFilter", true);
        }
        if (
            FieldType === "ID" ||
            FieldType === "STRING" ||
            FieldType === "EMAIL" ||
            FieldType === "URL" ||
            FieldType === "PHONE" ||
            FieldType === "HYPERLINK"
        ) {
            component.set("v.isString", true);
            component.set("v.canFilter", true);
        }
        //Other acceptable types
        if (FieldType === "BOOLEAN" || FieldType === "PICKLIST") {
            component.set("v.canFilter", true);
        }
        //for multiSelectPIcklist ~Akash
        if (FieldType === "MULTIPICKLIST") {
            component.set("v.isMultiSelect", true);
            component.set("v.canFilter", true);
        }
        //END
    },
    
    updateString: function(component, event, helper) {
        var value = component.find("StringField").get("v.value");
        var operator = component.find("StringOperatorField").get("v.value");
        helper.fireUpdate(component, value, operator);
    },
    updateCheckbox: function(component, event, helper) {
        var value = component.find("CheckboxField").get("v.value");
        
        helper.fireUpdate(component, value, "");
    },
    updateDate: function(component, event, helper) {
        var value = component.find("DateField").get("v.value");
        if (value === null) value = "";
        var operator = component.find("DateOperatorField").get("v.value");
        
        helper.fireUpdate(component, value, operator);
    },
    updateNumber: function(component, event, helper) {
        var value = component.find("NumberField").get("v.value");
        var operator = component.get("v.NumberOperator");
        
        helper.fireUpdate(component, value, operator);
    },
    updatePicklist: function(component, event, helper) {
        var value = component.find("PicklistField").get("v.value");
        
        helper.fireUpdate(component, value, "");
    },
    //For multiselect ~Akash
    updateMultiSelect: function(component, event, helper) {
        var value = component.find("MultiSelectField").get("v.value");
        //added check to display error div for multiselect picklist by Sameeksha Sahu
        component.set("v.isSplitText",false);
        if(value != null && value.includes(',')){
            component.set("v.isSplitText",true);
            return false;
        }
        var operator = component.find("MultiSelectOperatorField").get("v.value");
        helper.fireUpdate(component, value, operator);
    },
    callSdgFilterAction : function(component, event, helper) {
        
        
        //Added by Jonson: This method will get execute when aura method will get execute
        
        var params = event.getParam('arguments');
        if (params) {
            var value = params.value;
            var fieldSequence = params.fieldSequence;
            var objectApiName = params.objectApiName;
            // Changed Code by Sameer Industry__c and Region__c to be searched for global filter.
            //Bug Fixing: Applied column api name check ~Sameeksha Sahu
            var filterSeq = component.get("v.SDGField").filterSeq;
            
            if(filterSeq == fieldSequence || 
              objectApiName == component.get("v.SDGField").ColumnName.toLowerCase())
            {
                helper.fireUpdate(component, value, "");	//For applying filter
                if(component.find("StringField") != null ){
                    component.find("StringField").set("v.value",value); // For set Values in filter Added by Sameer
                    component.find("StringOperatorField").set("v.value",'=');
                }
                if(component.find("PicklistField") != null){
                    component.find("PicklistField").set("v.value",value);
                }
            }
        }
    }
});