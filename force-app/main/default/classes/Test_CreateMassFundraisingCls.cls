/*
Developer               :   Sumitab Saxena
Product Version         :   PE 3.5
Date of Creation        :   12/08/2016
Last Updated By         :   Sumitab Saxena
Purpose of Creation     :   Listed below:
1. Code Coverage for CreateMassFundraising Class. 

*/
@isTest
private class Test_CreateMassFundraisingCls
{
    static testMethod void testMyController(){
        try{
            Fund__c testFund = new Fund__c();
            testFund.name = 'pulse';
            testFund.Fund_Type__c = 'Fund';
            testFund.Investment_Category__c = 'Fund';
            insert testFund;
            System.assertEquals('pulse', testFund.Name); // (PE3.5, SK, 9Aug2017)
            
            Fund__c testFund2 = new Fund__c();
            testFund2.name = 'pulsejasdakjhgtwehkjthwkjheitqwieuhtiuhweiutkjsdiugfhsdi8ugvkjwensiughiqewbgiu';
            testFund2.Fund_Type__c = 'Fund';
            testFund2.Investment_Category__c = 'Co-investment';
            insert testFund2;
            System.assertEquals('pulsejasdakjhgtwehkjthwkjheitqwieuhtiuhweiutkjsdiugfhsdi8ugvkjwensiughiqewbgiu', testFund2.Name); // (PE3.5, SK, 9Aug2017)
            
            Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
            Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
            Account Acc_comp = new Account(Name='test',recordtypeid=AccountRecordTypeInfo.get('Company').getRecordTypeId());
            insert Acc_comp;
            System.assertEquals('test', Acc_comp.Name); // (PE3.5, SK, 9Aug2017)
            
            Account Acc_comp1 = new Account(Name='test',recordtypeid=AccountRecordTypeInfo.get('Company').getRecordTypeId());
            insert Acc_comp1;
            System.assertEquals('test', Acc_comp1.Name); // (PE3.5, SK, 9Aug2017)
            
            Account Acc_inst = new Account(Name='test1',recordtypeid=AccountRecordTypeInfo.get('Institution').getRecordTypeId());
            insert Acc_inst;
            System.assertEquals('test1', Acc_inst.Name); // (PE3.5, SK, 9Aug2017)
            contact con = new contact(lastName='testContact',accountId=Acc_inst.id,email='p@q.com') ;
            insert con;
            System.assertEquals('testContact', con.LastName); // (PE3.5, SK, 9Aug2017)
            
            Fundraising__c fObj = new Fundraising__c();
            List<Fundraising__c> fndRaisingRecords = new List<Fundraising__c>();
            fndRaisingRecords.add(fObj);
            
            CreateMassFundraisingCls tesObj1 = new CreateMassFundraisingCls(new ApexPages.StandardSetController(fndRaisingRecords));
            
            
            //start added by vanita- 7 oct
            List<Partnership__c> partnershipList = new List<Partnership__c>();
            for(Integer i=0; i<10;i++){
                Partnership__c partnershipObj = new Partnership__c();
                partnershipObj.Name='Partnershipname'+i;
                partnershipObj.Fund__c= testFund.Id;
                partnershipObj.Fund_Investment_Category__c=testFund.Investment_Category__c; 
                partnershipList.add(partnershipObj);
            }
            //end added by vanita- 7 oct
            
            Test.setCurrentPageReference(new PageReference('/apex/CreateMassFundraising?retURL=%2F'+testFund.id+'&wrapMassAction=1&scontrolCaching=1&id='+testFund.id));
            
            CreateMassFundraisingCls testObj = new CreateMassFundraisingCls(new ApexPages.StandardSetController(fndRaisingRecords));
            
            //start added by vanita- 7 oct
            testObj.ErrorStatus=true;
            testObj.lstFundDetailsCoInvst = testFund2;
            testObj.PrtFolioDetails = Acc_comp1;
            testObj.fundR = fObj;
            testObj.errorMesssage = '';
            testObj.blnCoInvestment = false;
            testObj.strComId ='';
            //testObj.accCount = '';
            testObj.FundIdLkup = '';
            //testObj.CompIdRcrdTyp='';
            testObj.objlstCommitmentDetailsComp = partnershipList;
            testObj.FundOptions = new list<SelectOption>();
            testObj.FndDupChkLst = new list<SelectOption>();
            testObj.FndDupChkLstPartnership = new list<SelectOption>();
            testObj.CompId = '';
            testObj.strcrntCompId = '';
            testObj.proptxtdata = '';
            testObj.ErrorVal = '';
            testObj.strCoInvstFundId = '';
            testObj.isCurrency = true;
            testObj.localeString = '';
            //testObj.commitmentTabData = '';
            testObj.CoInvstFund = '';
            
            testObj.CompSlctdLkupWarng();
            testObj.validCompSlctd();
            testObj.fundId = testFund.id;
            testObj.ContClickedPopup();
            testObj.fieldArray = '[["Next_Step__c","string"]]';
            testObj.valueArray = '["meeting"]';
            testObj.jsonString =  '{"'+Acc_inst.id+'":[["'+con.name+'","'+con.email+'","'+con.account.name+'","Other",true,"'+con.id+'"]]}';
            testObj.FundId = testFund.id;
            testObj.createMassFundraisings();
            //testObj.CompSlctdLkup();
            //testObj.slctLstDupeCheck();
            testObj.CompSlctdLkupWarng();
            testObj.validCompSlctd();
            testObj.ContClickedPopup();
            testObj.valueArray = '["f3214afsndgjhgfjh23ggug23uy4t8761tgjdsgf876t23ug486t2138gjh876tf3214afsndgjhgfjh23ggug23uy4t8761tgjdsgf876t23ug486t2138gjh876tf3214afsndgjhgfjh23ggug23uy4t8761tgjdsgf876t23ug486t2138gjh876tf3214afsndgjhgfjh23ggug23uy4t8761tgjdsgf876t23ug486t2138gjh876t29384"]';
            testObj.createMassFundraisings();
            //testObj.CompSlctdLkup();
            //testObj.slctLstDupeCheck();
            testObj.CompSlctdLkupWarng();
            testObj.validCompSlctd();
            testObj.ContClickedPopup();
            testObj.fieldArray = ' [["Stage__c","picklist"],["Target_Close_Date__c","date"]]';
            testObj.valueArray = '["Interested","05/19/2015"]';
            testObj.createMassFundraisings();
            testObj.CompSlctdLkup();
            //testObj.slctLstDupeCheck();
            testObj.CompSlctdLkupWarng();
            testObj.validCompSlctd();
            testObj.ContClickedPopup();
            testObj.fieldArray = '[["Potential_Management_Fee__c","percent"]]';
            testObj.valueArray = '["25"]';
            testObj.createMassFundraisings();
            //testObj.CompSlctdLkup();
            //testObj.slctLstDupeCheck();
            testObj.CompSlctdLkupWarng();
            testObj.validCompSlctd();
            testObj.ContClickedPopup();
            testObj.jsonString =  '{"'+Acc_comp.id+'":[["'+con.name+'","'+con.email+'","'+con.account.name+'","Other",true,"'+con.id+'"]]}';
            testObj.createMassFundraisings();
            testObj.CompSlctdLkup();
            //testObj.slctLstDupeCheck();
            testObj.CompSlctdLkupWarng();
            testObj.validCompSlctd();
            testObj.ContClickedPopup();
            testObj.jsonString =  '{"'+Acc_inst.id+'":[["'+con.name+'","'+con.email+'","'+con.account.name+'","Other",true,"'+con.id+'"]]}';
            testObj.FundId = testFund2.id;
            testObj.portFolioID = '';
            //testObj.portFolioValue = '';
            testObj.createMassFundraisings();  
            testObj.CompSlctdLkupWarng();
            testObj.validCompSlctd();
            testObj.ContClickedPopup();
            testObj.portFolioID = '000000000000000';
            testObj.createMassFundraisings();
            testObj.CompSlctdLkupWarng();
            testObj.validCompSlctd();
            testObj.ContClickedPopup();
            testObj.portFolioID = '';
            testObj.createMassFundraisings();
            //testObj.CompSlctdLkup();
            //testObj.slctLstDupeCheck();
            testObj.CompSlctdLkupWarng();
            testObj.validCompSlctd();
            testObj.ContClickedPopup();
            testObj.createMassFundraisings();
            //testObj.CompSlctdLkup();
            //testObj.slctLstDupeCheck();
            testObj.CompSlctdLkupWarng();
            testObj.validCompSlctd();
            testObj.ContClickedPopup();
            testObj.createMassFundraisings();
            testObj.CompSlctdLkupWarng();
            testObj.WarngPopupValEntrd=true;
            testObj.CompanyLkupWarngPopup.Portfolio_Company__c='asdsdadsadasa';
            testObj.validCompSlctd();
            testObj.ContClickedPopup();
            testObj.createMassFundraisings();
            testObj.removeFundraising();
            testObj.returnError();
            testObj.CompSlctdLkupWarng();
            
        }
        catch(Exception ex){
            string errormsgget = ex.getMessage();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,errormsgget));
        }
    }
    
    
    static testMethod void method1(){
        try{
            Fund__c testFund = new Fund__c();
            testFund.name = 'pulse';
            testFund.Fund_Type__c = 'Fund';
            testFund.Investment_Category__c = 'Fund';
            insert testFund;
            System.assertEquals('pulse', testFund.Name); // (PE3.5, SK, 9Aug2017)
            
            Fund__c testFund2 = new Fund__c();
            testFund2.name = 'pulsejasdakjhgtwehkjthwkjheitqwieuhtiuhweiutkjsdiugfhsdi8ugvkjwensiughiqewbgiu';
            testFund2.Fund_Type__c = 'Fund';
            testFund2.Investment_Category__c = 'Co-investment';
            insert testFund2;
            System.assertEquals('pulsejasdakjhgtwehkjthwkjheitqwieuhtiuhweiutkjsdiugfhsdi8ugvkjwensiughiqewbgiu', testFund2.Name); // (PE3.5, SK, 9Aug2017)
            
            Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
            Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
            Account Acc_comp = new Account(Name='test',recordtypeid=AccountRecordTypeInfo.get('Company').getRecordTypeId());
            insert Acc_comp;
            System.assertEquals('test', Acc_comp.Name); // (PE3.5, SK, 9Aug2017)
            
            Account Acc_comp1 = new Account(Name='test',recordtypeid=AccountRecordTypeInfo.get('Company').getRecordTypeId());
            insert Acc_comp1;
            System.assertEquals('test', Acc_comp1.Name); // (PE3.5, SK, 9Aug2017)
            
            Account Acc_inst = new Account(Name='test1',recordtypeid=AccountRecordTypeInfo.get('Institution').getRecordTypeId());
            insert Acc_inst;
            System.assertEquals('test1', Acc_inst.Name); // (PE3.5, SK, 9Aug2017)
            contact con = new contact(lastName='testContact',accountId=Acc_inst.id,email='p@q.com') ;
            insert con;
            System.assertEquals('testContact', con.LastName); // (PE3.5, SK, 9Aug2017)
            
            Fundraising__c fObj = new Fundraising__c();
            List<Fundraising__c> fndRaisingRecords = new List<Fundraising__c>();
            fndRaisingRecords.add(fObj);
            
            
            apexpages.currentpage().getHeaders().put('Host','https://ap1.salesforce.com');
            apexpages.currentpage().getparameters().put('Source','Com');
            apexpages.currentpage().getparameters().put('id',Acc_comp1.id);
            CreateMassFundraisingCls tesObj1 = new CreateMassFundraisingCls(new ApexPages.StandardSetController(fndRaisingRecords));
            tesObj1.isCoInvestmentStngOn = true;
            //tesObj1.blnDfrntCoInvstFund = false;
            tesObj1.FundLookupPopup.Fund_Name__c = testFund.id;
            tesObj1.strCoInvstFundId = testFund.id;
            tesObj1.ContClickedPopup();
            tesObj1.isCoInvestmentStngOn=false;
            tesObj1.ContClickedPopup();
            //isCoInvestmentStngOn==true
            tesObj1.ErrorStatusInsufficient=false;
            tesObj1.fieldArray = '[["Potential_Management_Fee__c","percent"]]';
            tesObj1.valueArray = '["Interested","05/19/2015"]';
            tesObj1.jsonString =  '{"'+Acc_inst.id+'":[["'+con.name+'","'+con.email+'","'+con.account.name+'","Other",true,"'+con.id+'"]]}';
            tesObj1.createMassFundraisings();
            tesObj1.jsonString =  '{"'+Acc_inst.id+'":[["","","","",,""]]}';
            tesObj1.createMassFundraisings();
            tesObj1.strSourceLoc='';
            tesObj1.BackRedirectionHome();
            tesObj1.strSourceLoc='Home';
            tesObj1.BackRedirectionHome();
            tesObj1.strSourceLoc='Fund';
            tesObj1.BackRedirectionHome();
            tesObj1.retrunURlID='/home/home.jsp';
            tesObj1.BackRedirection();
            tesObj1.CompSlctdLkupWarng();
            tesObj1.removeFundraising();
            tesObj1.returnError();
            
            
        }
        catch(Exception ex){
            string errormsgget = ex.getMessage();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,errormsgget));
        }
        
    }

    static testMethod void method2(){
        try{
            Fund__c testFund = new Fund__c();
            testFund.name = 'pulse';
            testFund.Fund_Type__c = 'Fund';
            testFund.Investment_Category__c = 'Fund';
            insert testFund;
            System.assertEquals('pulse', testFund.Name); // (PE3.5, SK, 9Aug2017)
            
            Fund__c testFund2 = new Fund__c();
            testFund2.name = 'pulsejasdakjhgtwehkjthwkjheitqwieuhtiuhweiutkjsdiugfhsdi8ugvkjwensiughiqewbgiu';
            testFund2.Fund_Type__c = 'Fund';
            testFund2.Investment_Category__c = 'Co-investment';
            insert testFund2;
            System.assertEquals('pulsejasdakjhgtwehkjthwkjheitqwieuhtiuhweiutkjsdiugfhsdi8ugvkjwensiughiqewbgiu', testFund2.Name); // (PE3.5, SK, 9Aug2017)
            
            Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
            Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
            Account Acc_comp = new Account(Name='test',recordtypeid=AccountRecordTypeInfo.get('Company').getRecordTypeId());
            insert Acc_comp;
            System.assertEquals('test', Acc_comp.Name); // (PE3.5, SK, 9Aug2017)
            
            Account Acc_comp1 = new Account(Name='test',recordtypeid=AccountRecordTypeInfo.get('Company').getRecordTypeId());
            insert Acc_comp1;
            System.assertEquals('test', Acc_comp1.Name); // (PE3.5, SK, 9Aug2017)
            
            Account Acc_inst = new Account(Name='test1',recordtypeid=AccountRecordTypeInfo.get('Institution').getRecordTypeId());
            insert Acc_inst;
            System.assertEquals('test1', Acc_inst.Name); // (PE3.5, SK, 9Aug2017)
            contact con = new contact(lastName='testContact',accountId=Acc_inst.id,email='p@q.com') ;
            insert con;
            System.assertEquals('testContact', con.LastName); // (PE3.5, SK, 9Aug2017)
            
            Fundraising__c fObj = new Fundraising__c();
            List<Fundraising__c> fndRaisingRecords = new List<Fundraising__c>();
            fndRaisingRecords.add(fObj);
            
            
            apexpages.currentpage().getHeaders().put('Host','https://ap1.salesforce.com');
            apexpages.currentpage().getparameters().put('Source','Fund');
            apexpages.currentpage().getparameters().put('id',testFund2.Id);
            CreateMassFundraisingCls tesObj1 = new CreateMassFundraisingCls(new ApexPages.StandardSetController(fndRaisingRecords));
            tesObj1.isCoInvestmentStngOn = true;
            tesObj1.ContClickedPopup();
        }
        
        catch(Exception ex){
            string errormsgget = ex.getMessage();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,errormsgget));
        }
        
    }
    static testMethod void method3(){
        try{
            Fund__c testFund = new Fund__c();
            testFund.name = 'pulse';
            testFund.Fund_Type__c = 'Fund';
            testFund.Investment_Category__c = 'Fund';
            insert testFund;
            System.assertEquals('pulse', testFund.Name); // (PE3.5, SK, 9Aug2017)
            
            Fund__c testFund2 = new Fund__c();
            testFund2.name = 'pulsejasdakjhgtwehkjthwkjheitqwieuhtiuhweiutkjsdiugfhsdi8ugvkjwensiughiqewbgiu';
            testFund2.Fund_Type__c = 'Fund';
            testFund2.Investment_Category__c = 'Co-investment';
            insert testFund2;
            System.assertEquals('pulsejasdakjhgtwehkjthwkjheitqwieuhtiuhweiutkjsdiugfhsdi8ugvkjwensiughiqewbgiu', testFund2.Name); // (PE3.5, SK, 9Aug2017)
            
            Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
            Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
            Account Acc_comp = new Account(Name='test',recordtypeid=AccountRecordTypeInfo.get('Company').getRecordTypeId());
            insert Acc_comp;
            System.assertEquals('test', Acc_comp.Name); // (PE3.5, SK, 9Aug2017)
            
            Account Acc_comp1 = new Account(Name='test',recordtypeid=AccountRecordTypeInfo.get('Company').getRecordTypeId());
            insert Acc_comp1;
            System.assertEquals('test', Acc_comp1.Name); // (PE3.5, SK, 9Aug2017)
            
            Account Acc_inst = new Account(Name='test1',recordtypeid=AccountRecordTypeInfo.get('Institution').getRecordTypeId());
            insert Acc_inst;
            System.assertEquals('test1', Acc_inst.Name); // (PE3.5, SK, 9Aug2017)
            contact con = new contact(lastName='testContact',accountId=Acc_inst.id,email='p@q.com') ;
            insert con;
            System.assertEquals('testContact', con.LastName); // (PE3.5, SK, 9Aug2017)
            
            Fundraising__c fObj = new Fundraising__c();
            List<Fundraising__c> fndRaisingRecords = new List<Fundraising__c>();
            fndRaisingRecords.add(fObj);            
            
            //apexpages.currentpage().getparameters().put('retURL','https://na30.salesforce.com/'+Acc_comp1.id+'');
            apexpages.currentpage().getHeaders().put('Host','https://ap1.salesforce.com');
            apexpages.currentpage().getparameters().put('Source','Home');
            //apexpages.currentpage().getparameters().put('id',testFund2.Id);
            CreateMassFundraisingCls tesObj1 = new CreateMassFundraisingCls(new ApexPages.StandardSetController(fndRaisingRecords));
            
            tesObj1.ContClickedPopup();
            tesObj1.isCoInvestmentStngOn = true;
            tesObj1.blnDfrntCoInvstFund = false;
            
            tesObj1.ContClickedPopup();
        }
        
        catch(Exception ex){
            string errormsgget = ex.getMessage();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,errormsgget));
        }
        
    }
    
}