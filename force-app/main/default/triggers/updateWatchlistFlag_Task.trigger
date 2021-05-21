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
trigger updateWatchlistFlag_Task on Task (after insert, after update,before update){
    
    if(Trigger.isAfter &&  !system.isFuture() && UpdateWatchlistFlagHelper.isTriggerCall){
        UpdateWatchlistFlagHelper.OnAfterInsUpdDel(Trigger.NewMap,Trigger.oldMap);
    }
}