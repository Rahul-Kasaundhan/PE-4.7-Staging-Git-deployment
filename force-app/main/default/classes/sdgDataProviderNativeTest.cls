/*
* Copyright (c) 2018, salesforce.com, inc.
* All rights reserved.
* SPDX-License-Identifier: BSD-3-Clause
* For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
*/
@isTest
public class sdgDataProviderNativeTest {
    
    private static testmethod void isSelectableTest()
    {
        system.assertequals(false, sdgDataProviderNative.isUserSelectable(), 'sdgDataProviderNativeTest:isUserSelectable Should not be userSelectable');
    }
    
    
    private static testmethod void testNoFields()
    {
        
        Account acc = new Account (Name = 'TestAcc');
        insert acc;
        
        System.assertEquals(acc.Name, 'TestAcc');
        Account acc2 = new Account (Name = 'TestAcc');
        insert acc2;
        System.assertEquals(acc2.Name, 'TestAcc');
        
        Task tskobj =new task();
        tskobj.subject = 'Test';
        tskobj.Priority = 'Normal';        
        Task tskobj1 =tskobj;
        insert tskobj1;
        string testtag = 'a string';
        String sdgID = sdgTestData.GenerateCoreSDG(testtag);
        boolean iserror = false;
        boolean isexpectederror = false;
        
        SDG__c sdgData = new SDG__c();
        sdgData.Name ='All Account123'; 
        sdgData.SDG_Tag__c='All Account';
        sdgData.Show_Icon__c=true;
        sdgData.sObjectName__c='Account';
        sdgData.My_Home__c=true;
        sdgData.Is_Valid__c=true;
        sdgData.MyRecords__c='acc';      
        sdgData.List_View_Name__c='All';
        insert sdgData;
        SDG__c sdgData1 = new SDG__c();
        sdgData1.Name ='Account'; 
        sdgData1.SDG_Tag__c='Account';
        sdgData1.Show_Icon__c=true;
        sdgData1.sObjectName__c='Account';
        sdgData1.My_Home__c=true;
        sdgData1.Is_Valid__c=true;
        sdgData1.MyRecords__c='acc';
        insert sdgData1;
        SDG_Field__c sdgf= new SDG_Field__c(
            sdg__c=sdgData.id, APIName__c='Name', Color__c='Red'
        ); 
        SDG_Field__c sdgf1= new SDG_Field__c(
            sdg__c=sdgData1.id, APIName__c='Name', Color__c='Red'
        ); 
        insert sdgf1;
        sdgDataProviderNative dp = new sdgDataProviderNative();             
       
        try
        {                    
            SDG newsdg = dp.LoadSDG('All Account',acc2.id);   
        }
        catch(Exception sdgex)
        {
            // isexpectederror = true;
        }
        try
        {       
            dp.LoadSDG('Account',acc.id);   
        }catch(Exception sdgex)
        {
            // isexpectederror = true;
        }       
        //create an sdg
        
        sdgDataProviderNative.generateLikeClause('Select Id from Account');
        SDG s = sdgDataProviderFactory.LoadSDG(sdgDataProviderType.Relationship.name(),sdgid,sdgNamespaceUtility2.GetNamespace() + 'SDGFields__r', '');
        SDGREquest req = new SDGRequest();
        req.SDGTag = sdgDataProviderType.Relationship + ':';
        req.FieldSetName = sdgNamespaceUtility2.GetNamespace() +'default';
        req.ParentRecordID = sdgid;
        req.RelationshipName = sdgNamespaceUtility2.GetNamespace() + 'SDGFields__r';
        req.pageid=1;
        req.pagesize=5;
        sdgDataProviderNative.getData(s,req);
        
        // system.assertequals(false, iserror, 'sdgDataProviderNativeTest:testNoFields Should not throw unhandled exception');
        // system.assertequals(true, isExpectedError, 'sdgDataProviderNativeTest:testNoFields Should throw with no fields');
        
    }
}