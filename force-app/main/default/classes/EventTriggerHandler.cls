/**
* --------------------------------------------------------------------------------------------------
* Apex class designed to calculate the Last Touch point from  Event based EndDateTime field and task based activity date field then update
* Last Touch Point date Contact.
* --------------------------------------------------------------------------------------------------
* @author         Rahul Kumar Kasaundhan
* @modifiedBy     Rahul Kumar Kasaundhan
* @version        3.0    
* @created        13-10-2020     
* @modified       13-10-2020
*/

public without sharing class EventTriggerHandler{
    
    
    //Find the Last Touch Point based on Task's EndDateTime and update the same on Contact.
    public static void OnAfterInsUpdDel(List<Event> newEventList, Map<Id, Event> oldEventMap){
        
        Set<Id> eventIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        for(Event oEvent : newEventList){
            
            if(((Trigger.isinsert || Trigger.isdelete || Trigger.isundelete) && oEvent.WhoId != null && oEvent.Is_Touchpoint__c && oEvent.EndDateTime != null ) || (Trigger.isupdate && (oldEventMap.get(oEvent.Id).Is_Touchpoint__c != oEvent.Is_Touchpoint__c || (oldEventMap.get(oEvent.Id).WhoId != oEvent.WhoId) || (oldEventMap.get(oEvent.Id).EndDateTime != oEvent.EndDateTime)))){				
                eventIds.add(oEvent.id);
                if(oEvent.WhoId != null){                
                    contactIds.add(oEvent.WhoId);
                }	
                
                if(Trigger.isupdate && (oldEventMap.get(oEvent.Id).WhoId != oEvent.WhoId) & oldEventMap.get(oEvent.Id).WhoId != null){
                    contactIds.add(oldEventMap.get(oEvent.Id).WhoId);
                }				
            }		
            
        }
        
        //get the contact ids from Event relation if EventRelation feature is enable.
        if(Schema.getGlobalDescribe().containsKey('EventRelation') && EventRelation.getSobjectType().getDescribe().fields.getMap().keySet().contains('iswhat')){
            Map<Id, Id> eventRelvsEventId = new Map<Id, Id>();//use this map to check if any contact is removed/added from the Event.
            
            if(Trigger.isdelete || Trigger.isundelete){
                GetContactIds(eventIds, contactIds, eventRelvsEventId, Trigger.isdelete);
            }
            else{	
                
                if(Trigger.isupdate){
                    //get old Event relation to check changes with new Event relation.
                    List<sObject> oldEventRelations = new List<sObject>();
                    Set<id> eventId = new Set<Id>();
                    eventId.addall(oldEventMap.keyset());
                    oldEventRelations = Database.Query('SELECT EventId,relationid FROM EventRelation WHERE relationid != null AND EventId IN :eventId AND IsWhat = false');
                    
                    for(sObject eventrel : oldEventRelations ){
                        eventRelvsEventId.put((String) eventrel.get('relationid'), (String) eventrel.get('EventId'));
                    }
                }
                //Call future method to get relationid
                OnAfterUpdateAsync(eventIds, contactIds, eventRelvsEventId);
            }			
        }
        else{
            updateContact(eventIds,contactIds, Trigger.isdelete);
        }
        
    }
    
    //Get all the Contacts from Event relation.
    @future 
    public static void OnAfterUpdateAsync(Set<Id> eventIds, Set<Id> contactIds, Map<Id, Id> eventRelvsEventId){	
        GetContactIds(eventIds, contactIds, eventRelvsEventId, false);
    }
    
    public static void GetContactIds(Set<Id> eventIds, Set<Id> contactIds, Map<Id, Id> eventRelvsEventId, boolean isDelete){
        
        List<sObject> EventRelations = new List<sObject>();
        
        if(eventRelvsEventId.size()>0)
            eventIds.addall(eventRelvsEventId.values());
        
        EventRelations = Database.Query('SELECT EventId, relationid FROM eventrelation WHERE relationid != null AND EventId IN :eventIds AND IsWhat = false');
        
        for(sObject eventrel:EventRelations ){
            //Event update: check existing Event relation(s) with new Event relation(s) and remove the exiting relationid from eventRelvsEventId Map.  
            if(eventRelvsEventId.containsKey((String) eventrel.get('RelationId')) && eventRelvsEventId.get((String) eventrel.get('RelationId')) == (String) eventrel.get('EventId'))
                eventRelvsEventId.remove((String) eventrel.get('RelationId'));
            contactIds.add((String) eventrel.get('RelationId'));
        }
        
        if(eventRelvsEventId.size()>0)
            contactIds.addall(eventRelvsEventId.keyset());
        updateContact(eventIds,contactIds, isDelete);
    }
    
    //Update the Last_Touch_Point__c field on Contact based on latest Event's EndDateTime
    public static void updateContact(Set<Id> eventIds, Set<Id> contactIds, boolean isDelete){
        List<Contact> updContacts = new List<Contact>();
        //Calculate the Last Touch Point date from Event and update Last_Touch_Point__c field on Contact.
        if(contactIds.size() > 0){
            Date eventTouchDate;
            Map<Id,Date> ContactVslastTouch = new Map<Id,Date>();
            
            string contactQueryforEvent='SELECT Id, Last_Touch_Point__c, (SELECT EndDateTime From ActivityHistories WHERE'+(isDelete?' Id NOT IN :eventIds AND ':'')+' Is_Touchpoint__c =true AND isTask =false  AND EndDateTime != null ORDER BY EndDateTime DESC LIMIT 1) FROM Contact WHERE Id IN :contactIds';
            string contactQueryforTask ='SELECT Id, Last_Touch_Point__c, (SELECT ActivityDate From ActivityHistories WHERE Is_Touchpoint__c =true AND isTask =true AND ActivityDate != null ORDER BY ActivityDate DESC LIMIT 1) FROM Contact WHERE Id IN :contactIds';
            
            List<Contact> lastTouchPointListAsEvent = Database.Query(contactQueryforEvent);
            List<Contact> lastTouchPointListAsTask = Database.Query(contactQueryforTask);
            
            for(Contact oContact : lastTouchPointListAsEvent){  
                if(oContact.ActivityHistories.size()>0){
                    eventTouchDate = date.newinstance(oContact.ActivityHistories[0].EndDateTime.year(), oContact.ActivityHistories[0].EndDateTime.month(), oContact.ActivityHistories[0].EndDateTime.day());
                    ContactVslastTouch.put(oContact.Id,eventTouchDate);
                }	
            }
            for(Contact oContact : lastTouchPointListAsTask){
                if(oContact.ActivityHistories.size()>0){
                    if(ContactVslastTouch.size()>0){
                        if(ContactVslastTouch.containsKey(oContact.Id) && ContactVslastTouch.get(oContact.Id) < oContact.ActivityHistories[0].ActivityDate){
                        ContactVslastTouch.put(oContact.Id,oContact.ActivityHistories[0].ActivityDate);                       
                    	}
                    }
                    else{
                        ContactVslastTouch.put(oContact.Id,oContact.ActivityHistories[0].ActivityDate);
                    }
                }    
            }
            for(String strContact : ContactVslastTouch.keyset())
            {
                contact con = new contact(Id=strContact);
                if(ContactVslastTouch.get(strContact) !=null && Schema.SObjectType.Contact.fields.Last_Touch_Point__c.isUpdateable()){ // added isUpdateable check for security issue PEv4.7
                    con.Last_Touch_Point__c = (Date)ContactVslastTouch.get(strContact);
                }
                updContacts.add(con);
            }
            if(updContacts.size() > 0 && Schema.sObjectType.Contact.isUpdateable()){ // added isUpdateable check for security issue PEv4.7 
                update updContacts;
            }  
                
        }
        
    }
}