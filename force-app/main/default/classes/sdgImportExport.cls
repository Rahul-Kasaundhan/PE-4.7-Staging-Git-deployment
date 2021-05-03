/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
public with sharing class sdgImportExport {
    static integer CURRENTVERSION = 1;
    private static string nameSpace = sdgNamespaceUtility2.GetNamespace(); // to get namespace PEv4.7 by Aditya
    @AuraEnabled
    public static String ExportSDG(String Id)
    {
        sdgExportFormat pak = new sdgExportFormat();
        pak.version = CURRENTVERSION;
        String sdgQuery = addFieldsToQuery('select name, @SDG@ (select name @SDG_FIELD@ from SDGFields__r),  (select name @SDG_ACTION@ from SDG_Actions__r)  from sdg__c where id = :Id limit 1'); //changed query to prevent duplicate fields exception by Aditya PEv4.7 23 April 2021
        sdg__c sdg = (sdg__c)database.query(sdgQuery)[0];
        sdg.Id = null;
        for(sdg_field__c field : sdg.SDGFields__r)
        {
            field.id = null;
            field.sdg__c = null;
        }
        for(sdg_action__c action : sdg.SDG_Actions__r)
        {
            action.id = null;
            action.sdg__c = null;
        }
        pak.sdg = sdg;
        String payload = JSON.serialize(pak);
        return payload;
    }
    @AuraEnabled
    public static String ImportSDG(String payload)
    {

        String Id;
        sdgExportFormat pak;
        try
        {
            pak = (sdgExportFormat)JSON.deserializeStrict(payload, sdgExportFormat.class);
        }
        catch (Exception ex)
        {
            throw new AuraHandledException('Unable to parse payload.  Please check you copied correctly.');
        }

        if (pak.version == CURRENTVERSION)
        {
            try
            {
                sdg__c sdg = pak.sdg;
                insert sdg;
                for(sdg_action__c action : sdg.SDG_Actions__r)
                {
                    action.sdg__c = sdg.id;
                }
                for(sdg_field__c field : sdg.SDGFields__r)
                {

                    field.sdg__c = sdg.id;
                }
                insert sdg.SDG_Actions__r;
                insert sdg.SDGFields__r;
                ID = sdg.Id;
            }
            catch (Exception ex)
            {
                throw new AuraHandledException('Unable to insert payload: ' + ex.getMessage());
            }
        }
        else
        {
            throw new AuraHandledException('Invalid version provided - you cannot import this version into this org.');
        }
        return ID;
    }
    public static SDG__c GetSDG(String payload)
    {

        String Id;
        sdgExportFormat pak;
        try
        {
            pak = (sdgExportFormat)JSON.deserializeStrict(payload, sdgExportFormat.class);
        }
        catch (Exception ex)
        {
            system.debug(ex.getMessage());
            throw new sdgException('sdgImportExport:GetSDG: Unable to parse payload.  Please check you copied correctly.');
        }
        SDG__c sdg;

            try
            {
                sdg = pak.sdg;

            }
            catch (Exception ex)
            {
                throw new AuraHandledException('Unable to insert payload: ' + ex.getMessage());
            }

        return sdg;
    }
    
    //Method to get all custom fields of object
    public static String addFieldsToQuery(String sdgQuery){
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        string finalQueryString;
        String sdgFields = getAllFieldsString(sdgQuery,nameSpace+'SDG__C',schemaMap); //added nameSpace by Aditya PEv4.7 
        String sdgFieldFields = getAllFieldsString(sdgQuery,nameSpace+'SDG_Field__C',schemaMap); //added nameSpace by Aditya PEv4.7 
        String sdgActionFields = getAllFieldsString(sdgQuery,nameSpace+'SDG_Action__C',schemaMap); //added nameSpace by Aditya PEv4.7 
        finalQueryString = sdgQuery.replace('@SDG@', sdgFields+',').replace('@SDG_FIELD@', (String.isNotBlank(sdgFieldFields)?',':'')+sdgFieldFields).replace('@SDG_ACTION@',(String.isNotBlank(sdgActionFields)?',':'')+sdgActionFields);
        return finalQueryString;
    }
    //To get Fields
    public static String getAllFieldsString(String queryString, String sobjName, Map <String, Schema.SObjectType> schemaMap){
        List<String> lstFields = new List<String>();
        String fieldStr = '';
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get(sobjName).getDescribe().fields.getMap();
        for (String fieldName: fieldMap.keySet()) {
            if(fieldName.endsWithIgnoreCase('__c') && !queryString.containsIgnoreCase(fieldName)){
                lstFields.add(fieldName);    
            }
            
        }
        fieldStr = String.join(lstFields,',');
        return fieldStr;
    }
}