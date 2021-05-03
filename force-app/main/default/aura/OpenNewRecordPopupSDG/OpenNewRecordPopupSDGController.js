({
    //updateDOM added for issue - 00029285 by Aditya
    updateDOM:function(component){
        var newAttr = component.get("v.domCounter")+1;
        component.set("v.domCounter",newAttr);
        
    },
    setRecordTypeId : function(component, event, helper) {
        component.set("v.recordTypeId",event.currentTarget.value);
    },
    closeModel : function (component) {
        component.set("v.showRecordTypePopup",false);
        component.set('v.recordTypeId','');
    },
    openNewRecord : function (component, event, helper) {
        helper.openNewRecordHelper(component, event, helper);
        component.set("v.showRecordTypePopup",false);
    },
    closeEditError:function(component, event, helper){
        window.close();
        component.set('v.recordTypeId','');
    },
    openPopupOnCall:function(component, event, helper){
        var params = event.getParam('arguments');
        if(params && params.payloadobj){
            component.set("v.objectApi",params.payloadobj.entityApiName);
            component.set("v.eventParameters",params.payloadobj);
            
            component.set("v.applyCSSFlg",params.applyCSSFlag);
            component.set("v.panelHeight",params.panelHeight);
            
        }
        helper.setRecordTypeList(component, event, helper);
    }
})