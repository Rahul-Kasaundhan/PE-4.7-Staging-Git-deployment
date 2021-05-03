({
    doInit : function(component, event, helper) {
        
        var sdgconfigs = component.get("v.sdgConfigs");
        if(sdgconfigs!= undefined && sdgconfigs!=''){
            let sdgWrapper = []
            let sdgs = sdgconfigs.split(',');
            for(let val of sdgs){
                if(val.includes(':')){
                    sdgWrapper.push({'title':val.split(':')[0],
                                     'sdgconfig':val.split(':')[1]})  
                }else{
                    helper.showInfoToast('Error!','Please provide valid SDG name in SDG Data Config Provider.','error')
                    break;
                }
            }
            if(sdgWrapper.length>0){
                component.set("v.sdgWrapper",sdgWrapper);
                let defSdg;
                if(component.get("v.defaultSdg")== undefined){
                    defSdg = sdgWrapper[0].sdgconfig;
                    component.set("v.currentSdg",defSdg);
                }else{
                    defSdg = component.get("v.defaultSdg");
                    component.set("v.currentSdg",defSdg);
                }
                
                let inactive = sdgWrapper.filter(val=> val.sdgconfig!=defSdg);
                let inactiveSdgs=[];
                if(inactive.length>0){
                    
                    for(let val of inactive){
                        inactiveSdgs.push(val.sdgconfig.toLowerCase());
                    }   
                }
                var loaded = false;
                let interval =  window.setTimeout(
                    $A.getCallback(function() {
                        if(!loaded){
                            helper.showSdg(component,event,helper,inactiveSdgs);
                            loaded = true;
                        }else{
                            clearTimeout(interval);
                        }
                    }), 1000
                );
            }
        }
    },
    updateCurrentTitle : function(component, event, helper) {  
       // Issue-00029262,00029263,00029264 updated currentSdg variable from event.getSource().get("v.title") to event.getSource().get("v.name") by Anirudh Raturi on 09-10-2020
        let currentSdg =event.getSource().get("v.name"); 
        let sdgWrapper = component.get("v.sdgWrapper");
        let inactive = sdgWrapper.filter(val=> val.sdgconfig!=currentSdg);
        let inactiveSdgs=[];
        for(let val of inactive){
            inactiveSdgs.push(val.sdgconfig.toLowerCase());
        }
        component.set("v.currentSdg",currentSdg);
        helper.showSdg(component,event,helper,inactiveSdgs);
    }
})