/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
({
    getNamespace: function(component) {
        var helper = this;
        try {
            this.callMethod(
                component,
                "c.GetNamespace",
                {},
                { isStorable: true, isAbortable: true },
                
                function(results) {
                    if (results !== null) {
                        component.set("v.namespace", results);
                    }
                }
            );
            
        } catch (ex) {
            helper.AddToLog(component, "Error retrieving namespace: " + ex.message);
        }
    },
    // Added by Sameer
    getcheckboxSync:function(component,event){
            //checkall
        var checkboxes = component.find("checkrow");
        var countFlag = 0;
        for (var i = 0; i < checkboxes.length; i++) {
            if(!checkboxes[i].get("v.checked")){
                component.find("checkall").set("v.checked", false);
                break;
            }
            else{
                countFlag++;
            }
        }
        if(countFlag == checkboxes.length){
            component.find("checkall").set("v.checked", true);
        }
    },

    // Added by Sameer
    resetCheckbox: function(component){
        if(component.find("checkall") != null){
            component.find("checkall").set("v.checked", false);
            component.set("v.CheckedRowIDs", []); // Added by Sameer 
        }
    },
    
    getCoreParams: function(component) {
        var config = component.get("v.SDGConfiguration");
        if (config === undefined)
            config = "CustomObject:" + component.get("v.SDGTag");
        
        var params = {
            ParentRecordID: component.get("v.recordId"),
            SDGTag: config,
            RelationshipName: component.get("v.RelationshipName"),
            FieldSetName: component.get("v.FieldSetName"),
            myRecords: component.get("v.myrecordOwnerId")	//added by Jonson: 26-06-2019
        };
        return params;
    },
    
    // Start Anurag For default showing icon
    callOnLoadSort: function(component) {
        component.set("v.SortColumn", component.get("v.SortColumnOnLoad"));
        component.set("v.SortOrder", component.get("v.SortOrderOnLoad")); 
        //this.getResponseData(component);			 	    
    },
    // End Anurag For default showing icon
    
    getSDG: function(component) {
        
        this.Waiting(component);
        
        var params = this.getCoreParams(component);
        
        var sPageSize = "10";
        try {
            sPageSize = component.get("v.DefaultPageSize");
        } catch (PageSize) {
            //ignore
        }
        params.DefaultPageSize = sPageSize;
        
        component.set("v.isPaging", false);
        var thishelper = this;
        this.callMethod(
            component,
            "c.GetSDGInitialLoad",
            params,
            {
                isStorable: component.get("v.UseCache"),
                isAbortable: true,
                isBackground: component.get("v.UseBackground")
            },
            function(results) {
                if (results !== null) {
                    if (results.isError) {
                        thishelper.AddToLog(component, "Error: " + results.ErrorMessage);
                        if (component.get("v.HideOnError")) {
                             component.set("v.ShowComponent", false);
                        }
                        
                        component.set("v.ShowSDGError", true);
                        component.set("v.ErrorMessage", results.ErrorMessage);
                        thishelper.showtoast("Error", results.ErrorMessage, component);
                    } else {
                        var order;
                        // Start Anurag For default showing icon
                        // Getting Sort Order and Sortable field Id from the results.
                        if(results.Results.onloadSortType != null && results.Results.onloadSortType != ''){
                            if(results.Results.onloadSortType.toUpperCase() == 'ASC'.toUpperCase()){
                                order = 'A';
                            }
                            if(results.Results.onloadSortType.toUpperCase() == 'DESC'.toUpperCase()){
                                order = 'D';
                            }
                            component.set("v.SortOrderOnLoad", order); 
                        }
                        if(results.Results.FilterFieldId != null && results.Results.FilterFieldId != ''){
                            component.set("v.SortColumnOnLoad", results.Results.FilterFieldId);
                        }
                        // End Anurag For default showing icon
                        component.set("v.isDoneRendering", false); // added for Done Rendering event
                        component.set("v.SDG", results.SDGObject);
                        
                        var highlightStr = results.SDGObject.highlightString;
                        if(highlightStr && highlightStr.split(';').length > 0){
                            if(highlightStr.split(';')[0]){
                                component.set("v.BorderColor",highlightStr.split(';')[0]);
                            }else{
                                component.set("v.BorderColor","#6e98c2");
                            }
                            if(highlightStr.split(';').length > 1 && highlightStr.split(';')[1]){
                                component.set("v.HeaderColor",highlightStr.split(';')[1]);
                            }else{
                                component.set("v.HeaderColor","#d2dae5");
                            }
                            if(highlightStr.split(';').length > 2 && highlightStr.split(';')[2] && highlightStr.split(';')[2].toLowerCase() == 'false'){
                                component.set("v.AlternateRow",highlightStr.split(';')[2]);
                            }else{
                                component.set("v.AlternateRow","");
                            }
                            if(highlightStr.split(';').length > 3 && highlightStr.split(';')[3]){
                                component.set("v.TableBorder",highlightStr.split(';')[3]);
                            }else{
                                component.set("v.TableBorder","#bec7d0");
                            }
                        }
                        
                        thishelper.maintainFilter(component);
                        //Check Filters
                        var fields = results.SDGObject.SDGFields;
                        var fieldlistlength = fields.length;
                        var hasFilters = false;
                        var hasSummary = false;
                        
                        for (var i = 0; i < fieldlistlength; i++) {
                            var field = fields[i];
                            if (field.canFilter) hasFilters = true;
                            if (
                                field.FieldStyle &&
                                field.FieldStyle.startsWith("Summarize")
                            ) {
                                hasSummary = true;
                            }
                        }
                        component.set("v.hasSummary", hasSummary);
                        component.set("v.hasFilters", hasFilters);
                        //Set up Actions
                        if (results.SDGObject.SDGActions !== null) {
                            var listsize = results.SDGObject.SDGActions.length;
                            
                            var hasListMenu = false;
                            var hasRowMenu = false;
                            var hasRowActions = false;
                            var hasMulti = false;
                            
                            component.set("v.SDGActions", results.SDGObject.SDGActions);
                            for (var j = 0; j < listsize; j++) {
                                var actiontype = results.SDGObject.SDGActions[j].Type;
                                
                                if (actiontype === "List") hasListMenu = true;
                                if (actiontype === "List Multi") hasMulti = true;
                                if (actiontype === "Row Button") hasRowActions = true;
                                if (actiontype === "Row") {
                                    hasRowMenu = true;
                                    hasRowActions = true;
                                }
                            }
                            component.set("v.hasRowMenu", hasRowMenu);
                            component.set("v.hasListMenu", hasListMenu);
                            component.set("v.hasRowActions", hasRowActions);
                            component.set("v.MultiSelectMode", hasMulti);
                        }
                        
                        component.set("v.isLoaded", true);
                        
                        //START - Changes to group child records and display rolled up data in SDG ~Akash for grouping
                        //thishelper.handleResults(component, results.Results); commented will be called later
                        thishelper.prepareDataMapGrouping(component, results, 0);
                        //END
						
                         // If the SDG is editable, don't use the cacheable data in Phase4(InlineEdit)
                        if (component.get("v.SDG.isEditableSDG")) {
                            component.set("v.UseCache", false);
                        }

                        // If the SDG is editable, set the functionality to close the update component
                        // when clicked outside it. in Phase4(InlineEdit)
                        // if (component.get("v.SDG.isEditableSDG")) {
                        //     document.addEventListener("mousedown", function(event) {
                        //         if (event.target != null && event.target.closest("section.updateFormSection.showForm") == null) {
                        //             let updateCmp = document.querySelector("section.updateFormSection.showForm");
                        //             if (updateCmp != null) {
                        //                 document.getElementById("closeUpdateCmpButton").click();
                        //             }
                        //         }
                        //     });
                        // }
                    }
                } else {
                    component.set("v.ShowSDGError", true);
                    showtoast(
                        "Error",
                        "Cannot load configuration data:  Please reconfigure the component in the designer.",
                        component
                    );
                    component.set("v.displayBlur", "none");
                }
            }
        );
    },
    Waiting: function(component) {
        this.AddToLog(component, "Mode: Waiting");
        var table = component.find("sdgdatatablewrapper");
        $A.util.addClass(table, "working");
        //var blurImz = component.find("blurred"); //added by Sameer of loading image
        //$A.util.addClass(blurImz, "blurredImz");
    },
    showtoast: function(title, message, component, type) {
        if (component.get("v.ShowComponent")) {
            var navtoast = $A.get("e.force:showToast");
            navtoast.setParams({
                title: title,
                message: message,
				type: type
            });
            
            navtoast.fire();
        }
    },
    DoneWaiting: function(component) {
        var table = component.find("sdgdatatablewrapper");
        $A.util.removeClass(table, "working");
        component.set("v.displayBlur", "none");
      //  var blurImz = component.find("blurred"); //added by Sameer of loading image
      //  $A.util.removeClass(blurImz, "blurredImz");
        this.AddToLog(component, "Mode: DoneWaiting");
    },
    GetCaseInsensitiveAttr: function(obj, propname) {
        var propvalue;
        propname = (propname + "").toLowerCase();
        for (var p in obj) {
            if (obj.hasOwnProperty(p) && propname === (p + "").toLowerCase()) {
                propvalue = obj[p];
                break;
            }
        }
        return propvalue;
    },
    
    handleResults: function(component, resultsobj) {
        if (resultsobj.isError) {
            component.set("v.ShowSDGError", true);
            component.set("v.ErrorMessage", resultsobj.ErrorMessage);
            //START - Changes to show error message in case of filter error
            if(resultsobj.ErrorMessage && resultsobj.ErrorMessage.includes("Unable to query:")){
                component.set("v.QueryError",'Additional filters are not allowed in this grid.'); // Changed Error Message 17-12-2019
            }
            //END
            showtoast("Error", resultsobj.ErrorMessage, component);
            
            this.AddToLog(component, resultsobj.ErrorMessage);
            this.DoneWaiting(component);
            this.showtoast("", resultsobj.ErrorMessage, component);
        } else {
            var toggleButton = component.find("FilterToggleButton");
            if (resultsobj.isFiltered) {
                component.set("v.ToggleFilterStyle", "slds-is-selected");
            } else {
                component.set("v.ToggleFilterStyle", "");
            }
            
            //Now process the data into a list of data:
            
            var fields = component.get("v.SDG.SDGFields");
            var fieldlistlength = fields.length;
            
            var rows = [];
            // var dataurl;
            
            var payload = resultsobj.data;
            
            for (var rowcounter = 0; rowcounter < payload.length; rowcounter++) {
                var datarow = payload[rowcounter];
                var row = [];
                
                //dataurl = '';
                for (var i = 0; i < fieldlistlength; i++) {
                    var field = fields[i];
                    var fieldparts = field.ColumnName.split(".");
                    var FieldName = fieldparts[fieldparts.length - 1];
                    
                    var datachunk = datarow;
                    var datachunk2 = datarow;
                    var datachunkid = null;
                    var FormattedValue = null;
                    for (var z = 0; z < fieldparts.length; z++) {
                        if (datachunk) {
                            if (z === fieldparts.length - 1) {
                                if (datachunk["Id"]) datachunkid = datachunk["Id"];
                                try {
                                    if (field.FieldType === "CURRENCY") {
                                        FormattedValue = this.GetCaseInsensitiveAttr(
                                            datachunk,
                                            fieldparts[z] + "Formatted"
                                        );
                                    }
                                } catch (getFormattedEx) {
                                    showtoast(
                                        "Error",
                                        "Unable to get formatted Currency",
                                        component
                                    );
                                }
                            }                                                        
                            //START - logic to get all the data related to report url from datachunk and add the url variable array to row attribute ~Akash
                            var reportFieldValues = [];
                            field.redirectUrl = this.replaceRecordId(component.get('v.recordId'),field.redirectUrl);
                            if(field.redirectUrl && field.redirectUrl.split('<<').length > 1){
                                var reportFields = field.redirectUrl.split('<<');
                                for(var x=1;x<reportFields.length;x++){
                                    reportFields[x] = reportFields[x].split('>>')[0];
                                    if(reportFields[x] && reportFields[x].indexOf('.') !== -1 ){
                                        var tempValues = datachunk2;
                                        for(var j=0;j<reportFields[x].split('.').length;j++){
                                            if(reportFields[x].split('.')[j] && tempValues[reportFields[x].split('.')[j]]){
                                                tempValues = tempValues[reportFields[x].split('.')[j]];
                                            }
                                        }
                                        if(tempValues != datachunk2){
                                            reportFieldValues.push(tempValues);
                                        }else{
                                            reportFieldValues.push('');
                                        }
                                    }else if(reportFields[x] && datachunk2[reportFields[x]]){
                                        reportFieldValues.push(datachunk2[reportFields[x]]);
                                    }
                                }
                            }
                            
                            //END
                            
                            datachunk = this.GetCaseInsensitiveAttr(datachunk, fieldparts[z]);
                            //This handles reference items on the record:
                            if (field.FieldType === "REFERENCE") {
                                datachunkid = datachunk;
                            }
                        } else {
                            datachunk = null;
                            datachunkid = null;
                        }
                    }
                    var photoUrl;
                    var datarowurl = datarow;
                    if (field.imageField) {
                        fieldparts = field.imageField.split(".");
                        FieldName = fieldparts[fieldparts.length - 1];
                        for (var z = 0; z < fieldparts.length; z++) {
                            if (datarowurl) {
                                datarowurl = this.GetCaseInsensitiveAttr(datarowurl, fieldparts[z]);
                            }
                            if (z == fieldparts.length - 1) {
                                photoUrl = datarowurl;
                            }
                        }
                    }
                    // Start for Grouping by Akash
                    var groupingDataMap = component.get("v.recordToGroupingDataMap");
                    var rolledupValue;
                    //To group by any Field not just the id
                    var groupByValue;
                    if(groupingDataMap && groupingDataMap[field.ID+'groupBy'] && datachunk2[groupingDataMap[field.ID+'groupBy']]){
                        groupByValue = datachunk2[groupingDataMap[field.ID+'groupBy']];
                    }else{
                        groupByValue = 'noData';
                    }
                    
                    if(groupingDataMap && groupingDataMap[field.ID+'groupBy'] && groupByValue && (groupingDataMap[field.ID+groupByValue] || groupingDataMap[field.ID+groupByValue] == 0 )){
                        if(field.groupingQuery && !field.groupingQuery.toUpperCase().includes(" GROUP ")){
                            field.isHTMLFormatted = true;
                        }
                        rolledupValue = groupingDataMap[field.ID+groupByValue]+'';
                    }else{
                        rolledupValue = datachunk;
                    }
                    // End for Grouping by Akash
                    
                    row.push({
						Id: field.ID, // field Id in Phase4(InlineEdit)
                        Path: field.ColumnName,
                        FieldType: field.FieldType,
                        FieldLabel: field.Label + ": ",
                        FieldName: FieldName,
                        FieldStyle: field.FieldStyle,
                        FormattedValue: FormattedValue,
                    //    datachunk: datachunk,
                        datachunk: rolledupValue,	// Added by Akash for grouping
                        datachunkid: datachunkid,
                        isHTMLFormatted: field.isHTMLFormatted,
                        scale: field.scale,
                        redirectUrl: field.redirectUrl,
                        reportVariables: reportFieldValues,
                        isHidden: field.isHidden,
                        FieldColor: field.FieldColor,
                        filterSeq: field.filterSeq,
                        groupingQuery: field.groupingQuery,
						relatedAssociationData: resultsobj.mapRecordIsToRecDetail, // Variable to store Name Icon and Id for related Assocation  in Phase3 CR by Akash(28-11-2019) 
					    isEditableField: field.isEditableField, // to store field is editable or not editable in Phase4(InlineEdit)
                        imageField: photoUrl,
                        hasImage: field.imageField
                    });
                    photoUrl = '';
                }
                
                //add to array
                rows.push({
                    rowID: datarow["Id"],
                    recordTypeId: datarow["RecordTypeId"],
                    data: row
                });
            }
            var generateSummary = component.get("v.hasSummary");
            
            var summaryrow = [];
            
            if (generateSummary) {
                for (var j = 0; j < fieldlistlength; j++) {
                    var summaryvalue = 0;
                    field = fields[j];
                    var coltotal = 0;
                    var colmin = null;
                    var colmax = null;
                    var prefix = "";
                    if (field.FieldStyle && field.FieldStyle.startsWith("Summarize")) {
                        //Add the fields up:
                        
                        for (
                            var rowsummarizer = 0;
                            rowsummarizer < payload.length;
                            rowsummarizer++
                        ) {
                            var val = rows[rowsummarizer].data[i].datachunk;
                            
                            if (typeof val === "number" || typeof val === "currency") {
                                coltotal += val;
                                colmin = Math.min(colmin === null ? val : colmin, val);
                                colmax = Math.max(colmax === null ? val : colmax, val);
                            }
                        }
                        
                        if (field.FieldStyle === "Summarize:Total") {
                            summaryvalue = coltotal.toFixed(2);
                            prefix = "Total: ";
                        }
                        
                        if (field.FieldStyle === "Summarize:Average") {
                            prefix = "Avg: ";
                            if (payload.length > 0)
                                summaryvalue = (coltotal / payload.length).toFixed(2);
                        }
                        if (field.FieldStyle === "Summarize:Max") {
                            prefix = "Max: ";
                            summaryvalue = colmax;
                        }
                        if (field.FieldStyle === "Summarize:Min") {
                            prefix = "Min: ";
                            summaryvalue = colmin;
                        }
                    } else {
                        summaryvalue = "";
                        prefix = "";
                    }
                    summaryrow.push({
                        FieldType: "SUMMARY",
                        FieldLabel: "",
                        datachunk: summaryvalue,
                        Path: "",
                        FieldName: "",
                        FieldStyle: "",
                        datachunkid: "",
                        FormattedValue: prefix + summaryvalue,
                        isHTMLFormatted: false
                    });
                }
            }
            component.set("v.summarydata", summaryrow);
            component.set("v.FullQueryCount", resultsobj.FullQueryCount);
            
            this.AddToLog(
                component,
                "Query returns: " + resultsobj.FullQueryCount + " rows"
            );
            //current page:
            if (component.get("v.isPaging") === false) {
                var opts = [];
                for (j = 0; j < resultsobj.pagecount; j++) {
                    opts.push({ label: j + 1, value: j + 1 });
                }

                var pp = component.find("PagerPage");
                if (pp) {
                    // Code added to resolve the Bug: 00028487 on 24 March, 2020
                    if (pp.get("v.value") == null || pp.get("v.value") == "") {
                        //Bind to the component
                        component.set("v.Pages", opts);
                        pp.set("v.value", "1");
                    }
                }
            }
            component.set("v.isPaging", false);
            component.set("v.processeddata", rows);

            // Handle already checked rows if pagesize is changed
            // Added to handle Bug: 00028444
            let tempCheckedRowIds = component.get("v.tempCheckedRowIds");
            if (tempCheckedRowIds.length > 0) {
                let newCheckedRowIds = [];
                rows.forEach(row => {
                    if (tempCheckedRowIds.includes(row.rowID)) {
                        newCheckedRowIds.push(row.rowID);
                    }
                });

                component.set("v.CheckedRowIDs", newCheckedRowIds);
                component.set("v.tempCheckedRowIds", []);
                this.syncCheckboxOnLoad(component);
            }
            
            var newTitle = component.get("v.Title");
            if (newTitle != '' && newTitle != undefined) {

                //newTitle =
                // newTitle + " " + " (" + component.get("v.FullQueryCount") + ")"; // Hide Count for bug fixing (00028993) in Einstein Code V1
                component.set("v.TitleName", newTitle);
            }
            this.DoneWaiting(component);	  	  
        }
    },
    
    getResponseData: function(component) { 
        var thishelper = this;
        thishelper.resetCheckbox(component); // Added by Sameer
		if (component.get("v.SDG.isEditableSDG")) { // Added by Hemendra
            component.set("v.updatedData", new Object());
            component.set("v.showEditButtons", false);
        }
        try {
           // this.Waiting(component);
           component.set("v.displayBlur", "block");
            var params = this.getCoreParams(component);
            
            params.PageID = parseInt(component.find("PagerPage").get("v.value"), 10);
            params.Filters = component.get("v.SDGFilters");
            params.PageSize = parseInt(
                component.find("PagerSize").get("v.value"),
                10
            );
            params.SortOrder = component.get("v.SortOrder");
            params.SortColumn = component.get("v.SortColumn");
            params.reloadseed = component.get("v.reloadseed");
            params.myRecords = component.get("v.myRecordFilter");	////added by Jonson: 26-06-2019
            params.myTeamFilter = component.get("v.myTeamFilter"); // #7 - Added by Hemendra
            
            if (component.get("v.SDGFilters").length > 0) {
                component.set("v.FilterButtonClass", "slds-is-selected");
            } else {
                component.set("v.FilterButtonClass", "");
            }
            
            var req = { jsonrequest: JSON.stringify(params) };
            
            this.callMethod(
                component,
                "c.getSDGResult",
                req,
                {
                    isStorable: component.get("v.UseCache"),
                    isAbortable: true,
                    isBackground: component.get("v.UseBackground")
                },
                function(results) {
                    //START - Changes to group child records and display rolled up data in SDG ~Akash for grouping
                    //thishelper.handleResults(component, results);
                    var resultsComplete = [];
                    resultsComplete['Results'] = results;
                    resultsComplete['SDGObject'] = component.get('v.SDG');
                  //  console.log(JSON.stringify(resultsComplete));
                    thishelper.prepareDataMapGrouping(component, resultsComplete, 0);
                    //END
                }
            );
        } catch (getResponseDataErr) {
            thishelper.AddToLog(component, "Error: " + getResponseDataErr.message);
            component.set("v.displayBlur", "none");
        }
    },
    
    FireEvent: function(component, actionid, datarow) {
        
        var evt;
        var actions = component.get("v.SDG.SDGActions");
        var opts = [];
        for (var i = 0; i < actions.length; i++) {
            if (actions[i].Id === actionid) {
                evt = actions[i];
            }
        }
        
        if (evt != null) {
            //build payload:
            var payload = evt.Payload;
            payload = payload.replace(
                /#parentrecordId#/gi,
                component.get("v.recordId")
            );
            
            var idlist = component.get("v.CheckedRowIDs");
            payload = payload.replace(/#Ids#/gi, idlist.join());
            
            if (datarow) {
                payload = payload.replace(/#Id#/gi, datarow.rowID);
            }
            
            if (datarow) {
                for (var fieldkey in datarow.data) {
                    var field = datarow.data[fieldkey];
                    payload = payload.replace("#" + field.Path + "#", field.datachunk);
                    try {
                        //this only works in Chrome/FF/Edge+ - ie no IE
                        if (field.Path.lastIndexOf("Name") === field.Path.length - 4) {
                            //if (field.Path.endsWith('Name'))
                            var newpath =
                                field.Path.substring(0, field.Path.length - 4) + "Id";
                            
                            if (field.datachunkid)
                                payload = payload.replace(
                                    "#" + newpath + "#",
                                    field.datachunkid
                                );
                        }
                    } catch (endwithex) {
                        //ignore - this is a javascript problem - probably IE
                    }
                }
            }
            
            var payloadobj = JSON.parse(payload);
            var internalevent = component.get("v.internalEvent");
            if (evt.Event !== internalevent) {
                var navEvt = $A.get(evt.Event);
                
                if (navEvt === null) {
                    this.showtoast(
                        "Error",
                        "Invalid event name - cannot identify event",
                        component
                    );
					// Check condition for createcustomcomponent then call component with payloadobj in Phase3 CR by Akash(28-11-2019).
                }else if(evt.Event.toLowerCase().includes('e.createcustomcomponent')){
                    
                    var componentName;
                    if(payloadobj.ComponentName){
                        componentName = payloadobj.ComponentName;
                        if(componentName.toLowerCase() == 'pem_dev:MultipleAssociationPopup'.toLowerCase() ){
                           /* bug(00028181) fixed code  
                             if(!payloadobj["recordTypeId"]){
                                payloadobj["recordTypeId"] = '012000000000000AAA';
                            }*/
                            payloadobj["recordTypeId"] = '012000000000000AAA';
                            if(!payloadobj["label"]){
                                payloadobj["label"] = 'Log A Call';
                            }
                        }
                    }
                    $A.createComponent(
                        componentName,
                        payloadobj,
                        function(msgBox){                
                            if (component.isValid()) {
                                var targetCmp = component.find('DynamicComponentModel');
                                var body = targetCmp.get("v.body");
                                body.push(msgBox);
                                targetCmp.set("v.body", body); 
                            }
                        }
                    );
                    
                } 
                else {
                    //Logic to call new record popup via application event in create new record event ~Akash
                    var rcdtypeId = payloadobj.recordTypeId;
                    if(evt.Event && evt.Event === 'e.force:createRecord' && !rcdtypeId){
                        //UAT BugFixing (00027960) Added record type check by Sameeksha Sahu
                        component.find('newRecordComp').openNewRecordPopup(payloadobj);
                    }else{
                        navEvt.setParams(payloadobj);
                        navEvt.fire();
                    }
                }
            } else {
                var objhelper = component.find("ObjectHelper");
                objhelper.doMethod(payloadobj);
            }
        }
    },
    
    RaiseRowEvent: function(component, helper, valuesString) {
        var values = valuesString.split(",");
        var actionid = values[0];
        var rowID = values[1];
        //get the data row:
        var allrows = component.get("v.processeddata");
        var selectedrow;
        for (var key in allrows) {
            var datarow = allrows[key];
            if (datarow.rowID === rowID) {
                selectedrow = datarow;
            }
        }
        
        this.FireEvent(component, actionid, selectedrow);
    },
    ToggleFiltersKJ: function(component, event, helper) {
        
        //Determine whether to show the filters:
        var FiltersSet = component.get("v.SDGFiltersDefinition");
        if (FiltersSet.length === 0) {
            var SDGObject = component.get("v.SDG");
            if(SDGObject != null){
            	component.set("v.SDGFiltersDefinition", SDGObject.SDGFields);   
            }            
        }
        
        var newvalue = !component.get("v.ShowFilters");
        var cmpTarget = component.find("FilterToggle");
        component.set("v.ShowFilters", newvalue);
    },
    
    //Method to prepare grouped data and set data values ~Akash for Grouping
    prepareDataMapGrouping: function(component, results, i){
        
        try {
            var prepareMapAction = component.get("c.prepareDataForRow");
            var groupingQueryStr = results.SDGObject.SDGFields[i].groupingQuery;
            if(results.SDGObject.SDGFields[i].parentFieldName){
                groupingQueryStr = groupingQueryStr.replace(/where/i, "where "+ results.SDGObject.SDGFields[i].parentFieldName +" = '"+component.get('v.recordId')+"' and")
            }
            //START - To call apex class only if grouping query field is present (To enhance performance) ~Akash
            if(!results.SDGObject.SDGFields[i].groupingQuery){
                i++;
                if(i<results.SDGObject.SDGFields.length){
                    this.prepareDataMapGrouping(component,results,i);
                }else{
                    this.handleResults(component, results.Results);
                }
                return;
            }
            //END 
            prepareMapAction.setParams({ 
                query :  results.Results.query,
                groupingQuery :  groupingQueryStr,
                sdgFieldId : results.SDGObject.SDGFields[i].ID,
                DisableSharing : results.SDGObject.internalData.DisableSharing
            });
            
            prepareMapAction.setCallback(this, function(response) { 
               var state = response.getState();
               if(state === "SUCCESS"){			
                if(response.getReturnValue()){
                    var mapValues = response.getReturnValue();
                    if(component.get("v.recordToGroupingDataMap")){
                        var existingMap = component.get("v.recordToGroupingDataMap");
                        for ( var key in existingMap ) {
                            mapValues[key] = existingMap[key];
                        }
                        component.set("v.recordToGroupingDataMap",mapValues);
                    }else{
                        component.set("v.recordToGroupingDataMap",mapValues);	
                    }
                    
                }
                if(i<results.SDGObject.SDGFields.length){
                    this.prepareDataMapGrouping(component,results,i);
                }else{
                    this.handleResults(component, results.Results);
                }
				//Condition added for bug fixing (00028539) in v1.3 Phase-4 by Rahulk
            }else if (state === "ERROR") { 
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
					  this.AddToLog(component, "Error preparing map for grouping: " + errors[0].message);
                      component.set("v.displayBlur", "none");
                    }
                } 
            }    
            });
            
            if(i<results.SDGObject.SDGFields.length ){
                $A.enqueueAction(prepareMapAction);
            }
            
            i++;
            //this.callMapMethod(component,results,0);
        } catch (ex) {
            this.AddToLog(component, "Error preparing map for grouping: " + ex.message);
            component.set("v.displayBlur", "none");
        }        
    },
    maintainFilter : function(component){
        
        var FiltersSet = component.get("v.SDGFiltersDefinition");
        if (FiltersSet.length === 0) {
            var SDGObject = component.get("v.SDG");
            
            //START Changes to fix issue with filters from preference
            var filters = component.get("v.SDGFilters");
            var filterlistlength = filters.length;
            var fieldlistlength = SDGObject.SDGFields.length;
            var newfilters = [];
            
            // create a map to deduplicate here...
            for (var i = 0; i < filterlistlength; i++) {
                newfilters.push(filters[i]);
            }
            for (var i = 0; i < fieldlistlength; i++) {
                if(SDGObject.SDGFields[i].Preferences){
                    newfilters.push(SDGObject.SDGFields[i].Preferences);
                }
            }
            component.set("v.SDGFilters", newfilters);
            //END
        }
    },
    updatePreference : function(component){
        var sdgTag = component.get("v.SDGConfiguration");
        if(sdgTag && sdgTag.split('CustomObject:').length > 1)
            sdgTag = sdgTag.split('CustomObject:')[1];
        var updateAction = component.get("c.updateSdgPreference");
        var isExpanded = component.get("v.isGridExpanded");
        updateAction.setParams({"sdgTag": sdgTag,"isExpanded": isExpanded});
        $A.enqueueAction(updateAction);
    },
    getUpdatedPreference : function(component){
        var getPrefAction = component.get("c.getSdgPreference");
        var sdgTag = component.get("v.SDGConfiguration");
        if(sdgTag && sdgTag.split('CustomObject:').length > 1)
            sdgTag = sdgTag.split('CustomObject:')[1];
        getPrefAction.setParams({"sdgTag": sdgTag});
        getPrefAction.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS"){
                component.set("v.isGridExpanded",response.getReturnValue());
            }
        });
        $A.enqueueAction(getPrefAction);
    },
    replaceRecordId : function(recordId,stringToUpdate){
        if(stringToUpdate && stringToUpdate.toUpperCase().includes("<<RECORDID>>")){
            if(recordId){
                stringToUpdate = stringToUpdate.replace(/<<RECORDID>>/ig,recordId);    
            }else{
                stringToUpdate = stringToUpdate.replace(/<<RECORDID>>/ig,'');    
            }
        }
        return stringToUpdate;
    },
	//fire event to close edit popup in sdgDataGridCell in Phase4(InlineEdit)
	fireFieldsUpdatedEvent: function(component, operation, parameters) {
        var processFieldDataChange = $A.get("e.c:UpdateFieldsData");
        processFieldDataChange.setParams({
            "operation": operation,
            "parameters": parameters 
        });
		processFieldDataChange.fire();
    },
    //Handle error when saving the record in Phase4(InlineEdit)
    handleErrors: function(component, errorMap) {
        let updatedRows = component.get("v.updatedData.rows");
        let processedData = component.get("v.processeddata");
        processedData.forEach(row => {
            
            if (errorMap[row.rowID] != null) {
                row.errorMessage = errorMap[row.rowID];
            } else if (updatedRows[row.rowID] != null) {
                let updatedFields = updatedRows[row.rowID].fields;
                Object.keys(updatedFields).forEach(updatedFieldId => {
                    let processedFieldObj = row.data.find(element => element.Id == updatedFieldId);
                    if (processedFieldObj != null) {
                        processedFieldObj.datachunk = updatedFields[updatedFieldId].updatedValue;
                        if (processedFieldObj.FormattedValue != null) {
                            processedFieldObj.FormattedValue = processedFieldObj.datachunk;
                        }
                    }
                });
            }
        });
        component.set("v.processeddata", processedData);

        Object.keys(updatedRows).forEach(rowId => {
            if (errorMap[rowId] == null) {
                delete updatedRows[rowId]; // Row is not present in error, which means this row is successfully saved. So, remove from updatedList.
            }
        });
        component.set("v.updatedData.rows", updatedRows);

        this.fireFieldsUpdatedEvent(component, "partialSave", null)
    },
    /**
     * This method check the checbox in the UI based upon the values present 
     * in the CheckedRowIDs attribute.
     * 
     * Added to handle Bug: 00028444
     */
    syncCheckboxOnLoad: function(component) {
        let checkboxes = component.find("checkrow");
        let checkedRowIDs = component.get("v.CheckedRowIDs");
        let noOfCheckedRows = 0;
        checkboxes.forEach(checkbox => {
            if (checkedRowIDs.includes(checkbox.get("v.value")) && !checkbox.get("v.checked")) {
                checkbox.set("v.checked", true);
                noOfCheckedRows++;
            }
        })

        if (component.get("v.processeddata").length === noOfCheckedRows) {
            component.find("checkall").set("v.checked", true);
        }
    },
    
    defineClickedOutside: function(component, event) {
        // If the SDG is editable, set the functionality to close the update component
        // when clicked outside it. in Phase4(InlineEdit)
        if (component.get("v.SDG.isEditableSDG")) {
            component.set("v.clickedOutsideDefined", true);
            let sdgGridDiv = document.querySelector(`div[class*="${component.get('v.SDG.sdgId')}_grid"]`);
            if (sdgGridDiv) {
                sdgGridDiv.onmousedown = (event) => {
                    if (event.target != null && event.target.closest("section.updateFormSection.showForm") == null) {
                        let updateCmp = document.querySelector("section.updateFormSection.showForm");
                        if (updateCmp != null) {
                            document.getElementById("closeUpdateCmpButton").click();
                        }
                    }
                };
            }
        }
    },
        /* For Open Manage Fields Popup */
    manageFieldPopupHelper: function (component) {
        debugger;
        var sobj = component.get("v.SDG.sObjectName");
        var sdgId = component.get("v.SDG.sdgId");
        var sdgFields = component.get("v.SDG.SDGFields");
       
        //sdgFields= sdgFields.filter(element => element.manageField); 

        var payloadObj = { rootObjectType: sobj, recordId: sdgId, fields: sdgFields };
        $A.createComponent(
            "c:SdgManageField",
            payloadObj,
            function (msgBox) {
                if (component.isValid()) {
                    var targetCmp = component.find('DynamicComponentModel');
                    var body = targetCmp.get("v.body");
                    body.push(msgBox);
                    targetCmp.set("v.body", body);
                }
            }
        );
    }
});