({
    doInit : function(component,event,helper){
        var sdgTags = component.get("v.SDGConfiguration");
        var sdgtagsList =[];
        try{
            if(sdgTags!=''){                    
                for(let tagValue of sdgTags.split(',')){
                    console.log('index'+tagValue)
                    let val={'sdgName':'','sdgTitle':''};
                    if(tagValue.includes(':')){
                        val.sdgName  = tagValue.split(':')[0];
                        val.sdgTitle = tagValue.split(':')[1];
                    }else{
                        val.sdgName = tagValue;
                    }
                    sdgtagsList.push(val);
                }
            }
            if(sdgtagsList.length>0){
                component.set("v.SDGConfigurationList",sdgtagsList);
            }else{
                //alert('please enter All the Title/SDG Tags for SDGs Provided');
            }
        }catch(err){
            console.log(err.message)
        }
    },
    closeModel : function(component, event, helper) {
        component.set("v.showModal",false);
    }
})