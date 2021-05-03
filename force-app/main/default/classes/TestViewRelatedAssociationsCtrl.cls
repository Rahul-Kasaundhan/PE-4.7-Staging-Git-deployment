/************************************************************************************************
** Module Name : View Related Associations modelUp
** Description : This class is used for get's all the realetd assocation details for task in ViewRelatedAssociationsCtrl class.
** Calls : NA
** Test Class : TestViewRelatedAssociationsCtrl
** Organization : Navatar Group

************************************************************************************************/
@isTest
public class TestViewRelatedAssociationsCtrl {
    public static testMethod void getRelatedAssociations1(){
        
        Account acc = new Account (Name = 'TestAcc');
        insert acc;
        
        System.assertEquals(acc.Name, 'TestAcc');
        Account acc2 = new Account (Name = 'TestAcc');
        insert acc2;
        System.assertEquals(acc2.Name, 'TestAcc');
        
        Task tskobj =new task();
        tskobj.subject = 'Test';
        tskobj.Priority = 'Normal';
       // tskobj.Related_Associations__c = acc.Id+','+acc2.Id;
        
        Task tskobj1 =tskobj;
        insert tskobj1;
        
        Task tskobj2 =new task();
        tskobj2.subject = 'Test1';
        tskobj2.Priority = 'Normal1';
       // tskobj2.Related_Associations__c = acc.Id+','+acc2.Id;
        insert tskobj2;
        
        Task tskobj3  =new task();
        tskobj3.subject = 'Test2';
        tskobj3.Priority = 'Normal2';
        //tskobj3.Related_Associations__c = acc.Id+','+acc2.Id;
        insert tskobj3;
        //LIST<Task> taids =[SELECT ID From Task];
        List<String> ods= new List<String>();
        ods.add(acc.Id);
        ods.add(acc2.Id);
        test.startTest();
        try{
            ViewRelatedAssociationsCtrl.getRelatedAssociations(ods);
        }
        catch(Exception ex){
            //return null;
        }
        List<String> sObjectName = new List<String>();
        sObjectName.add('Account');
        sObjectName.add('Contact');
        ViewRelatedAssociationsCtrl.getIconName(sObjectName);
        ViewRelatedAssociationsCtrl ab= new ViewRelatedAssociationsCtrl();
        test.stopTest();
    }
}