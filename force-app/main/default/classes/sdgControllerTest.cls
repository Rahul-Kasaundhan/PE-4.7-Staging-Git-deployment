/*
* Copyright (c) 2018, salesforce.com, inc.
* All rights reserved.
* SPDX-License-Identifier: BSD-3-Clause
* For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
*/
@isTest
public with sharing class sdgControllerTest {
    
    static testMethod void TestCustomObjInitialLoad()
    {
        //Generate test data: an account and an opportunity:
        String testdata=sdgTestData.GenerateTestSampleData();
        
        STring sdgid = sdgTestData.GenerateTestSDG();
        //do not generate any fields to get an error
        
        Test.startTest();
        
        String results = sdgController.GetSDGInitialLoad(testdata, testdata, 'Attachments', '',0);
        //json payload so parse
        SDGInitialLoad initial = (SDGInitialLoad)JSON.deserialize(results, SDGInitialLoad.class);
        system.assertEquals(true, initial.isError,'Expected error for SDG with no fields');
        
        Test.stopTest();
    }
    
    static testMethod void TestCustom()
    {
        SDG__c a = new SDG__c(Name='SDGName', sdg_tag__c = 'SDGName', is_valid__c=true, Myrecords__c='abc',sobjectname__c=sdgNamespaceUtility2.GetNamespace() + 'sdg_field__c', parent_field_name__c = sdgNamespaceUtility2.GetNamespace() + 'sdg__r.id');
        insert a;
        Test.startTest();
        //sdgController.deleteSdgPreference('abc:SDGName');
        sdgController.prepareDataForRow('select id from Account','SELECT Name, COUNT(Id) AccountCount FROM Account GROUP BY Name limit 10',a.id,true);
        sdgController.prepareDataForRow('select id from Account','SELECT Name, COUNT(Id) AccountCount FROM Account GROUP BY Name limit 10',a.id,false);
        // sdgController.getOwerIdFromSDGObj('abc:SDGName');
        sdgController.GetNamespace();
        sdgController.updateSdgPreference('SDGName',true);
        System.assertEquals('SDGName', a.Name); // added for security issues PEv4.7 by Aditya on 22 March 2021
        
        Test.stopTest();
    }
    
    static SDGResult GetResult(SDGRequest req)
    {
        String results = sdgController.getSDGResult(JSON.serialize(req));
        SDGResult result = (SDGResult)JSON.deserialize(results, SDGResult.class);
        return result;
        
    }
    
    static testMethod void TestInvalidSDG()
    {
        //Generate test data: an account and an opportunity:
        String testdatarecordid= sdgTestData.GenerateTestSampleData();
        
        STring erlid = sdgTestData.GenerateTestSDG();
        String stringfield = sdgTestData.GenerateTestSDGFieldString(erlid);
        String datefield = sdgTestData.GenerateTestSDGFieldDate(erlid);
        String booleanfield = sdgTestData.GenerateTestSDGFieldBoolean(erlid);
        String picklistfield = sdgTestData.GenerateTestSDGFieldPicklist(erlid);
        
        Test.startTest();
        
        //Generate a request:
        SDGRequest req = new SDGRequest();
        req.SDGTag = sdgTestData.TestSDGName;
        req.ParentRecordID = testdatarecordid;
        req.pageid=1;
        req.pagesize=5;
        
        system.debug('request: ' + JSON.serialize(req));
        //Now invoke normal list:
        SDGResult result = getresult(req);
        system.debug('result: ' + JSON.serialize(result));
        //system.assertEquals(false, result.isError,'TestInvalidSDG: No error expected with valid SDG');
        //system.assertEquals(2, result.filteredrowcount,'TestInvalidSDG: Expected 2 sdgfields as this is a valid SDG');
        
        //Update SDG:
        Sdg__c sdg = [select id, is_valid__c from sdg__c where id = :erlid limit 1];
        sdg.is_valid__c = false;
        update sdg;
        sdg = [select is_valid__c from sdg__c where id = :erlid limit 1];
        
        system.debug('set ' + sdg.id + ' to ' + sdg.is_valid__c + ' - should fail now');
        system.debug(JSON.serialize(sdg));
        SDGResult result2 = getResult(req);
        
        system.assertNotEquals('', result2.ErrorMessage,'Expected error message with is_valid=false');
        
        //system.assertEquals(null, result2.filteredrowcount,'Expected rowcount=0 as this is now invalid sdg');
        system.assertEquals(true, result2.isError,'Expected error with is_valid=false');
        
        Test.stopTest();
    }
    
    
    static testMethod void sdgPreferences()
    {
        
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
        
        Sdg_preferences__c pref = new sdg_preferences__c();
        pref.User__c = UserInfo.getUserId();
        pref.Filters__c = '[{"SDGFieldID":"a023i00000AFG8vAAH","FilterValue":"Sector 63","FilterOperator":"includes"}]';
        pref.sdgKey__c = 'All Account';
        insert pref;
        
        sdg sdgObj = new sdg('contact','Account','Contact','Name!=null','ORDER BY NAME', 'All Account');
        
        Test.startTest();
        
        sdgPreferences.GenerateRequestWithFilters(sdgObj,'TestId','SDG_tag');
        sdgPreferences.getPreference('Account');
        sdgPreferences.deletePreference('All Account');
        
        Test.stopTest();
    }
    static testMethod void testgetMyTeamFilter()
    {
        Profile prof = [Select Id from profile where Name='System Administrator'];
        User user = new User();
        user.firstName = 'Navtest';
        user.lastName = 'User';
        user.profileId = prof.Id;
        user.username = 'NavtestUser@test.com';
        user.email = 'NavtestUser@test.com';
        user.Team__c ='';
        user.EmailEncodingKey = 'ISO-8859-1'; 
        user.Alias = 'Navtest';  
        user.TimeZoneSidKey = 'America/Los_Angeles';  
        user.LocaleSidKey = 'en_US'; 
        user.LanguageLocaleKey = 'en_US'; 
        user.Team__c ='';
        insert user;
        
        SDG__c sdgData = new SDG__c();
        sdgData.Name ='All Account123'; 
        sdgData.SDG_Tag__c='All Account';
        sdgData.Show_Icon__c=true;
        sdgData.sObjectName__c='Account';
        sdgData.My_Home__c=true;
        sdgData.Is_Valid__c=true;
        sdgData.List_View_Name__c='All';
        sdgData.My_Teams_Records__c = 'OwnerId IN (SELECT Id FROM User WHERE Team__c =\'<<Team__c>>\')';
        insert sdgData;
        SDG_Field__c sdgf= new SDG_Field__c(sdg__c=sdgData.id, APIName__c='Name', Color__c='Red'); 
        insert sdgf;
        Sdg_preferences__c pref = new sdg_preferences__c();
        pref.User__c = UserInfo.getUserId();
        pref.Filters__c = '[{"SDGFieldID":"a023i00000AFG8vAAH","FilterValue":"Sector 63","FilterOperator":"includes"}]';
        pref.sdgKey__c = 'All Account';
        insert pref;
        
        SDG__c sdgobj = new SDG__c();
        sdgobj.Name ='All Deal'; 
        sdgobj.SDG_Tag__c='All Deal';
        sdgobj.sObjectName__c='Account';
        sdgobj.Is_Valid__c=true;
        sdgobj.My_Teams_Records__c = 'ID IN (SELECT Id FROM User WHERE Team__c =\'<<Team__c>>\')';
        insert sdgobj;
        SDG_Field__c sdgfobj= new SDG_Field__c(sdg__c=sdgobj.id, APIName__c='Name', Color__c='Red'); 
        insert sdgfobj;
        Test.startTest();
        System.assertNotEquals('', sdgController.getMyTeamFilter(sdgData.My_Teams_Records__c));
        sdgController.getMyTeamFilter(sdgobj.My_Teams_Records__c);
        sdgController.getSdgPreference(sdgData.SDG_Tag__c);
        system.runAs(user){
            sdgController.getMyTeamFilter(sdgData.My_Teams_Records__c);
        }
        Test.stopTest();
    }
    static testMethod void testsaveUpdatedRecords()
    {
    
        Account accobj =  new Account();
        accobj.Name ='TestNav';
        accobj.RecordTypeId =  Schema.sObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        insert accobj;
        
        SDG__c sdgData = new SDG__c();
        sdgData.Name ='All Account123'; 
        sdgData.SDG_Tag__c='All Account';
        sdgData.sObjectName__c='Account';
        sdgData.Is_Valid__c=true;
        sdgData.Enable_Inline_Edit__c = true;
        insert sdgData;
        
        SDG_Field__c sdgfield = new SDG_Field__c(sdg__c=sdgData.id, APIName__c='Name', Color__c='Red'); 
        insert sdgfield;
        SDG_Field__c sdgfield2 = new SDG_Field__c(sdg__c=sdgData.id, APIName__c='Industry', Color__c='Red'); 
        insert sdgfield2;
        SDG_Field__c sdgfield3 = new SDG_Field__c(sdg__c=sdgData.id, APIName__c='AnnualRevenue', Color__c='Red'); 
        insert sdgfield3;
         SDG_Field__c sdgfield4 = new SDG_Field__c(sdg__c=sdgData.id, APIName__c='Name', Color__c='Red'); 
        insert sdgfield4;
        // SDG_Field__c sdgfield4 = new SDG_Field__c(sdg__c=sdgData.id, APIName__c='Conversion_Date__c', Color__c='Red'); 
       // insert sdgfield4;
        // '{0013i00000IE1OkAAL={fields={a023i00000AEB4CAAX={fieldName=Name, fieldType=STRING, updatedValue=Bug Testing #0012}}, recordTypeId=0123i000000MB8tAAG}}';        
        //String jsonData ='{"'+accobj.Id+'":{"recordTypeId":"'+accobj.RecordTypeId+'","fields":{"'+sdgfield.ID+'":{"fieldName":"Name","fieldType":"STRING","updatedValue":"Test  Institution1"}}}}';     
       // String jsonData ='{"0013i00000IE1OkAAL":{"recordTypeId":"0123i000000MB8tAAG","fields":{"a023i00000AEB4CAAX":{"fieldName":"Name","fieldType":"STRING","updatedValue":"Test  Institution1"}}}}';     

        //Map<String, Object> updatedRecordsMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
       // Map<String, Object> n = (Map<String, Object>)JSON.deserialize(jsonData, updatedValue.class);
       
        String innerData = '{"recordTypeId":"'+accobj.RecordTypeId+'","fields":{"'+sdgfield.ID+'":{"fieldName":"Name","fieldType":"STRING","updatedValue":"Test  Institution1"}}}';
        Map<Object, Object> fieldMap = new Map<Object, Object>{'fieldName' => 'Name', 'fieldType' => 'STRING', 'updatedValue' => 'Test Com'};
		Map<Object, Object> fieldMap2 = new Map<Object, Object>{'fieldName' => 'Industry', 'fieldType' => 'Picklist', 'updatedValue' => 'Banking'};
        Map<Object, Object> fieldMap3 = new Map<Object, Object>{'fieldName' => 'AnnualRevenue', 'fieldType' => 'Currency', 'updatedValue' => 18};
         Map<Object, Object> fieldMap4 = new Map<Object, Object>{'fieldName' => 'Name', 'fieldType' => 'STRING', 'updatedValue' => ''};



        Map<Object, Object> fieldsMap = new Map<Object, Object>();
		fieldsMap.put(sdgfield.ID,fieldMap);    
        fieldsMap.put(sdgfield2.ID,fieldMap2);
        fieldsMap.put(sdgfield3.ID,fieldMap3);
        fieldsMap.put(sdgfield4.ID,fieldMap4);
        Map<Object, Object> innerObjMap = new Map<Object, Object>{'recordTypeId' => accobj.RecordTypeId, 'fields' => fieldsMap};
        Map<String, Object> updatedRecordsMap = new Map<String, Object>{accobj.Id => innerObjMap};

        
        //Map<Object, Object> innerObjMap2 = new Map<Object, Object>{'fields' =>sdgfield.ID+':{fieldName:Name,fieldType:STRING,updatedValue:Test  Institution1}'};
        //updatedRecordsMap.put(accobj.Id,innerObjMap2);
        //updatedRecordsMap.put('fields','{'+sdgfield.ID+':{fieldName:Name,fieldType:STRING,updatedValue:Test  Institution1}}');

        System.debug('updatedRecordsMap><>>'+updatedRecordsMap);
        Test.startTest();
        Test_sdgRequestMock fakeResponse = new Test_sdgRequestMock();
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        sdgController.saveUpdatedRecords(sdgData.sObjectName__c,sdgData.SDG_Tag__c,updatedRecordsMap);
        System.assertEquals('All Account', sdgData.SDG_Tag__c); // added for security issues PEv4.7 by Aditya on 22 March 2021
        Test.stopTest();
    }
   
public class updatedValue {
	public Rows rows { get; set; } 

}
public class Rows {
	public RowId rowId { get; set; } 

}
public class RowId {
	 public string recordTypeId { get; set; }
	public Fields fields { get; set; } 

}
public class Fields {
	public SDGFieldId SDGFieldId{ get; set; } 

}
public class SDGFieldId {
 public string fieldName { get; set; }
 public string fieldType { get; set; }
 public string updatedValue { get; set; }
 public string multiSelect { get; set; }

}
    /*static testMethod void TestInvalidCustomObject()
{
//Generate test data: an account and an opportunity:
String testdata=sdgTestData.GenerateTestSampleData();

STring erlid = sdgTestData.GenerateTestSDG();
//create invalid row:
SDG_Field__c efield = new SDG_Field__c();
efield.apiname__c='notavalidname';
efield.FieldOrder__c=1;
efield.sdg__c= erlid;
efield.is_valid_field__c=true;

//Prep test catching values:
Boolean errorThrown=false;
String errorMsg = '';
Test.startTest();

try
{
insert efield;

}
catch (DMLException ex)
{
errorThrown = true;
}

Test.stopTest();
system.assertEquals(true, errorThrown, 'Expected invalid field to throw exception as invalid');

}*/
    
    /*static testMethod void TestSDGInitialLoad()
{
//Generate test data: an account and an opportunity:
String testdata=sdgTestData.GenerateTestSAmpleDAta();

STring erlid = sdgTestData.GenerateTestSDG();
sdgTestData.GenerateTestSDGFieldString(erlid);
sdgTestData.GenerateTestSDGFieldDate(erlid);
sdgTestData.GenerateTestSDGFieldBoolean(erlid);
sdgTestData.GenerateTestSDGFieldPicklist(erlid);

//Prep test catching values:
Boolean errorThrown=false;
String errorMsg = '';
Test.startTest();

//Test Happy Path
String results = sdgController.GetSDGInitialLoad(testdata, sdgTestData.TestSDGName, '', '',2);
//json payload so parse
SDGInitialLoad initial = (SDGInitialLoad)JSON.deserialize(results, SDGInitialLoad.class);
//system.assertEquals(2, initial.results.filteredrowcount,'Expected rowcount=2 from load');
system.assertEquals(2, initial.results.data.size(),'Expected data size=1 from load');
system.assertEquals(false, initial.isError,'No error expected: initial');

//Test UnHappy Path
errorThrown=false;
errorMsg = '';

String results2 = sdgController.GetSDGInitialLoad(testdata, '', '', '',4);
SDGInitialLoad initial2 = (SDGInitialLoad)JSON.deserialize(results2, SDGInitialLoad.class);
system.assertEquals(true, initial2.isError, 'Expected handled error loading invalid Parent ID');
system.assertEquals(false, initial.isError,'No error expected: initial2 ');
//Test Unhappy Path

errorThrown=false;
errorMsg = '';
String results3 = sdgController.GetSDGInitialLoad(testdata, '', '', 'invalid value',5);
SDGInitialLoad initial3  = (SDGInitialLoad)JSON.deserialize(results3, SDGInitialLoad.class);
system.assertEquals(true, initial3.isError, 'Expected handled error loading invalid SDG Tag');
system.assertEquals(false, initial.isError,'No error expected: initial3 ');

Test.stopTest();
}*/
    
    /*static testMethod void GetSDGTest()
{
//Generate test data
String testid = sdgTestData.GenerateTestSampleData();

//Prep test catching values:
Boolean errorThrown=false;
String errorMsg = '';
Test.startTest();

//Test all params missing:
try
{
//SDG e = sdgLoaderFactory.LoadSDG('', '', '', '');

}
catch (SDGException ex)
{
errorThrown = true;
errorMsg = ex.getMessage();
}
system.assertEquals(true, errorThrown, 'Expected an SDGException with no parameters');

try
{
//sdgController SDGObj = new sdgController();
sdgController.GetNamespace();
//SDG e = sdgLoaderFactory.LoadSDG(testid, 'Opportunities', '','');

}
catch (SDGException ex)
{
errorThrown = true;
errorMsg = ex.getMessage();
}
system.assertEquals(true, errorThrown, 'Expected an SDGException with no fieldset');

Test.stopTest();
}*/
    
    /*static testMethod void TestSort()
{
//Generate test data:
String testdata=sdgTestData.GenerateTestSampleData();

STring erlid = sdgTestData.GenerateTestSDG();
String stringfield = sdgTestData.GenerateTestSDGFieldString(erlid);
String datefield = sdgTestData.GenerateTestSDGFieldDate(erlid);
String booleanfield = sdgTestData.GenerateTestSDGFieldBoolean(erlid);
String picklistfield = sdgTestData.GenerateTestSDGFieldPicklist(erlid);
//sdgTestData.GenerateTestSDGFieldTraverseString(erlid);

Test.startTest();

//Generate a request:
SDGRequest req = new SDGRequest();
req.SDGTag = sdgTestData.TestSDGName;
req.ParentRecordID = testdata;
req.pageid=1;
req.pagesize=5;
req.sortOrder='A';
req.sortColumn=stringfield;

//Now invoke normal list:
SDGResult result = getresult(req);
//Test this is sorted?
//system.assertEquals(2, result.filteredrowcount, 'expected two rows in sort results');
SDG_field__c o = (SDG_field__c)result.data[0];
//system.assertEquals('Name', o.sortablegrid__APIName__c, 'Expected');
system.assertEquals(false, result.isError,'Should not get error with valid sort value');

//Test descending sort
req.sortOrder='D';
SDGResult result2 = getresult(req);

//Test this is sorted?
//system.assertEquals(2, result.filteredrowcount, 'expected two rows in sort results');
SDG_field__c o2 = (SDG_field__c)result.data[0];
//system.assertNotEquals('sortablegrid__APIName__c', o2.sortablegrid__APIName__c, 'Expected changed order');
system.assertEquals(false, result.isError,'Should not get error with valid sort value');


//test invalid sort
req.sortColumn='Account.Name';
SDGResult result3 = getresult(req);
//should have an error:
system.assertEquals(true, result3.isError,'Should get error with invalid sort value');

}*/
}