/* 
New Implimentation:
Developer       :   Sameeksha Sahu
Project         :   Navigation & SDG 
Date            :   08/August/2019
*/
@isTest
public class Test_NewRecordPopupCtrlSdg{
    @isTest
    public static void method1() {
        string sObjectName ='Account';
        string nameSpace = sdgNamespaceUtility2.GetNamespace(); // to get name space
        test.startTest();
        NewRecordPopupCtrlSdg.getRecordTypeList(sObjectName);
        NewRecordPopupCtrlSdg.getSObjectLabel(sObjectName);
        sObjectName =nameSpace+'Marketing_Initiative__c'; // added nameSpace+ by Aditya 4 March 2021 PEv4.7
        NewRecordPopupCtrlSdg.getRecordTypeList(sObjectName);
        // added for security issues PEv4.7 by Aditya on 23 March 2021
        List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{sObjectName}); 
		String objectLabel = describeSobjectsResult[0].getLabel();
        System.assertEquals(objectLabel,NewRecordPopupCtrlSdg.getSObjectLabel(sObjectName));
        test.stopTest();
    }
}