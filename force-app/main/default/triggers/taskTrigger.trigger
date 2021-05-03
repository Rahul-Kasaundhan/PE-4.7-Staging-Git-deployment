/*
* --------------------------------------------------------------------------------------------------
* To calculate the Last Touch point from task based activity date field and update
* Last Touch Point date Contact.
* --------------------------------------------------------------------------------------------------
* @author         Raghvendra Jha
* @modifiedBy     Raghvendra Jha
* @version        1.0
* @created        2019-11-26
* @modified       2019-11-27
*/
trigger taskTrigger on Task (after insert, after update, before delete, after undelete, before update){
    
    if(Trigger.isAfter && !system.isFuture()){
        TaskTriggerHandler.OnAfterInsUpdDel(Trigger.New,Trigger.oldMap);
    }
    else{
        if(!system.isFuture()){
            TaskTriggerHandler.OnAfterInsUpdDel(Trigger.Old,Trigger.oldMap);
        }
    }
    // added for security fix PEv4.7 9 April 2021
    if(Trigger.isAfter &&  !system.isFuture() && UpdateWatchlistFlagHelper.isTriggerCall){
        UpdateWatchlistFlagHelper.OnAfterInsUpdDel(Trigger.NewMap,Trigger.oldMap);
    }
}