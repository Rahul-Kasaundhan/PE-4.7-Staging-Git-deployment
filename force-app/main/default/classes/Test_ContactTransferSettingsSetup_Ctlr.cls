@isTest
public class Test_ContactTransferSettingsSetup_Ctlr{
    public static testMethod void Test_ContactTransferSettingsSetup() {
        
    try {
            string np = CommonUtility.strNameSpacePrefix; 
            Navatar_Setup__c navSetup= new Navatar_Setup__c();           
            navSetup.admin_setting__c =  true;
            navSetup.cts_activity__c = 'Old Institution Only';
            navSetup.cts_advanced__c = 'Contact and Insitution';
            insert navSetup;
            
            ContactTransferSettingsSetup_Ctlr dclSetup= new  ContactTransferSettingsSetup_Ctlr();
            dclSetup.onEditContTransferSetup();
            dclSetup.onCancel();
            
            Account parentAccount = new Account();
            parentAccount.Name = 'SunMicro Group';
            insert parentAccount;
            
            String recdTypeId = [Select id From RecordType Where SobjectType = 'Account' And Name = 'Company'].Id;
            
            Account acc = new Account();
            acc.Name = 'AIS Group';
            acc.RecordTypeId = recdTypeId;
            acc.ParentId = parentAccount.id;
            insert acc; 
            
            Contact cont= new Contact();
            cont.firstname ='john';
            cont.lastname = 'smith';
            cont.accountid = acc.id;
            insert cont;
            
            Test.startTest();
           
            // Null Web Service mock implementation
            System.Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl());
            
            // Only required to workaround a current code coverage bug in the platform
            MetadataService metaDataService = new MetadataService();
            
            // Invoke operations         
            MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
            metaDataPort.listMetadata(null, null);
            metaDataPort.updateMetadata(null);
                       
            dclSetup.onSaveContTransferSetting();            
            dclSetup.updateContactLayout(true);
            
            Test.stopTest();
                        
        } catch (Exception e) {
            System.assert(false, 'Exception ' + e);
        }
    }
    
    
    public static testMethod void Test_ContactTransferSettingsSetup2() {
        
    try {
            string np = CommonUtility.strNameSpacePrefix; 
            Navatar_Setup__c navSetup= new Navatar_Setup__c();           
            navSetup.admin_setting__c =  true;
            navSetup.cts_activity__c = 'Old Institution Only';
            navSetup.cts_advanced__c = 'Contact and Insitution';
            insert navSetup;
            
            ContactTransferSettingsSetup_Ctlr dclSetup= new  ContactTransferSettingsSetup_Ctlr();
            dclSetup.onEditContTransferSetup();
            dclSetup.onCancel();
            dclSetup.isEnbleContTransferSetup = false;
            
            Account parentAccount = new Account();
            parentAccount.Name = 'SunMicro Group';
            insert parentAccount;
            
            String recdTypeId = [Select id From RecordType Where SobjectType = 'Account' And Name = 'Company'].Id;
            
            Account acc = new Account();
            acc.Name = 'AIS Group';
            acc.RecordTypeId = recdTypeId;
            acc.ParentId = parentAccount.id;
            insert acc; 
            
            Contact cont= new Contact();
            cont.firstname ='john';
            cont.lastname = 'smith';
            cont.accountid = acc.id;
            insert cont;
            
            Test.startTest();
            // Null Web Service mock implementation
            System.Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl());
            
            // Only required to workaround a current code coverage bug in the platform
            MetadataService metaDataService = new MetadataService();
            
             // Invoke operations         
            MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
            metaDataPort.listMetadata(null, null);
            metaDataPort.updateMetadata(null);
            dclSetup.onSaveContTransferSetting();
            
            dclSetup.updateContactLayout(true);
            
            Test.stopTest();
                        
        } catch (Exception e) {
            System.assert(false, 'Exception ' + e);
        }
    }
}