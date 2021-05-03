/*
* Copyright (c) 2018, salesforce.com, inc.
* All rights reserved.
* SPDX-License-Identifier: BSD-3-Clause
* For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
*/
public class sdgNamespaceUtility2 {
    //Self referential finds the current namespace
    private static string namespace = '';
    private static boolean isloaded = false;
    public static Set<Id> userIdsForMyTeam = new Set<Id>(); 
    public static string GetNamespace()
    {
        if (!isloaded)
        {
            ApexClass ac = [SELECT Id, NamespacePrefix,name FROM ApexClass where name = 'sdgNamespaceUtility2' limit 1];
            if (ac!=null)
            {
                if (String.isNotBlank(ac.NamespacePrefix))
                {
                    namespace = ac.NamespacePrefix + '__';
                }
                isloaded = true;
            }
            
        }
        return namespace;
        
    }
    
    // Added By Sameer get all the grouping query data for SDG
    public static map<string,string> prepareGroupingData(String query,String groupingQuery,String sdgFieldId){
        String fieldToCount; 
        String objectName;
        String fieldApi;  
        String fieldType;
        String Regex = '\\(+([a-zA-Z]\\w+)\\)';
        //To make mapping field dynamic
        String parentFieldToAggregate = 'Id'; 
        //Making URL for primary child
        String primaryid, primaryName;
        Boolean isChildQuery = false;
        
        Set<String> setObjId = new Set<String>();
        
        Map<String,string> mapRecordIdToData = new Map<String,string>();
        Map<String,string> mapFieldIdRecordIdToData = new Map<String,string>();
        
        List<Sobject> listResultData = database.query(query);
        List<AggregateResult> listAggregateResult = new list<AggregateResult>();
        
        //Set is child query flag
        if(!groupingQuery.containsIgnoreCase(' group ')){
            isChildQuery = true;
        }
        //Get fields to count
        if(String.isNotBlank(groupingQuery) && groupingQuery.split('<<').size() > 1){
            fieldToCount = groupingQuery.split('<<')[1].split('>>')[0].trim();
            //To store field to be used for grouping (by default ID)
            mapFieldIdRecordIdToData.put(sdgFieldId+'groupBy','Id');
            if(fieldToCount.contains(',')){
                if(String.isNotBlank(fieldToCount.split(',')[1])){
                    parentFieldToAggregate = fieldToCount.split(',')[1].trim();
                    //Override field to be used for grouping 
                    mapFieldIdRecordIdToData.put(sdgFieldId+'groupBy',parentFieldToAggregate);
                }
                fieldToCount = fieldToCount.split(',')[0].trim();
            }
        }	
        
        //Prepare set of all id's to query on related objects
        for(sobject o : listResultData){
            setObjId.add(String.valueOf(o.get(parentFieldToAggregate)));
        }
        
        //If groupingQuery is not blank(i.e. child records to be queried to get related data)
        if(String.isNotBlank(groupingQuery) && groupingQuery.split('<<').size() > 1){
            String groupedBy = groupingQuery.split('<<')[1].split('>>')[0];
            groupingQuery = groupingQuery.replace('<<'+groupedBy+'>>',' :setObjId');
            //Add limit to query if it doesn't exist
            if(!groupingQuery.containsIgnoreCase(' limit ')){
                groupingQuery += ' LIMIT 50000';
            }
            
            if(!isChildQuery){
                string tempGroupingQuery = groupingQuery.toUpperCase().split('FROM ')[0];
                objectName = groupingQuery.toUpperCase().split('FROM ')[1].split('WHERE')[0];
                Pattern regexPattern = Pattern.compile(Regex);
                Matcher regexMatcher = regexPattern.matcher(tempGroupingQuery);
                if (regexMatcher.find() && regexMatcher.groupCount() > 0) {
                    fieldApi = regexMatcher.group(1);
                }
                
                fieldType = checkFieldType(objectName,fieldApi);
                listAggregateResult = database.query(groupingQuery);
                for(AggregateResult ag : listAggregateResult){
				   if(String.valueOf(ag.get(fieldToCount)) != null) //Condition added for bug fixing (00028539) in v1.3 Phase-4 by Rahulk
                    mapRecordIdToData.put(String.valueOf(ag.get(fieldToCount)),STRING.valueOf(ag.get('expr0')));
                }
            }else{
                List<Sobject> listChildRecords = database.query(groupingQuery);
                //To avoid invalid id's in case child query contains sub query
                string tempGroupingQuery = groupingQuery.toUpperCase().split('FROM ')[0];
                Boolean showHyperLink = false;
                if(tempGroupingQuery.split(',').size() > 2){
                    showHyperLink = true;
                    primaryid = tempGroupingQuery.split(',')[2].split(',')[0].trim();
                }
                primaryName = tempGroupingQuery.split(',')[1].split(',')[0].trim();
                
                for(sobject sobj : listChildRecords){
                    if(showHyperLink){
                        mapRecordIdToData.put(String.valueOf(sobj.get(fieldToCount)),'<a href=\'\\'+STRING.valueOf(getDataValueFromSobj(sobj,primaryid))+'\'>'+STRING.valueOf(getDataValueFromSobj(sobj,primaryName)) + '</a>');
                    }else{
                        mapRecordIdToData.put(String.valueOf(sobj.get(fieldToCount)),getDataValueFromSobj(sobj,primaryName));
                    }
                }
            }
            
            for(Sobject so : listResultData){
                if(mapRecordIdToData.containskey(String.valueOf(so.get(parentFieldToAggregate))) && 
                   mapRecordIdToData.get(String.valueOf(so.get(parentFieldToAggregate))) != null && 
                   //Bug Fixing(00027958): added check for &nbsp for aggregate query result by Sameeksha Sahu
                   mapRecordIdToData.get(String.valueOf(so.get(parentFieldToAggregate))) != '&nbsp;'){
                       mapFieldIdRecordIdToData.put(sdgFieldId+String.valueOf(so.get(parentFieldToAggregate)),mapRecordIdToData.get(String.valueOf(so.get(parentFieldToAggregate))));
                   }else{
                       if(String.valueOf(so.get(parentFieldToAggregate)) != null){
                           //Check if result of GroupingQuery is date then display reslut otherwise blank for bugfixing(00028140)
                           if(fieldType=='DATE'|| fieldType=='DATETIME'){
                               mapFieldIdRecordIdToData.put(sdgFieldId+String.valueOf(so.get(parentFieldToAggregate)),'');
                           }else{
                               mapFieldIdRecordIdToData.put(sdgFieldId+String.valueOf(so.get(parentFieldToAggregate)),(!isChildQuery?'0':''));
                           }
                           
                       }else{
                           mapFieldIdRecordIdToData.put(sdgFieldId+'noData',(!isChildQuery?'0':''));
                       }
                   }
            }
        }
        return mapFieldIdRecordIdToData; 
    }
    
