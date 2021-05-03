/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
 global with sharing class sdgQueryBuilder {
public  class sdgInvalidFilterException extends sdgException {}
    
global static string BuildSortClause (String sortColumn, String sortOrder){
    system.debug('Sort Order: ' + SortOrder);
    system.debug('Sort Column: ' + SortColumn);
            
    String sSortClause = '';
    if (String.isNotBlank(sortColumn))
    {
        if (sortOrder == 'A')
            sSortClause = ' ORDER BY ' + String.escapeSingleQuotes(sortColumn) + ' ASC NULLS FIRST'; // added escapeSingleQuotes security fix PEv4.7 9 April 
        else
            sSortClause = ' ORDER BY ' + String.escapeSingleQuotes(sortColumn) + ' DESC NULLS LAST'; // added escapeSingleQuotes security fix PEv4.7 9 April 
    }
    return sSortClause;
}

global static string BuildFilterClause(String ColumnName, String FieldType, String filterOperator, String filterValue)
{
    String sClause = '';
    String colName = String.escapeSingleQuotes(ColumnName);

    if (string.isblank(filteroperator))
            filteroperator = '=';

            if (FieldType ==String.valueof(Schema.DisplayType.STRING))
            {
                if (String.isNotBlank(filtervalue.trim()))
                {
                    if (filteroperator=='=')
                        sclause =  colName + ' = \'' + String.escapeSingleQuotes(filtervalue) + '\' ';
                    if (filteroperator=='NOT=')
                        sclause =  colName + ' != \'' + String.escapeSingleQuotes(filtervalue) + '\' ';
                    if (filteroperator=='CONTAINS')
                        sclause =  colName + ' like \'%' + String.escapeSingleQuotes(filtervalue) + '%\'';
                    if (filteroperator=='NOTCONTAINS')
                        sclause = '(NOT ' + colName + ' like \'%' + String.escapeSingleQuotes(filtervalue) + '%\') ';
                    if (filteroperator=='STARTS')
                        sclause = colName + ' like \'' + String.escapeSingleQuotes(filtervalue) + '%\' ';
                    if (filteroperator=='ENDS')
                        sclause = colName + ' like \'%' + String.escapeSingleQuotes(filtervalue) + '\' ';

                }
            }
    //For multiselect picklist ~Akash
    if (FieldType ==String.valueof(Schema.DisplayType.MultiPicklist) )
    {
        if (String.isNotBlank(filtervalue.trim()))
        {
            if (filteroperator=='=')
                sclause =  colName + ' = \'' + String.escapeSingleQuotes(filtervalue) + '\' ';
            if (filteroperator=='NOT=')
                sclause =  colName + ' != \'' + String.escapeSingleQuotes(filtervalue) + '\' ';
            if (filteroperator=='includes')
                sclause = colName + ' Includes(\'' + String.escapeSingleQuotes(filtervalue) + '\') ';
            if (filteroperator=='excludes')
                sclause = colName + ' excludes(\'' + String.escapeSingleQuotes(filtervalue) + '\') ';
            
        }
    }
    //END
            if (FieldType ==String.valueof(Schema.DisplayType.BOOLEAN))
            {
                Set<String> booleanvalues = new set<String>{'true', 'false', ''};
                    if (!booleanvalues.contains(filtervalue))
                {
                    throw new SDGInvalidFilterException('Invalid date filter value provided');
                }
                if (filtervalue=='true')
                {
                    sclause = colName + ' = true ';
                }
                if (filtervalue == 'false')
                {
                    sclause = colName + ' = false ';
                }
            }
            if (FieldType ==String.valueof(Schema.DisplayType.INTEGER) || (FieldType ==String.valueof(Schema.DisplayType.CURRENCY)) || (FieldType ==String.valueof(Schema.DisplayType.PERCENT)) || FieldType ==String.valueof(Schema.DisplayType.DOUBLE))
            {
                if ((String.isNotBlank(filtervalue) && (String.isNotBlank(filtervalue.trim()) )))
                {

                    if (filteroperator=='=')
                        sclause = colName + ' = ' + String.escapeSingleQuotes(filtervalue) + ' ';

                    if (filteroperator=='GT')
                        sclause = colName + ' > ' + String.escapeSingleQuotes(filtervalue) + ' ';

                    if (filteroperator=='LT')
                        sclause = colName + ' < ' + String.escapeSingleQuotes(filtervalue) + ' ';

                }
            }
            if (FieldType ==String.valueof(Schema.DisplayType.DATE) || FieldType==String.valueof(Schema.DisplayType.DATETIME))
            {
                Set<String> datevalues = new set<String>{'=', 'LT', 'GT'};
                    Set<String> literaldatevalues = new set<String>{'THIS_WEEK', 'LAST_WEEK', 'NEXT_WEEK', 'TODAY', 'TOMORROW', 'YESTERDAY',  'NEXT_MONTH','THIS_MONTH', 'LAST_MONTH', 'LAST_QUARTER', 'THIS_QUARTER', 'NEXT_QUARTER', 'LAST_YEAR', 'THIS_YEAR', 'NEXT_YEAR'};
                        if (literaldatevalues.contains(filteroperator))
                    {
                        sclause = String.escapeSingleQuotes(colName) + ' = ' + String.escapeSingleQuotes(filteroperator) + ' '; // added escapeSingleQuotes for securoty fix PEv4.7 9 April 2021

                    }
                else
                {
                    if (datevalues.contains(filteroperator))
                    {
                        //we need to parse it as a date
                        if (String.isNotBlank(filtervalue.trim()) )
                        {
                            Date dateval = Date.today();

                            Boolean DateOK =false;
                            String StringDate ='';
                            try
                            {

                                List<String> dateparts = filtervalue.split('-');
                                Date dt = date.newInstance(Integer.valueOf(dateparts[0]),Integer.valueof(dateparts[1]),Integer.valueof(dateparts[2]));
                                DateOK = true;
                                //now convert to string:
                                StringDate = dt.year() + '-' + String.valueOf(dt.month()).leftpad(2).replaceall(' ','0')  + '-' + String.valueOf(dt.day()).leftpad(2).replaceall(' ','0') ;
                                String startDay = stringDate + 'T00:00:00Z'; //start
                                String endDay = StringDate + 'T23:59:59Z';//end of the day

                                if (DateOK)
                                {
                                    if (filteroperator=='=')
                                    {
                                        if (FieldType==String.valueof(Schema.DisplayType.DATE))
                                        {
                                            sclause = colName + ' = ' + StringDate + ' ';
                                        }
                                        else
                                        {
                                            sclause = colName + ' > ' + startDay + ' ';
                                            sclause = colName + ' < ' + endDay + ' ';
                                        }
                                    }
                                    if (filteroperator=='GT')
                                        if (FieldType==String.valueof(Schema.DisplayType.DATE))
                                    {
                                        sclause = colName+ ' > ' + StringDate + ' ';
                                    }
                                    else
                                    {
                                        sclause =  colName + ' > ' + endDay + ' ';

                                    }
                                    if (filteroperator=='LT')
                                        if (FieldType==String.valueof(Schema.DisplayType.DATE))
                                    {
                                        sclause =  colName + ' < ' + StringDate + ' ';
                                    }
                                    else
                                    {
                                        sclause = colName + ' < ' + startDay + ' ';
                                    }
                                }

                            }
                            catch (Exception ex)
                            {
                                Throw new SDGInvalidFilterException('Invalid date provided');

                            }
                        }
                    }
                }

            } //End of date handler

            if (FieldType ==String.valueof(Schema.DisplayType.PICKLIST))
            {
                if (!String.isblank(filtervalue))
                {
                    sclause = colName + ' = \'' + String.escapeSingleQuotes(filtervalue) + '\'';
                }
            }
        
    sclause = ' ' + sclause.trim() + ' ';
    return sClause;
    }
    
    public static string ProcessMergeFields(String query, String ParentRecordID)
    {
        String mergedquery = query.replaceall('#userid#', '\'' + String.escapeSingleQuotes(UserInfo.getUserId()) + '\''); // added String.escapeSingleQuotes for security fixes PEv4.7 9 April 2021
        if (!String.isBlank(ParentRecordID))
        {
            mergedquery = mergedquery.replaceall('#Id#',  String.escapeSingleQuotes(ParentRecordID) );
        }
        return mergedquery;
    }
}