/*
* Copyright (c) 2018, salesforce.com, inc.
* All rights reserved.
* SPDX-License-Identifier: BSD-3-Clause
* For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
*/

/*********************************************************************************
**   Project :- Navigation & SDG  
**  Version Date               (DD-MM-YYYY)          Author  Description of Action
**  1.3(Phase4)               29-01-2020             RahulK  Get My Team Filter values and return User Ids according to current user Team.
**  1.3(Phase4-InlineEdit)    14-02-2020             RahulK  Method for Save InlineEdit Value 
*********************************************************************************/
public with sharing class sdgController {
    public static String myTeamFilterRegex = '<<+([a-zA-Z]\\w+)>>';
    public static String authToken;
    public static Set<String> requiredLayoutFields;
    
    @AuraEnabled
    public static string GetNamespace()
    {
        return JSON.serialize( sdgNamespaceUtility2.GetNamespace());
    }
    
    @AuraEnabled
    public static String GetSDGInitialLoad(String ParentRecordID, String SDGTag, String RelationshipName, String FieldSetName, integer DefaultPageSize)
    {
        //Create response object
        SDGInitialLoad initial = new SDGInitialLoad();
        // Salesforce bug with Lightning serializer requires re-casting this value
        //https://salesforce.stackexchange.com/questions/108355/limit-expression-must-be-of-type-integer-error-when-using-apex-variable-in-soq/108423#108423
        try {
            DefaultPageSize = Integer.valueOf(DefaultPageSize);
        }
        catch (Exception ex)
        {
            throw new AuraHandledException('Invalid DefaultPageSize provided');
        }
        
        system.debug('sdgController:GetSDGInitialLoad:' + ParentRecordID + ':' + SDGTag + ':' + RelationshipName + ':' + FieldSetName);
        try
        {
            SDG newSDG = SDGDataProviderFactory.LoadSDG(SDGTag, ParentRecordId, RelationshipName, FieldsetName);
            //Create a full request:
            SDGRequest req = new SDGRequest();
            
            if (!String.isBlank(SDGTag)
                //Changes to apply filter only when remember filter is checked ~Akash
                && (newSDG.rememberFilter != null && newSDG.rememberFilter))
            {
                req = sdgPreferences.GenerateRequestWithFilters(newSDG, ParentRecordID, SDGTag);
            } 
            req.RelationshipName = RelationshipName;
            req.FieldSetName = FieldSetName;
            req.ParentRecordID = ParentRecordID;
            req.SDGTag = SDGTag;
            req.PageSize = DefaultPageSize;
            
            SDGResult result = sdgDataProviderFactory.getData( req, newSDG);
            //Blank out the internal data to save payload:
            //newSDG.InternalData = null;
            
            //build response object:
            initial.SDGObject = newSDG;
            initial.results = result;
            initial.isError = false;
        }
        
        catch (SDGException ex)
        {
            initial.ErrorMessage = ex.getMessage();
            initial.isError = true;
        }
        catch (Exception standardex)
        {
            initial.ErrorMessage = standardex.getMessage();
            initial.isError = true;
        }
        return JSON.serialize(initial);
    }
    
    @AuraEnabled
    public static string getSDGResult(String jsonrequest)
    {
        SDGResult results = new SDGResult();
        
        String resultsstring = '';
        string sdgTag = '';
        try
        {
            system.debug('sdgController:getSDGResult: getting request');
            SDGRequest request = (SDGRequest)JSON.deserialize(jsonrequest, SDGRequest.class);
            sdgTag = request.SDGTag;
            system.debug('sdgController:getSDGResult: getting result');
            
            results = sdgDataProviderFactory.getData(request);
            
            results.isError=false;
        }
        catch (Exception ex)
        {
            system.debug('sdgController:getSDGResult: Exception: ' + ex.getMessage() );
            results.ErrorMessage = ex.getMessage();
            
            //START : Delete preferences in case invalid filter is applied
            if(results.ErrorMessage.containsIgnoreCase('Unable to query:')){
                sdgPreferences.deletePreference(sdgTag);
            }
            //END
            
            results.isError = true;
        }
        return JSON.serialize(results);
    }
    
    //Method to create map of grouped values for each column of SDG
    @AuraEnabled
    public static map<string,string> prepareDataForRow(String query,String groupingQuery,String sdgFieldId,boolean DisableSharing){
        system.debug('disable sharing: ' + DisableSharing);
        Map<String,string> mapFieldIdRecordIdToData = new Map<String,string>();
        if(DisableSharing){
            groupingWithoutSharing gWS = new sdgController.groupingWithoutSharing();
            mapFieldIdRecordIdToData = gWS.prepareData(query,groupingQuery,sdgFieldId);
        }
        else{
            groupingWithSharing gWS = new sdgController.groupingWithSharing();
            mapFieldIdRecordIdToData = gWS.prepareData(query,groupingQuery,sdgFieldId);
        }
        return mapFieldIdRecordIdToData;     
    }
    
    /*START Code 
Added by: Sameer Rath 
Purpose: Run logic with & without sharing*/
    public with sharing class groupingWithSharing {
        public map<string,string> prepareData(String query,String groupingQuery,String sdgFieldId){
            System.debug('groupingQuery'+groupingQuery);
            return sdgNamespaceUtility2.prepareGroupingData(query,groupingQuery,sdgFieldId);
        }
    }
    
    private without sharing class groupingWithoutSharing{
        public map<string,string> prepareData(String query,String groupingQuery,String sdgFieldId){
            return sdgNamespaceUtility2.prepareGroupingData(query,groupingQuery,sdgFieldId);
        }
    }
    
    /* End Code - Sameer Rath */
    
    /***************************************************************************************************** 
* @Description  : Return User Ids according to current user Team.
* @Parameter    : Get My Team Filter values
*                
*****************************************************************************************************/
    @AuraEnabled
    public static string getMyTeamFilter(String myTeamFilter) {
        String newMyTeamFilter;
        
        if (String.isNotBlank(myTeamFilter)) {
            String regex = myTeamFilterRegex;
            Pattern regexPattern = Pattern.compile(regex);
            Matcher regexMatcher = regexPattern.matcher(myTeamFilter);
            
            if (regexMatcher.find() && regexMatcher.groupCount() > 0) {
                String fieldName = regexMatcher.group(1);
                Id userId = UserInfo.getUserId();
                User user = Database.query('SELECT Id, ' + fieldName + ' FROM User WHERE Id =:userId');
                //Add check for team value  for bug(00028622) fixing in V1.3 Phase-4 By RahulK
                String sTeamValue = ''; 
                if(String.isNotEmpty(string.valueof(user.get(fieldName))))
                {  
                    sTeamValue = string.valueof(user.get(fieldName));  
                    sTeamValue = String.escapeSingleQuotes(sTeamValue); //Handle single quote for my Team value  for bug(00028624) fixing in V1.3 Phase-4 By RahulK 
                }
                if (myTeamFilter.startsWithIgnoreCase('Id IN (')) {
                    //newMyTeamFilter = 'SELECT Id FROM User WHERE ' + fieldName + ' = \'' + user.get(fieldName) + '\'';
                    newMyTeamFilter = 'SELECT Id FROM User WHERE ' + fieldName + ' = \'' +sTeamValue+ '\'';
                    
                } else {
                    //newMyTeamFilter = myTeamFilter.replaceAll(regex, (String) user.get(fieldName));
                    sTeamValue = String.escapeSingleQuotes(sTeamValue); //Handle single quote for my Team value  for bug(00028624) fixing in V1.3 Phase-4 By RahulK
                    newMyTeamFilter = myTeamFilter.replaceAll(regex, sTeamValue);
                } 
                
            }
        }
        return JSON.serialize(newMyTeamFilter);
    }
    
    //Method to store expand collapse state on SdgPreference
    @AuraEnabled
    public static void updateSdgPreference(String sdgTag,boolean isExpanded){
        sdgPreferences.updatePreference(sdgTag,isExpanded);
    }
    
    //Method to get expand collapse state from SdgPreference
    @AuraEnabled
    public static Boolean getSdgPreference(String sdgTag){
        return sdgPreferences.getPreference(sdgTag);
    }
    /***************************************************************************************************** 
* @Description  : Method called when we save want to inline edit value
@Parameter      : Current Sdg ObjectName,SdgId,and updated value in object(Json)
Version         : 1.3 Phase4(InlineEdit)
*****************************************************************************************************/
    @AuraEnabled
    public static String saveUpdatedRecords(String sObjectName, String sdgId, Map<String, Object> updatedRecordsMap) {
        List<SObject> recordsToUpdate = new List<SObject>();
        List<SObject> errorRecordsToUpdate = new List<SObject>();
        sObject recToUpdate;
        Map<Id, String> errorMap = new Map<Id, String>();
        Map<Id, Map<String, Set<String>>> recTypeIdToFieldsMap = new Map<Id, Map<String, Set<String>>>();
        Map<Id, Set<String>> recTypeIdToRequiredFields = new Map<Id, Set<String>>();
        
        for (String rowId : updatedRecordsMap.keySet()) {
            recToUpdate = Schema.getGlobalDescribe().get(sObjectName).newSObject();
            recToUpdate.Id = rowId;
            Map<Object, Object> recordMap = (Map<Object, Object>) updatedRecordsMap.get(rowId);
            Map<Object, Object> fieldsMap = (Map<Object, Object>) recordMap.get('fields');
            String errorMessage = '';
            
            Id recordTypeId = (Id) recordMap.get('recordTypeId');
            
            if (!recTypeIdToFieldsMap.containsKey(recordTypeId)) {
                recTypeIdToFieldsMap.put(recordTypeId, getEditableFields(sObjectName, recordTypeId));
                recTypeIdToRequiredFields.put(recordTypeId, requiredLayoutFields);
            }
            
            for (Object sdgFieldId : fieldsMap.keySet()) {
                Map<Object, Object> fieldMap = (Map<Object, Object>) fieldsMap.get((String) sdgFieldId);
                String fieldType = String.valueOf(fieldMap.get('fieldType'));
                String fieldValue = String.valueOf(fieldMap.get('updatedValue'));
                String fieldName = String.valueOf(fieldMap.get('fieldName'));
                
                try {
                    if (recTypeIdToFieldsMap.get(recordTypeId).containsKey(fieldName)) {
                        if (fieldType == 'INTEGER') {
                            recToUpdate.put(fieldName, Integer.valueOf(fieldValue));
                        } else if (fieldType == 'DATETIME') {
                            if (String.isBlank(fieldValue)) {
                                recToUpdate.put(fieldName, null);
                            } else {
                                recToUpdate.put(fieldName, Datetime.valueOfGMT(fieldValue.replace('T', ' ').replace('Z', '')));
                            }
                        } else if (fieldType == 'DATE') {
                            if (String.isBlank(fieldValue)) {
                                recToUpdate.put(fieldName, null);
                            } else {
                                recToUpdate.put(fieldName, Date.valueOf(fieldValue));
                            }
                        } else if (fieldType == 'BOOLEAN') {
                            recToUpdate.put(fieldName, Boolean.valueOf(fieldValue));
                        } else if (fieldType == 'CURRENCY' || fieldType == 'PERCENT' 
                                   || fieldType == 'DOUBLE') {
                                       
                                       if (String.isBlank(fieldValue)) {
                                           recToUpdate.put(fieldName, null);
                                       } else {
                                           recToUpdate.put(fieldName, Double.valueOf(fieldValue));
                                       }
                                   } else if (fieldType == 'PICKLIST') {
                                       if (!String.isBlank(fieldValue) 
                                           && !recTypeIdToFieldsMap.get(recordTypeId).get(fieldName).contains(fieldValue)) {
                                               
                                               errorMessage += '"' + fieldValue + '" value is not available for [' + fieldName + '] field. ';
                                           }
                                       
                                       recToUpdate.put(fieldName, fieldValue);
                                   } else if (fieldType == 'MULTIPICKLIST') {
                                       if (String.isNotBlank(fieldValue)) {
                                           Set<String> invalidValues = new Set<String>();
                                           
                                           for (String value : fieldValue.split(';')) {
                                               if (!recTypeIdToFieldsMap.get(recordTypeId).get(fieldName).contains(value)) {
                                                   invalidValues.add(value);
                                               }
                                           }
                                           
                                           if (!invalidValues.isEmpty()) {
                                               String invalidValuesString = String.join(new List<String>(invalidValues), '; ');
                                               if (invalidValues.size() == 1) {
                                                   errorMessage += '"' + invalidValuesString + '" value is not available for [' + fieldName + '] field. ';
                                               } else {
                                                   errorMessage += '"' + invalidValuesString + '" values are not available for [' + fieldName + '] field. ';
                                               }
                                           }
                                       }
                                       
                                       recToUpdate.put(fieldName, fieldValue);
                                   } else {
                                       recToUpdate.put(fieldName, fieldValue);
                                   }
                    } else {
                        errorMessage += 'You don\'t have permission to edit [' + fieldName + '] field. ';
                    }
                    
                    // Added to resolve Bug: 00028439, 00028485
                    if (String.isBlank(fieldValue)
                        && (recTypeIdToRequiredFields.get(recordTypeId).contains(fieldName)
                            || fieldName.equalsIgnoreCase('Name'))) {
                                errorMessage += '[' + fieldName + '] field is required. ';
                            }
                } catch (Exception ex) {
                    errorMessage += 'Invalid data entered for [' + fieldName + '] field. ';
                }
            }
            
            if (!String.isBlank(errorMessage)) {
                errorMap.put(rowId, errorMessage);
                errorRecordsToUpdate.add(recToUpdate);
            } else {
                recordsToUpdate.add(recToUpdate);
            }
        }
        
        if (!errorRecordsToUpdate.isEmpty()) {
            // Process records with pagelayout error
            Integer index = 0;
            Savepoint sp = Database.setSavepoint();
            
            for (Database.SaveResult result : Database.update(errorRecordsToUpdate, false)) {
                if (!result.isSuccess()) {
                    Id recordId = errorRecordsToUpdate[index].Id;
                    String errorMessage = '';
                    
                    if (errorMap.containsKey(recordId)) {
                        errorMessage = errorMap.get(recordId);
                    }
                    for (Database.Error error : result.getErrors()) {
                        errorMessage += error.getMessage() + '. ';
                    }
                    errorMap.put(recordId, errorMessage);
                }
                index++;
            }
            
            Database.rollback(sp);
        }
        
        if (!recordsToUpdate.isEmpty()) {
            Integer index = 0;
            
            // Process records with no pagelayout error
            for (Database.SaveResult result : Database.update(recordsToUpdate, false)) {
                if (!result.isSuccess()) {
                    Id recordId = recordsToUpdate[index].Id;
                    String errorMessage = '';
                    
                    if (errorMap.containsKey(recordId)) {
                        errorMessage = errorMap.get(recordId);
                    }
                    for (Database.Error error : result.getErrors()) {
                        errorMessage += error.getMessage() + '. ';
                    }
                    errorMap.put(recordId, errorMessage);
                }
                index++;
            }
        }
        
        if (!errorMap.isEmpty()) {
            return JSON.serialize(errorMap);
        }
        
        return JSON.serialize('SUCCESS');
    }
    
    public static Map<String, Set<String>> getEditableFields(String sObjectName, Id recordTypeId) {
        Map<String, Set<String>> fieldsMapToReturn = new Map<String, Set<String>>();
        requiredLayoutFields = new Set<String>();
        
        String domain = URL.getSalesforceBaseUrl().toExternalForm();
        if (recordTypeId == null) {
            recordTypeId = '012000000000000AAA';
        }
        String endPoint = '/services/data/v47.0/sobjects/' + sObjectName + '/describe/layouts/' + recordTypeId;
        
        if (authToken == null) {
            authToken = 'Bearer ' + CommonCalloutUtility.getSalesforceSessionId();
        }
        
        CommonLayoutWrapper layout
            = CommonLayoutWrapper.parse(CommonCalloutUtility.fireRequest(domain, endPoint, authToken, 'GET'));
        
        for (CommonLayoutWrapper.EditLayoutSections editLayoutSection : layout.editLayoutSections) {
            for (CommonLayoutWrapper.LayoutRows layoutRow : editLayoutSection.layoutRows) {
                for (CommonLayoutWrapper.LayoutItems layoutItem : layoutRow.layoutItems) {
                    if (layoutItem.editableForUpdate && layoutItem.editableForNew) {
                        for (CommonLayoutWrapper.LayoutComponents layoutComponent : layoutItem.layoutComponents) {
                            if (layoutComponent.value != null) {
                                if (!layoutComponent.details.picklistValues.isEmpty()) {
                                    Set<String> availablePicklistValues = new Set<String>();
                                    for (CommonLayoutWrapper.PicklistValues picklistValue : layoutComponent.details.picklistValues) {
                                        availablePicklistValues.add(picklistValue.value);
                                    }
                                    fieldsMapToReturn.put(layoutComponent.value, availablePicklistValues);
                                } else {
                                    fieldsMapToReturn.put(layoutComponent.value, null);
                                }
                                
                                if (layoutItem.required) {
                                    requiredLayoutFields.add(layoutComponent.value);
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return fieldsMapToReturn;
    }
}