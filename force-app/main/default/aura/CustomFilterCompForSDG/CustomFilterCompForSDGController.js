({
    doInit : function(component, event, helper) {
        helper.getAllCustomFields(component,event);
    },//method close
    
      changePicklist: function(component, event) {
        var selectedOptionValue = event.getParam("value");
        var fieldSequence = event.getSource().get('v.id');
        var objectName;
        if(component.get("v.query"+fieldSequence)){
            var queryStr = component.get("v.query"+fieldSequence).toLowerCase();
            if(queryStr.split('from').length>1){
                objectName = queryStr.split('from')[1].split(' where ')[0].trim();
            }
        }
        
        if(!selectedOptionValue && fieldSequence == 'fundPicklist'){
            selectedOptionValue = 'All';
        }
        
        var url_string = window.location.href;
        var appEvent = $A.get("e.c:EventPassValueToSDG");		//Application Event
        appEvent.setParams({
            "value" :  selectedOptionValue,
            "pageUrl" : url_string,
            "fieldSequence" : fieldSequence,
            "objectApiName" : objectName
        });
        appEvent.fire();
       // }
        /*else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "message": "Please select any value."
            });
            toastEvent.fire();  
        }*/
    }
})