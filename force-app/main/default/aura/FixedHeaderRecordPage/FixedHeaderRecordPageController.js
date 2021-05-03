({
    doneRendering : function(component, event, helper) {
        try {
            var stickySectionAura = component.find("stickySection");
            if(window && stickySectionAura){
                window.onscroll = function() {
                    if(parseInt(window.pageYOffset) > 35) 
                        $A.util.addClass(stickySectionAura, 'stickySection');
                    else
                        $A.util.removeClass(stickySectionAura, 'stickySection');
                }
            }
        } catch(err){
            console.log('doneRendering ERROR: ' + err + ' ** MESSAGE: ' + err.message + ' ** STACK: ' + err.stack);
        }
    }
})