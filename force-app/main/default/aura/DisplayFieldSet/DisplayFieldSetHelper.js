({
    getDynamicFieldset: function (component, helper, recordId, fieldSet) {
        var getFieldWrapperList = component.get("c.getFieldSetFromRecId");
        component.set("v.showComponent", false);
        component.set("v.loaded", true);
        component.set("v.fieldSetName", fieldSet);
        var Imagefield = component.get("v.Imagefield") != undefined && component.get("v.Imagefield") != '' ? component.get("v.Imagefield") : '';
        getFieldWrapperList.setParams({
            "recordId": recordId,
            "fieldsetName": fieldSet,
            "imageFieldName": Imagefield
        });
        getFieldWrapperList.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseWrapper = response.getReturnValue();
                console.log('responseWrapper normal' + JSON.stringify(responseWrapper));
                if (responseWrapper.serverStatus == 'Success') {
                    helper.responseProcessor(component, helper, responseWrapper);
                } else {
                    component.set("v.showComponent", false);
                    this.showInfoToast('Error!', responseWrapper.serverStatus, 'error');
                    component.set("v.loaded", false);
                    
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        component.set("v.showComponent", false);
                        this.showInfoToast('Error!', errors[0].message, 'error');
                    }
                }
                component.set("v.loaded", false);
                
            }
            
        });
        $A.enqueueAction(getFieldWrapperList);
    },
    responseProcessor: function (component, helper, responseWrapper) {
        var imageMode = 'none';
        if (responseWrapper.listFields.length > 0) {
            component.set("v.editImageAllowed", responseWrapper.editImageAllowed);
            component.set("v.sObjectName", responseWrapper.objectName);
            component.set("v.imageIconUrl", responseWrapper.iconUrl);
            component.set("v.recordIdUsed", responseWrapper.recordIdUsed);
            setTimeout(
                $A.getCallback(
                    function() {
                        helper.imageSizing(component,event,helper,responseWrapper.listFields);
                    }
                )
            );
            if (responseWrapper.imageUrl) {
                helper.imageExists(component, helper, responseWrapper.imageUrl, function (exists) {
                    if (exists) {
                        component.set("v.imageUrl", responseWrapper.imageUrl);
                        component.set("v.imageMode", 'image');
                    } else {
                        component.set("v.imageMode", 'icon');
                    }
                });
            } else if (responseWrapper.iconUrl) {
                component.set("v.imageMode", 'icon');
            }
            let objList = component.get("v.objList");
            let found = objList.findIndex(val => val.objName == responseWrapper.objectName);
            if (found == -1) {
                objList.push({
                    'objName': responseWrapper.objectName,
                    'fields': responseWrapper.listFields,
                    'recordId': responseWrapper.recordIdUsed
                });
            } else {
                objList[found] = {
                    'objName': responseWrapper.objectName,
                    'fields': responseWrapper.listFields,
                    'recordId': responseWrapper.recordIdUsed
                };
            }
            component.set("v.objList", objList);
            component.set("v.showComponent", true);
            component.set("v.initDone", true);
            component.set("v.loaded", false);
        } else {
            component.set("v.loaded", false);
        }
    },
    imageSizing: function(component,event,helper,fieldList){
        
        var width = 750;
        if(component.find("measurement").getElement()!= null){
            width = component.find("measurement").getElement().getBoundingClientRect().width;
        }
        console.log('width'+width);
        let diff = 0;
        let iconHeight;
        if (fieldList.length <= 4) {
            component.set("v.imagesizeClass", ' slds-size_1-of-6');
            component.set("v.iconsizeClass", 'objectIconfor100');
            iconHeight = 100;
            component.set("v.imageHeight", '100'); //100
        } 
        else if (fieldList.length <= 6) {
            component.set("v.imagesizeClass", ' slds-size_2-of-12');
            if(width<600){
                component.set("v.iconsizeClass", 'objectIconfor80');
                iconHeight = 80;
                component.set("v.imageHeight", '80');
            }
            else if(width>=600 && width <=700 ){
                component.set("v.iconsizeClass", 'objectIconfor100');
                iconHeight = 100;
                component.set("v.imageHeight", '100');
            }
                else if(width>700 && width<=800){
                    component.set("v.iconsizeClass", 'objectIconfor120');
                    iconHeight = 120;
                    component.set("v.imageHeight", '120'); //190
                }
                    else if(width>800 && width<=995){
                        component.set("v.iconsizeClass", 'objectIconfor140');
                        iconHeight = 140;
                        component.set("v.imageHeight", '140');
                    }else{
                        component.set("v.iconsizeClass", 'objectIconfor140');
                        iconHeight = 140;
                        component.set("v.imageHeight", '140'); //190
                    }
        }
            else {
                if(width<600){
                    component.set("v.imagesizeClass", ' slds-size_3-of-12');
                    component.set("v.iconsizeClass", 'objectIconfor100');                                    
                    iconHeight = 100;
                    component.set("v.imageHeight", '100');
                }
                else if(width>=600 && width<=700){
                    component.set("v.imagesizeClass", ' slds-size_3-of-12');
                    component.set("v.iconsizeClass", 'objectIconfor140');                                    
                    iconHeight = 140;
                    component.set("v.imageHeight", '140');
                }
                    else if(width>700 && width<=800){
                        component.set("v.imagesizeClass", ' slds-size_3-of-12');
                        component.set("v.iconsizeClass", 'objectIconfor140');
                        iconHeight = 140;
                        component.set("v.imageHeight", '140'); 
                    }
                        else if(width>800 && width<=950){ //957
                            component.set("v.imagesizeClass", ' slds-size_3-of-12');
                            component.set("v.iconsizeClass", 'objectIconfor180');
                            iconHeight = 180;
                            component.set("v.imageHeight", '180');                   // Issue-00029291 updated imageHeight by Anirudh Raturi on 28-10-2020 
                        }else{
                            component.set("v.imagesizeClass", ' slds-size_2-of-12');
                            component.set("v.iconsizeClass", 'objectIconfor160');
                            iconHeight = 160;                                      // Issue-00029291 updated iconHeight by Anirudh Raturi on 28-10-2020
                            component.set("v.imageHeight", '160');                //190  // Issue-00029291 updated imageHeight by Anirudh Raturi on 28-10-2020
                        } 
            }
        diff = iconHeight -18.5;
        console.log('diff'+diff);
        component.set('v.iconPosition',diff);
        
        
    },
    deleteImage: function (component, helper) {
        component.set("v.loaded", true);
        let existingVersion;
        let currentImageUrl = component.get("v.imageUrl");
        if (currentImageUrl) {
            let parts = currentImageUrl.replace(/[?&]+([^=&]+)=([^&]*)/gi,
                                                function (m, key, value) {
                                                    if (key == 'versionId') {
                                                        existingVersion = value;
                                                    }else if (key == 'ids') {
                                                        existingVersion = value;
                                                    }
                                                });
        }
        var action = component.get("c.deleteFile");
        action.setParams({
            recordId: component.get("v.recordId"),
            imageField: component.get("v.Imagefield"),
            existingVersion: existingVersion
        });
        action.setCallback(this, function (a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                let result = a.getReturnValue();
                if (result.serverStatus == 'success') {
                    console.log('Image Delete Response' + JSON.stringify(result));
                    component.set("v.imageMode", 'icon');
                    component.set("v.imageUrl", undefined);
                } else {
                    helper.showInfoToast('Error!', result.serverStatus, 'error');
                }
            } else {
                helper.showInfoToast('Error!', 'There was some issue in deleting the file. Please try again later.', 'error');
            }
            component.set("v.loaded", false);
        });
        $A.enqueueAction(action);
    },
    imageExists: function (component, helper, url, callback) {
        var img = new Image();
        img.onload = function () { callback(true); };
        img.onerror = function () { callback(false); };
        img.src = url;
        
    },
    showInfoToast: function (title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            duration: ' 5000',
            type: type,
            mode: 'dismissible'
        });
        if (toastEvent) {
            toastEvent.fire();
        } else {
            alert(message);
        }
    }
})