    //Get related data by parsing sobject
    public static string getDataValueFromSobj(Sobject sobj, string fieldToGet){
        String fieldValue;
        list<String> fieldPath = fieldToGet.split('\\.');
        for(Integer i=0;i<fieldPath.size()-1;i++){
            sobj = sobj.getSObject(fieldPath[i]);
        }
        fieldValue = String.valueOf(sobj.get(fieldPath.get(fieldPath.size()-1)));
        return fieldValue;
    }
    
    // used to get Record Id and record name after passing related Associations record Ids Set.
    public static Map<Id, Sobject> populateObjectToSobjectMap(set<String> relatedAssociations){
        try{
            
            Map<String, Schema.SObjectType> gd;
            Map<String,string> PrefixToObjNameMap = new Map<String,String>(); //Variable to store prefix ids to avoid describe calls for same object
            map<String,Set<Id>> ObjectnametoSetRecIdsMap = new map<String,Set<Id>>();
            map<Id,Sobject> mapIdtosobjectName = new map<Id,Sobject>();
            if(gd==null){
                gd =  Schema.getGlobalDescribe(); 
            }
            for(String relatedRecordId : relatedAssociations){
                //Get prefix to get object name
                String prefix = relatedRecordId.substring(0,3);
                String objectName = '';
                
                //Check if map already contains prefix object
                if(PrefixToObjNameMap.containsKey(prefix)){
                    //Store object name
                    objectName = PrefixToObjNameMap.get(prefix);
                    if(gd.get(objectName).getDescribe().isAccessible()){
                        //Check if objectToSetId contains object
                        if(ObjectnametoSetRecIdsMap.containsKey(objectName)){
                            Set<Id> tempSet = ObjectnametoSetRecIdsMap.get(objectName);
                            tempSet.add(relatedRecordId);
                            ObjectnametoSetRecIdsMap.put(objectName,tempSet);
                        }else{
                            ObjectnametoSetRecIdsMap.put(objectName,new Set<Id>{relatedRecordId});
                        }
                    }
                }
                //Else make describe call and add to map
                else{
                    objectName = findObjectNameFromRecordIdPrefix(prefix,gd);
                    if(gd.get(objectName).getDescribe().isAccessible()){
                        //Add object name and related id to map
                        ObjectnametoSetRecIdsMap.put(objectName, new Set<Id>{relatedRecordId});
                        //add prefix and object name value to map
                        PrefixToObjNameMap.put(prefix,objectName);
                    }
                }
                
                
            }
            
            if(ObjectnametoSetRecIdsMap != null){
                mapIdtosobjectName =  getSobjectRecords(ObjectnametoSetRecIdsMap);
            }
            
            return mapIdtosobjectName ;
        }
        catch(Exception ex){
            system.debug('Exception::'+ex.getLineNumber()+':'+ex);
            return null ;
        }
    }
    
