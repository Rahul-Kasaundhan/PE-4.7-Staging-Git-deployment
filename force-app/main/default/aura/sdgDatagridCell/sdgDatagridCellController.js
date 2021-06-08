/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
({
    onInit: function(component, event, helper) {        
        try {
            //exception comes if field is hidden handled by Sameeksha Sahu (Added check for field data)
			
            if(component.get("v.renderfield")!=undefined){
                var field = component.get("v.renderfield");
                var fieldtype = field.FieldType;
                var fieldstyle = field.FieldStyle;
                var formattedValue = field.FormattedValue;
                // Add Conditon for bug fixing(00028982)  in DarkMode for Einstein Code V1 By Rahulk
                // Added slds-var-m-bottom_x-small by Lakshya on 20210524; 00029625
				var css_des = ((component.get("v.currentTheme") == 'Dark') ? "cls_desDark":"cls_des") + " slds-var-m-bottom_x-small"
                if (!field) {
                    helper.CreateCmp("ui:outputText", { value: "no data" });
                } else {
                    if (field.isEditableField) {
                        component.set("v.cmpGlobalId", component.getGlobalId());
                    }
                    var datachunk;
                    if (component.get("v.isValueUpdated")) {
                        datachunk = component.get("v.updatedValue");
                        formattedValue = datachunk;
                    } else {
                        datachunk = field.datachunk;
                    }
                    var datachunkid = field.datachunkid;
                    var relatedAssociationData = field.relatedAssociationData;
                    var fieldurl = field.url;
                    var objid = field.ObjId;
                    //START - Changes to show zero instead of blank when using numeric type field ~Akash
                    if (!datachunk && datachunk != 0) datachunk = "";
                    //END - Changes to show zero instead of blank when using numeric type field ~Akash

                    //Changes for showing related associations and call helper for name (Icon+Name+Id) in Phase3 CR by Akash(28-11-2019)
                    if(field && field.Path && field.Path.toLowerCase().includes('related_associations__c')){
                        if(datachunk && relatedAssociationData){
                            helper.renderRelatedAssociation(component, datachunkid, datachunk, relatedAssociationData);
                        }
                    } else if (component.get("v.isValueUpdated") && field.Path.includes('.')) {
                        helper.createLookup(component, datachunk);
                    } else if (field.isHTMLFormatted) {
                        helper.CreateCmp(component, "aura:unescapedHtml", {
                            value: '<div class="'+css_des+'" title="'+datachunk.toString().replace(/<[^>]*>/g, '')+'">'+datachunk+'</div>',
                            
                        });
                    } else {
                        switch (fieldtype) {                            
                            case "STRING":
                                if(field.hasImage){
                                    helper.renderImage(component, field.imageField, datachunk, field,datachunkid);
                                }
                                else if (field.FieldName.toLowerCase() === "name") {
                                    //Change to add hyperlink to text ~Akash
                                    if(field.redirectUrl){                                    
                                        var newUrl = helper.getNewUrl(field);
                                        var label = datachunk;
                                        helper.renderHyperLink(component, label, newUrl);
                                    }//END
                                    //Change to remove hyperlink from name field in case of grouping ~Akash 
                                    else if(field.groupingQuery){
                                        helper.renderText(component, datachunk);
                                    } else{
                                        helper.renderHyperLinktoObject(
                                            component,
                                            datachunk,
                                            datachunkid
                                        );
                                    }
                                    
                                } else {
                                    //Change to add hyperlink to text ~Akash
                                    if(field.redirectUrl){
                                        var newUrl = helper.getNewUrl(field);
                                        var label = datachunk;
                                        helper.renderHyperLink(component, label, newUrl);
                                    }
                                    //END
                                    else{
                                        helper.renderText(component, datachunk);
                                    }
                                }
                                break;
                            case "COMBOBOX":
                                helper.renderText(component, datachunk);
                                break;
                            case "ANYTYPE":
                                helper.renderText(component, datachunk);
                                break;
                            case "SUMMARY":
                                helper.renderSummaryText(component, formattedValue);
                                break;
                            case "ID":
                                //Change to add hyperlink to Id ~Akash
                                if(field.redirectUrl){                                    
                                    var newUrl = helper.getNewUrl(field);
                                    var label = datachunk;
                                    helper.renderHyperLink(component, label, newUrl);
                                }//END
                                else if(field.groupingQuery){
                                    helper.renderText(component, datachunk);
                                }else{
                                    helper.renderHyperLinktoObject(
                                        component,
                                        datachunkid,
                                        datachunkid
                                    );
                                }
                                break;
                            case "REFERENCE":
                                helper.renderText(component, datachunk);
                                break;
                            case "PERCENT":
                                //Change to add hyperlink to text ~Akash
                                if(field.redirectUrl){
                                    var newUrl = helper.getNewUrl(field);
									// check null condition for bug fixing (00028182);
									var label;
									if (datachunk.toString() != ''){
										label = datachunk.toString()+'%';
									}
                                    helper.renderHyperLink(component, label, newUrl);
                                }//END
                                else{
                                    helper.renderPercent(component, datachunk, field.scale);
                                }
                                break;
                            case "ENCRYPTEDSTRING":
                                helper.renderText(component, datachunk);
                                break;
                            case "INTEGER":
                                //Change to add hyperlink to text ~Akash
                                if(field.redirectUrl){
                                    
                                    var newUrl = helper.getNewUrl(field);
                                    var label = datachunk.toString();
                                    helper.renderHyperLink(component, label, newUrl);
                                }
                                //END
                                else{
                                    helper.renderNumber(component, datachunk, 0);
                                }
                                break;
                            case "MULTIPICKLIST":
                                //helper.renderText(component, datachunk);
                                if (datachunk.includes(';')) {
                                    datachunk = datachunk.replace(/;/g, '; ');
                                }
                                
                                helper.CreateCmp(component, "lightning:formattedText", {
                                    value: datachunk,
                                    linkify: false,
                                    title: datachunk.toString(),	// Added title for Text area field.                      
                                    class: css_des	// Added CSS class for showing gradient in case of description is more than 3 lines.                      
                                });
                                break;
                            case "PICKLIST":
                                //Change to add hyperlink to text ~Akash
                                if(field.redirectUrl){
                                    var newUrl = helper.getNewUrl(field);
                                    var label = datachunk;
                                    helper.renderHyperLink(component, label, newUrl);
                                }
                                //END
                                else{
                                    helper.renderText(component, datachunk);
                                }
                                
                                break;
                            case "ADDRESS":
                                var label = helper.getAddress(component, datachunk);
                                var url =
                                    "https://www.google.com/maps/search/?api=1&query=" +
                                    encodeURIComponent(label);
                                helper.renderHyperLink(component, label, url);
                                break;
                            case "CURRENCY":
                                if (formattedValue !== null) {
                                    try {
                                        helper.renderText(component, formattedValue);
                                    } catch (currencyex) {
                                        helper.showError("Unable to render currency");
                                    }
                                }
                                break;
                            case "DATE":
                                try {
                                    //Dates are unusual - they aren't timezone dependent, but the nice rendering libraries are - so have to slightly hack this.
                                    if (datachunk) {
                                        if (datachunk !== "") {
                                            var datevalue = $A.localizationService.parseDateTime(
                                                datachunk
                                            );
                                            
                                            if (datevalue !== "NaN") {
                                                //var dateoffsetcalc = new Date();
                                                //var offset = dateoffsetcalc.getTimezoneOffset();
                                                //datevalue = datevalue + (offset * 60 * 1000);
                                                if (fieldstyle === "Age") {
                                                    helper.renderText(
                                                        component,
                                                        helper.formatDurationDateTime(component, datevalue)
                                                    );
                                                } else {
                                                    var dateFormat = $A.get("$Locale.shortDateFormat");
                                                    var langLocale = $A.get("$Locale.langLocale");
                                                    var timezone = $A.get("$Locale.timezone");
                                                    var datetemp =$A.localizationService.formatDate(datevalue, dateFormat, langLocale);
                                                    
                                                    //Render this date WITHOUT a timezone
                                                    helper.CreateCmp(
                                                        component,
                                                        "lightning:formattedText",
                                                        {
                                                            value: datetemp,
                                                            title: datetemp
                                                        }
                                                    );
                                                }
                                            }
                                        }
                                    }
                                } catch (dateex) {
                                    helper.showError("Error parsing date");
                                }
                                
                                break;
                            case "TIME":
                                try {
                                    if (datachunk) {
                                        if (datachunk !== "") {
                                            helper.renderText(component, datachunk);
                                            /*var datevalue = '2000-01-15T' + datachunk;
                                    var timezone = $A.get("$Locale.timezone");
                                    helper.CreateCmp(component,
                                        "lightning:formattedDateTime",
                                        { "value": datevalue, timeZone: timezone, timeZoneName: "short", hour: "numeric", minute: "numeric", second: "numeric" }
                                    );*/
                                        }
                                    }
                                } catch (dateex) {
                                    helper.showError("Error parsing time");
                                }
                                
                                break;
                            case "DATETIME":
                                try {
                                    var datetimevalue = $A.localizationService.parseDateTime(
                                        datachunk
                                    );
                                    
                                    if (datetimevalue !== "NaN") {
                                        if (fieldstyle === "Age") {
                                            helper.renderText(
                                                component,
                                                helper.formatDurationDateTime(component, datetimevalue)
                                            );
                                        } else {
                                            var datetimetemp='';
                                            if(datetimevalue !=null){
                                                var dtFormat = $A.get("$Locale.shortDatetimeFormat");
                                                var langLocale = $A.get("$Locale.langLocale");
                                                var timezone = $A.get("$Locale.timezone");
                                                $A.localizationService.UTCToWallTime(datetimevalue, timezone, function(utctime) {
                                                    datetimetemp = $A.localizationService.formatDateTimeUTC(utctime, dtFormat, langLocale);
                                                });
                                            }
                                            helper.CreateCmp(component, "lightning:formattedText", {
                                                value: datetimetemp,
                                                title: datetimetemp
                                            });
                                        }
                                    }
                                } catch (dateex) {
                                    helper.showError("Error parsing datetime");
                                }
                                break;
                            case "DOUBLE":
                                //Change to add hyperlink to text ~Akash                            
                                if(field.redirectUrl){
                                    
                                    var newUrl = helper.getNewUrl(field);
                                    var label = datachunk.toString();
                                    helper.renderHyperLink(component, label, newUrl);
                                }
                                //END
                                else{
                                    try {
                                        helper.renderNumber(component, datachunk, field.scale);
                                    } catch (numex) {
                                        helper.showError("Unable to render double");
                                    }
                                }
                                break;
                            case "TEXTAREA":
                                var fieldValue = datachunk.toString();
                                if(field && field.Path && field.Path.toLowerCase().includes('description') &&
                                   fieldValue.includes('--------------------------------------------------------------------------------')){
                                    fieldValue = fieldValue.split('--------------------------------------------------------------------------------\n')[1];
                                }
                                helper.CreateCmp(component, "lightning:formattedText", {
                                    value: fieldValue,
                                    linkify: true,
                                    title: fieldValue,	// Added title for Text area field.                      
                                    class: css_des	// Added CSS class for showing gradient in case of description is more than 3 lines.                      
                                });
                                
                                break;
                            case "BOOLEAN":
                                try {
                                    if (typeof datachunk === "boolean") {
                                        helper.CreateCmp(component, "ui:outputCheckbox", {
                                            value: datachunk
                                        });
                                    }
                                } catch (boolex) {
                                    helper.showError("Error parsing boolean");
                                }
                                break;
                                
                            case "EMAIL":
                                helper.CreateCmp(component, "lightning:formattedEmail", {
                                    value: datachunk.toString(),
                                    title: datachunk.toString()
                                });
                                
                                break;
                            case "PHONE":
                                if (fieldstyle === "CTI") {
                                    helper.CreateCmp(component, "lightning:clickToDial", {
                                        value: datachunk,
                                        title: datachunk,
                                        recordId: datachunkid
                                    });
                                } else {
                                    helper.CreateCmp(component, "lightning:formattedPhone", {
                                        value: datachunk,
                                        title: datachunk,
                                    });
                                }
                                
                                break;
                            case "URL":
                                helper.renderHyperLink(component, datachunk, datachunk);
                                break;
                                
                            default:
                                //treat as text
                                helper.CreateCmp("ui:outputText", { value: datachunk });
                                
                                break;
                        }
                    }
                }
            }
        } catch (ex) {
            helper.showError("Error rendering");
            component.set("v.body", "Error: " + datachunk);
        }
    },
    
    NavigateToObj: function(component, event, helper) {
        var field = component.get("v.renderfield");
        var objID = field.datachunkid;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            recordId: objID
        });
        navEvt.fire();
    },
    NavigateToURL: function(component, event, helper) {
        var field = component.get("v.renderfield");
        
        var url = event.getSource().get("v.value");
        var navEvt = $A.get("e.force:navigateToURL");
        navEvt.setParams({
            url: url
        });
        navEvt.fire();
    },
	/* Fire Event and pass row id as TaskId in parameter  in Phase3 CR by Akash(28-11-2019)*/
    fireRelatedAssociationEvent : function(component){
      
        var relAssociationEvt = component.getEvent("relatedAssociationEvent");
        //relAssociationEvt.setParams({"taskId" : component.get("v.rowId") });
        // Now we are passing related Assocations ids instance of TaskId) for bugs(00028217) by Rahulk
        relAssociationEvt.setParams({"taskId" : component.get("v.sRelatedAssociationIds") });
        relAssociationEvt.fire();
    },

    updateValue: function(component, event, helper) {
        if (component.get("v.isEditableSDG") && component.get("v.renderfield.isEditableField") 
            && !component.get("v.isLoading")) {
            
            component.set("v.isLoading", true);
            helper.createEditCmp(component);
      

        }
    },

    handleFormLoad: function(component, event, helper) {
        let inputField = component.find("inputField");
        let sdgId = component.get("v.sdgId");
        let updateSection = component.find("updateCmp");

        if (inputField.get("v.required")) {
            $A.util.addClass(updateSection, "requiredField");
        }

        if (sdgId != null && sdgId != "") {
            let sdgGrid = document.querySelector(`div[class*="${sdgId}_grid"`);
            if (sdgGrid != null) {
                let sdgGridBoundry = sdgGrid.getBoundingClientRect();
                let updateSectionElement = updateSection.getElement()
                let updateSectionBoundry = updateSectionElement.getBoundingClientRect();

                if (updateSectionBoundry.y > (sdgGridBoundry.y + sdgGridBoundry.height)/2) {
                    $A.util.addClass(updateSection, "showTop");
                } else {
                    $A.util.removeClass(updateSection, "showTop");
                }

                if (updateSectionBoundry.left > sdgGridBoundry.width/2) {
                    $A.util.addClass(updateSection, "showLeft");
                } else {
                    $A.util.removeClass(updateSection, "showLeft");
                }
            }
        }
        
        component.set("v.isLoading", false);
        $A.util.addClass(component.find("updateCmp"), "showForm");
    },

    modifySelectedRows: function(component, event, helper) {
        let attributes = {
			"rowIdsToProcess": component.get("v.selectedRows"),
			"updatedValue": null,
			"multiSelect": event.getSource().get("v.checked")
        };
        helper.processUpdatedData(component, attributes, "multiSelectUpdated", {});
    },

    stopEvent: function(component, event, helper) { // We don't want updateValue to fire when dblclicked on updateCmp Div
        event.stopPropagation();
    },

    applyMultiData: function(component, event, helper) {
        let selectedRows;
        let multiSelect = component.find("multi-select");

        if (multiSelect.get("v.checked")) {
            selectedRows = component.get("v.selectedRows");
        } else {
            selectedRows = [component.get("v.rowId")];
        }

        let fieldValue = component.find("inputField").get("v.value");
        fieldValue = helper.modifyValues(component, fieldValue);

        let attributes = {
			"rowIdsToProcess": selectedRows,
			"updatedValue": fieldValue,
			"multiSelect": null
        };
        helper.processUpdatedData(component, attributes, "valueUpdated", {});

        helper.closeUpdateComponent(component);
    },

    closeUpdateCmp: function(component, event, helper) {
        let attributes = {
			"rowIdsToProcess": component.get("v.selectedRows"),
			"updatedValue": null,
			"multiSelect": null
        };
        helper.processUpdatedData(component, attributes, "valueUpdated", {});
        
        helper.closeUpdateComponent(component);
    },

    updateFieldsData: function(component, event, helper) {
        let updatedData = component.get("v.updatedData");
        let attributes = event.getParams();

        if (component.get("v.sdgId") != null && updatedData != null) {
            if (attributes.operation == "clickedOutside" && attributes.parameters.globalId == component.getGlobalId()) {
                let multiSelect = component.find("multi-select");
    
                if (multiSelect != null) {
                    // Multi-select update component is present, just close the update component
                    let selectedRows;
    
                    if (multiSelect.get("v.checked")) {
                        selectedRows = component.get("v.selectedRows");
                    } else {
                        selectedRows = [component.get("v.rowId")];
                    }
    
                    let attributes = {
                        "rowIdsToProcess": selectedRows,
                        "updatedValue": null,
                        "multiSelect": null
                    };
                    helper.processUpdatedData(component, attributes, "valueUpdated", {});
                } else {
                    // Single cell update component is present, check if the value is changed and if yes, then handle the updated
                    // value, otherwise just close the udpate component
                    let fieldValue = component.find("inputField").get("v.value");
                    fieldValue = helper.modifyValues(component, fieldValue);

                    if (component.get("v.isValueUpdated") || component.get("v.renderfield.datachunk") != fieldValue) {
                        let attributes = {
                            "rowIdsToProcess": [component.get("v.rowId")],
                            "updatedValue": fieldValue,
                            "multiSelect": null
                        };
                        helper.processUpdatedData(component, attributes, "valueUpdated", {});
                    }
                }
    
                helper.closeUpdateComponent(component);
            } else if (attributes.operation == "multiSelectUpdated" && updatedData.sdgId == component.get("v.sdgId")) {
                // Code Added to resolve the Bug: 00028520
                let rowId = component.get("v.rowId");
                let fieldId = component.get("v.renderfield.Id");
                let rowsData = updatedData.rows;
                  // Add Conditon  for bug fixing(00028987)  in DarkMode for Einstein Code V1 By Rahulk
				var updatefieldColor =  (component.get("v.currentTheme") == 'Dark') ? "darkThemeEditCell":"updated";
				component.set("v.highlightClass", "");
    
                if (rowsData != null && rowsData[rowId] != null && rowsData[rowId].fields != null
                    && rowsData[rowId].fields[fieldId] != null) {
                    let fieldObj = rowsData[rowId].fields[fieldId];

                    if (fieldObj.multiSelect) {
                        component.set("v.highlightClass", "selected");
                    } else if (fieldObj.updatedValue != null) {
                        component.set("v.highlightClass", updatefieldColor);
                    }
                }
            } else if (attributes.operation == "valueUpdated" && updatedData.sdgId == component.get("v.sdgId")) {
                let rowId = component.get("v.rowId");
                let fieldId = component.get("v.renderfield.Id");
                let rowsData = updatedData.rows;
                  // Add Conditon for bug fixing(00028987)  in DarkMode for Einstein Code V1 By Rahulk
                var updatefieldColor =  (component.get("v.currentTheme") == 'Dark') ? "darkThemeEditCell":"updated";
				component.set("v.highlightClass", "");
                
                if (rowsData != null && rowsData[rowId] != null) {
                    let rowObject = rowsData[rowId];

                    // Update the RecordTypeId in the updatedData map, if not available.
                    if (component.get("v.rowId") == rowId && rowObject.recordTypeId == null) {
                        rowObject.recordTypeId = component.get("v.recTypeId");
                        component.set("v.updatedData", updatedData);
                    }
                    
                    if (rowObject.fields != null && rowObject.fields[fieldId] != null) {
                        let fieldObj = rowObject.fields[fieldId];
                        if (fieldObj.updatedValue != null) {
                            component.set("v.highlightClass", updatefieldColor);
        
                            if (fieldObj.updatedValue == "" 
                                || fieldObj.updatedValue != component.get("v.updatedValue")) {
                            
                                component.set("v.body", "");
                                component.set("v.isValueUpdated", true);
                                component.set("v.updatedValue", fieldObj.updatedValue);
                                helper.closeUpdateComponent(component);
                                $A.enqueueAction(component.get("c.onInit"));
                            }
                        }
                        
                        if (fieldObj.multiSelect) {
                            component.set("v.highlightClass", "selected");
                        } else if (fieldObj.updatedValue == null) {
                            component.set("v.highlightClass", "");
                        }
                    }
                }
            } else if (attributes.operation == 'partialSave' && component.get("v.isValueUpdated")) {
                let rowId = component.get("v.rowId");
                let rowsData = updatedData.rows;
    
                if (rowsData[rowId] == null) {
                    component.set("v.isValueUpdated", false);
                    component.set("v.updatedValue", "");
                    component.set("v.highlightClass", "");
                    component.set("v.body", "");
                    $A.enqueueAction(component.get("c.onInit"));
                }
            }
        }
    }
});