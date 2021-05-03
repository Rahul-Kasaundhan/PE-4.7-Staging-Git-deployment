/*
* --------------------------------------------------------------------------------------------------
* To Show Fields And Image as Highlights Panel in enhanced way
* --------------------------------------------------------------------------------------------------
* @author        Akash Punera
* @modifiedBy    Shashank Singla
* @version        1.0
* @created        2020-05-08
* @used by 		 DisplayFieldSet.cmp
* @Description  Class Used to provide Field Details along with Image/Icon Url to display as Main Header on Record/App Page.
*/

public class DisplayFieldSetCtrl {
    
    /* deleteFile:  This method will return the delete status of the Image on Object and will clear the image url field on object
* @params: recordId : Name of the Object whose Fields are to be mapped
*existingVersion : Existing contentVersion Id which will yield to existing doc. to delete
*imageField : Name of the image field on sobject which will show unique image as per record
*/
    @auraEnabled 
    public static ResponseWrapper deleteFile(string recordId, string imageField,string existingVersion){
        ResponseWrapper resp = new ResponseWrapper();
        try{
            if(existingVersion!=''){
                Map<Id,ContentVersion> listCv = new Map<Id,ContentVersion>([SELECT ContentDocumentId
                                                                            FROM 	ContentVersion 
                                                                            WHERE 	id=:existingVersion
                                                                            ORDER BY lastmodifieddate desc]);
                if(listCv.containsKey(existingVersion))
                {
                    contentdocument cdoc = new contentdocument(Id=listCv.get(existingVersion).ContentDocumentId);
                    delete cdoc; //Can directly use database.delete(contentdocumentId);
                }
            }
            string sobjectName =  ((Id)recordId).getSObjectType().getDescribe().getName();    //Add check for blank record id    
            sObject sObj = Schema.getGlobalDescribe().get(sobjectName).newSObject() ;
            sObj.put('Id',recordId);
            sobj.put(imageField,null);
            update sObj;
            resp.serverStatus = 'success';
        }catch(Exception Ex){
            resp.serverStatus = 'Error Occured while deleting Photo '+ Ex.getMessage();
            system.debug('Ex '+Ex.getMessage() + ' - '+ ex.getStackTraceString());
        }
        return resp;
    }
    
    /*getFieldSetFromRecId:  This method will return the ResponseWrapper which will contain the fieldset fields with values 
* and the image field/Object Icon  value as well
* @params: recordId : Name of the Object whose Fields are to be mapped , fieldSetName : FieldSet where fields are stored to show,
*			imageFieldName : Name of the image field on sobject which will show unique image as per record
*/
    @AuraEnabled
    public static ResponseWrapper getFieldSetFromRecId(Id recordId, String imageFieldName,string fieldsetName){
        ResponseWrapper resp = new ResponseWrapper();
        
        try{
            resp.recordIdUsed = recordId;
            String sobjectName;
            string imageUrl;
            sobjectName = recordId.getSObjectType().getDescribe().getName();
            if(imageFieldName!=''){
                schema.SObjectField  imgField = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().get(imageFieldName);
                Schema.DescribeFieldResult imageFieldSchema = imgField.getDescribe();
                if(imgField==null){
                    resp.serverStatus = 'Please mention valid image field API name for the object.';//Is this reviewed
                    return resp;
                } else if(imageFieldSchema.isAccessible())
                {
                    List<Sobject> lstSobj = Database.query('SELECT '+imageFieldName+' FROM '+sobjectName+' WHERE id =:recordId');
                    imageUrl = String.valueOf(lstSobj[0].get(imageFieldName));
                    resp.iconUrl = getIconName(sobjectName); //Execute this only if image url is blank
                    resp.imageUrl = imageUrl;
                   
                    resp.editImageAllowed = imageFieldSchema.isUpdateable()?true:false;
                }
            }
            resp.objectName = sobjectName;
            resp.listFields = getQueryResult(sobjectName, fieldSetName, recordId);
            if(resp.listFields!=null && resp.listFields.size()>0){
                resp.serverStatus = 'Success';
                
            }else{
                resp.serverStatus = 'Please mention valid fieldset name for the object.';
            }
        }catch(exception ex){
            system.debug(ex.getMessage()+'-'+ex.getStackTraceString());
            resp.serverStatus = 'Error Occured While Loading Component '+ex.getMessage();
        }
        return resp;
        
    }
    /*getQueryResult:  This method will return the List<FieldSetWrapper> where fields w.r.t Fieldset will be queried for values in particular record
* @params: sobjectName : Name of the Object whose Fields are to be mapped , fieldSetName : FieldSet where fields are stored to show
*/
    private static List<FieldSetWrapper> getQueryResult(String sobjectName, string fieldSetName, String recordId){
        try{
            List<FieldSetWrapper> listWrapper = getFieldSetFields(sObjectName, fieldSetName);
            return listWrapper;
        }catch(Exception ex){
            system.debug(ex.getStackTraceString());
            return null;
        }
    }
    
