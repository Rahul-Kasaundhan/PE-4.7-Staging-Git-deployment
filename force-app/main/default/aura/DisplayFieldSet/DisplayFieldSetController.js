({
    loadData: function (component, event, helper) {
        var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi,
                                                 function (m, key, value) {
                                                     if (key == 'c__recordId' && (component.get("v.recordId") == "" || component.get("v.recordId") == null)) {
                                                         component.set("v.recordId", value);
                                                     }
                                                 });
        if (component.get("v.recordId") && component.get("v.fieldSetName")) {
            helper.getDynamicFieldset(component, helper, component.get('v.recordId'), component.get("v.fieldSetName"));
        } else {
            component.set("v.loaded", false);
            helper.showInfoToast('Info!', 'RecordId was not Found for Display Field Set Component', 'info')
        }
        window.addEventListener('resize', $A.getCallback(function(){
            if(component.isValid()) {
                let objList = component.get("v.objList");
                let currentObject = component.get("v.sObjectName");
                if(currentObject && objList.length>0){
                    let index = objList.findIndex(val=>val.objName == currentObject);
                    if(index>-1)
                    {
                        console.log('Resizing Window');
                        setTimeout(
                            $A.getCallback(
                                function() {
                                    helper.imageSizing(component,event,helper,objList[index].fields); 
                                }), 100
                        );
                    }
                }
                
            }
        }));
    },
    refreshOnUpdate: function (component, event, helper) {
        if (component.get("v.initDone") && component.get('v.recordIdUsed')) {
            console.log('in refresh');
            if (!component.get("v.updateInProgress")) {
                component.set("v.updateInProgress", true);
                helper.getDynamicFieldset(component, helper, component.get('v.recordIdUsed'), component.get("v.fieldSetName"));
            }
            setTimeout(function () { component.set("v.updateInProgress", false) }, 1000);
        }
    },
    handleImageUrlChange: function (component, event, helper) {
        console.log('image changed');
        component.set("v.imageUrl", undefined);
        component.set("v.imageMode", 'image');
        component.set("v.imageUrl", event.getParam("value"));
    },
    toggleImageIcon: function (component, event, helper) {
        console.log('entered in mouse hover');
        if (component.get("v.editImageAllowed") == true) {
            var cmpTarget = component.find('imageIcon');
            $A.util.toggleClass(cmpTarget, 'show');
            var optionsT = component.find('options');
            $A.util.addClass(optionsT, 'hideOptions');
            
        }
    },
    toggleOptions: function (component, event, helper) {
        if (component.get("v.editImageAllowed") == true) {
            var cmpTarget = component.find('options');
            $A.util.toggleClass(cmpTarget, 'hideOptions');
        }
    },
    handleSelect: function (component, event, helper) {
        var selectedCategory = event.target.getAttribute("data-produto");
        console.log('selectedCategory' + selectedCategory);
        if (selectedCategory == 'update') {
            component.set("v.updateImage", true);
        } else if (selectedCategory == 'delete') {
            component.set("v.deleteImage", true);
        }
        var optionsT = component.find('options');
        $A.util.removeClass(optionsT, 'hideOptions');
    },
    handledeleteImage: function(component,event,helper){
        helper.deleteImage(component, helper);
        component.set("v.deleteImage",false);
    },
    closedelPopup: function (component) {
        component.set("v.deleteImage", false);
    }
})