    /***************************************************************************************************** 
* @Description  : Returns mapofId to sobject to get name of particluar record
* @Parameter    : Map of object name vs record ids for that object
*                
*****************************************************************************************************/
    public static Map<Id, Sobject> getSobjectRecords(Map<String, Set<id>> objNamevsRecIds){
        
        Map<Id, Sobject> recIDvsRecord = new Map<Id, Sobject>();
        try{
            for(String objName :objNamevsRecIds.keyset()){
                Set<id> recIds = objNamevsRecIds.get(objName);
                Map<Id, Sobject> tempRecIDvsRecord = new Map<Id, Sobject>(Database.query('SELECT Id, Name FROM '+objName+' WHERE Id IN '+':recIds'));
                if(tempRecIDvsRecord.size() > 0)
                    recIDvsRecord.putAll(tempRecIDvsRecord);
            }
            return recIDvsRecord;
        }catch(Exception ex){
            return null;
        }
    }
    
    
    /*****************************************************************************************************
* @Name         :   findObjectNameFromRecordIdPrefix
* @Description  :   Method to Get record name based on record id prefix
* @Param        :   idPrefix - id or prefix of record id
*                   gd  -   global describe from schema
*****************************************************************************************************/
    public static String findObjectNameFromRecordIdPrefix(String idPrefix, Map<String, Schema.SObjectType> gd){
        String objectName = '';
        try{
            //Get prefix from record ID assuming that at least 3 characters are passed
            //String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);
            
            //Loop through all the sObject types returned by Schema
            for(Schema.SObjectType stype : gd.values()){
                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();
                
                //Check if the prefix matches with requested prefix
                if(prefix!=null && prefix.equals(idPrefix)){
                    objectName = r.getName();
                    break;
                }
            }
        }catch(Exception e){
            System.debug(e);
        }
        return objectName;
    }
    
    /*****************************************************************************************************
* @Name         :   checkFieldType 
* @Description  :   Method to return type of field
* @Param        :   Get ObjectName and field Api and method return type of field  
*****************************************************************************************************/
    public static String checkFieldType(String objectName, String fieldName){
        String fieldType = '';
        try{
            SObjectType r = ((SObject)(Type.forName('Schema.'+objectName.trim()).newInstance())).getSObjectType();
            DescribeSObjectResult d = r.getDescribe();
            fieldType = String.valueOf(d.fields.getMap().get(fieldName).getDescribe().getType());
        }Catch(Exception e ){
            System.debug(e);          
        }
        return fieldType;
    }
}