    /*getFieldSetFields:  This method will return List<FieldSetWrapper> where fields w.r.t Fieldset will be queried for values in particular record
* @params: sobjectName : Name of the Object whose Fields are to be mapped , fieldSetName : FieldSet where fields are stored to show
*/ 
    private static List<FieldSetWrapper> getFieldSetFields(String sObjectName, String fieldSetName){
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get(sObjectName);
        List<FieldSetWrapper> fieldSetList = new List<FieldSetWrapper>();
        if(fieldSetName!=''){
            for(Schema.FieldSetMember member : sObj.getDescribe().fieldSets.getMap().get(fieldSetName).getFields()){
                if(member.getSObjectField().getDescribe().isAccessible()){
                    fieldSetList.add(new FieldSetWrapper(member.getLabel(),member.getFieldPath(),String.valueOf(member.getType())));
                }
            }     
        }
        
        return fieldSetList;
    }
    
    /*getIconName This method will return the icon of any object if it has a tab created otherwise default icon will be returned
* @params: sobjectName : Name of the Object whose icon to be retrieved
* @Default Icon: standard:default
*/
    private static string getIconName(string sobjectName)
    {
        String u;
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
        List<Schema.DescribeTabResult> tabDesc = new List<Schema.DescribeTabResult>();
        List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();
        for(Schema.DescribeTabSetResult tsr : tabSetDesc) { tabDesc.addAll(tsr.getTabs()); }
        
        for(Schema.DescribeTabResult tr : tabDesc) {
            if( sobjectName == tr.getsobjectName() ) {
                if( tr.isCustom() == true ) {
                    iconDesc.addAll(tr.getIcons());
                } else {
                    u = 'standard:' + sobjectName.toLowerCase();
                }
            }
        }
        for (Schema.DescribeIconResult ir : iconDesc) {
            if (ir.getContentType() == 'image/svg+xml'){
                u = 'custom:' + ir.getUrl().substringBetween('custom/','.svg').substringBefore('_');
                break;
            }
        }
        return u!=null?u:'standard:default';
    }
    public class ResponseWrapper {
        @AuraEnabled public List<FieldSetWrapper> listFields;
        @AuraEnabled public String objectName;
        @AuraEnabled public String imageUrl;
        @AuraEnabled public String iconUrl;
        @AuraEnabled public String serverStatus;
        @AuraEnabled public String recordIdUsed;
        @AuraEnabled public Boolean editImageAllowed = false;
    }
    public class FieldSetWrapper{
        @AuraEnabled public String label;
        @AuraEnabled public String apiName;
        @AuraEnabled public String fieldType;
        public FieldSetWrapper(String label, String apiName, String fieldType){
            this.label = label;
            this.apiName = apiName;
            this.fieldType = fieldType;
        }
    }
}