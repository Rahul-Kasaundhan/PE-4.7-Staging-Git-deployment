/*
* --------------------------------------------------------------------------------------------------
* To Insert Images As Files in Salesforce and link the file to record via image url field on object
* --------------------------------------------------------------------------------------------------
* @author        Shashank Singla
* @modifiedBy    Shashank Singla
* @version        1.0
* @created        2020-07-16
* @used by 		 FileUploaderV1.cmp
* @Description  Class Used to provide Field Details along with Image/Icon Url to display as Main Header on Record/App Page.
*/
public with sharing class FileUploaderCtrl  {
    
    /*saveFile:  This method will insert the image as file in salesforce, will delete existing file if any and will provide
public url for image
* @params: recordId : Name of the Object whose Fields are to be mapped ,
*strFileName: File Name
*base64Data : URL Encoded base 64 Image file data
*imageField : Name of the image field on sobject which will show unique image as per record
*existingVersion : Existing contentVersion Id which will yield to existing doc. to delete if any.
*			
*/  
    @AuraEnabled
    public static response saveFile(Id recordId, String strFileName, String base64Data,string imageField,string existingVersion) {
        response res = new response(); 
        try{
            ContentVersion cv = new ContentVersion();
            cv.Title = strFileName;
            cv.FirstPublishLocationId = recordId;
            cv.ContentLocation = 'S';
            cv.PathOnClient =  strFileName;
            cv.VersionData = EncodingUtil.base64Decode(base64Data);
            List<ContentVersion> cvList=new List<ContentVersion>();
            cvList.add(cv);
            Database.SaveResult[] srList = Database.insert(cvList, false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    res.imageUrl = generateNewImageUrl(cvList[0].Id);
                    if(res.imageUrl!=null){
                        saveImageUrl(imageField,res.imageUrl,recordId,existingVersion);  
                    } else{
                        res.status = 'There was some issue in uploading the file. Please try again later.';
                    }
                }
                else {
                    res.status = 'There was some issue in uploading the file. Please try again later.';
                }
            }
        }catch(Exception ex){
            if(ex.getMessage().contains('INSUFFICIENT_ACCESS_OR_READONLY')){
                res.status = 'You do not have permission to update or delete this photo.';
            }else{
                res.status = ex.getMessage()+ ' - '+ ex.getStackTraceString();      
            }
            
        }
        return res;
    }  
    /*generateNewImageUrl:  This private method will provide public url from contentdistribution.
* @params: newversionId : Content version id of newly inserted Content doc.		
*/  
    private static string generateNewImageUrl(string versionId) {
        string imageUrl='';
        List<ContentVersion> listCv = [SELECT 	Id, ContentDocumentId, ContentBodyId
                                       FROM 	ContentVersion 
                                       WHERE 	Id=:versionId
                                       ORDER BY lastmodifieddate desc];
        //imageUrl = url.getSalesforceBaseUrl().toExternalForm()+ '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Jpg&versionId='; 
        //imageUrl+=listCv[0].Id+'&operationContext=CHATTER&contentId='+listCv[0].ContentBodyId;
        //Modified imageURL for displaying file image in iPhone by RahulK on 20210608; 00029692
        imageUrl = '/sfc/servlet.shepherd/version/download/'+listCv[0].Id+'?operationContext=S1';
        return imageUrl;
    }
    /*saveImageUrl:  This private method will save public url to current record and will delete existing doc if any.
* @params: imageField : Content version id of newly inserted Content doc.
*imageUrl : New Url to be updated on record and display as well
* recordId : Name of the Object whose Fields are to be mapped ,
*existingVersion : Existing contentVersion Id which will yield to existing doc. to delete if any.
*/  
    private static void saveImageUrl(String imageField, String imageUrl,String recordId,string existingVersion){
        if(existingVersion!=''){
            Map<Id,ContentVersion> listCv = new Map<Id,ContentVersion>([SELECT ContentDocumentId
                                                                        FROM 	ContentVersion 
                                                                        WHERE 	id=:existingVersion
                                                                        ORDER BY lastmodifieddate desc]);
            if(listCv.containsKey(existingVersion))
            {
                list<contentdocumentLink> clinks = [select id,LinkedEntity.name from contentdocumentLink where
                                                    contentdocumentid=:listCv.get(existingVersion).ContentDocumentId];
                contentdocument cdoc = new contentdocument(Id=listCv.get(existingVersion).ContentDocumentId);
                delete cdoc;
            }
        }
        string sobjectName =  ((Id)recordId).getSObjectType().getDescribe().getName();        
        sObject sObj = Schema.getGlobalDescribe().get(sobjectName).newSObject() ;
        sObj.put('Id',recordId);
        sobj.put(imageField,imageUrl);
        update sObj;
    }
    public class response{
        @auraEnabled
        public string status='success';
        @auraEnabled
        public string imageUrl;
    }
}