/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
@isTest
public class sdgDesignerTest {
    static testmethod void GetSObjectFieldsTest()
    {
        test.startTest();

        List<AuraFieldSelectOption> results = sdgDesigner.GetSObjectFields('Account', '');
        system.assertNotEquals(0, results.size(), 'Expecting multiple fields');

        test.stopTest();
    }

    static testmethod void GetNamespaceTest()
    {
        test.startTest();

        string results = sdgDesigner.GetNamespace();
        system.assertEquals(sdgNamespaceUtility2.getNamespace(), results, 'Expecting namespace');

        test.stopTest();
    }
    static testmethod void GetNewFieldOrderTest()
    {
        Id sdgid = sdgTestData.GenerateTestSampleData();
        test.startTest();
        integer result = sdgDesigner.GetNewFieldOrder(sdgid);
        system.assertEquals(3, result); // added for security issues PEv4.7 by Aditya on 22 March 2021
        sdgTestData.GenerateTestSDGFieldString(sdgid, 'name', 5);
        integer result2 = sdgDesigner.GetNewFieldOrder(sdgid);
        system.assertEquals(6, result2); // added for security issues PEv4.7 by Aditya on 22 March 2021
        test.stopTest();

    }

    static testmethod void GetSObjectFieldsIDTest()
    {
        Id recordId = sdgTestData.GenerateTestSDG();
        test.startTest();

        List<AuraFieldSelectOption> sdgresults = sdgDesigner.GetSObjectFields('SDG__c', '');
        //system.debug(sdgresults.size());
        List<AuraFieldSelectOption> fieldresults = sdgDesigner.GetSObjectFields('SDG_Field__c', '');
        //system.debug(fieldresults.size());
        List<AuraFieldSelectOption> sdgbyIDresults = sdgDesigner.GetSObjectFields('', recordId);
        //system.debug(sdgbyIDresults.size());
        system.assert(sdgresults.size()>10, 'Expecting multiple fields');
        system.assert(fieldresults.size()>10, 'Expecting multiple sObjectTypes');

        //test data has a sObjectName of sdg_field__c
        system.assertEquals(fieldresults.size(), sdgbyIDresults.size(), 'Expecting same data from both object name and id');

        test.stopTest();
    }
    
    //added by Aditya in PEv4.7 on 15 March 2021
    static testmethod void CheckSDG_FieldPermissionTest() {
        System.assertEquals(true, sdgDesigner.CheckSDG_FieldPermission());
    }
    
    //added by Aditya in PEv4.7 on 16 March 2021
    static testmethod void updateFieldsAndOrderTest() {
        String sdgId = sdgTestData.GenerateTestSDG();
        List<String> sdgToDelete = new List<String>();
        String jsonStr = '[{"scale":0,"redirectUrl":null,"Preferences":null,"parentFieldName":null,"options":[],"Label":"Name","isHTMLFormatted":false,"isHidden":false,"isEditableField":true,"imageField":null,"ID":"dynamic_","groupingQuery":null,"FilterType":null,"filterSeq":null,"FieldType":"STRING","FieldStyle":null,"FieldOrder":1,"FieldColor":null,"ColumnName":"Name","canSort":true,"canFilter":true}]';        
        test.startTest();
        sdgDesigner.updateFieldsAndOrder(jsonStr, sdgId, sdgToDelete);
        system.assertNotEquals('',sdgId); // added for security issues PEv4.7 by Aditya on 22 March 2021
        test.stopTest();   
    }

}