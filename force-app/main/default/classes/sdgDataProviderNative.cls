/*
* Copyright (c) 2018, salesforce.com, inc.
* All rights reserved.
* SPDX-License-Identifier: BSD-3-Clause
* For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
*/
global with sharing class sdgDataProviderNative implements sdgIDataProvider {
    global static Boolean isUserSelectable()
    {
        return false;
    }
    global static SDGResult getData(SDG CoreSDG, SDGRequest request)
    {
        
        SDGResult result =  sdgQueryEngine.getSDGResultRaw(CoreSDG, request);
        return result;
    }
    
    global   SDG LoadSDG(String SDGTag, String ParentRecordId)
    {
        SDG CoreSDG = null;
        Set<String> relatedIdsset;
        sdgSecurity.CanQuery('sdgDataProviderNative:LoadSDG', 'SDG__c', 'sobjectname__c, parent_field_name__c, filter__c, default_sort__c, is_valid__c, All_Rows__c, DisableSharing__c', 'Id', sdgNamespaceUtility2.GetNamespace(), true);
        sdgSecurity.CanQuery('sdgDataProviderNative:GetSDGActions' , 'SDG_Action__c', 'event__c, action_order__c, Requires_Createable__c, requires_deletable__c, Requires_Editable__c, Action_Type__c, Event_Payload__c, Icon__c', 'id,name', sdgNamespaceUtility2.GetNamespace(), true);
        sdgSecurity.CanQuery('sdgDataProviderNative:GetSDGFields', 'SDG_Field__c', 'apiname__c,  FieldOrder__c, Field_Style__c, Hide_Filter__c, Override_Label__c', 'id,name', sdgNamespaceUtility2.GetNamespace(), true);
        //Related_Association_Query__c field add in in Phase3 CR by Akash(28-11-2019).
        // My_Teams_Records__c,Grouping_Field_API__c in sdg and  Filter_sequence__c in SDGFields  fields added in v1.3 Phase4 at (29-01-2020).
        //Added Manage_Field in query
        List<SDG__c> sdgs= [select id, Show_Icon__c, MyRecords__c, my_home__c, Remember_Filter__c, Highlight_Colors__c, sobjectname__c, parent_field_name__c, filter__c, List_View_Name__c,  default_sort__c, is_valid__c, All_Rows__c, DisableSharing__c, Related_Association_Query__c, My_Teams_Records__c,Grouping_Field_API__c,Enable_Inline_Edit__c,Enable_Manage_Field__c,
                            (select id, name, event__c, Requires_Createable__c, Requires_Editable__c, requires_deletable__c, Action_Type__c, Event_Payload__c, Icon__c, action_order__c  from sdg_actions__r), 
                            (select id, name, apiname__c,  FieldOrder__c, Field_Style__c, Hide_Filter__c, Override_Label__c, URL__c, grouping_query__c, Is_Hidden__c,color__c,Parent_Field_Name_Grouping__c,Filter_sequence__c, Image_field_API__c from SDGFields__r where is_valid_field__c =true) 
                            from SDG__c where SDG_Tag__c = :SDGTag ]; // Akash added URL__c and grouping_query__c field
        if (sdgs.size()!=1)
        {
            throw new SDGException('sdgDataProviderNative:LoadSDG: Invalid number of SDG results for name: ' + SDGTag + '. retrieved: ' + sdgs.size());
        }
        else
        {
            //Now we can load this:
            SDG__c e;
            e = sdgs[0];
            
            // logic to populate filter dynamically ~Akash
            if(e.List_View_Name__c != null && e.List_View_Name__c != ''){
                //As discussed with Anurag, commenting if else condition from code listview filter will always override filter field(20190521)
                /*if(e.filter__c != null && e.filter__c != ''){
					e.filter__c = e.filter__c + ' AND (' + getFilterString(e.List_View_Name__c, e.sobjectname__c) + ' ) ';
			}
			else{*/
                e.filter__c = getFilterString(e.List_View_Name__c, e.sobjectname__c);
                //}
            }
            // Check Related_Association_Query__c field the get result and replace with '<<relatedids>>' in Phase3 CR by Akash(28-11-2019). 
            if(String.isNotBlank(e.Related_Association_Query__c) && String.isNotBlank(e.Filter__c) && e.Filter__c.containsIgnoreCase('<<relatedIds>>')){
               sdgDatabase.setIdsString  = generateLikeClause(e.Related_Association_Query__c); //For Using store Related Association Query in v1.3 phase-4 at 23-04-2020 By Rahulk
                e.Filter__c = e.Filter__c.tolowercase().replace('<<relatedids>>',' :setIdsString');
                e.Filter__c =  '('+ e.Filter__c+')'; //Bug fixing(00028263) in Phase4 v1.3 CR by Rahulk(17-03-2020). 
            }
            if(String.isNotBlank(e.Filter__c)){
                e.Filter__c =  '('+ e.Filter__c+')'; //Bug fixing(00028263) in Phase4 v1.3 CR by Rahulk(17-03-2020).
            }
            
            //Replace userId expression with logged in user id
            if(e.My_Home__c && String.isNotBlank(e.MyRecords__c)){ // Placed here by Himanshu, for MyRecord Sub Query issue
                if(String.isBlank(e.filter__c)){
                    e.filter__c = '('+e.MyRecords__c.replaceAll('<<User.Id>>',UserInfo.getUserId())+')';
                }else{
                    e.filter__c = e.filter__c+ ' AND ('+e.MyRecords__c.replaceAll('<<User.Id>>',UserInfo.getUserId())+')';
                }
            }
            system.debug('sdgDataProviderNative:LoadSDG:e.filter__c ' + e.filter__c);
            if (!e.is_valid__c)
            {
                system.debug('This is an invalid SDG');
                throw new SDGException('SDG: ' + SDGTag + ' is marked as invalid');
            }
            //Replace record id expression with parentId change for v1.3 Phase 4 at (29-01-2020)
            if(String.isNotBlank(e.Filter__c) && String.isNotBlank(ParentRecordId)){
                e.Filter__c = e.Filter__c.tolowercase().replace('<<recordid>>',ParentRecordId);            
            }
            
            CoreSDG = new SDG(e.sObjectName__c, e.Parent_Field_Name__c,  e.sobjectname__c,  e.Filter__c,  e.Default_Sort__c, e.Id, e.All_Rows__c );
            CoreSDG.internalData.DisableSharing = e.DisableSharing__c;
            CoreSDG.sdgId = e.Id;
            CoreSDG.highlightString = e.Highlight_Colors__c;
            CoreSDG.rememberFilter = e.Remember_Filter__c;
            CoreSDG.showIcon = e.Show_Icon__c;
            CoreSDG.myRecords = e.MyRecords__c;
            coreSDG.sdgGroupingField = e.Grouping_Field_API__c;
            CoreSDG.myTeamsRecords = e.My_Teams_Records__c; //  My Team's Records added in v1.3 at (29-01-2020)
            //coreSDG.highlightString = e.Highlight_row__c;
            //Check SDG edit permission for Manage_Field
            CoreSDG.enableManageField = (Schema.sObjectType.SDG_Field__c.isAccessible());
            CoreSDG.isEnableManageField = e.Enable_Manage_Field__c;
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get(CoreSDG.sObjectName);
            if (targetType==null)
            {
                system.debug('sdgDataProviderNative:LoadSDG: invalid sObjectName');
                throw new SDGException('sdgDataProviderNative: Invalid sObjectName provided - are you missing a namespace?');
            }
            Id CoreSDGId = CoreSDG.InternalData.sUniqueKey;
            // #9 - Inline edit functionality
            // Add value in  sdg response in Phase-4(InlineEdit) at 14-02-2020
            CoreSDG.isEditableSDG = e.Enable_Inline_Edit__c;
            List<SDG_Field__c> fields = e.sdgfields__r;
            if (fields!=null)
                CoreSDG.SDGFields = GetSDGFields(fields, targetType);
            
            List<SDG_Action__c> actions = e.sdg_actions__r;
            if (actions!=null)
                CoreSDG.SDGActions = GetSDGActions(actions, e.sObjectName__c);
        }
        
        return coreSDG;
    }
    
    private  List<SDGAction> GetSDGActions(List<SDG_Action__c> actions, String sObjectName)
    {
        
        
        List<SDGAction> results = sdgMapper.MapToSDGActions(sObjectName, actions);
        results.sort();
        return results;
    }
    private  List<SDGField> GetSDGFields(List<sdg_field__c> fields, Schema.SObjectType targetType )
    {
        
        if (fields.size()==0)
        {
            throw new SDGException('sdgDataProviderNative:GetSDGFields: SDG has no fields');
        }
        
        //Now convert to fields - do FLS checks as well
        List<SDGField> results = sdgMapper.MapToSDGFields(targetType, fields, true);
        results.sort();
        return results;
        
    }
    
    
    // This method is gives us Where clause of List view based on list view Id and sObject.
    //logic to populate filter dynamically ~Akash
    
    private string getFilterString(String listViewName, String objectName){
        
       String sessionId;
        if(Test.isRunningTest()){
            sessionId = UserInfo.getSessionId();
        }else{
            String  content = Page.PageWithSessionId.getContent().toString();
            Integer s = content.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
            e = content.indexOf('End_Of_Session_Id');
           sessionId = content.substring(s, e);
        }
        
        Http http = new Http();
        HttpRequest request;
        HttpResponse response;
        String queryStr;
        String filterStr = '';
        if(String.isBlank(listViewName)){
            filterStr = '';
        }else{
            queryStr = '';
            List<ListView> lstViewDetails =[SELECT Id, DeveloperName FROM ListView where DeveloperName =: listViewName];
            if(lstViewDetails.size() > 0){
                request = new HttpRequest();
                request.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v44.0/sobjects/'+objectName+'/listviews/'+lstViewDetails[0].Id+'/describe');
                request.setMethod('GET');
                request.setHeader('Authorization', 'OAuth ' + sessionId);        
                request.setHeader('Authorization', 'Bearer ' + sessionId); 
                response = http.send(request);
                if (response.getStatusCode() == 200) {
                    System.debug('response:'+ response.getBody());
                    Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                    if(resMap.containsKey('query') && String.isNotBlank((String)resMap.get('query'))){
                        queryStr = (String)resMap.get('query');
                        if(queryStr.containsIgnorecase('WHERE')){
                            filterStr = queryStr.substring(queryStr.indexOf('WHERE') + 6, queryStr.indexOf('ORDER BY'));
                        }
                        // Code added by sameer Reason: My data and all data filtering.
                        if((string)resMap.get('scope') == 'mine'){
                            string myFilter = 'ownerId = \''+userInfo.getUserId()+'\'';
                            if(string.isNotBlank(filterStr)){
                                filterStr = '('+filterStr+') AND '+myFilter;
                            }
                            else{
                                filterStr = myFilter;
                            }
                        }
                    }
                }
            }
        }
        return filterStr;
    }
    /*
       Method Modified for Bulk data of related Association for bug fixing (00028538) in v1.3 Phase-4 by Rahulk
	*/
    public static set<string> generateLikeClause(String queryStr){
        Map<id,Sobject> sObjMap = new Map<id,Sobject>(Database.query(queryStr));
        Set<String> relatedIds = new Set<String>();
        
        for(Id objId : sObjMap.keySet()){           
                relatedIds.add('%'+objId+'%');            
        }
        if(relatedIds.size() == 0){
            relatedIds.add('%000000000000000000%');
        }
        system.debug('relatedIds>>>>>>>>'+relatedIds);
        return relatedIds;
    }    
}