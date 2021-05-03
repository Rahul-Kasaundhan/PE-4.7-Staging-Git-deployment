@isTest
public class TestContactTransfer_ctlr{
    
    
    static TestMethod void TestMethodCase1(){
        //Create dummy contact for contact id,email id        
        Account acc = new Account();
        acc.name = 'Test Acc';
        insert acc;
        System.assertEquals('Test Acc', acc.Name); // (PE3.5, SK, 9Aug2017)
        
        Account acc1 = new Account();
        acc1.name = 'Test Acc New';
        insert acc1;     
        System.assertEquals('Test Acc New', acc1.Name); // (PE3.5, SK, 9Aug2017)
        
        Contact testContactObj = new Contact();
        testContactObj.FirstName = 'Elena';
        testContactObj.LastName = 'Gilbert';
        testContactObj.Email = 'elena@gmail.com';
        testContactObj.AccountId = acc.id;
        insert testContactObj;
        System.assertEquals('Gilbert', testContactObj.LastName ); // (PE3.5, SK, 9Aug2017)
        
        Contact testContactObj1 = new Contact();
        testContactObj1.FirstName = 'Elena1';
        testContactObj1.LastName = 'Gilbert1';
        testContactObj1.Email = 'elena1@gmail.com';
        testContactObj1.AccountId = acc.id;
        insert testContactObj1;
        System.assertEquals('Gilbert1', testContactObj1.LastName); // (PE3.5, SK, 9Aug2017)
                
        Fund__c fundObj = new Fund__c(Name='testFund',Fund_Type__c='Fund',Investment_Category__c='Fund');
        insert fundObj;
        System.assertEquals('testFund', fundObj.Name); // (PE3.5, SK, 9Aug2017)
        
        Fundraising__c fundraisingObj = new Fundraising__c(Name='testFundraising',Fund_Name__c=fundObj.id,Legal_Name__c=acc1.id);
        
        
        /*Fundraising_Contact__c fundraisingContactObj = new Fundraising_Contact__c();
        fundraisingContactObj.Contact__c=testContactObj1.Id;
        fundraisingContactObj.Fundraising__c=fundraisingObj.Id;
        fundraisingContactObj.Institution__c=acc1.Id;
        fundraisingContactObj.IsPrimary__c = false;
        insert fundraisingContactObj;*/
        
        Navatar_Setup__c nvsetupObj = new Navatar_Setup__c(CTS_Activity__c ='Old Institution Only',CTS_Advanced__c='Contact Only',Admin_Setting__c=true);
        insert nvsetupObj;
        System.assertNotEquals('', nvsetupObj.Name); // (PE3.5, SK, 9Aug2017)
        
        apexpages.currentpage().getparameters().put('id',testContactObj.id); 
        ContactTransfer_ctlr contactTransferObj= new ContactTransfer_ctlr(new ApexPages.StandardController(testContactObj));
        
        //Org_Setting__mdt orgSetting= new Org_Setting__mdt(Active__c=true, DeveloperName ='Contact_Tran_Setting' ); 
        //Navatar_Setup__c nvsetupObj = new Navatar_Setup__c(CCS__c='navpeiil__Commitment__c:navpeiil__Partner_Type__c;navpeiil__Commitment__c:navpeiil__Tax_Forms__c',CCS_Fundraising__c='navpeiil__Fundraising__c:Name,navpeiil__Fundraising__c:navpeiil__Legal_Name__c,navpeiil__Fundraising__c:navpeIIl__Potential_Management_Fee__c;navpeiil__Fundraising__c:navpeiil__Fund_Name__c,navpeiil__Fundraising__c:navpeiil__Portfolio_Company__c,navpeiil__Fundraising__c:navpeIIl__Investment_Likely_Amount_USD_mn__c',CCS_New_Limited_Partner__c='Institution;Account:Name',CCS_Partnership__c='navpeiil__Partnership__c:navpeiil__Fund__c,navpeiil__Partnership__c:Name,navpeiil__Partnership__c:navpeIIl__Fund_Investment_Category__c',CI_Fund_ID__c=fundObj.id,Admin_Setting__c=true);
        //insert nvsetupObj;
        
        contactTransferObj.contactLookup = testContactObj1;
        contactTransferObj.contactName = testContactObj.FirstName+' '+testContactObj.LastName;            
        contactTransferObj.displayMessage= '';
        contactTransferObj.isContactIdNull= false;
        contactTransferObj.legalIdOld= acc.id;
        contactTransferObj.legalIdNew = contactTransferObj.contactLookup.AccountId; 
        contactTransferObj.isError= false;
        contactTransferObj.errorMessage= '';
        contactTransferObj.isOrgSettingActive= true;
        contactTransferObj.isCode12365 = false;
        contactTransferObj.isPopupOpen = false;
        //Commented by Lakshya on 20210423 [PE v4.7]
        /*contactTransferObj.isFundraisingContact = false;        
        
        contactTransferObj.fetchLegalIdNew();
        contactTransferObj.beforeTransferActivity();*/
        
        Task taskObj =new Task();
        taskObj.WhoId = testContactObj.Id;
        taskObj.Subject ='Task sub';
        taskObj.Status ='Completed';
        taskObj.Priority = 'Normal';
        taskObj.WhatId = null;
        //taskObj.Institution__c = null; //Commented by Lakshya on 20210423 [PE v4.7]
        taskObj.CallDurationInSeconds =1;
        insert taskObj;
        //System.assertEquals('Task sub', taskObj.Subject); // (PE3.5, SK, 9Aug2017) //Commented by Lakshya on 20210423 [PE v4.7]
        
        Task taskObj1 =new Task();
        taskObj1.WhoId = testContactObj.Id;
        taskObj1.Subject ='Task sub1';
        taskObj1.Status ='Completed';
        taskObj1.Priority = 'Normal';
        taskObj1.WhatId = null;
        //taskObj1.Institution__c = null; //Commented by Lakshya on 20210423 [PE v4.7]
        taskObj1.CallDurationInSeconds =1;
        insert taskObj1;
        //System.assertEquals('Task sub1', taskObj1.Subject); // (PE3.5, SK, 9Aug2017) //Commented by Lakshya on 20210423 [PE v4.7]
        
        Event eventObj =new Event();
        eventObj.WhoId = testContactObj.Id;
        eventObj.Subject ='Event sub';
        eventObj.StartDateTime = DateTime.Now();
        eventObj.EndDateTime = DateTime.Now();
        eventObj.WhatId = null;
        //eventObj.Institution__c = null; //Commented by Lakshya on 20210423 [PE v4.7]
        eventObj.DurationInMinutes = 0;
        insert eventObj;
        //System.assertEquals('Event sub', eventObj.Subject); // (PE3.5, SK, 9Aug2017) //Commented by Lakshya on 20210423 [PE v4.7]
        
        Event eventObj1 =new Event();
        eventObj1.WhoId = testContactObj.Id;
        eventObj1.Subject ='Event sub1';
        eventObj1.StartDateTime = DateTime.Now();
        eventObj1.EndDateTime = DateTime.Now();
        eventObj1.WhatId = null;
        //eventObj1.Institution__c = null; //Commented by Lakshya on 20210423 [PE v4.7]
        eventObj1.DurationInMinutes = 0;
        insert eventObj1;
        //System.assertEquals('Event sub1', eventObj1.Subject); // (PE3.5, SK, 9Aug2017) //Commented by Lakshya on 20210423 [PE v4.7]
        
        //Commented by Lakshya on 20210423 [PE v4.7]
        /*contactTransferObj.transferActivity();
        contactTransferObj.contactAddressUpdate('retain');
        contactTransferObj.contactAddressUpdate('clear');
        contactTransferObj.retainAddress();
        contactTransferObj.clearAddress();*/        
        contactTransferObj.Cancel();
        
        contactTransferObj.contactId = apexpages.currentpage().getparameters().get('id'); 
        contactTransferObj.legalIdNew = acc1.Id;
        //contactTransferObj.transferActivity(); //Commented by Lakshya on 20210423 [PE v4.7]
        
        contactTransferObj.inputValue = '';
        contactTransferObj.contactPE = new Contact();
        contactTransferObj.namespacePE = '';
        contactTransferObj.contactDetailPagePath = '';
        contactTransferObj.legalNameNew = '';
        contactTransferObj.serverUrl = '';
    }
    
