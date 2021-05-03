/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
public with sharing class sdgDatabase {
 	public static Set<Id> userIdsForMyTeam; //For Using User Team ids in v1.3 at 29-01-2020
    public static Set<String> setIdsString; //For Using Related Association Query in v1.3 phase-4 at 23-04-2020 By Rahulk
   
	public static integer CountQuery(string query, Boolean DisableSharing)
    {
        system.debug('disable sharing: ' + DisableSharing);
        if (DisableSharing)
        {
            sdgDatabaseWithoutSharing ws = new sdgDatabase.sdgDatabaseWithoutSharing();
            return ws.CountQuery(query );
        }
        else
        {
            sdgDatabaseWithSharing ws = new sdgDatabase.sdgDatabaseWithSharing();
            return ws.CountQuery(query );
        }
        
    }
    public static List<SObject> Query(string query, Boolean DisableSharing)
    {
        system.debug('disable sharing: ' + DisableSharing);
        if (DisableSharing)
        {
            sdgDatabaseWithoutSharing ws = new sdgDatabase.sdgDatabaseWithoutSharing();
            return ws.Query(query );
        }
        else
        {
            sdgDatabaseWithSharing ws = new sdgDatabase.sdgDatabaseWithSharing();
            return ws.Query(query );
        }
        
    }
    public with sharing class sdgDatabaseWithSharing {
        public integer CountQuery(string query)
        {
            return database.countQuery(query);
        }

        public List<SObject> Query(string query)
        {
            return database.Query(query);
        }
    }

    private without sharing class sdgDatabaseWithoutSharing{
        public integer CountQuery(string query)
        {
            return database.countQuery(query);
        }

        public List<SObject> Query(string query)
        {
            return database.Query(query);
        }
    }

}