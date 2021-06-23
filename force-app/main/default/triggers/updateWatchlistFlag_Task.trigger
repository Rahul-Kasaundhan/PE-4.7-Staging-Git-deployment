/*
* --------------------------------------------------------------------------------------------------
* To update Is_Watchlist_Activity__c field on task if ant related contact's account status is watchlist.
* --------------------------------------------------------------------------------------------------
* @author         Raghvendra Jha
* @modifiedBy     Raghvendra Jha
* @version        1.0
* @created        2020-06-03
* @modified       2020-06-03
*/
trigger updateWatchlistFlag_Task on Task (after insert, after update,before update, before delete, after undelete){ // added before delete and after undelete to merge taskTrigger in it PEv4.7 security fix
    
    if(Trigger.isAfter &&  !system.isFuture() && UpdateWatchlistFlagHelper.isTriggerCall){
        UpdateWatchlistFlagHelper.OnAfterInsUpdDel(Trigger.NewMap,Trigger.oldMap);
    }
    // start changes to add taskTrigger 
    if(Trigger.isAfter && !system.isFuture()){
        TaskTriggerHandler.OnAfterInsUpdDel(Trigger.New,Trigger.oldMap);
    }
    else{
        if(!system.isFuture()){
            TaskTriggerHandler.OnAfterInsUpdDel(Trigger.Old,Trigger.oldMap);
        }
    }
    // end changes to add taskTrigger 
}