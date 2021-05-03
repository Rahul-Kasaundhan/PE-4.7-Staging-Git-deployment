@isTest
public class Test_CommonCalloutUtility {
    static testMethod void fireRequest()
    {
        String sObjectName = 'Account';
        String domain = URL.getSalesforceBaseUrl().toExternalForm();
        string recordTypeId =  Schema.sObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        String endPoint = '/services/data/v47.0/sobjects/' + sObjectName + '/describe/layouts/' + recordTypeId;
        String authToken = 'Bearer ' + UserInfo.getSessionId() ;
        Test.startTest();
        Test_sdgRequestMock fakeResponse = new Test_sdgRequestMock();
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        CommonCalloutUtility.fireRequest(domain,endPoint,authToken,'GET');
         CommonCalloutUtility.getSalesforceSessionId();
        system.assertEquals('Account',sObjectName); // added for security issue PEv4.7 by Aditya on 24 March 2021
        Test.stopTest();
    }
    
}