/*********************************************************************************
** Module Name : Contact Transfer Setup
** Description : This is used for Enable Contact Transfer Setup And add or remove button from Fund related list.
** Throws : NA
** Calls : NA
** Test Class : NA
** Organization : Navatar Group
** Revision History:-
** Version Date(YYYY-MM-DD)       Author  Description of Action
** 1.0     2016-06-21             Pramod  
*********************************************************************************/
public with Sharing class ContactTransferSettingsSetup_Ctlr{
    public Boolean isEnbleContTransferSetup{get;set;}           //used to enble conatct transfer setting
    public List<Navatar_Setup__c> lstNavSetup;                  //contains navatar setup record
    public Navatar_Setup__c objNavSetup;                        //Used for navatar setup record
    public String strErrorMessage{get;set;}                     //contain error message
    public Boolean isAuthorizeUser{get;set;}                    //used to check if login user system admin
    public String ctsActivity{get;set;}                         //contain cts activity value
    public String ctsAdvancedActivity{get;set;}                 //contain cts advance activity value
    public List<SelectOption> ctsActivityOption{get;set;}       //contain cts activity picklist value
    public List<SelectOption> ctsAdvancedOption{get;set;}       //contain cts advance activity piclist value
    public List<Org_Setting__mdt> lstOrgSett;                   //contain contact transfer setup setting
    public String strNameSpace{get;set;}                        //store org name space.
    public Boolean showEditSection{get;set;}                    //used to show edit section on page
    public Boolean showdetailSection{get;set;}                  //used to show detail section on page
    public MetadataService.RelatedListItem mdsrTemp;
    public String strOrgnizationNameSpace; 
    public String strPageName{get;set;}
    public Boolean isAdminSettingOn{get;set;} 
    
    public ContactTransferSettingsSetup_Ctlr(){         
        try{
            strOrgnizationNameSpace = CommonUtility.strOrgNameSpacePrefix;
            lstOrgSett = new List<Org_Setting__mdt>();
            //Added By Qadir Khan for PE 3.5 07 DEC 2017.
            if(Schema.sObjectType.Org_Setting__mdt.isAccessible() && Schema.sObjectType.Org_Setting__mdt.fields.IsActive__c.isAccessible() && Schema.sObjectType.Org_Setting__mdt.fields.label.isAccessible() && Schema.sObjectType.Org_Setting__mdt.fields.developername.isAccessible()){
                lstOrgSett=[SELECT IsActive__c,label,developername FROM Org_Setting__mdt where developername ='Contact_Tran_Setting' limit 1];
            }               
            showdetailSection = true; showEditSection = false;
            isAdminSettingOn = false;
            if(lstOrgSett.size()>0){
                if(lstOrgSett[0].IsActive__c==true)
                    isEnbleContTransferSetup = true;
            }
            lstNavSetup = new List<Navatar_Setup__c>();
            //Added By Qadir Khan for PE 3.5 07 DEC 2017.
            if(Schema.sObjectType.Navatar_Setup__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.cts_activity__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.cts_advanced__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.admin_setting__c.isAccessible()){ 
                lstNavSetup =[SELECT cts_activity__c ,cts_advanced__c FROM Navatar_Setup__c where admin_setting__c=true Limit 1];
            }
            if(lstNavSetup.Size()>0){               
                objNavSetup = lstNavSetup[0];  isAdminSettingOn = true;
                Schema.DescribeFieldResult activityField = Navatar_Setup__c.cts_activity__c.getDescribe();
                ctsActivityOption = new list<SelectOption>();
                ctsAdvancedOption = new list<SelectOption>();             
                for (Schema.Picklistentry picklistEntry : activityField.getPicklistValues())
                {
                    ctsActivityOption.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel()));
                }
                Schema.DescribeFieldResult ctsAdvancedField = Navatar_Setup__c.cts_advanced__c.getDescribe();
                for (Schema.Picklistentry picklistEntry : ctsAdvancedField.getPicklistValues())
                {
                    ctsAdvancedOption.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel()));
                }
                ctsActivity =   objNavSetup.cts_activity__c;
                ctsAdvancedActivity = objNavSetup.cts_advanced__c;
            }
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in Constructor : '+ex));                 
        }
        
    }
    
    /*
@Description: Method called on click Edit contact transfer Setup.
@Parameter1: variable isAuthorizeUser is used to check if user is system admin.
*/  
    public void onEditContTransferSetup(){          
        try{
            showdetailSection = false; showEditSection = true;
            Profile usrProfile = new Profile();
            if(Schema.sObjectType.Profile.isAccessible() && Schema.sObjectType.Profile.fields.Name.isAccessible())
                usrProfile = [Select Name from Profile where Id =: userinfo.getProfileid()];
            if(usrProfile.name!=null){
                if(usrProfile.name=='System Administrator'){ 
                    isAuthorizeUser = true;
                }
                else{
                    strErrorMessage ='You do not have permissions to edit this information. Please contact your System Administrator.';
                }
            }
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in onEditContTransferSetup method : '+ex));              
        }
    }
    
    /*
@Description: Method called on click cancel button.
@Parameter1: Variable showdetailSection is used to show detail section.
*/
    public PageReference onCancel(){
        showdetailSection= true; showEditSection= false;
        PageReference orderPage = new PageReference('/apex/ContactTransfer_Settings_setup');
        orderPage.setRedirect(true);
        return orderPage;         
    }
    
    /*
@Description: Method called on save contact transfer setup.
@Parameter1: variable isEnbleContTransferSetup is used to check if enable contact transfer setup.
*/  
    public void onSaveContTransferSetting(){  
        try{
            
            showdetailSection = true; showEditSection = false;
            if(lstOrgSett.Size()>0){               
                updateContactLayout(isEnbleContTransferSetup);                              
                CustomMetadataService.updateMetadata(new List<SObject> {lstOrgSett[0]},isEnbleContTransferSetup);
            }   
            if(lstNavSetup.Size()>0){
                if(Schema.sObjectType.Navatar_Setup__c.fields.cts_activity__c.isUpdateable()){
                    objNavSetup.cts_activity__c = ctsActivity;
				}
                if(Schema.sObjectType.Navatar_Setup__c.fields.cts_advanced__c.isUpdateable()){
                    objNavSetup.cts_advanced__c = ctsAdvancedActivity;
                 }					
                if(Schema.sObjectType.Navatar_Setup__c.isUpdateable()){
                    update objNavSetup;
				}
            }                     
            
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in onSaveContTransferSetting method : '+ex));                
        }
    }
    
    public list<string> getLayoutNameData(string objName)
    {
        List< String > strLayoutName = new List< String >();
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
        MetadataService.ListMetadataQuery listView = new MetadataService.ListMetadataQuery();
        listView.type_x = 'Layout';
        listView.folder = objName;
        queries.add(listView);
        
        if (!System.Test.isRunningTest()) {
            MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, 25);
            for(MetadataService.FileProperties fileProperty : fileProperties){              
                strLayoutName.add(fileProperty.fullname);
            } 
        }else{
            strLayoutName.add('contact layout');
        }
        return strLayoutName;
    }
    
    
    /*
@Description: Method called on enable contact transfer setup and used for update custom metadatatype.
@Parameter1: variable isEnbleContTransferSetup is used to check if enable contact transfer setup.
*/  
    public void updateContactLayout(boolean isEnableSetup){
        
        try{ 
            
            MetadataService.MetadataPort service = new MetadataService.MetadataPort();
            service.SessionHeader = new MetadataService.SessionHeader_element();
            service.SessionHeader.sessionId = UserInfo.getSessionId();  
            strNameSpace = CommonUtility.strNameSpacePrefix;
            
            List<String> layoutList = new List<String>();  
            List<String> accLayouts = new List<String>();  
            
            List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
            MetadataService.ListMetadataQuery listView = new MetadataService.ListMetadataQuery();
            listView.type_x = 'Layout';
            listView.folder = 'contact';
            queries.add(listView);            
            layoutList = getLayoutNameData('Contact');
            
            boolean isMetadataUpate = false;
            List< String > objLayouts= new List< String >();                
            objLayouts = getLayoutNameData('Account');
            MetadataService.MetadataPort service1 = new MetadataService.MetadataPort();
            service1.SessionHeader = new MetadataService.SessionHeader_element();
            service1.SessionHeader.sessionId = UserInfo.getSessionId();        
            
            List<string> excludeBtnLst= new List<string>();
            excludeBtnLst.add('NewTask');
            excludeBtnLst.add('NewEvent');
            //Commented by Lakshya on 20210423 [PE v4.7]
            /*MetadataService.RelatedListItem mdsr= new MetadataService.RelatedListItem(); 
            mdsr.excludeButtons= excludeBtnLst;
            mdsr.relatedList= 'Activity.'+strNameSpace+'Institution__c';
            mdsr.sortField= null;
            mdsr.sortOrder= null;
        
            for(string strInstitutionLayoutname: objLayouts){                
                if(isEnableSetup==true){
                    isMetadataUpate = false;
                    List<MetadataService.RelatedListItem> lstMD;
                    MetadataService.Layout layout;
                    
                    if (!System.Test.isRunningTest()) {
                        layout = (MetadataService.Layout)service1.readMetadata('Layout',new String[] {strInstitutionLayoutname.replace('Account-','Account-'+strOrgnizationNameSpace)}).getRecords()[0];
                        if(layout.relatedLists == null){
                            layout.relatedLists = new List<MetadataService.RelatedListItem>(); 
                        }                           
                        lstMD= layout.relatedLists;
                        
                    }else{
                        MetadataService.Layout objLayout = new MetadataService.Layout(); 
                        MetadataService.RelatedListItem[] lstRelatedLists = new list<MetadataService.RelatedListItem>();
                        MetadataService.RelatedListItem objRelatedListItem = new MetadataService.RelatedListItem();                                 
                        String[] lstFields = new list<String>();
                        lstFields.add('Field1');                            
                        objRelatedListItem.fields = lstFields;
                        lstRelatedLists.add(objRelatedListItem);
                        objLayout.relatedLists = lstRelatedLists;
                        layout = objLayout;
                        lstMD = layout.relatedLists;
                    }   
                    
                    if(layout.fullname != null){
                        for(integer i=0;i<lstMD.size();i++)
                    {
                        List<String> strlist = new List<String>(); 
                        if(lstMD[i].relatedList==mdsr.relatedList && !isMetadataUpate){
                            isMetadataUpate=true; 
                        }
                        if(lstMD[i]!= null)
                        {
                            if(lstMD[i].fields!=null)
                            {  
                                for(String str : lstMD[i].fields)
                                { 
                                    str =  str.replace(''+strOrgnizationNameSpace+'','');
                                    strlist.add(str);
                                }
                            }
                        }
                        lstMD[i].fields =  strlist; 
                    }
                    if(isMetadataUpate == false && isEnableSetup==true){
                        if(mdsr.fields!=null)
                        {  
                            List<String> strlist1 = new List<String>();
                            for(String str : mdsr.fields)
                            { 
                                str =  str.replace(''+strOrgnizationNameSpace+'','');
                                strlist1.add(str);
                            }
                            mdsr.fields =strlist1;
                        }
                        layout.relatedLists.add(mdsr);
                        MetadataServiceHandler.handleSaveResults(service.updateMetadata(new MetadataService.Metadata[] { layout })[0]);
                    }
                    }
                }else if(isEnableSetup==false){                     
                    removeRelatedListAct(strInstitutionLayoutname);
                }     
            }*/
            
            for(String strLayout: layoutList){  
                
                MetadataService.Layout layout;
                List<MetadataService.RelatedListItem> lstMD;
                
                if (!System.Test.isRunningTest()) {
                    layout = (MetadataService.Layout)service.readMetadata('Layout',new String[] {strLayout.replace('Contact-','Contact-'+strOrgnizationNameSpace)}).getRecords()[0];
                }
                else{
                    MetadataService.Layout objLayout = new MetadataService.Layout(); 
                    MetadataService.RelatedListItem[] lstRelatedLists = new list<MetadataService.RelatedListItem>();
                    MetadataService.RelatedListItem objRelatedListItem = new MetadataService.RelatedListItem();                                 
                    String[] lstFields = new list<String>();
                    lstFields.add('Field1');                            
                    objRelatedListItem.fields = lstFields;
                    lstRelatedLists.add(objRelatedListItem);
                    objLayout.relatedLists = lstRelatedLists;
                    layout = objLayout;
                    lstMD = layout.relatedLists;
                }   
                
                if(layout.fullname != null && layout.relatedLists!=null){
                    lstMD = layout.relatedLists;                            
                    for(integer i=0;i<lstMD.size();i++){                
                        
                        List<String> strlist = new List<String>();                    
                        if(lstMD[i]!=null){
                            if(lstMD[i].fields!=null){
                                
                                for(String str : lstMD[i].fields){                                      
                                    str =  str.replace(''+strOrgnizationNameSpace+'','');
                                    strlist.add(str);                                        
                                }
                            }
                        }
                        lstMD[i].fields =  strlist; 
                    }                       
                    if(layout.customButtons==null){        
                        if(isEnableSetup==true){
                            layout.customButtons = new List<String>();
                            layout.customButtons.add(''+strNameSpace+'Contact_Transfer');
                        }
                    }
                    else{
                        boolean isAddCustomButton= true;
                        for(integer i=0;i<(layout.customButtons).size();i++){
                            if((layout.customButtons).get(i)==''+strNameSpace+'Contact_Transfer'){ 
                                isAddCustomButton = false;
                                if(isEnableSetup==false){        
                                    layout.customButtons.remove(i);                                    
                                }                                 
                            }                           
                        }
                        if(isAddCustomButton){
                            if(isEnableSetup==true)
                                layout.customButtons.add(''+strNameSpace+'Contact_Transfer');
                        }                                            
                         
                    }
                    MetadataServiceHandler.handleSaveResults(service.updateMetadata( new MetadataService.Metadata[] { layout })[0]);
                }
            }
            
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in updateContactLayout method : '+ex));              
        } 
    }
    
    /*
    @Description: Method called on click page name to redirect page.   
    */ 
    public PageReference redirectpage() {
        PageReference pageRef = new PageReference('/apex/'+strPageName+'');
        pageRef.setRedirect(true);
        return pageRef;
    }
    //Commented by Lakshya on 20210423 [PE v4.7]
    /*public void removeRelatedListAct(string strName)
    {
        
        try
        {
            MetadataService.MetadataPort service = new MetadataService.MetadataPort();
            service.SessionHeader = new MetadataService.SessionHeader_element();
            service.SessionHeader.sessionId = UserInfo.getSessionId();
            
            List<MetadataService.RelatedListItem> lstMD  = new List<MetadataService.RelatedListItem>(); 
            MetadataService.Layout layout;
            
            if (!System.Test.isRunningTest()) {
                layout = (MetadataService.Layout)service.readMetadata('Layout',new String[] {strName.replace('Account-','Account-'+strOrgnizationNameSpace)}).getRecords()[0];
            }else{
                MetadataService.Layout objLayout = new MetadataService.Layout(); 
                MetadataService.RelatedListItem[] lstRelatedLists = new list<MetadataService.RelatedListItem>();
                MetadataService.RelatedListItem objRelatedListItem = new MetadataService.RelatedListItem();                                 
                String[] lstFields = new list<String>();
                lstFields.add('Field1');                            
                objRelatedListItem.fields = lstFields;
                lstRelatedLists.add(objRelatedListItem);
                objLayout.relatedLists = lstRelatedLists;
                layout = objLayout;
                lstMD = layout.relatedLists;                    
            }                                              
            if(layout!=null && layout.fullname != null){
                if(layout.relatedLists!=null)
                    lstMD= layout.relatedLists;
            }
            if(lstMD.size()>0) { 
                for(integer i=0;i<lstMD.size();i++)
                {
                    MetadataService.RelatedListItem mdsR= lstMD[i];
                    List<String> strlist = new List<String>();  
                    if(lstMD[i]!= null)
                    {
                        if(lstMD[i].fields!=null)
                        {  
                            for(String str : lstMD[i].fields)
                            { 
                                str =  str.replace(''+strOrgnizationNameSpace+'','');
                                strlist.add(str);
                            }
                        }
                    }
                    lstMD[i].fields =  strlist; 
                    if(mdsR.relatedList == 'Activity.'+strNameSpace+'Institution__c')
                    {
                        layout.relatedLists.remove(i);  
                    } 
                }
                MetadataServiceHandler.handleSaveResults(service.updateMetadata(new MetadataService.Metadata[] { layout })[0]);
            }            
        }
        Catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in updateContactLayout method : '+ex));
        }
    }*/    
}