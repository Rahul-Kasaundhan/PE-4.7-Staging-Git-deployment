({
     showSdg : function(component,event,helper,inactiveSdgs) {
        var appEvent = $A.get("e.c:toggleSdgEvt");		//Application Event
        appEvent.setParams({
            "sdgConfiguration" :  component.get("v.currentSdg"),
            "inActiveSdgConfiguration": inactiveSdgs
        });   
        appEvent.fire(); 
    },
    showInfoToast : function(title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            duration:' 5000',
            type: type,
            mode: 'dismissible'
        });
        if(toastEvent){
            toastEvent.fire();
        }else{
            alert(message);
        }
    }
})