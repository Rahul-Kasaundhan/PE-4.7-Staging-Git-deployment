/**
* --------------------------------------------------------------------------------------------------
* Apex class designed to calculate the Last Touch point from task based activity date field and update
* Last Touch Point date Contact.
* --------------------------------------------------------------------------------------------------
* @author         Raghvendra Jha
* @modifiedBy     Raghvendra Jha
* @version        1.0
* @created        2019-11-26
* @modified       2019-11-26
*/

public without sharing class TaskTriggerHandler{
	
    //Find the Last Touch Point based on Task's ActivityDate and update the same on Contact.
    public static void OnAfterInsUpdDel(List<Task> newTaskList, Map<Id, Task> oldTaskMap){
        
        Set<Id> taskIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        
        for(Task oTask : newTaskList){
			
			if(((Trigger.isinsert || Trigger.isdelete || Trigger.isundelete) && oTask.WhoId != null && oTask.Is_Touchpoint__c && oTask.ActivityDate != null && oTask.IsClosed) || (Trigger.isupdate && (oTask.IsClosed != oldTaskMap.get(oTask.Id).IsClosed || oldTaskMap.get(oTask.Id).Is_Touchpoint__c != oTask.Is_Touchpoint__c || (oldTaskMap.get(oTask.Id).WhoId != oTask.WhoId) || (oldTaskMap.get(oTask.Id).ActivityDate != oTask.ActivityDate)))){				
				taskIds.add(oTask.id);
				if(oTask.WhoId != null){                
					contactIds.add(oTask.WhoId);
				}	
				
				if(Trigger.isupdate && (oldTaskMap.get(oTask.Id).WhoId != oTask.WhoId) & oldTaskMap.get(oTask.Id).WhoId != null){
					contactIds.add(oldTaskMap.get(oTask.Id).WhoId);
				}				
			}		
            
		}
        
		//get the contact ids from task relation if TaskRelation feature is enable.
		if(Schema.getGlobalDescribe().containsKey('TaskRelation')){
			Map<Id, Id> taskRelvsTaskId = new Map<Id, Id>();//use this map to check if any contact is removed/added from the Task.
			if(Trigger.isdelete || Trigger.isundelete){
				GetContactIds(taskIds, contactIds, taskRelvsTaskId, Trigger.isdelete);
			}
			else{	
			
				if(Trigger.isupdate){
					//get old task relation to check changes with new task relation.
					List<sObject> oldTaskRelations = new List<sObject>();
					Set<id> tskId = new Set<Id>();
					tskId.addall(oldTaskMap.keyset());
					oldTaskRelations = Database.Query('SELECT taskid,relationid FROM TaskRelation WHERE relationid != null AND taskid IN :tskId AND IsWhat = false');
					
					for(sObject taskrel : oldTaskRelations ){
						taskRelvsTaskId.put((String) taskrel.get('relationid'), (String) taskrel.get('taskid'));
					}
				}
				//Call future method to get relationid
				OnAfterUpdateAsync(taskIds, contactIds, taskRelvsTaskId);
			}			
		}
		else{
			updateContact(taskIds,contactIds, Trigger.isdelete);
		}
		
    }
	
	//Get all the Contacts from Task relation.
	@future 
    public static void OnAfterUpdateAsync(Set<Id> taskIds, Set<Id> contactIds, Map<Id, Id> taskRelvsTaskId){	
		GetContactIds(taskIds, contactIds, taskRelvsTaskId, false);
    }
	
	public static void GetContactIds(Set<Id> taskIds, Set<Id> contactIds, Map<Id, Id> taskRelvsTaskId, boolean isDelete){
		
		List<sObject> taskRelations = new List<sObject>();
		
		if(taskRelvsTaskId.size()>0)
			taskIds.addall(taskRelvsTaskId.values());
		
		taskRelations = Database.Query('SELECT taskid, relationid FROM TaskRelation WHERE relationid != null AND taskid IN :taskIds AND IsWhat = false');
		
		for(sObject taskrel:taskRelations ){
			//Task update: check existing task relation(s) with new task relation(s) and remove the exiting relationid from taskRelvsTaskId Map.  
			if(taskRelvsTaskId.containsKey((String) taskrel.get('RelationId')) && taskRelvsTaskId.get((String) taskrel.get('RelationId')) == (String) taskrel.get('taskid'))
				taskRelvsTaskId.remove((String) taskrel.get('RelationId'));
			contactIds.add((String) taskrel.get('RelationId'));
		}
		
		if(taskRelvsTaskId.size()>0)
			contactIds.addall(taskRelvsTaskId.keyset());
		updateContact(taskIds,contactIds, isDelete);
    }
	
	//Update the Last_Touch_Point__c field on Contact based on latest Task's ActivityDate
	public static void updateContact(Set<Id> taskIds, Set<Id> contactIds, boolean isDelete){
		
		List<Contact> updContacts = new List<Contact>();
		//Calculate the Last Touch Point date from task and update Last_Touch_Point__c field on Contact.
        if(contactIds.size() > 0){
			
			string contactQuery='SELECT Id, Last_Touch_Point__c, (SELECT ActivityDate From ActivityHistories WHERE'+(isDelete?' Id NOT IN :taskIds AND ':'')+' Is_Touchpoint__c =true AND isTask =true AND ActivityDate != null ORDER BY ActivityDate DESC LIMIT 1) FROM Contact WHERE Id IN :contactIds';
            
            List<Contact> lastTouchPointList = Database.Query(contactQuery);
            for(Contact oContact : lastTouchPointList){  
                if(oContact.ActivityHistories.size()>0){
                    if(Schema.sObjectType.Contact.fields.Last_Touch_Point__c.isUpdateable()){ // added isUpdatable check for security fix in PEv4.7 by Aditya 5 April 2021
						oContact.Last_Touch_Point__c = oContact.ActivityHistories[0].ActivityDate;
                     }
                }else{
                    if(Schema.sObjectType.Contact.fields.Last_Touch_Point__c.isUpdateable()){ // added isUpdatable check for security fix in PEv4.7 by Aditya 5 April 2021
                        oContact.Last_Touch_Point__c = null;
                    }
                }
                if(Schema.sObjectType.Contact.isUpdateable()){ // added isUpdatable check for security fix in PEv4.7 by Aditya 5 April 2021
                    updContacts.add(oContact); 
                }
            }
             if(updContacts.size() > 0 && Schema.sobjectType.Contact.isUpdateable()) // added isUpdatable check for security fix in PEv4.7 by Aditya 17 March 2021
                update updContacts;
        }		
	}
	
	//dummy update on Task realted to Email Message to invoke the task process builder.
    public static void updateTask(List<EmailMessage> emailMessageList){	
		if(emailMessageList.size() > 0){
            List<Task> taskList = new List<Task>();
			for(EmailMessage oEmailMessage : emailMessageList){
				if(oEmailMessage.ActivityId != null)
					taskList.add(new Task(id=oEmailMessage.ActivityId));
			}
            if(taskList.size() > 0)
            	update taskList;
		}
		
    }
    
    //Get Contact ids when Email Message is deleted and recalculate the Contact's Last Touch Point.
    public static void onEmailMessageDel(List<EmailMessage> delEmailMessageList){	
        
		if(delEmailMessageList.size() > 0){
            Set<Id> taskIds = new Set<Id>();
            
			for(EmailMessage oEmailMessage : delEmailMessageList){
				if(oEmailMessage.ActivityId != null)
					taskIds.add(oEmailMessage.ActivityId);
			}
            
            if(taskIds.size() > 0){
                Set<Id> contactIds = new Set<Id>();
                for(Task delTask : [SELECT Id, WhoId FROM Task WHERE Id IN :taskIds AND WhoId != null]){
                    contactIds.add(delTask.WhoId);
                }
                updateContact(taskIds, contactIds, Trigger.isdelete);
            }
		}
		
    }
}