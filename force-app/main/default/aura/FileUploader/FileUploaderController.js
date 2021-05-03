({
    handleUploadFinished: function (component, event, helper) {
        let MAX_FILE_SIZE = 16777216;    //16000000 BugId-00029229,00029198,00029197 updated the value from 16000000 to 2500000 by Anirudh Raturi on 06-Oct-2020
        var filetypes = component.get("v.filetype");
        component.set("v.uploadSuccess", false);
        component.set("v.errorMessage", '');
        var files = component.get("v.fileToBeUploaded");
        if (files && files.length > 0) {
            component.set("v.files", files);
            var file = files[0][0];
            console.log('file type ' + file.type + ' size' + file.size);
            if (file.size <= MAX_FILE_SIZE) {
                if (filetypes.includes(file.type)) {
                    var fileReader = new FileReader();
                    let self = component;
                    fileReader.onload = function () {
                        helper.imageExists(component, helper, file.type, file.size,fileReader.result, function (exists) {
                            if (exists.exists) {
                                var dataURL = exists.imageUrl;
                                var content =  dataURL.match(/,(.*)$/)[1];
                                console.log('Reduced Size -> ' + content);
                                self.set("v.ftype", file.type);
                                self.set("v.uploadSuccess", true);
                                self.set("v.content", content);
                            } else {
                                console.log('broken Image');
                                component.set("v.errorMessage", "The file you uploaded doesn't appear to be a valid image.");
                            }
                        });
                    };
                    fileReader.readAsDataURL(file);
                    
                } else {
                    component.set("v.errorMessage", 'Incorrect file format. Please upload a JPG, JPEG, GIF or PNG file.');
                }
            } else {
                component.set("v.errorMessage", 'File too large. Please upload a file of size upto 16 MB.');
            }
        }
    },
    saveImage: function (component, event, helper) {
        let files = component.get("v.fileToBeUploaded");
        var file = files[0][0];
        let content = component.get("v.content");
        helper.upload(component, helper, file, content);
    },
    closePopup: function (component) {
        component.set("v.showPopup", false);
    }
})