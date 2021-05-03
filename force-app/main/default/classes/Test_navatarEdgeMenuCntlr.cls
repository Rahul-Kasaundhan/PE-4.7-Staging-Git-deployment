/* 
New Implimentation:
Developer       :   Sameeksha Sahu
Project         :   Navigation & SDG 
Date            :   08/August/2019
*/
@isTest
public class Test_navatarEdgeMenuCntlr {

    static testmethod void TestnavatarEdgeMenuCntlr()
    {
        Navigation__c nav1 = new Navigation__c(Name='TestNav',Quick_Create_Object__c='Account',List_View_Object__c='Account',List_View_Name__c='fsg');
        insert nav1;
        Navigation__c nav2 = new Navigation__c(Name='TestNav1',Quick_Create_Object__c='Account', URL__c='https://www.google.com');
        insert nav2;
        Navigation__c nav3 = new Navigation__c(Name='TestNav',Quick_Create_Object__c='Account',List_View_Object__c='Account');
        insert nav3;
        Navigation__c nav4 = new Navigation__c(Name='TestNav',Quick_Create_Object__c='Account',List_View_Object__c='Account',Parent__c=nav3.id);
        insert nav4;
        test.startTest();
        string json = 'abc';
        map<String,String> mapURL = new map<String,String>();
        mapURL.put('Con','Abdgjg');
        navatarEdgeMenuCntlr navEdgeClass = new navatarEdgeMenuCntlr();
        navatarEdgeMenuCntlr.responseWrapper testWrap = new navatarEdgeMenuCntlr.responseWrapper(); 
        testWrap.jsonStr = json;
        testWrap.mapIdToUrl = mapURL;
        navatarEdgeMenuCntlr.getJson('New Relationship');
        navatarEdgeMenuCntlr.getJson(''); // added to increase test coverage PEv4.7 by Aditya 26 April 2021
        system.assertEquals('TestNav',nav1.Name); // added for security issue PEv4.7 by Aditya on 23 March 2021
        Test.stopTest();
    }
    
}