/*
* Copyright (c) 2018, salesforce.com, inc.
* All rights reserved.
* SPDX-License-Identifier: BSD-3-Clause
* For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
*/
public with sharing class sdgQueryEngine {
    public virtual class sdgQueryEngineException extends sdgException {}
    public  class sdgInvalidFilterException extends sdgException {}
    public  class sdgInvalidSortException extends sdgException {}
    public  class sdgInvalidQueryException extends sdgException {}
    public  class sdgInvalidEngineRequestException extends sdgException {}
    
    public static SDGRequest InsertDefaults(SDGRequest request)
    {
        
        //If there are no filters - then create a dummy record:
        if (request.filters==null)
            request.filters = new list<SDGFilter>();
        //default pagesize and pageid if not set
        if (request.PageSize ==null)
            request.PageSize = 10;
        if (request.PageID ==null)
            request.PageID = 1;
        return request;
    }
    
    public static void VerifyRequest(SDGRequest request, Map<String, SDGField> mFields)
    {
        //Check if any of the filters aren't in the original set of ids for fields
        for (SDGFilter filter : request.filters)
        {
            //Note that mfields only has fields that are already checked for FLS so this is in effect an FLS check
            if (!mfields.containsKey(filter.SDGFieldID))
            {
                throw new sdgInvalidFilterException('Invalid SDGRequest.Filters');
            }
        }
        
        //And the sort order - can't sort by a field that you can't select...
        if (!String.isBlank(request.SortColumn))
        {
            if (!mfields.containsKey(request.SortColumn))
            {
                throw new sdgInvalidSortException('Invalid SDGRequest.SortColumn');
            }
        }
    }
    
    public static map<String, SDGField> GetSelectFieldsMap(sdg sdgObject)
    {
        
        Map<String, SDGField> results = new Map<String, SDGField>();
        //Get all the fields for the select clause
        for (SDGField field : sdgObject.SDGFields)
        {
            results.put(field.id,field);
        }
        return results;
    }
    
    public static List<String> GetUniqueSelectFieldsList(sdg sdgObject)
    {
        Set<String> fieldset = new Set<String>();
        //Get all the fields for the select clause
        for (SDGField field : sdgObject.SDGFields)
        {
            
            //Add the selectable field to the list of select names
            if (String.isNotBlank(field.columnName))
            {
                String colname = field.columnName;
                //Translate any picklist values
                if (field.FieldType ==String.valueof(Schema.DisplayType.PICKLIST))
                {
                    colname = 'tolabel(' + colname + ')';
                }
                if (field.FieldType ==String.valueof(Schema.DisplayType.CURRENCY))
                {
                    //if (field.FieldStyle == 'ShowCurrencyCode')
                    fieldset.add(String.escapeSingleQuotes(colname));
                    //Change for currency issue ~Akash (Will not work if different objects have same API name for currency field and are added to same grid)
                    List<String> relationList = colname.split('\\.');
                    if(relationList.size() > 1){
                        colname = 'FORMAT(' + colname + ') ' + relationList[relationList.size()-1] + 'Formatted';
                    }else{
                        colname = 'FORMAT(' + colname + ') ' + colname + 'Formatted';
                    }
                    //END
                }
                
                fieldset.add(String.escapeSingleQuotes(colname));
            }
            
        }
        // #9 - Inline edit functionality
        // adding recordType in field response 
        if (sdgObject.isEditableSDG != null && sdgObject.isEditableSDG) {
            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(sdgObject.sObjectName);
            if (objectType != null && objectType.getDescribe().getRecordTypeInfos().size() > 1) {
                fieldset.add('RecordTypeId');
            }
        }
        
        return new List<String>(fieldset);
    }
    
    public static SDGResult getSDGResultRaw(SDG newSDG, SDGRequest request)
    {
        system.debug('QueryEngine:getSDGResultRaw');
        system.debug(json.serialize(request));
        system.debug(json.serialize(newsdg));
        //Verify against the database, and escape everything - including the config values
        
        Boolean bInvalidRequest = false;
        integer internalpageid=0;
        decimal internalPageSize =0;
        String sAllWhereClause = '';
        String sCoreWhereClause = '';
        String pageQuery = '';
        Boolean DisableSharing = true;
        List<String> UserWhereClauses = new List<String>();
        List<String> CoreWhereClauses = new List<String>();
        String sCountLimit = ' limit 2100'; // Changed by Sameer bugID:	00027707
        String AllRows  = '';
        
        //Lots of steps:
        //0 Test if this is an apex call instead:
        //1 Verify that the data is valid for searching
        //2 Get the core query constructed
        //3 Do parent record id
        //4 Get where clause
        //5 handle pagination
        
        //load the SDG and fields:
        
        SDGResult result = new SDGResult();
        
        
        Map<String, SDGField> mFields = new Map<String, SDGField>();
        
        result.isError = true;
        result.ErrorMessage = 'No SDG found';
        //Validate that the request is safe:
        if (newSDG!=null)
        {
            //The SDG record exists
            try
            {
                mFields = GetSelectFieldsMap(newSDG);
                //Fix any blank data for paging and null filters
                request = InsertDefaults(request);
                
                //check there's nothing wrong - will throw an exception
                VerifyRequest(request, mFields);
                
                //Everything looks oK so far so save the filters
                sdgPreferences.SaveFilters(request, newSDG.InternalData.sUniqueKey); // Code Commented by sameer - As we are getting Commited work pending error. 
                
                //and generate the query
                List<String> AllSelectFields = GetUniqueSelectFieldsList(newSDG);
                
                //Added to get fields from report url
                List<String> uniqueFieldsFromRedirectUrl = getReportUrlFields(newSDG,new Set<String>(AllSelectFields));
                
                //Get Image fields
                for(SDGField field: newSDG.SDGFields){
                    if(String.isNotBlank(field.imageField)){
                        uniqueFieldsFromRedirectUrl.add(field.imageField);
                    }
                }
                
                String reportFieldString = String.join(uniqueFieldsFromRedirectUrl,',') ;
                
                // Note FLS checks done on AllSelectFields when retrieving SDG (in e.GetSDG()) above - actually in GetSDGFields and GetSDGFieldsFromFieldSet
                // Also - filters can only exist for fields - so this auto filters based on FLS
                pageQuery = 'SELECT ' + String.join(AllSelectFields,',')+' '+(String.isBlank(reportFieldString)?'':','+reportFieldString)+ ' FROM ' +  String.escapeSingleQuotes(newSDG.internalData.sObjectName);
                
                internalpageid =Integer.valueOf(request.PageID);
                internalPageSize = integer.valueOf(request.PageSize);
                internalpageid = internalpageid-1;
                String sSortClause;
                
                sSortClause = BuildSortClause(newSDG, request, mFields);
                
                //support where it's blank so we can use on non related lists
                if (!String.isBlank(newSDG.InternalData.ParentFieldName))
                {
                    //Changes to add like clause
                    String fieldType = '';
                    if(!newSDG.InternalData.ParentFieldName.contains('.')){
                        fieldType = getParentFieldType(newSDG.InternalData.ParentFieldName,newSDG.sObjectName);
                    }
                    if(fieldType != '' && (fieldType.equalsIgnoreCase('TEXTAREA255') || fieldType.equalsIgnoreCase('STRING'))){
                        CoreWhereClauses.add( ' ' + String.escapeSingleQuotes(newSDG.InternalData.ParentFieldName) + ' like \'%' + String.escapeSingleQuotes(request.ParentRecordID) + '%\' ');
                    }else{
                        CoreWhereClauses.add( ' ' + String.escapeSingleQuotes(newSDG.InternalData.ParentFieldName) + ' = \'' + String.escapeSingleQuotes(request.ParentRecordID) + '\' ');                        
                    }
                }
                
                //Add the serverside default filter:
                if (!String.isBlank(newSDG.InternalData.sFilter))
                {
                    //CorewhereClauses.add(' (' + newSDG.InternalData.sFilter + ') '); // Added "()" by sameer to use multiple filters 
                    CorewhereClauses.add(newSDG.InternalData.sFilter ); //Modified by Himanshu for Myrecord subquery issue 
                }
                
                //Loop through each filter clause
                UserWhereClauses = AddFilters(request, mfields);
                
                //Kumar Jonson: For filtering based on //added by Jonson: 26-06-2019's MyRecords fields 26-06-2019
                //Code Changed by sameer : Change Request to replace <<User.Id>>
                String myRequestField = request.myRecords;
                if (String.isNotBlank(myRequestField)) {
                    string currentUserId = String.escapeSingleQuotes(Userinfo.getUserId());
                    myRequestField = myRequestField.replaceAll('<<User.Id>>', currentUserId);
                    UserWhereClauses.add(String.escapeSingleQuotes(myRequestField)); // added escapeSingleQuotes for security fix PEv4.7 9 April 2021
                }
                
                // Added My Teams's Records in v1.3 at 29-01-2020
                if (String.isNotBlank(request.myTeamFilter)) {
                    if (newSDG.myTeamsRecords.startsWithIgnoreCase('Id IN (')) {
                        String myTeamsFilter = newSDG.myTeamsRecords;
                        sdgDatabase.userIdsForMyTeam = (new Map<Id, User>((List<User>) Database.query(String.escapeSingleQuotes(request.myTeamFilter)))).keySet(); // added escapeSingleQuotes for security fix PEv4.7 9 April 2021
                        UserWhereClauses.add(myTeamsFilter.replaceAll(sdgController.myTeamFilterRegex, ' :userIdsForMyTeam'));
                    } else {
                        UserWhereClauses.add(String.escapeSingleQuotes(request.myTeamFilter)); // added escapeSingleQuotes for security fix PEv4.7
                    }
                }
                
                //Now merge all parts together
                List<STring> AllWhereClauses = new List<String>();
                AllWhereClauses.AddAll(CoreWhereClauses);
                AllWhereClauses.AddAll(UserWhereClauses);
                
                //Changes to group main data by grouped id's
                if(newSDG != null && String.isNotBlank(newSDG.sdgGroupingField)){
                    List<String> listOfIdsToQuery = new List<String>();
                    listOfIdsToQuery = prepareGroupingQueryToFilter(newSDG.internalData,newSDG.sdgGroupingField,AllWhereClauses);
                    AllWhereClauses.add( ' id IN (' +'\''+String.join(listOfIdsToQuery,'\',\'')+'\')' );
                }
                if (AllWhereClauses.size()>0){
                    //sAllWhereClause = ' WHERE ' + String.join( AllWhereClauses, ' AND ');
                    sAllWhereClause = ' WHERE ' +' (' +   String.join( AllWhereClauses, ' AND ')  + ') ' ; //Added by Himanshu for Myrecord subquery issue
                }
                if (CoreWhereClauses.size()>0)
                    sCoreWhereClause = ' WHERE ' + String.join( CoreWhereClauses, ' AND ');
                
                sAllWhereClause = sdgQueryBuilder.ProcessMergeFields(sAllWhereClause, request.ParentRecordId);
                sCoreWhereClause = sdgQueryBuilder.ProcessMergeFields(sCoreWhereClause, request.ParentRecordId);
                
                pageQuery = pageQuery + sAllWhereClause;
                integer offset =integer.valueOf( internalPageSize * internalpageid);
                String sPagination = ' limit ' + internalPageSize + ' offset  ' + offset;
                
                if (newSDG.InternalData.AllRows)
                {
                    AllRows = ' ALL ROWS';
                }
                
                pageQuery = pageQuery +  String.escapeSingleQuotes(sSortClause) + String.escapeSingleQuotes(sPagination) + String.escapeSingleQuotes(AllRows); // added escapeSingleQuotes for security fix PEv4.7 9 April 2021
                system.debug('getSDGResultRaw:pageQuery: ' + pageQuery);
                
                //Jonson: Start getting filter record Name and Sorting Order
                String[] sortField = sSortClause.split('ORDER BY ');
                system.debug('Field name= '+sortField[1].split(' ')[0]);
                system.debug('Order type= '+sortField[1].split(' ')[1]);
                String sortFieldName = sortField[1].split(' ')[0];
                String sortOrderType = sortField[1].split(' ')[1];
                String sortFieldId ='';
                If(mFields <> null && mFields.size() > 0){
                    For(SDGField fd : mFields.Values()){
                        system.debug('fields='+fd.ColumnName);
                        if(!fd.ColumnName.equalsIgnoreCase('id') && sortFieldName.toLowerCase() == fd.ColumnName.toLowerCase()){
                            sortFieldId = fd.ID;
                        }
                    }
                }
                result.FilterFieldId = sortFieldId;
                result.onloadSortType = sortOrderType;
                system.debug('Field name= '+sortFieldId);
                system.debug('Order type= '+sortOrderType);
                //Jonson: End getting filter record Name and Sorting Order
                
            }
            catch (Exception ex)
            {
                
                if( ex.getMessage()=='Invalid SDGRequest.Filters'){
                    throw new sdgInvalidEngineRequestException(ex.getMessage());
                }else{
                    throw new sdgInvalidEngineRequestException(ex);
                }
                
            }
            
            try
            {
                
                //now evaluate the count
                String countQuery = 'select count() from ' + String.escapeSingleQuotes(newSDG.InternalData.sObjectName) + ' ' + sAllWhereClause + sCountLimit + AllRows;
                DisableSharing = newSDG.internalData.DisableSharing;
                
                Integer countFull = sdgDatabase.CountQuery(countQuery, DisableSharing);
                
                result.FullQueryCount =countFull;
                result.pagecount = (integer) math.ceil(countFull/internalPageSize);
                
                result.data = sdgDatabase.Query(pageQuery, DisableSharing);
                // Check if query have  related_associations__c then add map(Id,RAId,Name,Icon) in result in Phase3 CR by Akash(28-11-2019).
                if(pageQuery.containsIgnoreCase('related_associations__c')){
                    result.mapRecordIsToRecDetail = new map<string,string>();
                    Map<String,String> mapObjectToIcon = new map<String,String>();
                    Set<String> relatedAssociationIdsSet = new Set<String>();
                    Map<Id,Sobject> relatedassociationIdNameMap = new Map<Id,Sobject>();
                    for(Sobject obj : result.data){
                        if(String.isNotBlank(String.valueof(obj.get('Related_Associations__c')))){
                            relatedAssociationIdsSet.addall((String.valueof(obj.get('Related_Associations__c'))).split(','));
                        }
                    }
                    if(RelatedAssociationIdsSet.size()>0){
                        relatedassociationIdNameMap = sdgNamespaceUtility2.populateObjectToSobjectMap(RelatedAssociationIdsSet);
                        List<String> objectNameList = new List<String>();
                        for(sobject obj : relatedassociationIdNameMap.values()){
                            String sobjectname = obj.getSObjectType().getDescribe().getName()+'';
                            objectNameList.add(sobjectname);
                        } 
                        mapObjectToIcon = ViewRelatedAssociationsCtrl.getIconName(objectNameList);
                        for(sobject sobj : relatedassociationIdNameMap.values()){
                            String sobjectname = sobj.getSObjectType().getDescribe().getName()+'';
                            result.mapRecordIsToRecDetail.put(String.valueOf(sobj.get('id')), String.valueOf(sobj.get('name'))+'<@>'+mapObjectToIcon.get(sobjectname));
                        }
                    }
                }
                system.debug(result.mapRecordIsToRecDetail);
                system.debug('Query complete - pagesize: ' + result.data.size());
                result.query = pageQuery;
                result.isFiltered = UserWhereClauses.size()>0;
                result.isError = false;
                result.ErrorMessage = '';
            }
            catch (exception ex)
            {
                result.query = pageQuery;
                throw new SDGInvalidQueryException('Unable to query: ' + pageQuery, ex);
            }
            
        }
        
        return  result;
    }
    private static String BuildSortClause(SDG sdg, SDGRequest request, Map<String, SDGField> mFields)
    {
        
        //Default input:
        String sSortColumn = 'Id';
        String sSortOrder = 'A';
        String sSortClause = '';
        try
        {
            if (!String.isBlank(request.SortColumn)) {
                try
                {
                    sSortColumn = String.escapeSingleQuotes(((SDGField)mFields.get(request.SortColumn)).ColumnName);
                    sSortOrder = request.SortOrder;
                }
                catch(Exception ex)
                {
                    //bad sort - remove sort:
                    sSortColumn = '';
                    sSortOrder = '';
                }
                
            }
            else
            {
                //NO FLS check here for internal sorts
                String defaultSort = sdg.InternalData.sDefaultSort;
                
                if (String.isNotBlank( defaultSort))
                {
                    String[] sSortClauseParts = defaultSort.trim().toLowerCase().split(' ');
                    sSortColumn = sSortClauseParts[0];
                    
                    sSortOrder = 'A';
                    if (sSortClauseParts.size()==2)
                    {
                        if (((sSortClauseParts[1]).left(1).toLowerCase() == 'd'))
                            sSortOrder = 'D';
                    }
                    
                }
            }
            
            //Now build the actual clause:
            sSortClause = sdgQueryBuilder.buildSortClause(sSortColumn, sSortOrder);
            
        }
        catch (Exception ex)
        {
            if (sdgEx.RaiseNew(ex))
                throw new sdgInvalidSortException('Invalid sort clause', ex);
        }
        return sSortClause;
    }
    private static List<String> AddFilters(SDGRequest request, Map<String, SDGField> mfields)
    {
        system.debug('sdgQueryEngine:AddFilters ' + JSON.serialize(request.filters));
        List<String> UserWhereClauses = new List<String>();
        for (SDGFilter filter : request.filters)
        {
            if (string.isblank(filter.filteroperator))
                filter.filteroperator = '=';
            
            SDGField databasefield = mfields.get(filter.SDGFieldID);
            if (databasefield.canFilter)
            {
                String clause = sdgQueryBuilder.BuildFilterClause( databasefield.ColumnName, databasefield.FieldType, filter.filterOperator, filter.filterValue);
                if (!String.isBlank(clause))
                    UserWhereClauses.add(clause);
            }
        }
        return UserWhereClauses;
    }
    //Method to get report url fields in query ~Akash
    private static List<string> getReportUrlFields(SDG newSDG,Set<String> setAddedFields){
        string fieldsStr = String.join(new List<String>(setAddedFields), '@');
        fieldsStr = '@'+fieldsStr+'@';
        Set<String> uniqueFields = new Set<String>();
        List<String> listReportFields = new List<String>();
        //iterate all fields and extract unique field names used in redirect url
        for(SDGField field: newSDG.SDGFields){
            if(field.redirectUrl != null && field.redirectUrl.split('<<').size() > 1){
                listReportFields = field.redirectUrl.split('<<');
                for(integer i=1;i<listReportFields.size();i++){
                    //Fixed issue: SDG not loading when any picklist field is added to URL and SDG together ~Akash	
                    if(!(fieldsStr.containsIgnoreCase('@'+listReportFields[i].split('>>')[0]+'@') || fieldsStr.containsIgnoreCase('@tolabel('+listReportFields[i].split('>>')[0]+')@'))&& 	
                       !listReportFields[i].split('>>')[0].equalsIgnoreCase('recordid')){
                           uniqueFields.add(listReportFields[i].split('>>')[0]);
                       }
                }
            }
        }
        system.debug('uniquefields from report url'+uniqueFields);
        return new List<String>(uniqueFields);
    }
    //Method to check type of field ~Akash
    public static string getParentFieldType(String fieldName, String objectName){
        string fieldStr = '';
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Schema.DescribeFieldResult fieldDesc = objDescribe.fields.getMap().get(fieldName).getDescribe();
        fieldStr = fieldDesc.getType().name();
        if(fieldStr == 'TEXTAREA' && fieldDesc.getLength() <= 255){
            fieldStr = 'TEXTAREA255';
        }
        return fieldStr;
    }
    
    //Method to create grouping query for fetching ids to filter
    public static List<string> prepareGroupingQueryToFilter(SDGInternal objInternal, String groupByField, List<String> AllWhereClauses){
        String queryStr = 'SELECT max(id),'+String.escapeSingleQuotes(groupByField)+' FROM '+(String.escapeSingleQuotes(objInternal.sObjectName)); //added escapeSingleQuotes to groupByField for security fix PEv4.7 9 April 2021
        List<String> setOfIdsToQuery = new List<String>();
        queryStr += ' WHERE '+String.escapeSingleQuotes(groupByField)+' != \'\''; //added escapeSingleQuotes to groupByField for security fix PEv4.7 9 April 2021
        if(AllWhereClauses.size() > 0){
            queryStr += ' AND '+String.join( AllWhereClauses, ' AND ');
        }
        queryStr += ' GROUP BY '+String.escapeSingleQuotes(groupByField); //added escapeSingleQuotes for security fix PEv4.7 9 April 2021
        List<AggregateResult> groupedResults = new list<AggregateResult>();
        if(objInternal.DisableSharing){
            groupingQueryWithoutSharing wos = new groupingQueryWithoutSharing();
            groupedResults = wos.query(queryStr);
        }else{
            groupingQueryWithSharing ws = new groupingQueryWithSharing();
            groupedResults = ws.query(queryStr);
        }
        for(AggregateResult ag : groupedResults){
            setOfIdsToQuery.add(String.valueOf(ag.get('expr0')));
        }
        return setOfIdsToQuery;     
    }
    //To get data without sharing settings
    private without sharing class groupingQueryWithoutSharing{
        public List<AggregateResult> Query(string query)
        {
            return database.Query(query);
        }
    }
    //To get data with sharing settings
    private with sharing class groupingQueryWithSharing{
        public List<AggregateResult> Query(string query)
        {
            return database.Query(query);
        }
    }
}