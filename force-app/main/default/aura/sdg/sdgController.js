/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
({
    doInit: function(component, event, helper) {
        var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi,
                                                 function(m,key,value) {
                                                     if(key =='c__recordId' && (component.get("v.recordId") == "" || component.get("v.recordId") == null)){
                                                         component.set("v.recordId",value);
                                                     }
                                                 });
        
        
        component.set("v.pageURL",window.location.href);  //Added by Jonson,to hold the current URL.
        component.set("v.updatedData", new Object());  //To hold the current Update value in json format.
        var TargetSize = component.get("v.width");
        var DisableResponsive = component.get("v.PreventResponsiveness");
        
        if (DisableResponsive) {
            TargetSize = "LARGE";
        } else {
            if (TargetSize === undefined) {
                var formFactor = $A.get("$Browser.formFactor");
                
                TargetSize = "MEDIUM";
                if (formFactor === "PHONE") {
                    TargetSize = "SMALL";
                }
                if (formFactor === "DESKTOP") {
                    TargetSize = "LARGE";
                }
            }
        }
        
        component.set("v.TargetSize", TargetSize);
        
        if (TargetSize === "LARGE") component.set("v.filtersize", 4);
        if (TargetSize === "MEDIUM") component.set("v.filtersize", 6);
        if (TargetSize === "SMALL") component.set("v.filtersize", 12);
        
        component.set("v.TitleName", component.get("v.Title"));
        helper.getSDG(component);
        helper.getNamespace(component);
        helper.getUpdatedPreference(component);
        // Kumar: this method is used to set sorting image on load of grid.
        /* comment setTimeout functon then add doneRendering
          setTimeout(function() { 
            helper.callOnLoadSort(component);
        }, 2000);  
    */
        var hideSdg = component.get("v.enableToggle");
        if(hideSdg){
            component.set("v.hideSdgInToggle",true);
        }
    },
    handleObjectManagerEvent: function(component, event, helper) {}, 
    paging: function(component, event, helper) {
        component.set("v.isPaging", true);
        helper.getResponseData(component);
    },
    CreateNew: function(component, event, helper) {
        var navEvt = $A.get("e.force:createRecord");
        
        var objname = component.get("v.SDG").sObjectName;
        navEvt.setParams({
            entityApiName: objname,
            recordTypeId: null
        });
        navEvt.fire();
    },
    reload: function(component, event, helper) {
        component.set("v.reloadseed", Date.now());
        //UAT Bug Fixing(00027970): added by Sameeksha Sahu for refreshing data issue for aggregate result
        component.set("v.recordToGroupingDataMap",'');
        // Code added to resolve the Bug: 00028487 on 24 March, 2020
        var pp = component.find("PagerPage");
        pp.set("v.value", "");
        helper.getResponseData(component);
    },
    filterUpdated: function(component, event, helper) {
        helper.resetCheckbox(component); // Added by Sameer
        component.set("v.displayBlur", "block");
        component.set("v.ShowSDGError", false);
        component.set("v.QueryError","");// Added to show error message in case of filter error
        var filters = component.get("v.SDGFilters");
        var filterlistlength = filters.length;
        var newfilters = [];
        var newSDGFieldID = event.getParam("SDGFieldID");
        
        // create a map to deduplicate here...
        for (var i = 0; i < filterlistlength; i++) {
            if (filters[i].SDGFieldID !== newSDGFieldID) {
                newfilters.push(filters[i]);
            }
        }
        
        //Add the new value:
        var newfilter = {
            FilterValue: event.getParam("FilterValue"),
            FilterOperator: event.getParam("FilterOperator"),
            SDGFieldID: event.getParam("SDGFieldID")
        };
        newfilters.push(newfilter);
        component.set("v.SDGFilters", newfilters);
        helper.AddToLog(component, "Filters updated");
        helper.getResponseData(component);
    },
    
    handleSort: function(cmp, event, helper) {
        var val = event.getParam("value");
        var vals = val.split(":");
        cmp.set("v.SortColumn", vals[0]);
        cmp.set("v.SortOrder", vals[1]);
        helper.getResponseData(cmp);
    },
    // Code Added by sameer to fix sorting issue
    sort: function(component, event, helper) { 
        component.set("v.displayBlur", "block");
        // Added by Sameer to fixing Sorting
        if(component.get("v.SortColumn") != event.getParam("SDGFieldID")){ 
            component.set("v.SortOrder", 'A'); 
        }
        else{
            if(component.get("v.SortOrder") == 'A'){
                component.set("v.SortOrder", 'D');
            }
            else if(component.get("v.SortOrder") == 'D'){
                component.set("v.SortOrder", 'A');
            }
        }
        component.set("v.SortColumn", event.getParam("SDGFieldID"));
        helper.getResponseData(component);
    },
    ClearFilters: function(component, event, helper) {
        helper.resetCheckbox(component); // Added by Sameer
        var filters = component.find("cmpFilter");
        
        if (filters) {
            var filterlistlength = filters.length;
            
            // clear the values
            for (var i = 0; i < filterlistlength; i++) {
                filters[i].set("v.FilterValue", "");
            }
            
            helper.AddToLog(component, "Filters cleared");
        }
    },
    checkboxchange: function(component, event, helper) {
        var idlist = component.get("v.CheckedRowIDs");
        // Condition Added by Sameer
        if (event.getSource().get("v.checked") && idlist.indexOf(event.getSource().get("v.value")) == -1) {
            idlist.push(event.getSource().get("v.value"));
        } else {
            var index = idlist.indexOf(event.getSource().get("v.value"));
            idlist.splice(index, 1);
        }
        component.set("v.CheckedRowIDs", idlist);
        helper.getcheckboxSync(component,event);
    },
    ToggleDebug: function(component, event, helper) {
        var cmpTarget = component.find("debuglogpanel");
        
        $A.util.toggleClass(cmpTarget, "debugsize");
    },
    ToggleFilters: function(component, event, helper) {
        //Determine whether to show the filters:
        // helper.resetCheckbox(component); // Added by Sameer
        var FiltersSet = component.get("v.SDGFiltersDefinition");
        if (FiltersSet.length === 0) {
            var SDGObject = component.get("v.SDG");
            component.set("v.SDGFiltersDefinition", SDGObject.SDGFields);
            helper.maintainFilter(component);
        }
        
        var newvalue = !component.get("v.ShowFilters");
        var cmpTarget = component.find("FilterToggle");
        
        if (newvalue) {
            $A.util.addClass(cmpTarget, "slds-is-selected");
            $A.util.removeClass(cmpTarget, "slds-not-selected");
        } else {
            $A.util.removeClass(cmpTarget, "slds-is-selected");
            $A.util.addClass(cmpTarget, "slds-not-selected");
        }
        component.set("v.ShowFilters", newvalue);
    },
    CheckAll: function(component, event, helper) {
        //var idlist = component.get("v.CheckedRowIDs");
        if(component.find("checkrow") != null){
            var idlist = [];
            var checkboxes = component.find("checkrow");
            var checkboxeslength = checkboxes.length;
            var targetstate = event.getSource().get("v.checked"); 
            
            //Moved existing code inside else condition & added code in if condition by Lakshya on 20210525; 00029629 
            if(!Array.isArray(checkboxes)){
                checkboxes.set("v.checked", targetstate);
                if (targetstate && idlist.indexOf(checkboxes.get("v.value")) == -1) {
                    idlist.push(checkboxes.get("v.value"));
                }
            }
            else{
                for (var i = 0; i < checkboxeslength; i++) {
                    checkboxes[i].set("v.checked", targetstate);
                    if (targetstate && idlist.indexOf(checkboxes[i].get("v.value")) == -1) {
                        idlist.push(checkboxes[i].get("v.value"));
                    }
                }    
            }
            
            if (!targetstate) {
                idlist = [];
            }
            
            component.set("v.CheckedRowIDs", idlist);
            
        }
    },
    ShowAll: function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        var c = component;
        
        evt.setParams({
            componentDef: "c:sdgList",
            componentAttributes: {
                SDGConfiguration: c.get("v.SDGConfiguration"),
                HideOnError: false,
                recordId: c.get("v.recordId"),
                Title: c.get("v.Title"),
                ShowDebug: c.get("v.ShowDebug"),
                UseCache: c.get("v.UseCache"),
                FieldSetName: c.get("v.FieldSetName"),
                SVGName: c.get("v.SVGName")
            }
        });
        evt.fire();
    },
    RaiseListEventMenu: function(component, event, helper) {
        var menuItem = event.detail.menuItem;
        var actionid = menuItem.get("v.value");
        helper.FireEvent(component, actionid);
    },
    RaiseListEventButton: function(component, event, helper) {
        
        var actionid = event.getSource().get("v.value");
        helper.FireEvent(component, actionid);
    },
    RaiseListMultiEventButton: function(component, event, helper) {
        var actionid = event.getSource().get("v.value");
        helper.FireEvent(component, actionid);
    },
    RaiseRowEventMenu: function(component, event, helper) {
        var menuItem = event.detail.menuItem;
        var valuesString = menuItem.get("v.value");
        helper.RaiseRowEvent(component, helper, valuesString);
    },
    RaiseRowEventButton: function(component, event, helper) {
        var valuesString = event.getSource().get("v.value");
        helper.RaiseRowEvent(component, helper, valuesString);
    },
    //Added by Jonson
    handleSDGfilterEvent : function(component, event, helper) {        
        debugger; 
        var value = event.getParam("value");
        var pgUrl = event.getParam("pageUrl");
        var fieldSequence = event.getParam("fieldSequence");
        
        var currentUrl = component.get("v.pageURL");
        var objectName = event.getParam("objectApiName");
        if(pgUrl == currentUrl){
            if(fieldSequence != 'UserRecords'){
                helper.ToggleFiltersKJ(component, event, helper);
                var sdgFilterCompId = component.find("cmpFilter");
                var returnVal='';
                for(var cont in sdgFilterCompId){
                    var FieldsRecords = component.get("v.SDGFiltersDefinition");
                    for(var fieldsName in FieldsRecords){
                        var columnFilterSeq = FieldsRecords[fieldsName].filterSeq;
                        var columnName = FieldsRecords[fieldsName].ColumnName;
                        if(columnFilterSeq == fieldSequence || columnName.toLowerCase() == (objectName.toLowerCase())){
                            //callSDGfilter is an aura method, which is written in sdgFilter(It's child) component
                            returnVal = sdgFilterCompId[cont].callSDGfilter(value, fieldSequence, objectName.toLowerCase()); 	               
                        }
                    }
                }
            }
            else {
                component.set("v.myRecordFilter", '');
                component.set("v.myTeamFilter", '');
                
                if (value == 'All Records') {
                    helper.getResponseData(component);
                } else if (value == 'My Records') {
                    if (component.get("v.SDG.myRecords") != null) {
                        component.set("v.myRecordFilter", component.get("v.SDG.myRecords"));
                        helper.getResponseData(component);
                    }
                } else if (value == 'My Teams Records') {
                    if (component.get("v.SDG.myTeamsRecords") != null) {
                        helper.callMethod(
                            component,
                            "c.getMyTeamFilter",
                            {
                                "myTeamFilter" : component.get("v.SDG.myTeamsRecords")
                            },
                            {},
                            function(responseValue) {
                                component.set("v.myTeamFilter", responseValue);
                                helper.getResponseData(component);
                            }
                        );
                    }
                }
            }
        }
        component.set("v.ShowFilters", false);
    },
    //Added to toggle sdg
    toggleExpand: function(component, event, helper){
        var isExpandedjs = component.get("v.isGridExpanded");
        if(isExpandedjs){
            component.set("v.isGridExpanded",false);
        }else{
            component.set("v.isGridExpanded",true);
        }
        helper.updatePreference(component);
    },
    navigateToSdg: function(component) {
        var sdgId = component.get("v.SDG.sdgId");
        window.open("/"+sdgId);
    },
    /* handle Event action and call get getRelatedAssociations's method getRelatedAssociations to show remaining related association 
	  in Phase3 CR by Akash(28-11-2019)
	*/
    openRelatedAssociationPopup : function(component,event) {
        var taskId = event.getParam("taskId");
        component.find('relatedAssociation').getRelatedAssociations(taskId);
    },
    
    /* Event Handle to display Buttons(Show/Cancel) fire by SdgdatagirdCell in Phase4(InlineEdit)-(17-02-2020)*/
    updateFieldsData: function(component, event, helper) {
        let updatedData = component.get("v.updatedData");
        
        if (component.get("v.SDG.sdgId") != null && updatedData.sdgId == component.get("v.SDG.sdgId")) {
            let mainFieldsList = Object.values(updatedData.rows);
            
            if (mainFieldsList.find(element => element.fields[Object.keys(element.fields)[0]].updatedValue != null)) {
                component.set("v.showEditButtons", true);
            } else {
                component.set("v.showEditButtons", false);
            }
        }
         //component.set("v.applyInlineCss",'sdgdatatablewrapper')
         //Remove auto flow in case No scrool
         component.set("v.applyInlineCss",'')
        event.stopPropagation();
    },
    /* Click on Cancel button refresh the gird  in Phase4(InlineEdit)-(17-02-2020)*/ 
    cancelChanges: function(component, event, helper) {
        helper.getResponseData(component);
		component.set("v.applyInlineCss",'')
         //component.set("v.applyInlineCss",'sdgdatatablewrapper')
    },
    /* Click on Save button get data from updateData object in Phase4(InlineEdit)-(17-02-2020)*/ 
    saveChanges: function(component, event, helper) {
        component.set("v.displayBlur", "block");
        component.set("v.saveChanges", true);
        helper.callMethod(
            component,
            "c.saveUpdatedRecords",
            {
                "sObjectName": component.get("v.SDG.sObjectName"),
                "updatedRecordsMap": component.get("v.updatedData.rows")
            },
            {},
            function(responseValue) {
                if (responseValue === "SUCCESS") {
                    helper.getResponseData(component);
                    helper.showtoast("Success", "Your changes are saved.", component, "success");
                } else {
                    console.log(JSON.parse(JSON.stringify(responseValue)));
                    helper.handleErrors(component, responseValue);
                    helper.DoneWaiting(component);
                    let failedRecordsCount = Object.keys(responseValue).length;
                    let errorMessage = failedRecordsCount + " " + (failedRecordsCount > 1 ? "records" : "record") 
                    + " has error. Kindly resolve them and try again.";
                    
                    helper.showtoast("Error", errorMessage, component, "error");
                }
            }
        );
 		component.set("v.applyInlineCss",'')
        component.set("v.applyInlineCss",'sdgdatatablewrapper')
    },
    /* Click on out of sdg gird fire event for close edit Popup in Phase4(InlineEdit)-(17-02-2020)*/ 
    clickedOutside: function(component, event, helper) {
        let updateCmp = document.querySelector("section.updateFormSection.showForm");
        if (updateCmp != null) {
            helper.fireFieldsUpdatedEvent(
                component,
                "clickedOutside", 
                {"globalId": updateCmp.getAttribute('data-cmpId')}
            );
        }
        //component.set("v.applyInlineCss",'sdgdatatablewrapper'); //Added for bug(00029057) fixing in Einstein Code V1 by Rahulk
        
    },
    /* Adding Done Rendering to remove timeout function for bugfixing (00028496) in v1.3 Phase4 by Rahulk */
    doneRendering: function(component, event, helper) {
        if(!component.get("v.isDoneRendering")){
            component.set("v.isDoneRendering", true);
            helper.callOnLoadSort(component);
        }
    },
    /**
     * This method is called when the page size is changed and it stores 
     * the checked rows in a temporary attribute which will be utilized later
     * in the handleResults helper method.
     * 
     * Added to handle Bug: 00028444
     */
    pageSizeChanged: function(component, event, helper) {
        component.set("v.tempCheckedRowIds", component.get("v.CheckedRowIDs"));
        $A.enqueueAction(component.get("c.reload"));
    },
    RaiseEventMenuItem: function(component, event, helper) {
        var menuItem = event.detail.menuItem;
        var buttonValue = menuItem.get("v.value");
        if(buttonValue == 'openManageFieldPopup'){
            helper.manageFieldPopupHelper(component);
        }else if(buttonValue == 'navigateToSdg'){
            var sdgId = component.get("v.SDG.sdgId");
            window.open("/"+sdgId);
        }else if(buttonValue == 'reload'){
            component.set("v.reloadseed", Date.now());
            component.set("v.recordToGroupingDataMap",'');
            helper.getResponseData(component);
        }else{
            helper.FireEvent(component, buttonValue);
        }
    },
    
    onRender: function(component, event, helper) {
        if (!component.get("v.clickedOutsideDefined")) {
            helper.defineClickedOutside(component, event);
        }
    },
    //Start -For toggle changes
    handleSdgToggle : function(component, event, helper) {
        var hideSdg = component.get("v.enableToggle");
        if(hideSdg){
            var currentSdgName = component.get("v.SDGConfiguration");
            currentSdgName = currentSdgName.replace('CustomObject:','').toLowerCase();
            let inactiveSdgs = event.getParam('inActiveSdgConfiguration');
            console.log('inactive- '+ inactiveSdgs +' currentSdgName - '+currentSdgName+ ' event sdg '+event.getParam('sdgConfiguration'));
            if( currentSdgName ==  event.getParam('sdgConfiguration').toLowerCase()){
                component.set("v.hideSdgInToggle",false);
            }else if(inactiveSdgs.includes(currentSdgName)){
                component.set("v.hideSdgInToggle",true);
            }
        }
    },
    //END
    ///* For Open Manage Fields Popup */
     openManageFieldPopup: function (component, event, helper) {
        helper.manageFieldPopupHelper(component);
    },
    reloadColumns: function (component, event, helper) {
        var cacheSetting = component.get("v.UseCache");
        if (cacheSetting) {
            component.set("v.UseCache", false);
        }
        helper.getSDG(component);
        component.set("v.UseCache", cacheSetting);
    }
});