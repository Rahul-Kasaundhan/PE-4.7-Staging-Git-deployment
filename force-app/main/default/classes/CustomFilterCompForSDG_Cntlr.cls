/*********************************************************************************
** Project :- Navigation & SDG  
** Version Date(DD-MM-YYYY)       Author  Description of Action
**  1.3    28-01-2020             RahulK  Phase4:- Get string query in parameter and return picklist Values in wrapper
*********************************************************************************/
public class CustomFilterCompForSDG_Cntlr {
    
    @AuraEnabled
   public static WrapperClass getFieldValues(String query1, String query2, String query3, String query4){
        WrapperClass wr = new WrapperClass();
		try{
            wr.picklist1 = new List<String>();
            wr.picklist2 = new List<String>();
            wr.picklist3 = new List<String>();
            wr.picklist4 = new List<String>();
            wr.picklist1 = getPicklistValues(query1);
			wr.picklist2 = getPicklistValues(query2);
            wr.picklist3 = getPicklistValues(query3);
            wr.picklist4 = getPicklistValues(query4);
            return wr;
        }catch(Exception e){
            return wr;
        }
    }
    
   private static List<String> getPicklistValues(String queryStr){
        List<String> picklistFromRecord = new List<String>();
        try{
            String fieldToDisplay = queryStr.touppercase().split(' FROM')[0].split('SELECT ')[1].split(',')[0].trim();
            //Get the records
            List<sObject> sObjectList = new List<Sobject>();
            sObjectList = database.query(queryStr);
            for(sObject sObj : sObjectList){
                picklistFromRecord.add(String.valueOf(sObj.get(fieldToDisplay)));
            }
            return picklistFromRecord;
        }catch(Exception ex){
            system.debug('exception '+ex.getMessage());
            system.debug('Stack trace '+ex.getStackTraceString());
            return picklistFromRecord;
        }
    }
    public class WrapperClass{
        @AuraEnabled
        public List<String> picklist1{get;set;}
        @AuraEnabled
        public List<String> picklist2{get;set;}
        @AuraEnabled
        public List<String> picklist3{get;set;}
        @AuraEnabled
        public List<String> picklist4{get;set;}
        
    }
 }