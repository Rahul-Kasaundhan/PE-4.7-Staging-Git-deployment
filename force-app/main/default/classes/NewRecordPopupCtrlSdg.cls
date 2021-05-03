public class NewRecordPopupCtrlSdg {
       
    /*****************************************************************************************************
    * @Name         :   getRecordTypeList
    * @Description  :   Method to return all active recordtypes for selected record
    * @Param        :   objectName: name of object to check recordtypes
    *****************************************************************************************************/ 
    @AuraEnabled
    public static List<String> getRecordTypeList(String objectName){
        List<String> listRecordTypes = new List<String>();
        
        if(!String.isBlank(objectName)){
            Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
            
            List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
            //Map<Id, String> recordTypeDetails = new Map<Id, String>(); //Added by Lakshya on 20210420 to store record type details fetched from schema [PE v4.7]
            set<id> recordTypeIdToQuery = new Set<id>();
            
            String defaultRecordType = '';
            
            for(Schema.RecordTypeInfo info : recordTypeInfo){
                if(info.isAvailable() && ! info.isMaster()){
                    if(info.isDefaultRecordTypeMapping()){
                        defaultRecordType = info.getRecordTypeId();
                        listRecordTypes.add(info.getName()+'¤'+info.getRecordTypeId());
                    }
                    recordTypeIdToQuery.add(info.getRecordTypeId());
                    //recordTypeDetails.put(info.getRecordTypeId(), info.getName()); //Added by Lakshya on 20210420 to store record type details fetched from schema [PE v4.7]
                }
                
            }
            //Added toLabel() by Lakshya on 20210427 to resolve translation issue [PE v4.7]
            for(RecordType objRt : [SELECT Id, SobjectType, IsActive, toLabel(Name), toLabel(description) 
                                    FROM RecordType 
                                    WHERE isActive = true 
                                    AND sobjecttype =: objectName
                                    AND id IN :recordTypeIdToQuery ORDER BY Name]){
                                        if(objRt.id == defaultRecordType){
                                            //Modified objRt.name with recordTypeDetails.get(objRt.id) by Lakshya on 20210420 to put name from schema  in place of query [PE v4.7]
                                            //listRecordTypes[0] = recordTypeDetails.get(objRt.id)+'¤'+objRt.id+'¤'+objRt.description;
                                            listRecordTypes[0] = objRt.name+'¤'+objRt.id+'¤'+objRt.description;

                                        }else{
                                            //Modified objRt.name with recordTypeDetails.get(objRt.id) by Lakshya on 20210420 to put name from schema  in place of query [PE v4.7]
                                            //listRecordTypes.add(recordTypeDetails.get(objRt.id)+'¤'+objRt.id+'¤'+objRt.description);
                                            listRecordTypes.add(objRt.name+'¤'+objRt.id+'¤'+objRt.description);
                                        }
                                        system.debug('objRt.description'+objRt.description);
                                    }
            
            
        }
        return listRecordTypes;                     
    }
    
     @AuraEnabled
    public static String getSObjectLabel(String objectName){
        List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{objectName}); // this can accept list of strings, we describe only one object here
		String objectLabel = describeSobjectsResult[0].getLabel();
        return objectLabel;
    }
}