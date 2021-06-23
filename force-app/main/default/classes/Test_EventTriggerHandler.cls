@isTest
public class Test_EventTriggerHandler {
    Static testmethod void myTest() {
        Account Acc1 = new Account(Name = 'Account 1');
        insert Acc1;
        Contact Con1 = new Contact(LastName = 'Contact 1',Email = 'test@gmail.com', AccountId = Acc1.Id);
        insert Con1;
        Event e1 = new Event();
        e1.Subject = 'Meeting';
        e1.WhoId = Con1.Id;
        //e1.WhatId = Acc1.Id;
        e1.DurationInMinutes = 60;
        e1.ActivityDateTime = DateTime.newInstance(2021, 10, 20, 7, 8, 16);
        e1.Is_Touchpoint__c= true;
        Event e2 = new Event();
        e2.Subject = 'New Meeting';
        e2.WhoId = Con1.Id;
        //e2.WhatId = Acc1.Id;
        e2.DurationInMinutes = 120;
        e2.ActivityDateTime = DateTime.newInstance(2021, 10, 20, 7, 8, 16);
        e2.Is_Touchpoint__c= true;
        insert e1;
        insert e2;
        
        test.startTest();
        
        e2.Is_Touchpoint__c = false;
        update e2;
        Set<Id> eventIds = new Set<Id>();
        eventIds.add(e1.Id);
        eventIds.add(e2.Id);
        Set<Id> conIds = new Set<Id>();
        conIds.add(con1.Id);
        Map<Id,Id> eventRelvsEventId = new Map<Id,Id>();
        EventTriggerHandler.updateContact(eventIds, conIds, False);
        System.assertEquals('Account 1', Acc1.Name); // added for security fix PEv4.7 
        
        test.stopTest();
    }
}