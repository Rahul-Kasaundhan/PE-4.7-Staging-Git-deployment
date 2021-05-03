({
    doneRendering : function(component, event, helper) {
        try {
            var spageYOffset =95;
            if ((screen.width == 1280) && (screen.height == 720)){
                spageYOffset =65;
            }
            var stickySectionAura = component.find("stickySection");
            if(window && stickySectionAura){
                window.onscroll = function() {
                    if(parseInt(window.pageYOffset) >spageYOffset) {
                        $A.util.addClass(stickySectionAura, 'stickySection');
                        document.getElementById("hidediv").style.display = "block";
                        
                    }else{
                        $A.util.removeClass(stickySectionAura, 'stickySection');
                        document.getElementById("hidediv").style.display = "none";
                        
                    }
                    
                }
            }
        } catch(err){
            console.log('doneRendering ERROR: ' + err + ' ** MESSAGE: ' + err.message + ' ** STACK: ' + err.stack);
        }
    }
})