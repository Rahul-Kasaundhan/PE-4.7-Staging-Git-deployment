/*
* Copyright (c) 2018, salesforce.com, inc.
* All rights reserved.
* SPDX-License-Identifier: BSD-3-Clause
* For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
*/
public class sdgPreferences {
    
    public static sdgRequest GenerateRequestWithFilters(SDG sdg, String ParentRecordID, String SDGTag)
    {
        
        //Create a request:
        SDGRequest req = new SDGRequest();
        req.ParentRecordID = ParentRecordID;
        req.SDGTag = SDGTag;
        
        system.debug('sdgPreferences:GenerateRequestWithFilters');
        if (sdg.InternalData != null)
        {
            if (sdg.internalData.sUniqueKey!=null)
            {
                //Get the user preferences
                List<sdg_preferences__c> oldpref= [select filters__c from sdg_preferences__c where user__c = :UserInfo.getUserID() and sdgKey__c = :sdg.InternalData.sUniqueKey];
                if (oldpref.size()>0)
                {
                    try
                    {
                        system.debug('sdgPreferences:GenerateRequestWithFilters: retrieving filters');
                        req.filters = (List<SDGFilter>)JSON.deserialize(oldpref[0].filters__c, List<SDGFilter>.class);
                        Map<String, SDGFilter> mpFilters = new Map<String, SDGFilter>();
                        for (SDGFilter filter : req.filters)
                        {
                            mpFilters.put(filter.SDGFieldID, filter);
                        }
                        for(SDGField field : sdg.SDGFields)
                        {
                            if (mpFilters.containsKey(field.ID))
                                field.Preferences = mpFilters.get(field.ID);
                        }
                        
                    }
                    catch(exception ex)
                    {
                        //ignore this - caused by invalid/out of date filters usually
                    }
                }
            }
        }
        return req;
    }
    
    public static void SaveFilters(SDGRequest request, String sUniqueKey)
    {
        //Save the Filters:
        String filters = JSON.serialize(request.Filters);
        Sdg_preferences__c pref = new sdg_preferences__c();
        if(Schema.sObjectType.Sdg_preferences__c.fields.User__c.isCreateable()){ // added for security fix PEv4.7 by Aditya 5 April 2021
            pref.User__c = UserInfo.getUserId();
        }
        if(Schema.sObjectType.Sdg_preferences__c.fields.Filters__c.isCreateable()){ // added for security fix PEv4.7 by Aditya 5 April 2021
            pref.Filters__c = filters;
        }
        if(Schema.sObjectType.Sdg_preferences__c.fields.sdgKey__c.isCreateable()){ // added for security fix PEv4.7 by Aditya 5 April 2021
            pref.sdgKey__c = sUniqueKey;
        }
        if (String.isNotBlank(sUniqueKey))
        {
            try
            {
                //Can't upsert using multiple columns so delete existing
                if ( SDGSecurity.canQuery('sdgPreferences:SaveFilters', 'sdg_preferences__c','filters__c,user__c,sdgKey__c', '',sdgNamespaceUtility2.GetNamespace(), false))
                {
                    
                    List<sdg_preferences__c> oldpref= [select id,isExpanded__c from sdg_preferences__c where user__c = :UserInfo.getUserID() and sdgKey__c = :sUniqueKey];
                    
                    if(oldpref.size()>0)
                        if(Schema.sObjectType.Sdg_preferences__c.fields.isExpanded__c.isCreateable()){ // added for security fix PEv4.7 by Aditya 5 April 2021
                            pref.isExpanded__c = oldpref[0].isExpanded__c;
                        }
                    if (Schema.sObjectType.sdg_preferences__c.isDeletable()){ 
                    	delete oldpref;
                    }
                    if (Schema.sObjectType.sdg_preferences__c.isCreateable()){
                        insert pref;
                    }
                }
            }
            catch (DMLException ex)
            {
                //this is probably a race condition on aura calls so ignore
                system.debug('sdgPreferences:SaveFilters: DMLException - ignoring');
            }
            
        }
    }
    
    public static void updatePreference(String sdgTag, boolean isExpanded)
    {
        if(String.isNotBlank(sdgTag)){
            list<sdg__c> listSdg = [SELECT id FROM sdg__c WHERE sdg_tag__c =:sdgTag];
            if(listSdg.size() > 0){
                List<sdg_preferences__c> listPref= [select id from sdg_preferences__c where user__c = :UserInfo.getUserID() and sdgKey__c = :listSdg[0].id];
                if(listPref.size()>0){
                    listPref[0].isExpanded__c = isExpanded;    
                    update listPref[0];
                }
                
            }
        }
    }
    public static boolean getPreference(String sdgTag)
    {
        system.debug('sdgTag'+sdgTag);
        if(String.isNotBlank(sdgTag)){
            list<sdg__c> listSdg = [SELECT id FROM sdg__c WHERE sdg_tag__c =:sdgTag];
            if(listSdg.size() > 0){
                List<sdg_preferences__c> listPref= [select id,isExpanded__c from sdg_preferences__c where user__c = :UserInfo.getUserID() and sdgKey__c = :listSdg[0].id];
                if(listPref.size()>0){
                    return listPref[0].isExpanded__c;
                }else{
                    //create a record
                    sdg_preferences__c newPref = new sdg_preferences__c(isExpanded__c=true,user__c = UserInfo.getUserID(),sdgKey__c = listSdg[0].id);
                    insert newPref;
                    return true;
                }
            }else{
                return true;
            }
        }else{
            return true;
        }
    }
    
    /* Method to delete preferences in case there is an error in apply filter(Phase 3 fix for inner query in soql queries) 
* Parameters: string sdgtag for the sdg whose preferences are to be deleted
* */ 
    public static void deletePreference(String sdgTag)
    {
        if(String.isNotBlank(sdgTag)){
            if(sdgTag.containsIgnoreCase('CustomObject:')){
                sdgTag = sdgTag.split(':')[1];
            }
            list<sdg__c> listSdg = [SELECT id FROM sdg__c WHERE sdg_tag__c =:sdgTag];
            if(listSdg.size() > 0){
                List<sdg_preferences__c> listPref= [select id from sdg_preferences__c where user__c = :UserInfo.getUserID() and sdgKey__c = :listSdg[0].id];
                if(listPref.size()>0){
                    delete listPref;
                }
                
            }
        }
    }
}