    //Commented by Lakshya on 20210423 [PE v4.7]
    /*static TestMethod void TestMethodCase2(){
        //Create dummy contact for contact id,email id        
        Account acc = new Account();
        acc.name = 'Test Acc';
        insert acc;
        System.assertEquals('Test Acc', acc.Name); // (PE3.5, SK, 9Aug2017)
        
        Account acc1 = new Account();
        acc1.name = 'Test Acc New';
        insert acc1;     
        System.assertEquals('Test Acc New', acc1.Name); // (PE3.5, SK, 9Aug2017)
        
        Contact testContactObj = new Contact();
        testContactObj.FirstName = 'Elena';
        testContactObj.LastName = 'Gilbert';
        testContactObj.Email = 'elena@gmail.com';
        testContactObj.AccountId = acc.id;
        insert testContactObj;
        System.assertEquals('Gilbert', testContactObj.LastName); // (PE3.5, SK, 9Aug2017)
        
        Contact testContactObj1 = new Contact();
        testContactObj1.FirstName = 'Elena1';
        testContactObj1.LastName = 'Gilbert1';
        testContactObj1.Email = 'elena1@gmail.com';
        testContactObj1.AccountId = acc.id;
        insert testContactObj1;
        System.assertEquals('Gilbert1', testContactObj1.LastName); // (PE3.5, SK, 9Aug2017)
        
        Fund__c fundObj = new Fund__c(Name='testFund',Fund_Type__c='Fund',Investment_Category__c='Fund');
        insert fundObj;
        System.assertEquals('testFund', fundObj.Name); // (PE3.5, SK, 9Aug2017)
        
        Fundraising__c fundraisingObj = new Fundraising__c(Name='testFundraising',Fund_Name__c=fundObj.id,Legal_Name__c=acc1.id);
        
        
        Navatar_Setup__c nvsetupObj = new Navatar_Setup__c(CTS_Activity__c ='Old Institution Only',CTS_Advanced__c='Contact and Institution',Admin_Setting__c=true);
        insert nvsetupObj;
        System.assertNotEquals('', nvsetupObj.Name); // (PE3.5, SK, 9Aug2017)
        
        apexpages.currentpage().getparameters().put('id',testContactObj.id); 
        ContactTransfer_ctlr contactTransferObj= new ContactTransfer_ctlr(new ApexPages.StandardController(testContactObj));
        
        contactTransferObj.contactLookup = testContactObj1;
        contactTransferObj.contactName = testContactObj.FirstName+' '+testContactObj.LastName;            
        contactTransferObj.displayMessage= '';
        contactTransferObj.isContactIdNull= false;
        contactTransferObj.legalIdOld= acc.id;
        contactTransferObj.legalIdNew = contactTransferObj.contactLookup.AccountId; 
        contactTransferObj.isError= false;
        contactTransferObj.errorMessage= '';
        contactTransferObj.isOrgSettingActive= true;
        contactTransferObj.isCode12365 = false;
        contactTransferObj.isPopupOpen = false;
        contactTransferObj.isFundraisingContact = false;        
        
        Task taskObj =new Task();
        taskObj.WhoId = testContactObj.Id;
        taskObj.Subject ='Task sub';
        taskObj.Status ='Completed';
        taskObj.Priority = 'Normal';
        taskObj.WhatId = null;
        taskObj.Institution__c = null;
        taskObj.CallDurationInSeconds =1;
        insert taskObj;
        System.assertEquals('Task sub', taskObj.Subject); // (PE3.5, SK, 9Aug2017)
        
        Task taskObj1 =new Task();
        taskObj1.WhoId = testContactObj.Id;
        taskObj1.Subject ='Task sub';
        taskObj1.Status ='Completed';
        taskObj1.Priority = 'Normal';
        taskObj1.WhatId = contactTransferObj.legalIdOld;
        taskObj1.Institution__c = null;
        taskObj1.CallDurationInSeconds =1;
        insert taskObj1;
        System.assertEquals('Task sub', taskObj1.Subject); // (PE3.5, SK, 9Aug2017)
        
        Event eventObj =new Event();
        eventObj.WhoId = testContactObj.Id;
        eventObj.Subject ='Event sub';
        eventObj.StartDateTime = DateTime.Now();
        eventObj.EndDateTime = DateTime.Now();
        eventObj.WhatId = null;
        eventObj.Institution__c = null;
        eventObj.DurationInMinutes = 0;
        insert eventObj;
        System.assertEquals('Event sub', eventObj.Subject); // (PE3.5, SK, 9Aug2017)
        
        Event eventObj1 =new Event();
        eventObj1.WhoId = testContactObj.Id;
        eventObj1.Subject ='Event sub';
        eventObj1.StartDateTime = DateTime.Now();
        eventObj1.EndDateTime = DateTime.Now();
        eventObj1.WhatId = contactTransferObj.legalIdOld;
        eventObj1.Institution__c = null;
        eventObj1.DurationInMinutes = 0;
        insert eventObj1;
        System.assertEquals('Event sub', eventObj1.Subject); // (PE3.5, SK, 9Aug2017)
        
        
        contactTransferObj.fetchLegalIdNew();
        contactTransferObj.beforeTransferActivity();
        contactTransferObj.transferActivity();
        contactTransferObj.contactAddressUpdate('retain');
        contactTransferObj.contactAddressUpdate('clear');
        contactTransferObj.retainAddress();
        contactTransferObj.clearAddress();        
        contactTransferObj.Cancel();
        
        contactTransferObj.contactId = apexpages.currentpage().getparameters().get('id'); 
        contactTransferObj.legalIdNew = acc1.Id;
        contactTransferObj.transferActivity();    
    }
    
    
    static TestMethod void TestMethodCase3(){
        //Create dummy contact for contact id,email id        
        Account acc = new Account();
        acc.name = 'Test Acc';
        insert acc;
        System.assertEquals('Test Acc', acc.Name); // (PE3.5, SK, 9Aug2017)
        
        Account acc1 = new Account();
        acc1.name = 'Test Acc New';
        insert acc1;     
        System.assertEquals('Test Acc New', acc1.Name); // (PE3.5, SK, 9Aug2017)
        
        Contact testContactObj = new Contact();
        testContactObj.FirstName = 'Elena';
        testContactObj.LastName = 'Gilbert';
        testContactObj.Email = 'elena@gmail.com';
        testContactObj.AccountId = acc.id;
        insert testContactObj;
        System.assertEquals('Gilbert', testContactObj.LastName); // (PE3.5, SK, 9Aug2017)
        
        Contact testContactObj1 = new Contact();
        testContactObj1.FirstName = 'Elena1';
        testContactObj1.LastName = 'Gilbert1';
        testContactObj1.Email = 'elena1@gmail.com';
        testContactObj1.AccountId = acc.id;
        insert testContactObj1;
        System.assertEquals('Gilbert1', testContactObj1.LastName); // (PE3.5, SK, 9Aug2017)   
        
        Fund__c fundObj = new Fund__c(Name='testFund',Fund_Type__c='Fund',Investment_Category__c='Fund');
        insert fundObj;
        System.assertEquals('testFund', fundObj.Name); // (PE3.5, SK, 9Aug2017)
        
        Fundraising__c fundraisingObj = new Fundraising__c(Name='testFundraising',Fund_Name__c=fundObj.id,Legal_Name__c=acc1.id);
        
        Navatar_Setup__c nvsetupObj = new Navatar_Setup__c(CTS_Activity__c ='Old Institution Only',CTS_Advanced__c='Contact, Institution and Custom Object',Admin_Setting__c=true);
        insert nvsetupObj;
        System.assertNotEquals('', nvsetupObj.Name); // (PE3.5, SK, 9Aug2017)
        
        apexpages.currentpage().getparameters().put('id',testContactObj.id); 
        ContactTransfer_ctlr contactTransferObj= new ContactTransfer_ctlr(new ApexPages.StandardController(testContactObj));
        
        contactTransferObj.contactLookup = testContactObj1;
        contactTransferObj.contactName = testContactObj.FirstName+' '+testContactObj.LastName;            
        
        contactTransferObj.displayMessage= '';
        contactTransferObj.isContactIdNull= false;
        contactTransferObj.legalIdOld= acc.id;
        contactTransferObj.legalIdNew = contactTransferObj.contactLookup.AccountId; 
        contactTransferObj.isError= false;
        contactTransferObj.errorMessage= '';
        contactTransferObj.isOrgSettingActive= true;
        contactTransferObj.isCode12365 = false;
        contactTransferObj.isPopupOpen = false;
        contactTransferObj.isFundraisingContact = false;        
        
        Task taskObj =new Task();
        taskObj.WhoId = testContactObj.Id;
        taskObj.Subject ='Task sub';
        taskObj.Status ='Completed';
        taskObj.Priority = 'Normal';
        taskObj.WhatId = null;
        taskObj.Institution__c = null;
        taskObj.CallDurationInSeconds =1;
        insert taskObj;
        System.assertEquals('Task sub', taskObj.Subject); // (PE3.5, SK, 9Aug2017)
        
        Task taskObj1 =new Task();
        taskObj1.WhoId = testContactObj.Id;
        taskObj1.Subject ='Task sub';
        taskObj1.Status ='Completed';
        taskObj1.Priority = 'Normal';
        taskObj1.WhatId = contactTransferObj.legalIdOld;
        taskObj1.Institution__c = null;
        taskObj1.CallDurationInSeconds =1;
        insert taskObj1;
        System.assertEquals('Task sub', taskObj.Subject); // (PE3.5, SK, 9Aug2017)
        
        Task taskObj2 =new Task();
        taskObj2.WhoId = testContactObj.Id;
        taskObj2.Subject ='Task sub';
        taskObj2.Status ='Completed';
        taskObj2.Priority = 'Normal';
        taskObj2.WhatId = acc1.Id;
        taskObj2.Institution__c = null;
        taskObj2.CallDurationInSeconds =1;
        insert taskObj2;
        System.assertEquals('Task sub', taskObj.Subject); // (PE3.5, SK, 9Aug2017)
        
        Event eventObj =new Event();
        eventObj.WhoId = testContactObj.Id;
        eventObj.Subject ='Event sub';
        eventObj.StartDateTime = DateTime.Now();
        eventObj.EndDateTime = DateTime.Now();
        eventObj.WhatId = null;
        eventObj.Institution__c = null;
        eventObj.DurationInMinutes = 0;
        insert eventObj;
        System.assertEquals('Event sub', eventObj.Subject); // (PE3.5, SK, 9Aug2017)
        
        Event eventObj1 =new Event();
        eventObj1.WhoId = testContactObj.Id;
        eventObj1.Subject ='Event sub';
        eventObj1.StartDateTime = DateTime.Now();
        eventObj1.EndDateTime = DateTime.Now();
        eventObj1.WhatId = contactTransferObj.legalIdOld;
        eventObj1.Institution__c = null;
        eventObj1.DurationInMinutes = 0;
        insert eventObj1;
        System.assertEquals('Event sub', eventObj1.Subject); // (PE3.5, SK, 9Aug2017)
        
        Event eventObj2 =new Event();
        eventObj2.WhoId = testContactObj.Id;
        eventObj2.Subject ='Event sub';
        eventObj2.StartDateTime = DateTime.Now();
        eventObj2.EndDateTime = DateTime.Now();
        eventObj2.WhatId = acc1.Id;
        eventObj2.Institution__c = null;
        eventObj2.DurationInMinutes = 0;
        insert eventObj2;
        System.assertEquals('Event sub', eventObj2.Subject); // (PE3.5, SK, 9Aug2017)
        
        contactTransferObj.fetchLegalIdNew();
        contactTransferObj.beforeTransferActivity();
        contactTransferObj.transferActivity();
        contactTransferObj.contactAddressUpdate('retain');
        contactTransferObj.contactAddressUpdate('clear');
        contactTransferObj.retainAddress();
        contactTransferObj.clearAddress();        
        contactTransferObj.Cancel();
        
        contactTransferObj.contactId = apexpages.currentpage().getparameters().get('id'); 
        contactTransferObj.legalIdNew = acc1.Id;
        contactTransferObj.transferActivity();    
    }
    
    
    static TestMethod void TestMethodCase4(){
        //Create dummy contact for contact id,email id        
        Account acc = new Account();
        acc.name = 'Test Acc';
        insert acc;
        System.assertEquals('Test Acc', acc.Name); // (PE3.5, SK, 9Aug2017)
        
        Account acc1 = new Account();
        acc1.name = 'Test Acc New';
        insert acc1;     
        System.assertEquals('Test Acc New', acc1.Name); // (PE3.5, SK, 9Aug2017)
        
        Contact testContactObj = new Contact();
        testContactObj.FirstName = 'Elena';
        testContactObj.LastName = 'Gilbert';
        testContactObj.Email = 'elena@gmail.com';
        testContactObj.AccountId = acc.id;
        insert testContactObj;
        System.assertEquals('Gilbert', testContactObj.LastName); // (PE3.5, SK, 9Aug2017)
        
        Contact testContactObj1 = new Contact();
        testContactObj1.FirstName = 'Elena1';
        testContactObj1.LastName = 'Gilbert1';
        testContactObj1.Email = 'elena1@gmail.com';
        testContactObj1.AccountId = acc.id;
        insert testContactObj1;
        System.assertEquals('Gilbert1', testContactObj1.LastName); // (PE3.5, SK, 9Aug2017)   
        
        Fund__c fundObj = new Fund__c(Name='testFund',Fund_Type__c='Fund',Investment_Category__c='Fund');
        insert fundObj;
        System.assertEquals('testFund', fundObj.Name); // (PE3.5, SK, 9Aug2017)
        
        Fundraising__c fundraisingObj = new Fundraising__c(Name='testFundraising',Fund_Name__c=fundObj.id,Legal_Name__c=acc1.id);
        
        Navatar_Setup__c nvsetupObj = new Navatar_Setup__c(CTS_Activity__c ='Old and New Institution',CTS_Advanced__c='Contact Only',Admin_Setting__c=true);
        insert nvsetupObj;
        System.assertNotEquals('Test Acc', nvsetupObj.Name); // (PE3.5, SK, 9Aug2017)
        
        apexpages.currentpage().getparameters().put('id',testContactObj.id); 
        ContactTransfer_ctlr contactTransferObj= new ContactTransfer_ctlr(new ApexPages.StandardController(testContactObj));
        
        contactTransferObj.contactLookup = testContactObj1;
        contactTransferObj.contactName = testContactObj.FirstName+' '+testContactObj.LastName;            
        contactTransferObj.displayMessage= '';
        contactTransferObj.isContactIdNull= false;
        contactTransferObj.legalIdOld= acc.id;
        contactTransferObj.legalIdNew = contactTransferObj.contactLookup.AccountId; 
        contactTransferObj.isError= false;
        contactTransferObj.errorMessage= '';
        contactTransferObj.isOrgSettingActive= true;
        contactTransferObj.isCode12365 = false;
        contactTransferObj.isPopupOpen = false;
        contactTransferObj.isFundraisingContact = false;        
        
        contactTransferObj.fetchLegalIdNew();
        contactTransferObj.beforeTransferActivity();
        
        Task taskObj =new Task();
        taskObj.WhoId = testContactObj.Id;
        taskObj.Subject ='Task sub';
        taskObj.Status ='Completed';
        taskObj.Priority = 'Normal';
        taskObj.WhatId = null;
        taskObj.Institution__c = null;
        taskObj.CallDurationInSeconds =1;
        insert taskObj;
        System.assertEquals('Task sub', taskObj.Subject); // (PE3.5, SK, 9Aug2017)
        
        Task taskObj1 =new Task();
        taskObj1.WhoId = testContactObj.Id;
        taskObj1.Subject ='Task sub1';
        taskObj1.Status ='Completed';
        taskObj1.Priority = 'Normal';
        taskObj1.WhatId = null;
        taskObj1.Institution__c = null;
        taskObj1.CallDurationInSeconds =1;
        insert taskObj1;
        System.assertEquals('Task sub1', taskObj1.Subject); // (PE3.5, SK, 9Aug2017)
        
        Event eventObj =new Event();
        eventObj.WhoId = testContactObj.Id;
        eventObj.Subject ='Event sub';
        eventObj.StartDateTime = DateTime.Now();
        eventObj.EndDateTime = DateTime.Now();
        eventObj.WhatId = null;
        eventObj.Institution__c = null;
        eventObj.DurationInMinutes = 0;
        insert eventObj;
        System.assertEquals('Event sub', eventObj.Subject); // (PE3.5, SK, 9Aug2017)
        
        Event eventObj1 =new Event();
        eventObj1.WhoId = testContactObj.Id;
        eventObj1.Subject ='Event sub1';
        eventObj1.StartDateTime = DateTime.Now();
        eventObj1.EndDateTime = DateTime.Now();
        eventObj1.WhatId = null;
        eventObj1.Institution__c = null;
        eventObj1.DurationInMinutes = 0;
        insert eventObj1;
        System.assertEquals('Event sub1', eventObj1.Subject); // (PE3.5, SK, 9Aug2017)
        
        contactTransferObj.transferActivity();
        contactTransferObj.contactAddressUpdate('retain');
        contactTransferObj.contactAddressUpdate('clear');
        contactTransferObj.retainAddress();
        contactTransferObj.clearAddress();        
        contactTransferObj.Cancel();
        
        contactTransferObj.contactId = apexpages.currentpage().getparameters().get('id'); 
        contactTransferObj.legalIdNew = acc1.Id;
        contactTransferObj.transferActivity();    
    }
    
    
    static TestMethod void TestMethodCase5(){
        //Create dummy contact for contact id,email id        
        Account acc = new Account();
        acc.name = 'Test Acc';
        insert acc;
        System.assertEquals('Test Acc', acc.Name); // (PE3.5, SK, 9Aug2017)
        
        Account acc1 = new Account();
        acc1.name = 'Test Acc New';
        insert acc1;     
        System.assertEquals('Test Acc New', acc1.Name); // (PE3.5, SK, 9Aug2017)
        
        Contact testContactObj = new Contact();
        testContactObj.FirstName = 'Elena';
        testContactObj.LastName = 'Gilbert';
        testContactObj.Email = 'elena@gmail.com';
        testContactObj.AccountId = acc.id;
        insert testContactObj;
        System.assertEquals('Gilbert', testContactObj.LastName); // (PE3.5, SK, 9Aug2017)
        
        Contact testContactObj1 = new Contact();
        testContactObj1.FirstName = 'Elena1';
        testContactObj1.LastName = 'Gilbert1';
        testContactObj1.Email = 'elena1@gmail.com';
        testContactObj1.AccountId = acc.id;
        insert testContactObj1;
        System.assertEquals('Gilbert1', testContactObj1.LastName); // (PE3.5, SK, 9Aug2017)
           
        Fund__c fundObj = new Fund__c(Name='testFund',Fund_Type__c='Fund',Investment_Category__c='Fund');
        insert fundObj;
        System.assertEquals('testFund', fundObj.Name); // (PE3.5, SK, 9Aug2017)
        
        Fundraising__c fundraisingObj = new Fundraising__c(Name='testFundraising',Fund_Name__c=fundObj.id,Legal_Name__c=acc1.id);
        
        Navatar_Setup__c nvsetupObj = new Navatar_Setup__c(CTS_Activity__c ='Old and New Institution',CTS_Advanced__c='Contact and Institution',Admin_Setting__c=true);
        insert nvsetupObj;
        System.assertNotEquals('', nvsetupObj.Name); // (PE3.5, SK, 9Aug2017)
        
        apexpages.currentpage().getparameters().put('id',testContactObj.id);
        ContactTransfer_ctlr contactTransferObj= new ContactTransfer_ctlr(new ApexPages.StandardController(testContactObj));
        
        
        contactTransferObj.contactLookup = testContactObj1;
        contactTransferObj.contactName = testContactObj.FirstName+' '+testContactObj.LastName;            
        contactTransferObj.displayMessage= '';
        contactTransferObj.isContactIdNull= false;
        contactTransferObj.legalIdOld= acc.id;
        contactTransferObj.legalIdNew = contactTransferObj.contactLookup.AccountId; 
        contactTransferObj.isError= false;
        contactTransferObj.errorMessage= '';
        contactTransferObj.isOrgSettingActive= true;
        contactTransferObj.isCode12365 = false;
        contactTransferObj.isPopupOpen = false;
        contactTransferObj.isFundraisingContact = false;        
        
        Task taskObj =new Task();
        taskObj.WhoId = testContactObj.Id;
        taskObj.Subject ='Task sub';
        taskObj.Status ='Completed';
        taskObj.Priority = 'Normal';
        taskObj.WhatId = null;
        taskObj.Institution__c = null;
        taskObj.CallDurationInSeconds =1;
        insert taskObj;
        System.assertEquals('Task sub', taskObj.Subject); // (PE3.5, SK, 9Aug2017)
        
        Task taskObj1 =new Task();
        taskObj1.WhoId = testContactObj.Id;
        taskObj1.Subject ='Task sub';
        taskObj1.Status ='Completed';
        taskObj1.Priority = 'Normal';
        taskObj1.WhatId = contactTransferObj.legalIdOld;
        taskObj1.Institution__c = null;
        taskObj1.CallDurationInSeconds =1;
        insert taskObj1;
        System.assertEquals('Task sub', taskObj1.Subject); // (PE3.5, SK, 9Aug2017)
        
        Event eventObj =new Event();
        eventObj.WhoId = testContactObj.Id;
        eventObj.Subject ='Event sub';
        eventObj.StartDateTime = DateTime.Now();
        eventObj.EndDateTime = DateTime.Now();
        eventObj.WhatId = null;
        eventObj.Institution__c = null;
        eventObj.DurationInMinutes = 0;
        insert eventObj;
        System.assertEquals('Event sub', eventObj.Subject); // (PE3.5, SK, 9Aug2017)
        
        Event eventObj1 =new Event();
        eventObj1.WhoId = testContactObj.Id;
        eventObj1.Subject ='Event sub';
        eventObj1.StartDateTime = DateTime.Now();
        eventObj1.EndDateTime = DateTime.Now();
        eventObj1.WhatId = contactTransferObj.legalIdOld;
        eventObj1.Institution__c = null;
        eventObj1.DurationInMinutes = 0;
        insert eventObj1;
        System.assertEquals('Event sub', eventObj1.Subject); // (PE3.5, SK, 9Aug2017)
        
        contactTransferObj.fetchLegalIdNew();
        contactTransferObj.beforeTransferActivity();
        contactTransferObj.transferActivity();
        contactTransferObj.contactAddressUpdate('retain');
        contactTransferObj.contactAddressUpdate('clear');
        contactTransferObj.retainAddress();
        contactTransferObj.clearAddress();        
        contactTransferObj.Cancel();
        
        contactTransferObj.contactId = apexpages.currentpage().getparameters().get('id'); 
        contactTransferObj.legalIdNew = acc1.Id;
        contactTransferObj.transferActivity();    
    }
    
    
    static TestMethod void TestMethodCase6(){
        //Create dummy contact for contact id,email id        
        Account acc = new Account();
        acc.name = 'Test Acc';
        insert acc;
        System.assertEquals('Test Acc', acc.Name); // (PE3.5, SK, 9Aug2017)
        
        Account acc1 = new Account();
        acc1.name = 'Test Acc New';
        insert acc1;     
        System.assertEquals('Test Acc New', acc1.Name); // (PE3.5, SK, 9Aug2017)
        
        Contact testContactObj = new Contact();
        testContactObj.FirstName = 'Elena';
        testContactObj.LastName = 'Gilbert';
        testContactObj.Email = 'elena@gmail.com';
        testContactObj.AccountId = acc.id;
        insert testContactObj;
        System.assertEquals('Gilbert', testContactObj.LastName); // (PE3.5, SK, 9Aug2017)
        
        Contact testContactObj1 = new Contact();
        testContactObj1.FirstName = 'Elena1';
        testContactObj1.LastName = 'Gilbert1';
        testContactObj1.Email = 'elena1@gmail.com';
        testContactObj1.AccountId = acc.id;
        insert testContactObj1;
        System.assertEquals('Gilbert1', testContactObj1.LastName); // (PE3.5, SK, 9Aug2017)  
        
        Fund__c fundObj = new Fund__c(Name='testFund',Fund_Type__c='Fund',Investment_Category__c='Fund');
        insert fundObj;
        System.assertEquals('testFund', fundObj.Name); // (PE3.5, SK, 9Aug2017)
        
        Fundraising__c fundraisingObj = new Fundraising__c(Name='testFundraising',Fund_Name__c=fundObj.id,Legal_Name__c=acc1.id);
                
       
        Navatar_Setup__c nvsetupObj = new Navatar_Setup__c(CTS_Activity__c ='Old and New Institution',CTS_Advanced__c='Contact, Institution and Custom Object',Admin_Setting__c=true);
        insert nvsetupObj;
        System.assertNotEquals('', nvsetupObj.Name); // (PE3.5, SK, 9Aug2017)
        
        apexpages.currentpage().getparameters().put('id',testContactObj.id);
        ContactTransfer_ctlr contactTransferObj= new ContactTransfer_ctlr(new ApexPages.StandardController(testContactObj));
        
        contactTransferObj.contactLookup = testContactObj1;
        contactTransferObj.contactName = testContactObj.FirstName+' '+testContactObj.LastName;            
        contactTransferObj.displayMessage= '';
        contactTransferObj.isContactIdNull= false;
        contactTransferObj.legalIdOld= acc.id;
        contactTransferObj.legalIdNew = contactTransferObj.contactLookup.AccountId; 
        contactTransferObj.isError= false;
        contactTransferObj.errorMessage= '';
        contactTransferObj.isOrgSettingActive= true;
        contactTransferObj.isCode12365 = false;
        contactTransferObj.isPopupOpen = false;
        contactTransferObj.isFundraisingContact = false;        
        
        Task taskObj =new Task();
        taskObj.WhoId = testContactObj.Id;
        taskObj.Subject ='Task sub';
        taskObj.Status ='Completed';
        taskObj.Priority = 'Normal';
        taskObj.WhatId = null;
        taskObj.Institution__c = null;
        taskObj.CallDurationInSeconds =1;
        insert taskObj;
        System.assertEquals('Task sub', taskObj.Subject); // (PE3.5, SK, 9Aug2017)
        
        Task taskObj1 =new Task();
        taskObj1.WhoId = testContactObj.Id;
        taskObj1.Subject ='Task sub';
        taskObj1.Status ='Completed';
        taskObj1.Priority = 'Normal';
        taskObj1.WhatId = contactTransferObj.legalIdOld;
        taskObj1.Institution__c = null;
        taskObj1.CallDurationInSeconds =1;
        insert taskObj1;
        System.assertEquals('Task sub', taskObj1.Subject); // (PE3.5, SK, 9Aug2017)
        
        Task taskObj2 =new Task();
        taskObj2.WhoId = testContactObj.Id;
        taskObj2.Subject ='Task sub';
        taskObj2.Status ='Completed';
        taskObj2.Priority = 'Normal';
        taskObj2.WhatId = acc1.Id;
        taskObj2.Institution__c = null;
        taskObj2.CallDurationInSeconds =1;
        insert taskObj2;
        System.assertEquals('Task sub', taskObj2.Subject); // (PE3.5, SK, 9Aug2017)
        
        Event eventObj =new Event();
        eventObj.WhoId = testContactObj.Id;
        eventObj.Subject ='Event sub';
        eventObj.StartDateTime = DateTime.Now();
        eventObj.EndDateTime = DateTime.Now();
        eventObj.WhatId = null;
        eventObj.Institution__c = null;
        eventObj.DurationInMinutes = 0;
        insert eventObj;
        System.assertEquals('Event sub', eventObj.Subject); // (PE3.5, SK, 9Aug2017)
        
        Event eventObj1 =new Event();
        eventObj1.WhoId = testContactObj.Id;
        eventObj1.Subject ='Event sub';
        eventObj1.StartDateTime = DateTime.Now();
        eventObj1.EndDateTime = DateTime.Now();
        eventObj1.WhatId = contactTransferObj.legalIdOld;
        eventObj1.Institution__c = null;
        eventObj1.DurationInMinutes = 0;
        insert eventObj1;
        System.assertEquals('Event sub', eventObj1.Subject); // (PE3.5, SK, 9Aug2017)
        
        Event eventObj2 =new Event();
        eventObj2.WhoId = testContactObj.Id;
        eventObj2.Subject ='Event sub';
        eventObj2.StartDateTime = DateTime.Now();
        eventObj2.EndDateTime = DateTime.Now();
        eventObj2.WhatId = acc1.Id;
        eventObj2.Institution__c = null;
        eventObj2.DurationInMinutes = 0;
        insert eventObj2;
        System.assertEquals('Event sub', eventObj2.Subject); // (PE3.5, SK, 9Aug2017)
        
        contactTransferObj.fetchLegalIdNew();
        contactTransferObj.beforeTransferActivity();
        contactTransferObj.transferActivity();
        contactTransferObj.contactAddressUpdate('retain');
        contactTransferObj.contactAddressUpdate('clear');
        contactTransferObj.retainAddress();
        contactTransferObj.clearAddress();        
        contactTransferObj.Cancel();
        
        contactTransferObj.contactId = apexpages.currentpage().getparameters().get('id'); 
        contactTransferObj.legalIdNew = acc1.Id;
        contactTransferObj.transferActivity();    
    }
    
    
    static TestMethod void TestMethodCase7(){
        //Create dummy contact for contact id,email id        
        Account acc = new Account();
        acc.name = 'Test Acc';
        insert acc;
        System.assertEquals('Test Acc', acc.Name); // (PE3.5, SK, 9Aug2017)
        
        Account acc1 = new Account();
        acc1.name = 'Test Acc New';
        insert acc1;     
        System.assertEquals('Test Acc New', acc1.Name); // (PE3.5, SK, 9Aug2017)
        
        Contact testContactObj = new Contact();
        testContactObj.FirstName = 'Elena';
        testContactObj.LastName = 'Gilbert';
        testContactObj.Email = 'elena@gmail.com';
        testContactObj.AccountId = acc.id;
        insert testContactObj;
        System.assertEquals('Gilbert', testContactObj.LastName); // (PE3.5, SK, 9Aug2017)
        
        Contact testContactObj1 = new Contact();
        testContactObj1.FirstName = 'Elena1';
        testContactObj1.LastName = 'Gilbert1';
        testContactObj1.Email = 'elena1@gmail.com';
        testContactObj1.AccountId = acc.id;
        insert testContactObj1;
        System.assertEquals('Gilbert1', testContactObj1.LastName); // (PE3.5, SK, 9Aug2017)   
        
        Fund__c fundObj = new Fund__c(Name='testFund',Fund_Type__c='Fund',Investment_Category__c='Fund');
        insert fundObj;
        System.assertEquals('testFund', fundObj.Name); // (PE3.5, SK, 9Aug2017)
        
        Fundraising__c fundraisingObj = new Fundraising__c(Name='testFundraising',Fund_Name__c=fundObj.id,Legal_Name__c=acc1.id);
        
        
        Task taskObj =new Task();
        taskObj.Subject ='Task sub';
        taskObj.Status ='Completed';
        taskObj.Priority = 'Normal';
        taskObj.WhatId = null;
        taskObj.Institution__c = null;
        taskObj.CallDurationInSeconds =1;
        insert taskObj;
        System.assertEquals('Task sub', taskObj.Subject); // (PE3.5, SK, 9Aug2017)
        
        Event eventObj =new Event();
        eventObj.Subject ='Event sub';
        eventObj.StartDateTime = DateTime.Now();
        eventObj.EndDateTime = DateTime.Now();
        eventObj.WhatId = null;
        eventObj.Institution__c = null;
        insert eventObj;
        System.assertEquals('Event sub', eventObj.Subject); // (PE3.5, SK, 9Aug2017)
        
        Navatar_Setup__c nvsetupObj = new Navatar_Setup__c(CTS_Activity__c ='Old Institution Only1',CTS_Advanced__c='Contact Only',Admin_Setting__c=true);
        insert nvsetupObj;
        System.assertNotEquals('', nvsetupObj.Name); // (PE3.5, SK, 9Aug2017)
         
        ContactTransfer_ctlr contactTransferObj= new ContactTransfer_ctlr(new ApexPages.StandardController(testContactObj));
        
        contactTransferObj.contactLookup = testContactObj1;
        contactTransferObj.contactName = testContactObj.FirstName+' '+testContactObj.LastName;            
        contactTransferObj.displayMessage= '';
        contactTransferObj.isContactIdNull= true;
        contactTransferObj.isError= true;
        contactTransferObj.errorMessage= '';
        contactTransferObj.isOrgSettingActive= false;
        contactTransferObj.isCode12365 = true;
        contactTransferObj.isPopupOpen = true;
        contactTransferObj.isFundraisingContact = true;        
        
        contactTransferObj.fetchLegalIdNew();
        contactTransferObj.beforeTransferActivity();
        contactTransferObj.transferActivity();
        contactTransferObj.contactAddressUpdate('rgvfvf');        
        contactTransferObj.retainAddress();
        contactTransferObj.clearAddress();        
        contactTransferObj.Cancel();
        
        contactTransferObj.contactId = apexpages.currentpage().getparameters().get('id'); 
        contactTransferObj.transferActivity();    
    }
    
    
    static TestMethod void TestMethodCase8(){
        //Create dummy contact for contact id,email id        
        Account acc = new Account();
        acc.name = 'Test Acc';
        insert acc;
        System.assertEquals('Test Acc', acc.Name); // (PE3.5, SK, 9Aug2017)
        
        Account acc1 = new Account();
        acc1.name = 'Test Acc New';
        insert acc1;     
        System.assertEquals('Test Acc New', acc1.Name); // (PE3.5, SK, 9Aug2017)
        
        Contact testContactObj = new Contact();
        testContactObj.FirstName = 'Elena';
        testContactObj.LastName = 'Gilbert';
        testContactObj.Email = 'elena@gmail.com';
        testContactObj.AccountId = acc.id;
        insert testContactObj;
        System.assertEquals('Gilbert', testContactObj.LastName); // (PE3.5, SK, 9Aug2017)
        
        Contact testContactObj1 = new Contact();
        testContactObj1.FirstName = 'Elena1';
        testContactObj1.LastName = 'Gilbert1';
        testContactObj1.Email = 'elena1@gmail.com';
        testContactObj1.AccountId = acc.id;
        insert testContactObj1;
        System.assertEquals('Gilbert1', testContactObj1.LastName); // (PE3.5, SK, 9Aug2017)
        
        Fund__c fundObj = new Fund__c(Name='testFund',Fund_Type__c='Fund',Investment_Category__c='Fund');
        insert fundObj;
        System.assertEquals('testFund', fundObj.Name); // (PE3.5, SK, 9Aug2017)
        
        
        Task taskObj =new Task();
        taskObj.WhoId = testContactObj.Id;
        taskObj.Subject ='Task sub';
        taskObj.Status ='Completed';
        taskObj.Priority = 'Normal';
        taskObj.WhatId = null;
        taskObj.Institution__c = null;
        taskObj.CallDurationInSeconds =1;
        insert taskObj;
        System.assertEquals('Task sub', taskObj.Subject); // (PE3.5, SK, 9Aug2017)
        
        Event eventObj =new Event();
        eventObj.WhoId = testContactObj.Id;
        eventObj.Subject ='Event sub';
        eventObj.StartDateTime = DateTime.Now();
        eventObj.EndDateTime = DateTime.Now();
        eventObj.WhatId = null;
        eventObj.Institution__c = null;
        eventObj.DurationInMinutes = 0;
        insert eventObj;
        System.assertEquals('Event sub', eventObj.Subject); // (PE3.5, SK, 9Aug2017)
        
        
        apexpages.currentpage().getparameters().put('id',testContactObj.id); 
        ContactTransfer_ctlr contactTransferObj= new ContactTransfer_ctlr(new ApexPages.StandardController(testContactObj));
        
        contactTransferObj.contactLookup = testContactObj1;
        contactTransferObj.contactName = testContactObj.FirstName+' '+testContactObj.LastName;            
        contactTransferObj.displayMessage= '';
        contactTransferObj.isContactIdNull= false;
        contactTransferObj.legalIdOld= acc.id;
        contactTransferObj.legalIdNew = contactTransferObj.contactLookup.AccountId; 
        contactTransferObj.isError= false;
        contactTransferObj.errorMessage= '';
        contactTransferObj.isOrgSettingActive= true;
        contactTransferObj.isCode12365 = false;
        contactTransferObj.isPopupOpen = false;
        contactTransferObj.isFundraisingContact = false;        
        
        contactTransferObj.fetchLegalIdNew();
        contactTransferObj.beforeTransferActivity();
        
        //contactTransferObj.transferActivity();
        Affiliation__c affiliationObj = new Affiliation__c(Contact__c=testContactObj.Id,Institution__c = acc.Id);
        insert affiliationObj;
        contactTransferObj.contactAddressUpdate('retain');
        contactTransferObj.contactAddressUpdate('clear');
        contactTransferObj.retainAddress();
        contactTransferObj.clearAddress();    
        //contactTransferObj.contactId = '32133232323';
        contactTransferObj.Cancel();
        
        contactTransferObj.contactId = apexpages.currentpage().getparameters().get('id'); 
        
        //Fundraising_Contact__c fundraisingContactObj = new Fundraising_Contact__c();
        //fundraisingContactObj.Contact__c=contactTransferObj.contactId;
        //fundraisingContactObj.Fundraising__c=fundraisingObj.Id;
        //fundraisingContactObj.Institution__c=acc1.Id;
        //fundraisingContactObj.IsPrimary__c = false;
        //insert fundraisingContactObj;
        
        
        contactTransferObj.legalIdNew = '';
        contactTransferObj.transferActivity();    
        
        contactTransferObj.inputValue = '';
        contactTransferObj.contactPE = new Contact();
        contactTransferObj.namespacePE = '';
        contactTransferObj.contactDetailPagePath = '';
        contactTransferObj.legalNameNew = '';
        contactTransferObj.serverUrl = ''; 
    }*/
    
}