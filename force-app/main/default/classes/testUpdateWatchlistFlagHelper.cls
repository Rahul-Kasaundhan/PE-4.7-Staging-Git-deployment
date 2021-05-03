@isTest
public class testUpdateWatchlistFlagHelper {
    @testSetup
    static void createDisplayFieldSetup() {
         Account acc = new Account(Name='Sample',Status__c= 'Watchlist');
      
        insert acc;
        Contact C1 = new Contact (Lastname='Roger',AccountId=acc.Id);
        Insert c1;
        Task tsk = new Task(Subject='Demo WatchLit',Whoid=C1.Id);
        Insert tsk;
    }  
     @isTest
    static void test_DisplayFieldSetCtrl(){
        list<task> tasks = [select id from task ];
        tasks[0].whoid = null;
        update tasks;
        // added for security issue PEv4.7 by Aditya on 23 March 2021
        task t = [select id,whoid from task where id=:tasks[0].id];
        system.assertEquals(null,t.whoid);
    }
    
    @isTest
    static void test_OnAfterUpdateAsync() {
        Account acc = new Account(Name='New Account',Status__c='Watchlist');
        insert acc;
        Contact con = new Contact(LastName='Wayne',AccountId=acc.Id);
        insert con;
        Contact con1 = new Contact(LastName='Luther',AccountId=acc.Id);
        insert con1;
        Set<Id> cons = new Set<Id>();
        cons.add(con.Id);
        cons.add(con1.Id);
        UpdateWatchlistFlagHelper.OnAfterUpdateAsync(cons);
        system.assertEquals('Luther',con1.LastName); 
    }
}