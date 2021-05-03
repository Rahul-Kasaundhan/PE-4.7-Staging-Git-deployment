/*
* --------------------------------------------------------------------------------------------------
* To update Watchlist__c field on task if ant related contact's account status is watchlist.
* --------------------------------------------------------------------------------------------------
* @author         Raghvendra Jha
* @modifiedBy     Raghvendra Jha
* @version        1.0
* @created        2020-06-03
* @modified       2020-06-03
*/

public class UpdateWatchlistFlagHelper{ 
    public static boolean isTriggerCall =true;
    private static string nameSpace = sdgNamespaceUtility2.GetNamespace(); // to get namespace 
    
    /*
@ OnAfterInsUpdDel: 
@Description : will handle post update task opeartion if taskrelations are updates
*/
    public static void OnAfterInsUpdDel(Map<Id,Task> newTaskMap,Map<Id,Task>OldTaskMap){
        list<Task> tasksToUpdate = new List<Task>();
        Map<Id,Id> whoIdChangedTasks = new Map<Id,Id>();
        Map<Id, Contact> watchListContacts = new Map<Id, Contact>();
        
        for(Task oTask : newTaskMap.values()){
            if(oTask.WhoId != null && !oTask.watchlist__c){
                whoIdChangedTasks.put(oTask.Id,oTask.WhoId);
            }
        }
        //get the contact ids from task relation if TaskRelation feature is enable.
        if(whoIdChangedTasks.size()>0){
            if(Schema.getGlobalDescribe().containsKey('TaskRelation') && !Test.isRunningTest()){
                OnAfterUpdateAsync(whoIdChangedTasks.keySet());
            }
            else if(whoIdChangedTasks.size()>0){
                //watchListContacts = new Map<Id, Contact>([SELECT Id FROM Contact WHERE ID IN :whoIdChangedTasks.values() AND Account.'+pem_dev__Status__c+' = 'Watchlist']);
                // Handle Namespace for status in PE v4.7 By Rahulk 05-03-2021
                List<Id> whoIdChangedTasksValues = whoIdChangedTasks.values();
                String theQuery = 'SELECT Id FROM Contact WHERE ID IN :whoIdChangedTasksValues and Account.'+nameSpace+'Status__c=\'Watchlist\'';
				System.debug('theQuery '+theQuery);
                watchListContacts = new Map<Id, Contact>((List<Contact>)Database.query(theQuery));

                for(id taskid: whoIdChangedTasks.keyset()){
                    if(watchListContacts.containskey(whoIdChangedTasks.get(taskid))){
                        tasksToUpdate.add(new Task(id=taskid,Watchlist__c=true));
                    } 
                }
                updateTask(tasksToUpdate);
            }    
        }
    }
    
    /*
@ OnAfterUpdateAsync:
@Description : future method used to compare taskrelation changes as it gets updated in different context than in task context.
*/
    @future 
    public static void OnAfterUpdateAsync(Set<Id> whoIdChangedTasks){ 
        try{
            Set<Id> watchlistTask = new Set<Id>();
            List<Task> tasksToUpdate = new List<Task>();
            // handled namespace for status in PEv4.7 by Aditya 15 March 2021 
            String query = 'SELECT taskid FROM TaskRelation WHERE taskid IN:whoIdChangedTasks AND IsWhat = false  and relationid IN (SELECT id from Contact WHERE Account.'+nameSpace+'Status__c ='+ '\''+ 'Watchlist'+  '\''+') group by taskid';
            for(AggregateResult newRel: database.query(query))
            {
                tasksToUpdate.add(new Task(id=(Id)newRel.get('taskid'),Watchlist__c=true));
            }
            updateTask(tasksToUpdate); 
        }catch(exception ex){
            system.debug('exception--> '+ex.getMessage()+'-- stack -- '+ex.getStackTraceString());
        }
        
    }
    /*
@ updateTask
@Description: this method is solely involved for the update of task with watchlist flag marking.
*/
    private static void updateTask(List<Task> taskList){
        if(taskList.size() > 0){
            if(!test.isRunningTest()) {
                update taskList;  
                isTriggerCall = false;
            }
            
        }
    }
}