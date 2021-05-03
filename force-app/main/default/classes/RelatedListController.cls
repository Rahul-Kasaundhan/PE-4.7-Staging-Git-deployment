/*
@created by : Shashank Singla
@created on : 25-04-2020
@Used by : RelatedList.cmp
@purpose: To create Related list in a way that it can accommodate to show current object's related records and Parent Object Related Records as well including parent object fields, how cool is that??
*/
public with sharing class RelatedListController {
    /*Main method to retrieve the list of field Structure and the record List for the Specified params.
* objectQuery --> It has a specific format in which it works like --> Select id,name.Account.Name from Contact where  AccountId='<<AccountId>>' and Id!='<<recordId>>'
the API name should be in this <<>> should be exact API Name including namespace if any and only for recordID field variable should be recordId and rest will be taken care by code.
* getIcon -> if you want to show any other image as through URL then keep it False and set image URL in Component's Design Attribute
* CurrentPageObject--> Bravo,you guessed it right!!
* recordId --> current Page Object's Record Id
*/
    @auraEnabled
    public static responseWrapper fetchRelatedList(string objectQuery,boolean getIcon,string CurrentPageObject,string recordId,String sdgName,string querylimit){
        responseWrapper result = new responseWrapper();
        try{
            result.recordIdUsed = recordId;
            if(objectQuery!='')
            {
                if(recordId!='') objectQuery = objectQuery.replaceAll('<<recordId>>', recordId);
                
                result.sobjectName =  objectQuery.toLowerCase().substringAfter('from').trim().split(' ')[0].trim();
                system.debug('objName'+result.sobjectName);
                
                if(objectQuery.contains('<<')){
                    objectQuery = getRelatedfieldValue(objectQuery,CurrentPageObject,recordId);
                }
                Schema.SobjectType  relateObjectType = Schema.getGlobalDescribe().get(result.sobjectName);
                Schema.DescribeSObjectResult relatedObjSchema = relateObjectType.getDescribe();
                result.sobjectName = relatedObjSchema.getName();
                List<string> fields = objectQuery.toLowerCase().substringBetween('select','from').replaceAll(' ','').trim().split(',');
                if(result.sobjectName.toLowerCase() =='account' || result.sobjectName.toLowerCase() == 'lead' || result.sobjectName.toLowerCase() == 'contact'){
                    result.iconExist = false;
                }
                objectQuery=objectQuery+ ' Limit '+querylimit;
                system.debug('objectQuery-->'+objectQuery);
                result.resultData =  Database.query(objectQuery);
                if(result.resultData.size()>0){
                    for(string field : fields)
                    {
                        setSObjectField(relatedObjSchema,field,result.fStruct,'');
                    }
                    
                    if(result.fStruct[0].objName.toLowerCase() == 'account' || result.fStruct[0].objName.toLowerCase() == 'lead'||
                       result.fStruct[0].objName.toLowerCase() == 'contact'){
                           result.iconExist = false;
                       }   
                }
            }else if(sdgName!='')
            {
                system.debug('sdgName'+SdgName);
                sdgName = sdgName.substringAfter(':').trim();                
                list<Sdg__c>sdgList = new List<Sdg__c>([select id,sObjectName__c,Parent_Field_Name__c from SDG__c where name=:sdgName]);
                if(sdgList.size()>0){
                    result.sobjectName = sdgList[0].sObjectName__c;
                    result.parentField = sdgList[0].Parent_Field_Name__c;
                }
            }
            if(getIcon){
                result.objectIcon = getIconName(result.sobjectName);
            }
            system.debug(result);
        }catch(Exception Ex){
            result.serverStatus = Ex.getMessage();
            system.debug('Exception occured-->'+Ex.getMessage()+'--'+ex.getStackTraceString());
        }
        return result; 
    }
    /*
Internal Method specifically used to replace parent Id Filter Field with its Value from current page Record
*@params => query -> Select id,name from Contact where  Accountid='<<AccountId>>'
* the value inside <<>> should be exact api name for this to work
=>objectname -> current page Object Name
=>recordid -> current page Object's Record Id
Ex.--> Contact AccountId filter then Get the Accountid Value from contact.
returns --> Select id,name from Contact where  Accountid='0017F0000XXXXXX'
*/
    private static string getRelatedfieldValue(string query,string objectname,String recordid){
        string relatedfieldname = query.substringbetween('<<','>>');
        //string stlimit=String.valueOf(Limits.getLimitQueryRows() - Limits.getQueryRows());
        string stquery='SELECT '+relatedfieldname+' FROM '+ objectname +' WHERE Id=:recordid';
        System.debug('stquery:'+stquery);
        List<sObject> sobjList = database.query(stquery);
        list<string> fieldApis = relatedfieldname.split('\\.');
        String fieldValue='';
        if(sobjList!=null && sobjList.size()>0){
            switch on fieldApis.size() {
                when 1 {		
                    fieldValue = (String) sobjList[0].get(fieldApis[0]);                
                }	
                when 2 {
                    fieldValue = (String) sobjList[0].getSobject(fieldApis[0]).get(fieldApis[1]);
                }
                when 3 {	
                    fieldValue = (String) sobjList[0].getSobject(fieldApis[0]).getSobject(fieldApis[0]).get(fieldApis[1]);
                }
                when else {	
                }
            }   
        }
        query = query.replaceAll('<<'+relatedfieldname.trim()+'>>',fieldValue==null?'00':fieldValue);
        return query;
    }
    /*
the field we mention to query needs to be passed with labels to UI so this method will fetch the field Label w.r.t your current Object
*/
    private static void setSObjectField(Schema.DescribeSObjectResult testObj, string field,List<FieldStructure> fstruct,string resultApi)
    {
        if(field.indexOf('.') == -1){
            schema.sObjectField  fieldSchema =  testObj.fields.getMap().get(field);
            resultApi+=String.valueOf(fieldSchema);
            Schema.DescribeFieldResult fieldSchemaResult = fieldSchema!=null?fieldSchema.getDescribe():null;
            string Label =fieldSchema!=null?fieldSchemaresult.getLabel():null;
            if(Label !=null){
                string fieldtype = string.valueOf(fieldSchemaresult.getType());
                fstruct.add(new FieldStructure(Label,resultApi,fieldtype,testObj.getName()));
            }
        }
        else{
            string newObjName = '';
            integer literal=0;
            string fieldApiName=field.substringBefore('.');
            if(fieldApiName.contains('__r')){
                fieldApiName = field.substringBefore('r.')+'c';
                literal=1;
            }else{
                fieldApiName+='id';
                literal=2;
            }
            schema.sObjectField  fieldSchema = testObj.fields.getMap().get(fieldApiName);
            if(fieldSchema!=null){
                newObjName= fieldSchema.getDescribe().getReferenceTo()[0].getDescribe().getName();
                string newapi = String.valueOf(fieldSchema);
                newapi = newapi.substring(0,newapi.length()-literal);
                resultApi +=  field.substringBefore('.').replace(newapi.toLowerCase(),newapi)+'.';
                setSObjectField (Schema.getGlobalDescribe().get(newObjName).getDescribe(),field.substringAfter('.'),fstruct,resultApi);
            }
        }
    }
    /*getIconName This method will return the icon of any object if it has a tab created otherwise default icon will be returned
* @params: sobjectName : Name of the Object whose icon to be retrieved
* @Default Icon: action:freeze_user
*/
    public static string getIconName(string sobjectName)
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
        return u!=null?u:'action:freeze_user';
    }
    /*Method Used to deleted record of any Sobject
* @Params: recordId of any object record and its name in objName
* @Return : Delete Status of the record 
*/
    @AuraEnabled
    public static string  deleterecord (string recordId,string objName){
        string resultmsg = 'success';
        try{
            sObject sObj = Schema.getGlobalDescribe().get(objname).newSObject();
            sobj.Id =recordId;
            delete sObj;
        }
        catch(Exception ex){
            system.debug(ex.getMessage()+'--'+ex.getStackTraceString());
            resultmsg = ex.getMessage();
        }
        return resultmsg;
    }
    
    public class responseWrapper{
        @auraEnabled
        public string objectIcon='';
        @auraEnabled
        public List<FieldStructure> fStruct= new List<FieldStructure>();
        @auraEnabled 
        public boolean iconExist = true; // it will be false for Account/Lead/Contact as their profile photo can be shown using Twitter/Youtube
        @auraEnabled
        public String sobjectName;
        @auraEnabled 
        public String parentField;
        @auraEnabled
        public list<Sobject> resultData = new List<Sobject>();
        @auraEnabled 
        public string serverStatus='success';
        @auraEnabled 
        public string recordIdUsed;
    }
    public class FieldStructure{
        @auraEnabled
        public string label;
        @auraEnabled 
        public string apiName;
        @auraEnabled 
        public string fieldType;
        @auraEnabled 
        public string objName;
        
        public FieldStructure(string label,string apiName,string fieldType,string objName){
            this.label = label;
            this.apiName = apiName;
            this.fieldType = fieldType;
            this.objName = objName;
        }
    }
}