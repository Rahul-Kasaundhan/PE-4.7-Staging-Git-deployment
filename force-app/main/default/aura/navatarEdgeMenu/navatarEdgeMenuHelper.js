({
    onLoadHelper : function(component) {
        var getJsonAction = component.get("c.getJson");
        //start changes for utilityType by Aditya PEv4.7 on 19 April 2021
        var globalId = component.getGlobalId().replace(":", "");        
        component.set("v.cmpGlobalId",globalId);
        var expandLevels = 2; // for expanded view of navigation menu
        if(component.get("v.expandNavigationView") == 'False'){
            expandLevels = 1; // for collapsed view of navigtion menu
        }
        var navigationType = component.get("v.navigationType");
        getJsonAction.setParams({
            navigationType: navigationType
        });
        //end changes for utilityType by Aditya PEv4.7 on 19 April 2021
        $A.enqueueAction(getJsonAction);
        getJsonAction.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseObj = response.getReturnValue();
                
                // Create jqxTree
                var source = JSON.parse(responseObj.jsonStr);
                //var source = JSON.stringify(JSON.parse(responseObj.jsonStr),null,2); 
                var mapValue = responseObj.mapIdToUrl;
                
                var newMapIdToUrl = new Object();
                for ( var key in mapValue) {
                    newMapIdToUrl[key] = mapValue[key];
                }
                component.set("v.mapIdToURL2",newMapIdToUrl);
                var jq = jQuery('#treeview12'+globalId); // added globalId by Aditya PEv4.7 20 April 2021
                var tree = jq.treeview({ 
                    levels: expandLevels, // added by Aditya PEv4.7 on 27 April 2021
                    data: source,
                    onNodeSelected: function(event, node) {
                        //Expand collapse parent node on click
                        if(!node.parentId){
                            if(node.state.expanded){
                                jq.treeview('collapseNode', [ node.nodeId, { silent: true } ]); 
                            }else{
                                jq.treeview('expandNode', [ node.nodeId, { silent: false } ]);
                            }
                        }
                        
                        if(!component.get("v.flagCheck")){
                            component.set("v.flagCheck", true);
                            var clickedId = node.id; 
                            if(clickedId.startsWith('create<@>'))
                            {
                                debugger;
                                var flag = true;
                                var objectName = clickedId.split("<@>")[1];
								var rtId;
                                var actBtnApiName;// Phase 3 CR:To store the button API name for Multi association popup.
								
								if(objectName.indexOf('<btnapi>') > 0){
                                    actBtnApiName = clickedId.split('<btnapi>')[1];
                                    objectName = objectName.split('<RT>')[0];
								}
								
								if(clickedId.indexOf('<RT>') > 0){
                                    rtId = clickedId.split('<RT>')[1];
                                    objectName = objectName.split('<RT>')[0];
								}
								
                                //Phase 3 CR changes: get the button api and object label name.
								if(objectName.indexOf('<btnapi>') > 0){
                                    actBtnApiName = objectName.split('<btnapi>')[1];
                                    objectName = objectName.split('<btnapi>')[0];
								}
                                var createRecordEvent = $A.get("e.force:createRecord");
                                if(objectName == 'Task' && actBtnApiName != undefined){
									$A.createComponent(
										"pem_dev:MultipleAssociationPopup",
										{
											"label":actBtnApiName.split('<objlbl>')[1],
											"recordTypeId":(rtId!=undefined?rtId:'012000000000000AAA'),
											"actName":actBtnApiName.split('<objlbl>')[0],
											"parentRecordId":'',
											"parentObjectName":'',
                                            "applyCss":'true'
										},
										function(msgBox){
											if(msgBox!= null){                                            
												if (component.isValid()) {
													var targetCmp = component.find('MultipleAssociationModal');
													var body = targetCmp.get("v.body");
													body.push(msgBox);
													targetCmp.set("v.body", body); 
													var utilityAPI = component.find("utilitybar");
													var utilityId;
													var panelHeight;
													utilityAPI.getEnclosingUtilityId().then(function(response) {
														utilityId = response;
													});
													
													utilityAPI.getUtilityInfo(utilityId).then(function(response) {
														panelHeight = response.panelHeight;
														setTimeout(function(){
															var element = document.getElementById("parentContainer");
															element.classList.remove("slds-hide");
															var centerPopup = document.getElementById('containerBody');
															var centerPopupBody = document.getElementById('popupOpenId');
															var popupHeight = centerPopupBody.clientHeight;
															var popupWidth = centerPopup.clientWidth;
															var windowWidth = window.innerWidth;
															var windowHeight = window.screen.availHeight;
															var remainingHeight = windowHeight - panelHeight;
															centerPopup.style.top = (windowHeight/2-popupHeight/2)-remainingHeight+50+"px";
															centerPopup.style.left= (windowWidth/2-popupWidth/2)+"px";
															centerPopup.style.position = "fixed";
														}, 1000);
													});
												}
											}
											else{
												createRecordEvent.setParams({ "entityApiName": objectName,  "recordTypeId": rtId});
												createRecordEvent.fire(); 
											}
										}
									);
								}
                                else if(clickedId.indexOf('<RT>') > 0){                                    
                                    createRecordEvent.setParams({ "entityApiName": objectName,  "recordTypeId": rtId});
									createRecordEvent.fire();  
                                }
                                else{
                                    var utilityAPI = component.find("utilitybar");
                                    var utilityId;
                                    var panelHeight;
                                    utilityAPI.getEnclosingUtilityId().then(function(response) {
                                        utilityId = response;
                                    });
                                    
                                    utilityAPI.getUtilityInfo(utilityId).then(function(response) {
                                        panelHeight = response.panelHeight;
                                        component.find('newRecordTypeComp').openNewRecordPopup({ "entityApiName": objectName},flag,panelHeight+50); //Added by Jonson
                                    });
                                    
                                    //component.find('newRecordTypeComp').openNewRecordPopup(objectName , flag);
                                }                        
                            }
                            else
                            {
                                var mapUrl = component.get("v.mapIdToURL2");
                                if(mapUrl[clickedId]){
                                    var urlEvent = $A.get("e.force:navigateToURL");
                                    urlEvent.setParams({
                                        "url": mapUrl[clickedId]
                                    });
                                    urlEvent.fire();
                                    
                                    // code for minimize utility bar.
                                    var utilityAPI = component.find("utilitybar");
                                    utilityAPI.minimizeUtility();
                                }
                            }
                            
                            window.setTimeout(
                                $A.getCallback(function() {	
                                    component.set("v.flagCheck", false);
                                    //To perform operation even if user clicks on a node which is already selected
                                    jq.treeview('unselectNode', [ node.nodeId, { silent: true } ]);
                                }), 100
                            );
                        }
                    },
                    
                    //START-Added to collapse all other nodes on expanding a node ~Akash
                    onNodeExpanded: function (event, node) {
                        jq.treeview('collapseAll', { silent: true }); 
                        jq.treeview('expandNode', [ node.nodeId, { silent: true } ]); 

                    }
                    //END
				});
			}
        });
        
    }
})