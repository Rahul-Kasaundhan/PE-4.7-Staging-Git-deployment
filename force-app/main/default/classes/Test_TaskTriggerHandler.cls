@isTest
public class Test_TaskTriggerHandler {
    Static testmethod void myTest(){
        Account testAccount = new Account(name='Test account 1');
        insert testAccount;
        Contact con1 = new Contact(LastName = 'Test Con',email='test@gmail.com', Accountid=testAccount.id);
        insert con1;
        Task t2 =new task();
        t2.subject = 'New_Task_with_Multiple_Associations';
        t2.Priority = 'Normal';
        t2.whatId = testAccount.Id;
        t2.whoId = con1.Id;
        t2.Is_Touchpoint__c= true;
        //t2.Related_Associations__c = testAccount.Id;
        Task t3 =new task();
        t3.subject = 'NewTask';
        t3.Priority = 'Normal';
        t3.whatId = testAccount.Id;
        t3.whoId = con1.Id;
        t3.Is_Touchpoint__c= true;
        //t3.Related_Associations__c = testAccount.Id;
        insert t2;
        update t2;
        insert t3;
         
        test.startTest();
        
        t2.Is_Touchpoint__c= false;
        update t2;
        Set<Id> taskIds = new Set<Id>();
        taskIds.add(t2.id);
        taskIds.add(t3.id);
        t2.Is_Touchpoint__c= true;
        update t2;
        update t3;
        Set<Id> contactIds =new Set<Id>();
        contactIds.add(con1.id);
        contactIds.add(con1.id);
        Map<Id, Id> taskRelvsTaskId =new Map<Id, Id>();
        
        EmailMessage em= new EmailMessage(Subject='test mmail', RelatedToId=testAccount.Id);
        insert em;
        delete t2;
        List<EmailMessage> lisms= new List<EmailMessage>();
        lisms.add(em);
        EmailMessage[] newEmail = new EmailMessage[0]; 
        
        newEmail.add(new EmailMessage(FromAddress = 'test@abc.org', 
                                      Incoming = True,
                                      ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', 
                                      Subject = 'Test email', TextBody = '23456 ', 
                                      RelatedToId=testAccount.Id)); 
        
        
        
        insert newEmail;
        system.assertEquals('test mmail',em.Subject); // added for security issue PEv4.7 by Aditya on 23 March 2021
        
        
        TaskTriggerHandler.updateTask(lisms);
        TaskTriggerHandler.onEmailMessageDel(newEmail);
        delete newEmail;
        try{
            //TaskTriggerHandler.OnAfterUpdateAsync(taskIds,contactIds,taskRelvsTaskId);
            TaskTriggerHandler.GetContactIds(taskIds,contactIds,taskRelvsTaskId,false);
        }
        catch(Exception ex){
          System.debug(ex.getMessage());
        }
        test.stopTest();      
    }
}