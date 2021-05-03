/*********************************************************************************
    ** Project: PE 3.5
    ** Start: 09-June-2016
    ** Module Name : ContactTransfer
    ** Description : This opens when Contact Transfer button gets clicked, and contact's activities gets copied to old/new institutions as per scenarios
    ** Throws : Exception and Custom Exceptions
    ** Calls : NA
    ** Test Class : TestContactTransfer_ctlr
    ** Organization : Navatar Group
    ** Revision History:-
    ** Version Date(YYYY-MM-DD)       Author  Description of Action
    ** 3.5     2016-05-25             Vanita  This opens when Contact Transfer button gets clicked, and contact's activities gets copied to old/new institutions as per scenarios
    *********************************************************************************/
public with sharing class ContactTransfer_ctlr{

    public string inputValue{get;set;}
    public contact contactPE{get;set;}
    public string namespacePE{get;set;}
    public string serverUrl{get;set;}
    public string contactDetailPagePath{get;set;}
    public string contactId{get;set;}
    public Contact contactLookup{get;set;}
    public string contactName{get;set;}
    public string legalNameOld{get;set;}
    public string legalNameNew{get;set;}
    public string displayMessage{get;set;}
    public boolean isContactIdNull{get;set;}
    public string legalIdOld{get;set;}
    public string legalIdNew{get;set;}
    public boolean isError{get;set;}
    public string errorMessage {get;set;}
    public boolean isOrgSettingActive{get;set;}
    public boolean isTransferred {get;set;}
    public boolean isCode12365 {get;set;}
    public boolean isPopupOpen {get;set;}
    public Contact contactInfo {get;set;}
    public Org_Setting__mdt orgSettingOffice {get;set;}
    //public boolean isFundraisingContact {get;set;} //Commented by Lakshya on 20210423 [PE v4.7]
    public string affiliationID='';
   
    /*
    @Description: Constructor of ContactTransfer_ctlr
    */
    public ContactTransfer_ctlr(ApexPages.StandardController controller) {
        try{
            isContactIdNull =false;
            isOrgSettingActive = true;
            isError = false;
            isCode12365 = false;
            //isFundraisingContact = false; //Commented by Lakshya on 20210423 [PE v4.7] 
            contactId = apexpages.currentpage().getparameters().get('id');            
            contactLookup = new Contact();
            if(string.isEmpty(contactId)||string.isBlank(contactId)){
                isContactIdNull = true;             
                throw new MyCustomException('Contact ID missing in URL.');              
            }
            else{               
                //Query in CustomMetaData Types and select OrgSetting.Active where Org Setting Name = Contact Tran Setting
                
                Org_Setting__mdt orgSetting = new Org_Setting__mdt();
                if(Schema.sObjectType.Org_Setting__mdt.isAccessible() && Schema.sObjectType.Org_Setting__mdt.fields.IsActive__c.isAccessible() && Schema.sObjectType.Org_Setting__mdt.fields.DeveloperName.isAccessible()){
                    orgSetting=[SELECT IsActive__c,DeveloperName FROM Org_Setting__mdt where DeveloperName ='Contact_Tran_Setting' limit 1]; 
                }
                if(orgSetting.IsActive__c==false){
                    isOrgSettingActive = false;
                    throw new MyCustomException('You cannot access this functionality .Functionality may be disabled. Please contact Navatar administrator.');
                }
                else{
                    //Query in Navatar Setup-> CTS Activity where AdminSetting is true
                    //Added By Qadir khan for siurity Issues 07 DEC 2017..
                    List<Navatar_Setup__c> setupInfoList = new List<Navatar_Setup__c>();
                    List<Fundraising_Contact__c> fundraisingContactList = new List<Fundraising_Contact__c>();
                    if(Schema.sObjectType.Navatar_Setup__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.CTS_Activity__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.Admin_Setting__c.isAccessible()){
                        setupInfoList = [SELECT CTS_Activity__c FROM Navatar_Setup__c WHERE Admin_Setting__c=true Limit 1]; 
                    }
                    if(Schema.sObjectType.Fundraising_Contact__c.isAccessible() && Schema.sObjectType.Fundraising_Contact__c.fields.name.isAccessible() && Schema.sObjectType.Fundraising_Contact__c.fields.Contact__c.isAccessible()){
                        fundraisingContactList = [SELECT Name, Contact__c from Fundraising_Contact__c where Contact__c =:contactId];
                    }
                    //Commented by Lakshya on 20210423 [PE v4.7]
                    /*if(fundraisingContactList.size()>0){
                        isFundraisingContact = true;                        
                    }*/
                    if(setupInfoList.size()==0){
                        isCode12365 = true;
                        throw new MyCustomException('Code: 12365. Please contact Navatar Support. System setup improperly.');
                    }
                    else{
                        //Load Contact Data
                        Contact contactObj = new Contact();
                        if(Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Account.isAccessible() && Schema.sObjectType.Account.fields.Name.isAccessible() && Schema.sObjectType.Contact.fields.Name.isAccessible()){
                            contactObj= [Select Name, Account.Name, Account.Id from Contact where Id=:contactId];
                        }
                        contactName = contactObj.Name;
                        legalNameOld = contactObj.Account.Name;
                        legalIdOld = contactObj.Account.Id;                     
                    }
                }
                //beforeTransferActivity(); //Commented by Lakshya on 20210423 [PE v4.7]
            }
        }
        catch(MyCustomException ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));                      
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));              
        }       
    }
        
    /*
    @Description:   Cancel method is for going back to Contact Detail Page
    This is called by clicking "Cancel button" and also called on "oncomplete event of TransferActivity"
    */     
    public PageReference Cancel(){
        try{
            PageReference pr = new pagereference('/' + contactId);       
            return pr;
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));            
            return new PageReference('');
        }       
    }
    
    /*
    @Description:   This is an Action method to fetch the new Legal Id after selecting it from the Institution Lookup
    */
    //Commented below code by Lakshya on 20210423 [PE v4.7]
    /*public void fetchLegalIdNew(){
        try{
            legalIdNew = contactLookup.AccountId;                
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));            
        }       
    }
    
    public void beforeTransferActivity(){
        try{
            isError = false;
            isTransferred = false;
            legalIdNew = contactLookup.AccountId;   
            //Added By Qadir Khan for PE 3.5 07 DEC 2017.
            if(Schema.sObjectType.Org_Setting__mdt.isAccessible() && Schema.sObjectType.Org_Setting__mdt.fields.IsActive__c.isAccessible() && Schema.sObjectType.Org_Setting__mdt.fields.DeveloperName.isAccessible()){
                orgSettingOffice=[SELECT IsActive__c,DeveloperName FROM Org_Setting__mdt where DeveloperName ='Office_Location_Setting' limit 1];
            }
            if(orgSettingOffice.IsActive__c==true){
                isPopupOpen = true;                 
            }
            else{
                isPopupOpen = false;                
            }
            
            if(legalIdNew==legalIdOld){
                isTransferred =false;
                throw new MyCustomException('Old and new Legal Name cannot be the same.');
            }
                                   
        }
        catch(MyCustomException ex){
            isPopupOpen = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));            
        }
        catch(Exception ex){
            isPopupOpen = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));            
        } 
    }*/
    
    /*
    @Description:   This is an Action method for transferring Activity
    */
    //Commented below code by Lakshya on 20210423 [PE v4.7]
    /*public PageReference transferActivity(){
        //Using savepoint if your code performs DML for multiple objects and exception occurs during DML, then it is for rolling back the data from database.               
        Savepoint savePointDb = Database.setSavepoint();
        try{
            isTransferred = false;
            legalIdNew = contactLookup.AccountId;  
            
            if(string.isEmpty(legalIdNew)||string.isBlank(legalIdNew)){
                //throw new MyCustomException('Legal name cannot be blank.');
                return null;
            }
            
            else{
                //Added By Qadir Khan for PE 3.5 07 DEC 2017.
                List<Task> taskList = new List<Task>();
                List<Event> eventList = new List<Event>();
                if(Schema.sObjectType.Task.isAccessible() && Schema.sObjectType.Task.fields.WhoId.isAccessible() && Schema.sObjectType.Task.fields.WhatId.isAccessible() && Schema.sObjectType.Task.fields.Institution__c.isAccessible()){
                    taskList = [SELECT Id, WhoId, WhatId, Institution__c from Task WHERE (WhoId = :contactId AND WhatId = null AND Institution__c = null) OR (WhoId = :contactId AND WhatId = null) OR (WhoId = :contactId AND Institution__c = null AND WhatId = :legalIdOld) OR (WhoId = :contactId AND WhatId = null) OR (WhoId = :contactId AND Institution__c = null AND WhatId !=: legalIdOld AND WhatId !=: null) OR (WhoId = :contactId AND WhatId = :legalIdOld AND Institution__c = null) OR (WhoId = :contactId AND WhatId = :legalIdOld AND Institution__c != null) OR (WhoId = :contactId AND Institution__c = null AND WhatId !=: legalIdOld AND WhatId !=: null)];
                }
                if(Schema.sObjectType.Event.isAccessible()  && Schema.sObjectType.Event.fields.WhoId.isAccessible() && Schema.sObjectType.Event.fields.WhatId.isAccessible() && Schema.sObjectType.Event.fields.Institution__c.isAccessible()){
                    eventList = [SELECT Id, WhoId, WhatId, Institution__c from Event WHERE ((WhoId = :contactId AND WhatId = null AND Institution__c = null) OR (WhoId = :contactId AND WhatId = null) OR (WhoId = :contactId AND Institution__c = null AND WhatId = :legalIdOld) OR (WhoId = :contactId AND WhatId = null) OR (WhoId = :contactId AND Institution__c = null AND WhatId !=: legalIdOld AND WhatId !=: null) OR (WhoId = :contactId AND WhatId = :legalIdOld) OR (WhoId = :contactId AND Institution__c = null AND WhatId !=: legalIdOld AND WhatId !=: null)) and GroupEventType!='2'];
                }
                
                List<Task> toUpdateTaskList = new List<Task>();
                List<Event> toUpdateEventList = new List<Event>();
                //Added By Qadir Khan for PE 3.5 07 DEC 2017.
                Navatar_Setup__c setupInfoAdvanced = new Navatar_Setup__c();
                Navatar_Setup__c setupInfoActivity = new Navatar_Setup__c();
                if(Schema.sObjectType.Navatar_Setup__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.CTS_Advanced__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.CTS_Activity__c.isAccessible()){
                    setupInfoAdvanced = [SELECT CTS_Advanced__c FROM Navatar_Setup__c WHERE CTS_Advanced__c='Contact Only' OR CTS_Advanced__c='Contact and Institution' OR CTS_Advanced__c='Contact, Institution and Custom Object'];                
                    //Check Navatar Setup -> CTS Activity = Old Institution
                    setupInfoActivity = [SELECT CTS_Activity__c FROM Navatar_Setup__c WHERE CTS_Activity__c='Old Institution Only' OR CTS_Activity__c='Old and New Institutions'];             
                }
                if(legalIdOld!=null && legalIdOld!=''){
                    if(setupInfoActivity.CTS_Activity__c=='Old Institution Only'){//YES
                        //Check Navatar Setup -> CTS Advanced = Contact only
                        if(setupInfoAdvanced.CTS_Advanced__c=='Contact Only'){  //YES
                            //Check if WhoId = contactId AND WhatId = null AND Institution = null   
                            //FOR TASK
                            if(taskList.size()>0 && Schema.sObjectType.Task.fields.Institution__c.isUpdateable() && Schema.sObjectType.Task.fields.WhatId.isUpdateable()){
                                for(Task taskInfo : taskList){
                                    if(taskInfo.WhoId==contactId && taskInfo.whatId==null && taskInfo.Institution__c==null){
                                        taskInfo.WhatId = legalIdOld;
                                        taskInfo.Institution__c = legalIdOld;
                                        toUpdateTaskList.add(taskInfo);
                                    }
                                }
                            }
                            //FOR EVENT
                            if(eventList.size()>0 && Schema.sObjectType.Event.fields.Institution__c.isUpdateable() && Schema.sObjectType.Event.fields.WhatId.isUpdateable()){
                                for(Event eventInfo : eventList){
                                    if(eventInfo.WhoId==contactId && eventInfo.whatId==null && eventInfo.Institution__c==null){
                                        eventInfo.WhatId = legalIdOld;
                                        eventInfo.Institution__c = legalIdOld;
                                        toUpdateEventList.add(eventInfo);
                                    }
                                }
                            }
                        }                   
                        else{   //NO
                            //Check if Navatar Setup -> CTS Advanced = Contact and Institution
                            
                            if(setupInfoAdvanced.CTS_Advanced__c=='Contact and Institution'){   //YES
                                //TASK
                                if(taskList.size()>0 && Schema.sObjectType.Task.fields.Institution__c.isUpdateable() && Schema.sObjectType.Task.fields.WhatId.isUpdateable()){
                                    for(Task taskInfo : taskList){
                                        //Check if WhoId = contactId AND WhatId = null      
                                        if(taskInfo.WhoId==contactId && taskInfo.whatId==null){
                                            taskInfo.whatId=legalIdOld;
                                            taskInfo.Institution__c = legalIdOld;                               
                                            toUpdateTaskList.add(taskInfo);
                                        }                                   
                                        
                                        //Check if WhoId = contactId AND Institution = null AND WhatId = OldInsID   
                                        if(taskInfo.WhoId==contactId && taskInfo.Institution__c==null && taskInfo.whatId==legalIdOld){
                                            taskInfo.Institution__c = legalIdOld;   
                                            toUpdateTaskList.add(taskInfo);
                                        }
                                        
                                        
                                    }
                                }
                                if(eventList.size()>0 && Schema.sObjectType.Event.fields.Institution__c.isUpdateable() && Schema.sObjectType.Event.fields.WhatId.isUpdateable()){
                                    //EVENT
                                    for(Event eventInfo : eventList){
                                        //Check if WhoId = contactId AND WhatId = null      
                                        if(eventInfo.WhoId==contactId && eventInfo.whatId==null){
                                            eventInfo.whatId=legalIdOld;
                                            eventInfo.Institution__c = legalIdOld;                              
                                            toUpdateEventList.add(eventInfo);
                                        }  
                                        //Check if WhoId = contactId AND Institution = null AND WhatId = OldInsID   
                                        if(eventInfo.WhoId==contactId && eventInfo.Institution__c==null && eventInfo.whatId==legalIdOld){
                                            eventInfo.Institution__c = legalIdOld;  
                                            toUpdateEventList.add(eventInfo);
                                        }
                                        
                                    }
                                }
                            }
                            else{   //NO
                                //TASK
                                if(taskList.size()>0 && Schema.sObjectType.Task.fields.Institution__c.isUpdateable() && Schema.sObjectType.Task.fields.WhatId.isUpdateable()){
                                    for(Task taskInfo : taskList){
                                        //Check if WhoId = contactId AND WhatId = null
                                        if(taskInfo.WhoId==contactId && taskInfo.whatId==null){
                                            taskInfo.whatId=legalIdOld;
                                            taskInfo.Institution__c = legalIdOld;
                                            toUpdateTaskList.add(taskInfo);
                                        }
                                        //Check if WhoId = contactId AND Institution = null AND WhatId = OldInsID
                                        if(taskInfo.WhoId==contactId && taskInfo.Institution__c==null && taskInfo.whatId==legalIdOld){
                                            taskInfo.Institution__c = legalIdOld;
                                            toUpdateTaskList.add(taskInfo);
                                        }
                                        //Check if WhoId = contactId AND Institution = null AND WhatId <> legalIdOld AND WhatId <> null
                                        if(taskInfo.WhoId == contactId && taskInfo.Institution__c == null && taskInfo.WhatId != legalIdOld && taskInfo.WhatId != null){
                                            taskInfo.Institution__c = legalIdOld;
                                            toUpdateTaskList.add(taskInfo);
                                        }
                                    }
                                }
                                if(eventList.size()>0 && Schema.sObjectType.Event.fields.Institution__c.isUpdateable() && Schema.sObjectType.Event.fields.WhatId.isUpdateable()){
                                    //EVENT
                                    for(Event eventInfo : eventList){
                                        //Check if WhoId = contactId AND WhatId = null
                                        if(eventInfo.WhoId==contactId && eventInfo.whatId==null){
                                            eventInfo.whatId=legalIdOld;
                                            eventInfo.Institution__c = legalIdOld;
                                            toUpdateEventList.add(eventInfo);
                                        }
                                        //Check if WhoId = contactId AND Institution = null AND WhatId = OldInsID
                                        if(eventInfo.WhoId==contactId && eventInfo.Institution__c==null && eventInfo.whatId==legalIdOld){
                                            eventInfo.Institution__c = legalIdOld;
                                            toUpdateEventList.add(eventInfo);
                                        }
                                        //Check if WhoId = contactId AND Institution = null AND WhatId <> legalIdOld AND WhatId <> null
                                        if(eventInfo.WhoId == contactId && eventInfo.Institution__c == null && eventInfo.WhatId != legalIdOld && eventInfo.WhatId != null){
                                            eventInfo.Institution__c = legalIdOld;
                                            toUpdateEventList.add(eventInfo);
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                    else{   //NO
                        //Check in Navatar Setup -> CTS Advanced = Contact only
                        if(setupInfoAdvanced.CTS_Advanced__c=='Contact Only'){  //YES
                            //TASK
                            if(taskList.size()>0 && Schema.sObjectType.Task.fields.Institution__c.isUpdateable()){
                                for(Task taskInfo : taskList){
                                    //Check if WhoId = contactId AND WhatId = null AND Institution = null       
                                    if(taskInfo.WhoId==contactId && taskInfo.whatId==null && taskInfo.Institution__c==null){                                
                                        taskInfo.Institution__c = legalIdOld;
                                        toUpdateTaskList.add(taskInfo);
                                    }                           
                                }
                            }
                            
                            //EVENT
                            if(eventList.size()>0 && Schema.sObjectType.Event.fields.Institution__c.isUpdateable()){
                                for(Event eventInfo : eventList){
                                    //Check if WhoId = contactId AND WhatId = null AND Institution = null       
                                    if(eventInfo.WhoId==contactId && eventInfo.whatId==null && eventInfo.Institution__c==null){                             
                                        eventInfo.Institution__c = legalIdOld;
                                        toUpdateEventList.add(eventInfo);
                                    }                           
                                }
                            } 
                        }                   
                        else{   //NO
                            //Check in Navatar Setup -> CTS Advanced = Contact and Insitution
                            if(setupInfoAdvanced.CTS_Advanced__c=='Contact and Institution'){   //YES
                                
                                //TASK
                                if(taskList.size()>0 && Schema.sObjectType.Task.fields.Institution__c.isUpdateable() && Schema.sObjectType.Task.fields.WhatId.isUpdateable()){
                                    for(Task taskInfo : taskList){
                                        //Check if WhoId = contactId AND WhatId = null AND Institution = null       
                                        if(taskInfo.WhoId==contactId && taskInfo.whatId==null && taskInfo.Institution__c==null){                                    
                                            taskInfo.Institution__c = legalIdOld;
                                            toUpdateTaskList.add(taskInfo);
                                        }
                                        
                                        //Check if WhoId = contactId AND WhatId = OldInsID      
                                        if(taskInfo.WhoId==contactId && taskInfo.whatId==legalIdOld){
                                            
                                            if(taskInfo.Institution__c!=null){
                                                taskInfo.whatId = legalIdNew;
                                            }
                                            else{
                                                taskInfo.whatId = legalIdNew;
                                                taskInfo.Institution__c = legalIdOld;
                                            }
                                            toUpdateTaskList.add(taskInfo);
                                        }
                                    }
                                }
                                
                                //EVENT
                                if(eventList.size()>0 && Schema.sObjectType.Event.fields.Institution__c.isUpdateable() && Schema.sObjectType.Event.fields.WhatId.isUpdateable()){
                                    for(Event eventInfo : eventList){
                                        //Check if WhoId = contactId AND WhatId = null AND Institution = null       
                                        if(eventInfo.WhoId==contactId && eventInfo.whatId==null && eventInfo.Institution__c==null){                                 
                                            eventInfo.Institution__c = legalIdOld;
                                            toUpdateEventList.add(eventInfo);
                                        }
                                        
                                        //Check if WhoId = contactId AND WhatId = OldInsID      
                                        if(eventInfo.WhoId==contactId && eventInfo.whatId==legalIdOld){
                                            
                                            if(eventInfo.Institution__c!=null){
                                                eventInfo.whatId = legalIdNew;
                                            }
                                            else{
                                                eventInfo.whatId = legalIdNew;
                                                eventInfo.Institution__c = legalIdOld;
                                            }
                                            toUpdateEventList.add(eventInfo);
                                        }
                                    }   
                                }
                                
                            }
                            else{   //NO
                                //TASK
                                if(taskList.size()>0 && Schema.sObjectType.Task.fields.Institution__c.isUpdateable() && Schema.sObjectType.Task.fields.WhatId.isUpdateable()){
                                    for(Task taskInfo : taskList){
                                        //Check if WhoId = contactId AND WhatId = null AND Institution = null  
                                        if(taskInfo.WhoId==contactId && taskInfo.whatId==null && taskInfo.Institution__c==null){                                    
                                            taskInfo.Institution__c = legalIdOld;
                                            toUpdateTaskList.add(taskInfo);
                                        }
                                        
                                        //Check if WhoId = contactId AND WhatId = OldInsID      
                                        if(taskInfo.WhoId==contactId && taskInfo.whatId==legalIdOld){
                                            
                                            if(taskInfo.Institution__c!=null){
                                                taskInfo.whatId = legalIdNew;
                                            }
                                            else{
                                                taskInfo.whatId = legalIdNew;
                                                taskInfo.Institution__c = legalIdOld;
                                            }
                                            toUpdateTaskList.add(taskInfo);
                                        }
                                        
                                        //Check if WhoId = contactId AND Institution = null AND WhatId <> legalIdOld AND WhatId <> null
                                        if(taskInfo.WhoId == contactId && taskInfo.Institution__c == null && taskInfo.WhatId <> legalIdOld && taskInfo.WhatId <> null){
                                            taskInfo.Institution__c = legalIdOld;
                                            toUpdateTaskList.add(taskInfo);
                                        }
                                    }
                                }
                                
                                //EVENT
                                if(eventList.size()>0 && Schema.sObjectType.Event.fields.Institution__c.isUpdateable() && Schema.sObjectType.Event.fields.WhatId.isUpdateable()){
                                    for(Event eventInfo : eventList){
                                        //Check if WhoId = contactId AND WhatId = null AND Institution = null       
                                        if(eventInfo.WhoId==contactId && eventInfo.whatId==null && eventInfo.Institution__c==null){                                 
                                            eventInfo.Institution__c = legalIdOld;
                                            toUpdateEventList.add(eventInfo);
                                        }
                                        
                                        //Check if WhoId = contactId AND WhatId = OldInsID      
                                        if(eventInfo.WhoId==contactId && eventInfo.whatId==legalIdOld){
                                            
                                            if(eventInfo.Institution__c!=null){
                                                eventInfo.whatId = legalIdNew;
                                            }
                                            else{
                                                eventInfo.whatId = legalIdNew;
                                                eventInfo.Institution__c = legalIdOld;
                                            }
                                            toUpdateEventList.add(eventInfo);
                                        }
                                        
                                        //Check if WhoId = contactId AND Institution = null AND WhatId <> legalIdOld AND WhatId <> null
                                        if(eventInfo.WhoId == contactId && eventInfo.Institution__c == null && eventInfo.WhatId <> legalIdOld && eventInfo.WhatId <> null){
                                            eventInfo.Institution__c = legalIdOld;
                                            toUpdateEventList.add(eventInfo);
                                        }
                                    } 
                                }
                            }
                        }
                    }
                }
                else{
                    throw new MyCustomException('You cannot transfer this contact as it doesn’t have an associated account. Please associate it with an account in order to use contact transfer.');
                }
             
                if(toUpdateTaskList.size()>0){                              
                    if(Schema.sObjectType.task.isUpdateable()==true)
                        update toUpdateTaskList;
                    toUpdateTaskList.Clear();
                }
                if(toUpdateEventList.size()>0){                         
                    if(Schema.sObjectType.event.isUpdateable()==true)
                        update toUpdateEventList;
                    toUpdateEventList.Clear();
                }
                
                //Insert an Affiliation on old Account/Institution with Role=Former Employee
                Affiliation__c affiliationObj = new Affiliation__c();    
                
                if(Schema.sObjectType.Affiliation__c.Fields.Contact__c.isCreateable() ){
                    affiliationObj.Contact__c = contactId;
                }
                if(Schema.sObjectType.Affiliation__c.Fields.Institution__c.isCreateable() ){
                    affiliationObj.Institution__c = legalIdOld;
                }
                if(Schema.sObjectType.Affiliation__c.Fields.Role__c.isCreateable() ){
                    affiliationObj.Role__c = 'Former Employee';
                }
                
                if(Schema.sObjectType.Affiliation__c.isCreateable()==true)
                    insert affiliationObj;                
                affiliationID = affiliationObj.ID;                
                isTransferred = true;   
                contactInfo =new contact();
                if(Schema.sObjectType.contact.isAccessible() && Schema.sObjectType.Account.isAccessible() && Schema.sObjectType.contact.fields.phone.isAccessible() && Schema.sObjectType.contact.fields.Office_Location_Info__c.isAccessible() && Schema.sObjectType.contact.fields.Fax.isAccessible()){
                    contactInfo = [SELECT id,Account.Id, Office_Location_Info__c, Phone, Fax from Contact where Id =: contactId];
                }
                //Update Account in Contact
                if(contactInfo!=null){
                    if(Schema.sObjectType.Contact.Fields.AccountId.isUpdateable() ){
                        contactInfo.AccountId = legalIdNew;
                    }
                    
                    if(Schema.sObjectType.contact.isUpdateable()==true)
                        update contactInfo;
                }               
            }
            return null;
        }
        catch(MyCustomException ex){
            isError = true;
            errorMessage='You cannot transfer this contact as it doesn’t have an associated account. Please associate it with an account in order to use contact transfer.';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,errorMessage));  
            return null;
        }
        catch(Exception ex){
            // Roll the database back to before we saved ANYTHING
            isError = true;            
            errorMessage = ex.getMessage();
            if(errorMessage.contains('Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing:') && (affiliationID=='' || affiliationID==null)){
                errorMessage = 'Contact transfer has failed. Mandatory information is missing on contact affiliation that will be created with previous Institution on transfer. Please contact Navatar Support.';
                Database.rollback(savePointDb);                
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,errorMessage));  
            }
            else{
                Database.rollback(savePointDb);                
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));  
            }                                          
            return null;
        }
    }*/

    /*
    @Description:   This is an Action method for clearing address
    Mailing Address fields will be deleted. 
    Office Location will be cleared.
    */
    //Commented below code by Lakshya on 20210423 [PE v4.7]
    /*public PageReference clearAddress(){
        Savepoint savePointDb = Database.setSavepoint();
        transferActivity();
        try{            
            if(isError==false){
                contactAddressUpdate('clear');
                return Cancel();
                
            }
            else{
                return null;
            }
        }
        
        catch(Exception ex){
            // Roll the database back to before we saved ANYTHING
            isError = true;
            errorMessage = ex.getMessage();
            Database.rollback(savePointDb);            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            return null;
        }           
    }*/
    
    /*
    @Description:   This is an Action method for retaining address
    Mailing Address fields will remain the same as the old institution’s address fields.
    Office Location will be cleared.
    */
    //Commented below code by Lakshya on 20210423 [PE v4.7]
    /*public PageReference retainAddress(){
        Savepoint savePointDb = Database.setSavepoint();
        transferActivity();
        try{                        
            if(isError==false){
                contactAddressUpdate('retain');
                return Cancel();
            }
            else{
                //return null;
                throw new MyCustomException(errorMessage);
                
            }
            return null;
        } 
        catch(MyCustomException ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage())); 
            return null;
        }
        catch(Exception ex){
            // Roll the database back to before we saved ANYTHING
            isError = true;
            errorMessage = ex.getMessage();
            Database.rollback(savePointDb);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            return null;
        }       
    }*/

    /*
    @Description:   This is a method which is called from retainAddress() and clearAddress() methods   .
    Office Location will be cleared in both the cases.
    @Param1: addressType: string
    */
    //Commented below code by Lakshya on 20210423 [PE v4.7]
    /*public void contactAddressUpdate(string addressType){
        Savepoint savePointDb = Database.setSavepoint();
        try{            
            //Check in CMT Org Settings where Org Setting Name is 'Office Location Setting' , check if Active is true
            
            if(contactInfo!=null){
                if(addressType=='clear')
                {                                           
                    if(orgSettingOffice.IsActive__c==true && Schema.sObjectType.Contact.fields.MailingCity.isUpdateable() && Schema.sObjectType.Contact.fields.MailingState.isUpdateable() && Schema.sObjectType.Contact.fields.MailingCountry.isUpdateable() && Schema.sObjectType.Contact.fields.MailingPostalCode.isUpdateable() && Schema.sObjectType.Contact.fields.MailingStreet.isUpdateable() && Schema.sObjectType.Contact.fields.Phone.isUpdateable() && Schema.sObjectType.Contact.fields.Fax.isUpdateable() && Schema.sObjectType.Contact.fields.OtherCity.isUpdateable() && Schema.sObjectType.Contact.fields.OtherState.isUpdateable() && Schema.sObjectType.Contact.fields.OtherCountry.isUpdateable() && Schema.sObjectType.Contact.fields.OtherPostalCode.isUpdateable() && Schema.sObjectType.Contact.fields.OtherStreet.isUpdateable())
                    {  
                        contactInfo.MailingCity = null;
                        contactInfo.MailingState = null;
                        contactInfo.MailingCountry = null;
                        contactInfo.MailingPostalCode = null;
                        contactInfo.MailingStreet = null;
                        contactInfo.Phone = null;
                        contactInfo.Fax = null;
                        
                        contactInfo.OtherCity = null;
                        contactInfo.OtherState = null;
                        contactInfo.OtherCountry = null;
                        contactInfo.OtherPostalCode = null;
                        contactInfo.OtherStreet = null;
                    }                                                           
                }
                if(Schema.sObjectType.Contact.fields.Office_Location_Info__c.isUpdateable()){    
                    contactInfo.Office_Location_Info__c = null;
				}
                if(Schema.sObjectType.contact.isUpdateable()==true){
                    update contactInfo; 
				}					
            }           
        }
        catch(Exception ex){
            isError = true;
            errorMessage = ex.getMessage();
            Database.rollback(savePointDb);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));          
        }       
    }*/
    
    public class MyCustomException extends Exception{}
}