/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
({
	handleBuild: function (component, object, status, errorMessage) {
		//Add the new button to the body array
		if (status === "SUCCESS") {
			var body = component.get("v.body");
			body.push(object);
			component.set("v.body", body);
		} else if (status === "INCOMPLETE") {
			this.showError("No response from server or client is offline.");
			// Show offline error
		} else if (status === "ERROR") {
			this.showError("Error: " + errorMessage);
			// Show error message
		}
	},
	showError: function (msg) {
		var navToast = $A.get("e.force:showToast");
		navToast.setParams({
			title: "",
			message: msg,
			type: "error"
		});
		navToast.fire();
	},
	renderHyperLinktoObject: function (component, datachunk, datachunkid, isPhotoField) {
       
		try {
            // Add Conditon for bug fixing(00028982)  in DarkMode for Einstein Code V1 By Rahulk
            var css_des =  (component.get("v.currentTheme") == 'Dark') ? "cls_desDark":"cls_des";
            if(isPhotoField){
                css_des = ' photoText ';
            }
			if (typeof datachunkid === "string" && typeof datachunk === "string") {
				if (datachunkid !== null && datachunk !== null) {
					if (datachunkid !== "" && datachunk !== "") {
						this.CreateCmp(component, "lightning:formattedUrl", {
							value: "/" + datachunkid,
							title: datachunk,
							label: datachunk,
                            target: "_blank", 
							class: css_des	// Added CSS class for showing gradient in case of description is more than 3 lines.
						});
					}
				}
			}
			//}
			//}
		} catch (linkex) {
			this.showError("Error rendering hyperlinktoobject");
		}
	},
	getAddress: function (component, datachunk) {
		var outputarray = [];
		var addr = "";
		outputarray = this.addnonblank(outputarray, datachunk.street);
		outputarray = this.addnonblank(outputarray, datachunk.city);
		outputarray = this.addnonblank(outputarray, datachunk.state);
		outputarray = this.addnonblank(outputarray, datachunk.statecode);
		outputarray = this.addnonblank(outputarray, datachunk.country);

		if (outputarray.length > 0) {
			addr = outputarray.join(", ");
		}
		return addr;
	},
	addnonblank: function (arr, val) {
		if (val) {
			if (val !== "") {
				arr.push(val);
			}
		}
		return arr;
	},
	renderText: function (component, datachunk, isPhotoField) {
        // Add Conditon for bug fixing(00028982)  in DarkMode for Einstein Code V1 By Rahulk
	  var css_des =  (component.get("v.currentTheme") == 'Dark') ? "cls_desDark":"cls_des";
        if(isPhotoField){
            css_des = css_des+' photoText ';
        }
		if (typeof datachunk === "string") {
			if (datachunk !== null) {
				this.CreateCmp(component, "lightning:formattedText", {
					value: datachunk,
					title: datachunk,
					linkify: false,
					class: css_des	// Added CSS class for showing gradient in case of description is more than 3 lines.
				});
			}
		}
	},
	renderNumber: function (component, datachunk, scale) {
		if (datachunk !== null) {
			this.CreateCmp(component, "lightning:formattedNumber", {
				value: datachunk,
				title: datachunk,
				maximumFractionDigits: scale
			});
		}
	},
	renderPercent: function (component, datachunk, scale) {
		if (datachunk !== null) {
			if (datachunk !== "") {
				var percentvalue = datachunk / 100;
				this.CreateCmp(component, "lightning:formattedNumber", {
					value: percentvalue,
					title: percentvalue,
					style: "percent",
					maximumFractionDigits: scale
				});
			}
		}
	},
	renderSummaryText: function (component, summarytext) {
		if (typeof summarytext === "string") {
			if (summarytext !== null) {
				this.CreateCmp(component, "lightning:formattedText", {
					value: summarytext,
					title: summarytext,
					class: "summary",
					linkify: false
				});
			}
		}
	},
	renderHyperLink: function (component, label, url, isPhotoField) {
     // Add Conditon for bug fixing(00028982)  in DarkMode for Einstein Code V1 By Rahulk
	var css_des =  (component.get("v.currentTheme") == 'Dark') ? "cls_desDark":"cls_des";
        if(isPhotoField){
            css_des = ' photoText ';
        }
		if (typeof url === "string" && typeof label === "string") {
			if (url !== null && label !== null) {
				if (url !== "" && label !== "") {
					this.CreateCmp(component, "ui:outputURL", {
						value: url,
						title: label,
						label: label,
						target: "_blank",
						class: css_des	// Added CSS class for showing gradient in case of description is more than 3 lines.
					});
				}
			}
		}
	},
	formatDurationDateTime: function (cmp, dateRecord) {
		var sdgAgo = cmp.get("v.sdgAgo");
		var sdgIn = cmp.get("v.sdgIn");
		var dateNow = Date.now();
		var dur = $A.localizationService.duration(
			(dateNow - dateRecord) / (1000 * 60 * 60 * 24),
			"d"
		);
		var displayduration = $A.localizationService.displayDuration(dur);
		var output = "";
		if (dateNow - dateRecord > 0) {
			output = sdgAgo.replace("{0}", displayduration);
		} else {
			output = sdgIn.replace("{0}", displayduration);
		}
		return output;
	},
	CreateCmp: function (component, cmpType, cmpConfig) {
		var config = cmpConfig;
		if (config !== null) {
			config["aura:id"] = "findableAuraId";
			var self = this;

			$A.createComponent(cmpType, cmpConfig, function (
				cmp,
				status,
				errorMessage
			) {
				self.handleBuild(component, cmp, status, errorMessage);
			});
		}
	},
	/*
	  Method for Creating Related Association grid button combination(Icon,Name,relatedAssociation Count)  in Phase3 CR. 
	  By::- Akash(28-11-2019).
	*/
	renderRelatedAssociation: function (component, datachunkid, datachunk, relatedAssociationData) {
		//Logic Change for bugs(00028217)  by Rahulk
		var oldidList = datachunk.split(',');
		var idList = [];
		for (let i = 0; i < oldidList.length; i++) {
			if (relatedAssociationData[oldidList[i]] != undefined)
				idList.push(oldidList[i]);
		}
		if (relatedAssociationData && datachunk && idList.length > 1) {
			this.CreateCmp(component, "lightning:icon", {
				iconName: relatedAssociationData[idList[0]].split('<@>')[1],
				size: 'small'
			});
			this.CreateCmp(component, "lightning:formattedUrl", {
				value: '/' + idList[0],
				label: relatedAssociationData[idList[0]].split('<@>')[0],
				title: relatedAssociationData[idList[0]].split('<@>')[0],
				target: "_blank",
				class: "linkCss"
			});
			this.CreateCmp(component, "lightning:formattedText", {
				value: ' + '
			});
			this.CreateCmp(component, "lightning:button", {
				label: (idList.length - 1) + '',
				title: 'View All',
				onclick: component.getReference("c.fireRelatedAssociationEvent"),
				class: 'buttonCss'
			});
		} else if (relatedAssociationData && datachunk && idList.length == 1) {
			this.CreateCmp(component, "lightning:icon", {
				iconName: relatedAssociationData[idList[0]].split('<@>')[1],
				size: 'small'
			});
			this.CreateCmp(component, "lightning:formattedUrl", {
				value: '/' + idList[0],
				label: relatedAssociationData[idList[0]].split('<@>')[0],
				target: "_blank",
				class: "linkCss"
			});
		}
		component.set("v.rowId", datachunkid);
		component.set("v.sRelatedAssociationIds", idList);  //Logic Change for bugs(00028217) by Rahulk
	},
	getNewUrl: function (field) {
		var url = field.redirectUrl;
		var newUrl = url.split('<<')[0];
		if (url.split('<<').length > 1)
			for (var k = 1; k < url.split('<<').length; k++) {
				if (url.split('<<')[k].split('>>').length > 1 && url.split('<<')[k].split('>>')[1]) {
					newUrl += field.reportVariables[k - 1] + url.split('<<')[k].split('>>')[1];
				} else {
					newUrl += field.reportVariables[k - 1];
				}
			}
		return newUrl;
	},

	createLookup: function(component, datachunk) {
		component.set("v.blurCell", true);
		let componentsToCreate = [
			[
				"lightning:recordViewForm",
				{
					"recordId": datachunk,
					"objectApiName": component.get("v.sObjectName")
				}
			],
			[
				"aura:html",
				{
					"tag": "a",
					"HTMLAttributes": {
						"href": `/${datachunk}`,
						"target": "_blank",
						"class": "lookupFieldAnchor"
					}
				}
			],
			[
				"lightning:outputField",
				{
					"fieldName": "Name",
					"variant": "label-hidden"
				}
			]
		];

		$A.createComponents(
			componentsToCreate,
			function (newComponents, status, errorMessage) {
				//Add the new button to the body array
				if (status === "SUCCESS") {
					let viewForm = newComponents[0];
					let anchorTag = newComponents[1];
					anchorTag.set("v.body", newComponents[2]);
					viewForm.set("v.body", anchorTag);
					component.set("v.body", viewForm);
					var selfCmp = component;

					setTimeout(() => {
						selfCmp.set("v.blurCell", false);
					}, 1000)
				}
				else if (status === "INCOMPLETE") {
					console.log("No response from server or client is offline.");
					// Show offline error
				}
				else if (status === "ERROR") {
					console.log("Error: " + errorMessage);
					// Show error message
				}
			}
		);
	},

	createEditCmp: function (component) {
		let selectedRows = component.get("v.selectedRows");
		let rowId = component.get("v.rowId");
		let fieldId = component.get("v.renderfield.Id");
		let fieldName = component.get("v.renderfield.Path");
		let rowsData = component.get("v.updatedData.rows");
		let recordTypeId = component.get("v.recTypeId");

		if (fieldName.includes('.')) {
			fieldName = this.modifyParentField(fieldName);
		}

		// Added to resolve Bug: 00028537 and Bug: 00028470
		let recordEditFormAttributes = {
			"aura:id": "recordForm",
			"recordId": component.get("v.rowId"),
			"objectApiName": component.get("v.sObjectName"),
			"mode": "edit",
			"columns": 1,
			"onload": component.getReference("c.handleFormLoad")
		};

		if (recordTypeId != null || recordTypeId != "") {
			recordEditFormAttributes.recordTypeId = recordTypeId;
		}

		let inputFieldsAttributes = {
			"fieldName": fieldName,
			"variant": "label-hidden",
			"aura:id": "inputField"
		};

		if (rowsData != null && rowsData[rowId] != null && rowsData[rowId].fields != null
			&& rowsData[rowId].fields[fieldId] != null
			&& rowsData[rowId].fields[fieldId].updatedValue != null) {

			inputFieldsAttributes.value = rowsData[rowId].fields[fieldId].updatedValue;
		} else {
			inputFieldsAttributes.value = component.get("v.renderfield.datachunk");
		}

		let componentsToCreate = [
			[
				"lightning:recordEditForm",
				recordEditFormAttributes
			],
			[
				"lightning:inputField",
				inputFieldsAttributes
			]
		];

		if (selectedRows.includes(rowId)) {
			componentsToCreate.push(...[
				[
					"lightning:input",
					{
						"type": "checkbox",
						"label": `Update ${selectedRows.length} selected items`,
						"onchange": component.getReference("c.modifySelectedRows"),
						"class": "highlightCheckbox",
						"aura:id": "multi-select"
					}
				],
				[
					"lightning:button",
					{
						"label": "Cancel",
						"onclick": component.getReference("c.closeUpdateCmp")
					}
				],
				[
					"lightning:button",
					{
						"label": "Apply",
						"variant": "brand",
						"onclick": component.getReference("c.applyMultiData")
					}
				]
			]);
		}

		$A.createComponents(
			componentsToCreate,
			function (newComponents, status, errorMessage) {
				//Add the new button to the body array
				if (status === "SUCCESS") {
					let body = new Array();
					let footer = new Array();
					let targetBody = component.find("updateCmpBody");
					let targetFooter = component.find("updateCmpFooter");
					let formCmp = newComponents[0];
					let fieldCmp = newComponents[1];

					formCmp.set("v.body", fieldCmp);
					body.push(formCmp);

					if (selectedRows.includes(rowId)) {
						body.push(newComponents[2]);
						footer.push(newComponents[3]);
						footer.push(newComponents[4]);
						$A.util.addClass(targetFooter, "slds-popover__footer");
						targetFooter.set("v.body", footer);
					}

					targetBody.set("v.body", body);
                    component.set("v.applyInlineCss",'inableInlineEdit');
                    //component.set("v.applyInlineCss",''); //Added for bug(00029057) fixing in Einstein Code V1 by Rahulk
				}
				else if (status === "INCOMPLETE") {
					console.log("No response from server or client is offline.");
					// Show offline error
				}
				else if (status === "ERROR") {
					console.log("Error: " + errorMessage);
					// Show error message
				}
			}
		);
	},

	processUpdatedData: function (component, attributes, operation, parameters) {
		let fieldId = component.get("v.renderfield.Id");
		let fieldName = component.get("v.renderfield.Path");
		let updatedData = component.get("v.updatedData");
		let rowIdsToProcess = attributes.rowIdsToProcess;
		let rowsData;

		if (fieldName.includes('.')) {
			fieldName = this.modifyParentField(fieldName);
		}

		if (updatedData.sdgId == null) {
			updatedData.sdgId = component.get("v.sdgId");
			updatedData.rows = new Object();
		}

		rowsData = updatedData.rows;

		rowIdsToProcess.forEach(rowId => {
			let rowObject = rowsData[rowId] != null ? rowsData[rowId] : new Object();

			if (component.get("v.rowId") == rowId && rowObject.recordTypeId == null) {
				rowObject.recordTypeId = component.get("v.recTypeId");
			}

			let fields = rowObject.fields != null ? rowObject.fields : new Object();
			let fieldObject = fields[fieldId] != null ? fields[fieldId] : new Object();

			if (fieldObject.fieldName == null) {
				fieldObject.fieldName = fieldName;
			}

			if (fieldObject.fieldType == null) {
				fieldObject.fieldType = component.get("v.renderfield.FieldType");
			}

			if (attributes.updatedValue != null) {
				fieldObject.updatedValue = attributes.updatedValue;
			}

			if (attributes.multiSelect != null) {
				fieldObject.multiSelect = attributes.multiSelect;
			} else {
				delete fieldObject.multiSelect;
			}

			fields[fieldId] = fieldObject;
			rowObject.fields = fields;
			rowsData[rowId] = rowObject;
		});

		component.set("v.updatedData", updatedData);
		this.fireFieldsUpdatedEvent(component, operation, parameters);
	},

	fireFieldsUpdatedEvent: function(component, operation, parameters) {
		var processFieldDataChange = $A.get("e.c:UpdateFieldsData");
		processFieldDataChange.setParams({
			"operation": operation,
			"parameters": parameters
		});
		processFieldDataChange.fire();
	},

	closeUpdateComponent: function (component) {
		$A.util.removeClass(component.find("updateCmpFooter"), "slds-popover__footer");
		$A.util.removeClass(component.find("updateCmp"), "showForm");
		let targetBody = component.find("updateCmpBody");
		let targetFooter = component.find("updateCmpFooter");
		targetBody.set("v.body", '');
		targetFooter.set("v.body", '');
	},

	modifyParentField: function(fieldName) {
		if (fieldName.toLowerCase().endsWith('__r.Name'.toLowerCase())) {
			return fieldName.replace(/__r.Name/gi, '__c');
		} else {
			return fieldName.replace(/.Name/gi, 'Id');
		}
	},

	/**
	 * This method update the invalid/null values to blank value, which will be
	 * handled in the backend later.
	 * 
	 * Code Added to resolve the Bug: 00028502, 00028446, 00028617
	 * 
	 * @param {any} component 
	 * @param {String} fieldValue 
	 */
	modifyValues: function(component, fieldValue) {
		let fieldType = component.get("v.renderfield.FieldType");
		
		if (fieldType == "CURRENCY") {
			if (isNaN(fieldValue) || fieldValue == null) {
				fieldValue = "";
			} else if (typeof(fieldValue) != "string") {
				fieldValue = fieldValue.toString();
			}
		} else if (fieldType == "DATE" && fieldValue == null) {
            fieldValue = "";
		} else if (fieldType == "DATETIME" && fieldValue == null) {
            fieldValue = "";
		}
		
		return fieldValue;
	},
	renderImage: function (component, datachunk,datachunkText, field,datachunkid) {
        debugger;
			if (datachunk) {
				this.CreateCmp(component, "aura:html", {
					tag: "img",
					HTMLAttributes:{"src": datachunk,"class": "imageContainer"}
				});
			}else{
				this.CreateCmp(component, "aura:html", {
					tag: "img",
					HTMLAttributes:{"src": '/img/icon/t4v35/standard/user_120.png',"class": "imageContainerbg"}
				});
			}
		
		if (datachunkText) {
			if (field.Path.toLowerCase() === "name" || field.Path.toLowerCase().endsWith(".name")) {
				//Change to add hyperlink to text ~Akash
				if(field.redirectUrl){                                    
					var newUrl = this.getNewUrl(field);
					var label = datachunkText;
					this.renderHyperLink(component, label, newUrl, true);
				}//END
				else{
					this.renderHyperLinktoObject(component,datachunkText,datachunkid,true);
				}
				
			} else {
				//Change to add hyperlink to text ~Akash
				if(field.redirectUrl){
					var newUrl = this.getNewUrl(field);
					var label = datachunkText;
					this.renderHyperLink(component, label, newUrl,true);
				}
				//END
				else{
					this.renderText(component,datachunkText,true);
				}
			}
			
		}
	}
});