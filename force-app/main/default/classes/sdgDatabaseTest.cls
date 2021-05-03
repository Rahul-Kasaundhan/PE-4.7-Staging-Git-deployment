/*
* Copyright (c) 2018, salesforce.com, inc.
* All rights reserved.
* SPDX-License-Identifier: BSD-3-Clause
* For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
*/
@isTest

public with sharing class sdgDatabaseTest {
    static testMethod void GetSDGTest()
    {
        Account acc = new Account (Name = 'TestAcc');
        insert acc;
        system.assertEquals('TestAcc', acc.Name); // added for security issues PEv4.7 by Aditya on 22 March 2021
        sdgDatabase.CountQuery('Select COUNT() from Account',true);
        sdgDatabase.CountQuery('Select COUNT() from Account',false);
        sdgDatabase.Query('Select id,name from Account',true);
        sdgDatabase.Query('Select  id,name from Account',false);        
    }
}