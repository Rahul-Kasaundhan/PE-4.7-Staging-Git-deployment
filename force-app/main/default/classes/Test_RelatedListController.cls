@istest
public class Test_RelatedListController {
    static testMethod void test_fetchRelatedList() {
        
        Account objAccount = new Account(name='Nav_account');
        insert objAccount;
        List<Contact> listcon = new List<Contact>();
        Contact con = new Contact(LastName = 'Test_Con',email='test1@gmail.com', Accountid=objAccount.id);
        listcon.add(con);
        Contact con_2 = new Contact(LastName = 'Test_Con_2',email='test2@gmail.com', Accountid=objAccount.id);
        listcon.add(con_2);
        Contact con_3= new Contact(LastName = 'Test_Con_3',email='test3@gmail.com', Accountid=objAccount.id);
        listcon.add(con_3);
        insert listcon;
        SDG__c objsdg= new SDG__c();
        objsdg.Name ='All_Contact'; 
        objsdg.SDG_Tag__c='All_Contact';
        objsdg.sObjectName__c='Contact';
        objsdg.Is_Valid__c=true;
        objsdg.Enable_Inline_Edit__c = true;
        objsdg.Parent_Field_Name__c='AccountId';
        insert objsdg;
        
        SDG_Field__c sdgfield = new SDG_Field__c(sdg__c=objsdg.id, APIName__c='FirstName', Color__c='Red'); 
        insert sdgfield;
         Test.startTest();
        String objectQuery= 'Select id,name,Account.Name from Contact where  AccountId=\'<<recordId>>\'';
        boolean getIcon = true;
        string CurrentPageObject ='Contact';
        string recordId = string.valueOf(objAccount.id);
        String sdgName = objsdg.Name;
        RelatedListController.fetchRelatedList(objectQuery,getIcon,CurrentPageObject,recordId,sdgName,'1');
        String objectQuery2= 'Select id,name,Account.Name from Contact where  AccountId=\'<<AccountId>>\'';
		RelatedListController.fetchRelatedList(objectQuery2,getIcon,CurrentPageObject,recordId,sdgName,'1');
        RelatedListController.fetchRelatedList('',getIcon,CurrentPageObject,recordId,sdgName,'1');
		RelatedListController.deleterecord(recordId, 'Account');
        system.assertEquals(objAccount.name, 'Nav_account');
        Test.stopTest();  
    }
    
}