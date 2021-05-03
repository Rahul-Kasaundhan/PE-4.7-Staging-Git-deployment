({
    doInit: function (component, event, helper) {
        console.log('divided' + component.get("v.divided"));
        var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi,
            function (m, key, value) {
                if (key == 'c__recordId') {
                    component.set("v.recordId", value);
                }
            });
        if (component.get("v.recordId") != '') {
            component.set("v.loaded", true);
            helper.fetchRelatedList(component, event, helper, component.get("v.showList"));
        }
    },
    handleUpdateEvent: function (component, event, helper) {
        component.set("v.loaded", true);
        helper.fetchRelatedList(component, event, helper, true);
        component.set("v.showList", false);
    },
    /*stopPropagate: function (component, event, helper) {
        console.log('handled');
    },
    createRecord: function (component, event, helper) {
        console.log('Create');
        helper.handleCreateRecord(component, event, helper);
        event.stopPropagation();
    },*/
    toggle: function (component, event, helper) {
        console.log("toggled" + component.get("v.RelatedList").length);
        var bool = component.get("v.showList");
        component.set("v.showList", !bool);
        event.stopPropagation();
    },

    showAllList: function (component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        if (evt) {
            helper.redirectToSDG(component, event, helper);
        }
        var bool = component.get("v.showList");
        component.set("v.showList", !bool);
    },
    openSDG: function (component, event, helper) {
        helper.redirectToSDG(component, event, helper);
        event.stopPropagation();
    }
})