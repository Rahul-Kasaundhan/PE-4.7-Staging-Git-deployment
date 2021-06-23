/*
* --------------------------------------------------------------------------------------------------
* To calculate the Last Touch point from task based activity date field and update
* Last Touch Point date Contact.
* --------------------------------------------------------------------------------------------------
* @author         Rahul Kumar Kasaundhan
* @modifiedBy     rahul kumar Kasaundhan
* @version        2.8
* @created        13-10-2020
* @modified       13-10-2020
*/
trigger eventTrigger on Event (after insert, after update, before delete, after undelete){
    
    List<Event> evtList = Trigger.isDelete ? Trigger.Old : Trigger.New;
    EventTriggerHandler.OnAfterInsUpdDel(evtList, Trigger.oldMap);
    
}