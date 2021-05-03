({
    upload: function (component, helper, file, base64Data) {
        component.set("v.loaded", true);
        let existingVersion;
        let currentImageUrl = component.get("v.imageUrl");
        if (currentImageUrl) {
            let parts = currentImageUrl.replace(/[?&]+([^=&]+)=([^&]*)/gi,
                                                function (m, key, value) {
                                                    if (key == 'versionId') {
                                                        existingVersion = value;
                                                    } else if (key == 'ids') {
                                                        existingVersion = value;
                                                    }
                                                });
        }
        
        var action = component.get("c.saveFile");
        action.setParams({
            recordId: component.get("v.recordId"),
            strFileName: file.name,
            imageField: component.get("v.imageField"),
            base64Data: base64Data,
            existingVersion: existingVersion,
        });
        action.setCallback(this, function (a) {
            var state = a.getState();
            console.log('Image Response' + a.getState() + ' - ' + JSON.stringify(a.getReturnValue()));
            
            if (state === "SUCCESS") {
                let result = a.getReturnValue();
                if (result.status == 'success') {
                    component.set("v.newImageUrl", result.imageUrl);
                    component.set("v.showPopup", false);
                } else {
                    helper.showInfoToast('Error!', result.status, 'error');
                }
            } else {
                helper.showInfoToast('Error!', 'There was some issue in uploading the file. Please try again later.', 'error');
            }
            component.set("v.loaded", false);
        });
        $A.enqueueAction(action);
    },
    imageExists: function (component, helper,mime_type,size, url, callback) {
        var img = new Image();
        img.src = url;
        img.onload = function () {
            const canvas = document.getElementById('canvas');            
            canvas.width = img.width;
            canvas.height = img.height;
            let quality;
            var ctx = canvas.getContext("2d");
            ctx.drawImage(img, 0, 0)
            var newImageData;
            try{
                if(mime_type == 'image/jpeg' || mime_type == 'image/jpg' || mime_type == 'image/gif'){
                    if(size<2500000){
                        newImageData =img.src;
                    }
                    else if(size> 2500000 && size< 5700000) {
                        quality =  0.04;   // Issue-00029288, updated quality from 0.85 to 0.04 by Anirudh Raturi on 15-10-2020 
                        newImageData = canvas.toDataURL(mime_type,quality);
                    }else{
                        quality = 1/100;
                        newImageData = canvas.toDataURL(mime_type,quality);
                    }                
                }
                else{
                    if(size<2000000){
                        newImageData =img.src;
                    }else{
                        quality = 0.85;
                        newImageData = canvas.toDataURL('image/jpeg',quality);
                    }
                } 
            }catch(err){
                console.log('err'+err.message+ 'Stack -> '+err.stack);
            }
      
            callback({'exists':true,'imageUrl':newImageData});
        };
        img.onerror = function () { callback({'exists':false}); };
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