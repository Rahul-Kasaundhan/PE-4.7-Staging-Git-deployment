/******************************************************************************************************************************************************
** Module Name             : Create Fundraisings
** Description             :    1. Create multiple fundraising on a single button click
                                2. Validate all the information provided by CMF page  
                                3. Inserting information with dynamically seted fields and corresponding values 
** Use in Page             : CreateFundraisings
** Product Version         : PE 3.5
** Test Class              : Test_CreateFundraisingsCls
** Object Use for SOQL     : Fundraising,Contact,Account,Fundraising Contacts
** Developer               : Sumitab Saxena
** Date                    : 12-May-2016
** Organization            : Navatar Group
** Revision History:-
** Version  Date(YYYY-MM-DD)       Author  Description of Action
** 2.0      2018-08-02             Qadir   PE v3.7: Summer 18 lightning navigation fix.  
********************************************************************************************************************************************************/
public with sharing class CreateMassFundraisingCls
{
    public string strSourceLoc{get;set;}        // get Source Location
    public string retrunURlID{get;set;}         // get URL id
    public string fundId{get;set;}              //get Fund Id
    public boolean ErrorStatusInsufficient{get;set;}        // get the Errorstatus for Insufficient .
    public boolean ErrorStatus{get;set;}        // get the Errorstatus  .
    public boolean ErrorStatusFundId{get;set;}        // get the Errorstatus for Fund Id missing.
    public fund__c lstFundDetails{get;set;}        // get fund's detail
    public fund__c lstFundDetailsCoInvst{get;set;}        // get fund's detail for co invstment Setting
    public list<fund__c> strFundExist{get;set;}        // get fund's detail for co invstment Setting
    public Account PrtFolioDetails {get;set;} 
    public Fundraising__c fundR {get;set;}      // get fundraising's detail  
    public String NameSpacePrefix {get;set;}    // get namespaceprefix from commonutill class
    public string locale_info{get;set;}         // get the local information of org
    public Transient String fieldArray {get;set;}         // get fundraising field's selected from CMF page 
    public Transient String valueArray {get;set;}         // get fundraising selected field's value from CMF page
    //public String accCount {get;set;}           // get the number of accounts 
    public Transient string jsonString {get;set;}         // get the information sent from CMF in JSON format   
    public string portFolioID {get;set;}        // get the portfolio interms of id 
    //public string portFolioValue{get;set;}      // get the portfolio interms of name   
    public List<sObject> fndRaisingRecords = new List<Fundraising__c>();    // get all the fundraising that going to create
    public List<List<String>> fieldArrayParsed = new List<List<String>>();  // get all the parsed fields  
    public List<String> valueArrayParsed = new List<String>();              // get all the parsed fields' value  
    //public List<String> accCountParsed = new List<String>();                // get parsed accountID 
    public List<String> jsonStringParsed;                                   // get information during parsing    
    public Map<Id,List<List<String>>> accIDToFundContacts = new Map<Id,List<List<String>>>();    // Link account info to fundraising contact
    public List<Id> accIds = new List<Id>();     // get list of Account Ids               
    public List<Id> fnDRIds = new List<Id>();    // get lsit of fundraising Ids
    private sObject fObj;                        // get the temporary data for different records of fundraising
    public string errorMesssage{get;set;}        // Alert the error
    public boolean blnCoInvestment{get;set;}     //Check for Co-investment or not
    public Fundraising__c FundLookupPopup{get;set;}
    public Fundraising__c CompanyLkupPopup{get;set;}
    public Fundraising__c CompanyLkupWarngPopup{get;set;}
    public string FundIdLkup{get;set;}
    public Fundraising__c FundLookupLndPg{get;set;}
    public string strComId{get;set;}
    public list<fundraising__c> objlstFundDetailsComp{get;set;}   
    public list<Partnership__c> objlstCommitmentDetailsComp{get;set;}   
    public list<SelectOption> FundOptions {get;set;}
    public list<SelectOption> FndDupChkLst {get;set;}
    public list<SelectOption> FndDupChkLstPartnership {get;set;}
    
    
    public String strSelectedFund  {get;set;}
    public boolean ErrorStatusDiffAcc  {get;set;}
    public boolean blnCoInvstFundDel  {get;set;}
    public String ErrorMsgDiffAcc{get;set;}
    public string CompId {get;set;}
    public string strcrntCompId{get;set;}
    public string selectedTabVal{get;set;}
    public boolean blnValidCompTyp{get;set;}
    private boolean blnval;
    private list<account> CompIdAcc;
    private list<recordtype> CompIdRecTyp;
    private string CompIdRcrdTyp;
    public boolean blnCompValidEntr{get;set;}
    public boolean WarngPopupValEntrd{get;set;}
    private boolean blnExistVal;
    public string portFolioName{get;set;}
    public string WrenchClickedLoctnVal{get;set;}
    public string proptxtdata{get;set;}
    public string ErrorVal{get;set;} 
    public boolean isCoInvestmentStngOn{get;set;}
    public string strCoInvstFundId{get;set;}
    public List<Navatar_Setup__c> lstNavatarSetup{get;set;}
    public boolean blnFundIdMatchedHome{get;set;}   
    public boolean blnDfrntCoInvstFund{get;set;}    
    public boolean blnRegularFundCoInvst{get;set;} 
    public boolean isCurrency{get;set;}   /*variable  to check if multicurrency is enabled in class or not  */
    public string localeString{get;set;}  /*variable  to check locale of the user  */
    public string strCurrencySystembol{get;set;}/*variable  to check default currency of the user  */   
    public string Idsubstr;
    public string FundraisingTabData{get;set;}
    public string strFundraisingTabId{get;set;}
    public string strServerUrl{get;set;}
    public string CoInvstFund{get;set;}
    public string FundName{get;set;}
    public string SourceId{get;set;}
    public boolean blnConEmailAccDenied{get;set;}
    //public static boolean blnIsRunConst=true;
     public String[] arryServarUrl;
     
    public map < String, String > mapFundSelectOptions {get;set;}
    public static boolean triggerenabled = false;
        
    // Defining constructor 
    public CreateMassFundraisingCls(ApexPages.StandardSetController controller)
    {
        WarngPopupValEntrd=false;
        isCoInvestmentStngOn = false;
        WrenchClickedLoctnVal='';
        blnConEmailAccDenied=false;
        FundLookupPopup=new Fundraising__c();
        NameSpacePrefix = CommonUtility.strNameSpacePrefix;
        CompanyLkupPopup=new Fundraising__c();
        CompanyLkupWarngPopup=new Fundraising__c();
        FundLookupLndPg= new Fundraising__c();
        blnValidCompTyp=true;
        blnCoInvstFundDel=false;
        selectedTabVal='AllContTabId';
        blnDfrntCoInvstFund=true;
        
        strCoInvstFundId='';
        blnCompValidEntr=false;
        objlstFundDetailsComp=new list<fundraising__c>();
        
        try{
            strServerUrl = ApexPages.currentPage().getHeaders().get('Host');
            arryServarUrl = strServerUrl.split('\\.');
            strSourceLoc=apexpages.currentpage().getparameters().get('Source');
            
            if(strSourceLoc!='' && strSourceLoc!=null)
            {
                if(strSourceLoc=='Com' || strSourceLoc=='Fund')
                {
                
                    id srcId = apexpages.currentpage().getparameters().get('Id');
                    SourceId = string.valueOf(srcId);
                    if(SourceId != '' && SourceId != null) {
                        retrunURlID  = '/' + SourceId;
                    }
                    else{
                        
                        retrunURlID =apexpages.currentpage().getparameters().get('retURL'); //PE v3.7: Summer 18 lightning navigation fix
                    }                   
                    
                }
                else
                {
                    retrunURlID =apexpages.currentpage().getparameters().get('retURL');//PE v3.7: Summer 18 lightning navigation fix
                }
                locale_info = UserInfo.getLocale();
                ErrorStatusInsufficient=true;
                ErrorStatusFundId=true;
                blnFundIdMatchedHome=true;
                blnRegularFundCoInvst=false;
                strSelectedFund = '';
                ErrorMsgDiffAcc = '';
                strCurrencySystembol = UserInfo.getDefaultCurrency();
                string user_id=Userinfo.getUserId();
                mapFundSelectOptions = new map < String, String > ();
                if ((Schema.sObjectType.Account.isCreateable() || Schema.sObjectType.Account.isAccessible()) && (Schema.sObjectType.Contact.isCreateable() || Schema.sObjectType.Contact.isAccessible()) && (Schema.sObjectType.Fundraising__c.isCreateable()) && (Schema.sObjectType.Fundraising_Contact__c.isCreateable()))
                {
                    if(Schema.sObjectType.Account.Fields.Institution_Type__c.isAccessible() && Schema.sObjectType.Account.Fields.Fund_Types__c.isAccessible()  &&  Schema.sObjectType.Contact.Fields.AccountId.isAccessible()  && Schema.sObjectType.Fundraising__c.Fields.Fund_Name__c.isCreateable() && Schema.sObjectType.Fundraising__c.Fields.Portfolio_Company__c.isCreateable())
                    {
                        ErrorStatusInsufficient= true;
                    }
                    else
                    {
                        ErrorStatusInsufficient= false;
                    }
                }
                else
                {
                    ErrorStatusInsufficient=false;  
                }
                if(ErrorStatusInsufficient == true)
                {
                    String strFundRaisingObj = NameSpacePrefix + 'Fundraising__c';
                    Schema.DescribeSObjectResult FundRaisingTabData = Schema.getGlobalDescribe().get(strFundRaisingObj.toLowerCase()).getDescribe();
                    strFundraisingTabId = FundRaisingTabData.getKeyPrefix();
                    List<Org_Setting__mdt> lstOrgSett = new List<Org_Setting__mdt>();
                    if(Schema.sObjectType.Org_Setting__mdt.isAccessible() && Schema.sObjectType.Org_Setting__mdt.fields.IsActive__c.isAccessible() && Schema.sObjectType.Org_Setting__mdt.fields.label.isAccessible() && Schema.sObjectType.Org_Setting__mdt.fields.developername.isAccessible()){
                        lstOrgSett=[SELECT IsActive__c,label,developername FROM Org_Setting__mdt where developername ='Co_Inv_Setting' and IsActive__c=true limit 1];
                    }
                    if(lstOrgSett.size() >0)
                    {
                        isCoInvestmentStngOn = lstOrgSett[0].IsActive__c;
                        
                    }
                    lstNavatarSetup = new List<Navatar_Setup__c>();
                    if(Schema.sObjectType.Navatar_Setup__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.CI_Fund_ID__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.Admin_Setting__c.isAccessible()){
                        lstNavatarSetup = [Select CI_Fund_ID__c from Navatar_Setup__c  where Admin_Setting__c = true order by CreatedDate ASC limit 1]; 
                    }
                    if(lstNavatarSetup.size() >0 && lstNavatarSetup[0].CI_Fund_ID__c!=null)
                    {
                        if(Schema.sObjectType.fund__c.isAccessible())
                            strFundExist=[select id from fund__c where id =: lstNavatarSetup[0].CI_Fund_ID__c limit 1];
                        if(strFundExist.size()>0)
                        {
                            strCoInvstFundId = lstNavatarSetup[0].CI_Fund_ID__c;
                            strCoInvstFundId = strCoInvstFundId.substring(0,15);
                        }
                        else
                        {
                            strCoInvstFundId = '';
                            
                        }
                    }
                    
                    if(strSourceLoc=='Com')
                    {
                        if(SourceId != null && SourceId !='')
                        { 
                            if(isCoInvestmentStngOn==true)
                            {
                                fundId=strCoInvstFundId;
                                if(fundId!='')
                                {
                                    CompId=retrunURlID.substring(retrunURlID.lastIndexOf('/')+1,retrunURlID.length());
                                    CompId=CompId.substring(0,15);
                                    CompIdRcrdTyp=CompId;
                                    ContClickedPopup();
                                }
                                else
                                {
                                    blnCoInvstFundDel=true;
                                }
                            }
                            else
                            {   
                                strcrntCompId=retrunURlID.substring(retrunURlID.lastIndexOf('/')+1,retrunURlID.length());
                                strcrntCompId=strcrntCompId.substring(0,15);
                                if(Schema.sObjectType.Fundraising__c.fields.Portfolio_Company__c.isUpdateable())
                                    CompanyLkupPopup.Portfolio_Company__c=strcrntCompId;
                                CompSlctdLkup();
                            }
                        }
                        else
                        {
                             ErrorStatusFundId = false; 
                            
                        }                   
                    }
                    else if(strSourceLoc=='Fund')
                    {
                        fundId = apexpages.currentpage().getparameters().get('id');
                        if(fundId != null && fundId !='')
                        {       
                             if(Schema.sObjectType.Fund__c.isAccessible() && Schema.sObjectType.Fund__c.fields.name.isAccessible() && Schema.sObjectType.Fund__c.fields.Investment_Category__c.isAccessible())  
                                lstFundDetailsCoInvst = [select name,Investment_Category__c from Fund__c WHERE id =: fundId limit 1];
                                if(isCoInvestmentStngOn==true)
                                {
                                    if(lstFundDetailsCoInvst.Investment_Category__c =='Co-investment' && fundId != strCoInvstFundId)
                                    {
                                       blnRegularFundCoInvst=false;
                                    }
                                    else if(lstFundDetailsCoInvst.Investment_Category__c=='Co-investment' && fundId == strCoInvstFundId)
                                    {
                                        blnDfrntCoInvstFund=false;
                                        blnRegularFundCoInvst=false;
                                        fundId=strCoInvstFundId;
                                        CoInvstFund=lstFundDetailsCoInvst.Name;
                                    }
                                    else
                                    {
                                        blnRegularFundCoInvst=true;
                                        ContClickedPopup();
                                    }
                                    
                                    
                                }
                                else
                                {
                                    if(lstFundDetailsCoInvst.Investment_Category__c !='Co-investment' )
                                    {
                                        ContClickedPopup();
                                    }
                                    
                                }
                        }
                        else
                        {
                            ErrorStatusFundId = false; 
                            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Fund ID missing can not load this page.'));
                        }
                        
                    }
                    else
                    {
                        
                        
                    }
                }   
                
            }
        }
        catch(exception ex){
             ErrorStatusInsufficient= false;
             retrunURlID='/home/home.jsp';
        }
        
        
    }
    public pageReference BackRedirection() {
        
            pageReference pagref = new pageReference(retrunURlID);
            pagref.setRedirect(true);
            return pagref;
        
        
    }
    public pageReference BackRedirectionHome() {
        string strPageRefVal;
        if(strSourceLoc!='' && fundId!='' && fundId!=null)
        {
            if(strSourceLoc=='Home')
            {
                strPageRefVal='/'+strFundraisingTabId+'/o';
            }
            else
            {
                
                strPageRefVal= retrunURlID;
                
            }
            
        }
        else 
        {
            strPageRefVal= apexpages.currentpage().getparameters().get('retURL');
        }
        pageReference pagref = new pageReference(strPageRefVal);
        pagref.setRedirect(true);
        return pagref;
    }
    
    
    //This method is called when Company from Company page is changed and for showing the related fund values inselectlist.
    public void CompSlctdLkup()
    {
        mapFundSelectOptions = new map < String, String > ();
        //strcrntCompId=CompanyLkupPopup.Portfolio_Company__c;
        blnValidCompTyp=validCompSlctd();
        if(blnValidCompTyp)
        {
            objlstFundDetailsComp = new List<fundraising__c>();
            objlstCommitmentDetailsComp = new List<Partnership__c>();
            if(Schema.sObjectType.fundraising__c.isAccessible() && Schema.sObjectType.fund__c.fields.name.isAccessible() && Schema.sObjectType.fundraising__c.fields.portfolio_company__c.isAccessible() && Schema.sObjectType.fundraising__c.fields.Fund_Name__c.isAccessible()){
                objlstFundDetailsComp =[select Fund_Name__r.id,Fund_Name__r.name from fundraising__c where portfolio_company__c =:CompId];
            }
            if(Schema.sObjectType.Partnership__c.isAccessible() && Schema.sObjectType.fund__c.isAccessible() && Schema.sObjectType.fund__c.fields.name.isAccessible() && Schema.sObjectType.Commitment__c.isAccessible() && Schema.sObjectType.Commitment__c.fields.Partnership__c.isAccessible() && Schema.sObjectType.Commitment__c.fields.portfolio_company__c.isAccessible()){
                objlstCommitmentDetailsComp =[Select Fund__r.Name, Fund__r.Id From Partnership__c where Id IN (Select Partnership__c from Commitment__c where Portfolio_Company__c =:CompId )];
            }
            FundOptions = new list<SelectOption>();
            FundOptions.add(new SelectOption('','None'));
            if(objlstFundDetailsComp.size()>0)
            {
                for(Fundraising__c objFndDtlLoopVl :objlstFundDetailsComp )
                {
                    mapFundSelectOptions.put(objFndDtlLoopVl.Fund_Name__r.Id, objFndDtlLoopVl.Fund_Name__r.Name);
                }
                
            }
            if(objlstCommitmentDetailsComp.size()>0)
            {
                
                for(Partnership__c objFndDtlLoopVlPrtnership : objlstCommitmentDetailsComp )
                {
                    mapFundSelectOptions.put(objFndDtlLoopVlPrtnership.Fund__r.Id, objFndDtlLoopVlPrtnership.Fund__r.Name);
                }
            }
            if (mapFundSelectOptions.size() > 0) {
                for (String strFundId: mapFundSelectOptions.keyset()) {
                    FundOptions.add(new SelectOption(strFundId, mapFundSelectOptions.get(strFundId)));
                }
            }
        }
        else
        {}
    }
    //This method is called when Company from Warning Msg is selected.
    public void CompSlctdLkupWarng()
    {
        blnValidCompTyp=validCompSlctd();
        portFolioID=CompanyLkupWarngPopup.Portfolio_Company__c;
    }
    
    //Check's whether correct Account with recort typ of Company is selected or not. 
    public boolean validCompSlctd()
    {
        blnCompValidEntr=true;
        //Additional for Property Check Starts
        CompIdRecTyp = new list<recordtype>();
        if(Schema.sObjectType.recordtype.isAccessible() && Schema.sObjectType.recordtype.fields.developername.isAccessible()){
            //Added condition Portfolio_Company recordtype in PE v4.5 By Hemendra 
            CompIdRecTyp=[select id from recordtype where SobjectType= 'account' and (DeveloperName = 'company' or DeveloperName = 'Portfolio_Company' Or DeveloperName = 'property')];
        }
        if(WarngPopupValEntrd)
        {
            CompIdRcrdTyp=CompanyLkupWarngPopup.Portfolio_Company__c;
        }
        else
        {
            CompIdRcrdTyp=CompanyLkupPopup.Portfolio_Company__c;
        }
        if(CompIdRcrdTyp!=null)
        {
            CompIdAcc = new list<account>();
            if(Schema.sObjectType.account.isAccessible() && Schema.sObjectType.Account.fields.recordtypeId.isAccessible()){
                CompIdAcc=[select recordtypeid from account where id=:CompIdRcrdTyp limit 1];
            }
            //Additional for Property Check Starts
            for(integer x=0;x<CompIdRecTyp.size();x++)
            {
                if(CompIdRecTyp[x].id==CompIdAcc[0].recordtypeid)
                {
                    if(WarngPopupValEntrd)
                    {
                        CompId=CompanyLkupWarngPopup.Portfolio_Company__c;
                    }
                    else
                    {
                        CompId=CompanyLkupPopup.Portfolio_Company__c;
                    }
                    blnval=true;
                    break;
                }
                else
                {
                    blnval=false;
                }
                
            }
            //Additional for Property Check End
            
        }
        else
        {
            blnval=true;
        }
        return blnval;
    }
    
    //Check's Fund Type and Redirection Location after Continue Clicked from popup. 
    public void ContClickedPopup()
    {
        if(strSourceLoc == 'Home' || (strSourceLoc == 'Fund' && lstFundDetailsCoInvst.Investment_Category__c=='Co-investment'))
        {   blnValidCompTyp=validCompSlctd();
            if(blnValidCompTyp)
            {
                if(strSourceLoc == 'Home')
                {
                    fundId=FundLookupPopup.Fund_Name__c;
                }
                else
                {
                    if(isCoInvestmentStngOn==true  && blnDfrntCoInvstFund==false)
                    {
                        fundId=strCoInvstFundId;
                    }
                    else
                    {
                        fundId=FundLookupPopup.Fund_Name__c;
                    }
                    
                }
                if(CompanyLkupPopup.Portfolio_Company__c!=null && Schema.sObjectType.Fundraising__c.fields.Portfolio_Company__c.isUpdateable())
                {
                     CompanyLkupPopup.Portfolio_Company__c=CompId;
                }
            }
        }
        else if(strSourceLoc == 'Com')
        {
            if(isCoInvestmentStngOn==true)
            {
                fundId=strCoInvstFundId;
            }
            else{
                if(string.isBlank(strSelectedFund))
                {
                    fundId=CompanyLkupPopup.Fund_Name__c;
                }
                else
                    fundId=strSelectedFund;
            }
            if(CompanyLkupPopup.Portfolio_Company__c!=null && Schema.sObjectType.Fundraising__c.fields.Portfolio_Company__c.isUpdateable())
            {
                 CompanyLkupPopup.Portfolio_Company__c=CompId;
            }
           
            
        }
        
            
        if (fundId != null && fundId !='')
        {
            //to check if the Fund Is been channged in case of home for Co invstment setting ON
            if(strSourceLoc == 'Home' && FundLookupPopup.Fund_Name__c!=null)
            {
                fundId=FundLookupPopup.Fund_Name__c;
            }
            if(Schema.sObjectType.Fund__c.isAccessible() && Schema.sObjectType.Fund__c.fields.Investment_Category__c.isAccessible() && Schema.sObjectType.Fund__c.fields.name.isAccessible())
                lstFundDetails = [select id, name, Investment_Category__c from Fund__c WHERE id =: fundId limit 1];
            FundName=lstFundDetails.name;
            if(FundName.length()>30)
            {
                FundName=FundName.substring(0,30)+'...';
                //lstFundDetails.name=FundName;
            }
            else{}
            
            
            if(lstFundDetails.Investment_Category__c == 'Co-investment' ){
                if(strSourceLoc == 'Home' && isCoInvestmentStngOn==true )
                {   
                    Idsubstr=FundLookupPopup.Fund_Name__c;
                    Idsubstr=Idsubstr.substring(0,15);
                    if(strCoInvstFundId == Idsubstr)
                    {   
                        blnFundIdMatchedHome=true;
                    }
                    else
                    {
                        blnFundIdMatchedHome=false;
                    }
                }
            
                Schema.DescribeFieldResult chk_Fund_Name = Fundraising__c.Portfolio_Company__c.getDescribe();
                if(!chk_Fund_Name.isCreateable()){
                    //errorMesssage = 'Insufficient privilege';   
                    ErrorStatusInsufficient=false;
                }
            }
            else
            {
                blnFundIdMatchedHome=true;
            }
            ErrorStatusInsufficient = true;  
        }
        else
        {
            ErrorStatusFundId = false; 
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Fund ID missing can not load this page.'));
        }
        
        if(strSourceLoc == 'Com')
        {
            portFolioID=CompIdRcrdTyp;
            if(Schema.sObjectType.Fundraising__c.fields.Portfolio_Company__c.isUpdateable())
                CompanyLkupPopup.Portfolio_Company__c=CompIdRcrdTyp;
        }
        else
        {
            portFolioID=CompanyLkupPopup.Portfolio_Company__c;
        }
        
        if(portFolioID!=null)
        {
            if(Schema.sObjectType.Account.isAccessible() && Schema.sObjectType.Account.fields.name.isAccessible())
                PrtFolioDetails = [select Name from Account WHERE id =: portFolioID limit 1];
            portFolioName=PrtFolioDetails.Name;
        }
        else
        {
            portFolioName='';
        }
    }
     
    //Create & check multiple fundraising with respect to data sent from CMF page 
    public Pagereference createMassFundraisings(){
        
        triggerenabled = true;
        boolean chk_security = false;
        string strBlnkValPC='';
        ErrorStatusInsufficient = true;
        set<id> ConId = new set<id>();
        list<string> lstBlnkContDataAccId =new list<string>();
        list<Account> lstAccDataBlankCont =new list<Account>();
        
        //blnIsRunConst=false;
        //blnIsRun=false;
        
        valueArrayParsed = new List<String>();
        fieldArrayParsed  = new List<List<String>>();
        map<id,id> conAccountIdData = new  map<id,id>();
        map<id,string> accName = new map<id,string>();
        try{
            accIds = new List<Id>();
            JSONParser parser1 = JSON.createParser(fieldArray);
            while (parser1.nextToken() != null) {
                List<String> list1;
                if (parser1.getCurrentToken() == JSONToken.START_ARRAY){ 
                    list1 = new List<String>();
                    
                    while (parser1.nextToken() != JSONToken.END_ARRAY) {
                    
                        if (parser1.getCurrentToken() == JSONToken.VALUE_STRING){    
                            list1.add(parser1.getText());
                        }
                    }
                    fieldArrayParsed.add(list1);
                }
            }
            JSONParser parser2 = JSON.createParser(valueArray);
            while (parser2.nextToken() != null) {
                if(parser2.getCurrentToken() == JSONToken.START_ARRAY){
                    while (parser2.nextToken() != null) {
                        if (parser2.getCurrentToken() != JSONToken.END_ARRAY){
                            valueArrayParsed.add(parser2.getText());
                        }
                    }
                }
            }
            JSONParser parser3 = JSON.createParser(jsonString);
              
            while (parser3.nextToken() != null) {
                jsonStringParsed = new List<String>(); 
                List<List<String>> fundRContactRecords = new List<List<String>>();                
                String id1='';
                if(parser3.getCurrentToken() == JSONToken.FIELD_NAME){
                    jsonStringParsed = new List<String>(); 
                    id1 = parser3.getText();
                    parser3.nextToken(); 
                    while(parser3.getCurrentToken() != JSONToken.END_ARRAY || parser3.nextToken() != JSONToken.END_ARRAY){
                        jsonStringParsed = new List<String>(); 
                        if(parser3.getCurrentToken() == JSONToken.START_ARRAY && parser3.nextToken() != JSONToken.START_ARRAY){
                            integer  i=0;
                            while(parser3.getCurrentToken()!=JSONToken.END_ARRAY){
                                jsonStringParsed.add(parser3.getText());
                                string strConId='';
                                if(blnConEmailAccDenied)
                                {
                                    if(i==1)
                                    {
                                        if(parser3.getText()!='')
                                        {
                                            accName.put(id1,parser3.getText());
                                        }
                                        else{
                                            
                                            lstBlnkContDataAccId.add(id1);
                                        }
                                    }
                                    else if(i==4)
                                    {
                                        
                                        if(parser3.getText() != '')
                                        {
                                            ConId.add(parser3.getText());
                                            conAccountIdData.put(parser3.getText(),id1);
                                        }   
                                    
                                    }
                                }
                                else
                                {
                                    if(i==2)
                                    {
                                        if(parser3.getText()!='')
                                        {
                                            accName.put(id1,parser3.getText());
                                        }
                                        else{
                                            
                                            lstBlnkContDataAccId.add(id1);
                                        }
                                        
                                    }
                                    else if(i==5)
                                    {
                                        
                                        if(parser3.getText() != '')
                                        {
                                            ConId.add(parser3.getText());
                                            conAccountIdData.put(parser3.getText(),id1);
                                        }
                                    }
                                }   
                                parser3.nextToken();
                                i++;
                            }
                             
                             fundRContactRecords.add(jsonStringParsed);
                         }
                        
                     }
                     accIds.add(id1);                   
                     accIDToFundContacts.put(id1, fundRContactRecords); 
                }  
                    
            } 
        }
        catch(exception ex){
            ErrorStatusInsufficient = false; 
            ErrorStatusDiffAcc = true; 
            ErrorMsgDiffAcc=ex.getMessage();
        }
        
        try{
            if(lstBlnkContDataAccId.size()>0)
            {
                if(Schema.sObjectType.Account.isAccessible() && Schema.sObjectType.Account.fields.name.isAccessible()){ 
                    lstAccDataBlankCont=[select name from account where id in:lstBlnkContDataAccId];
                }
                
            }
            for(Account AccBlnkContRec :  lstAccDataBlankCont)
            {
                accName.put(AccBlnkContRec.id,AccBlnkContRec.name);
                
            }
            for(Integer i=0;i<accIds.size();i++){
                if(accIDToFundContacts.get(accIds.get(i))!=null){
                    String frName = accName.get(accIds[i])+' '+'-'+' '+lstFundDetails.Name;
                    if(frName.length() >= 80){
                        frName = frName.substring(0, 79);
                    }
                    fObj = Schema.getGlobalDescribe().get(NameSpacePrefix+'Fundraising__c').newSObject();
                    fObj.put('Name' , frName);
                    Schema.DescribeFieldResult chk_Fund_Name = Fundraising__c.Fund_Name__c.getDescribe();
                    if(chk_Fund_Name.isCreateable()){
                        fObj.put(NameSpacePrefix+'Fund_Name__c' , lstFundDetails.Id);
                    }
                    else{
                        returnError();
                        return null;
                    }
                    Schema.DescribeFieldResult chk_legal_Name = Fundraising__c.Legal_Name__c.getDescribe();
                    if(chk_legal_Name.isCreateable()){
                        fObj.put(NameSpacePrefix+'Legal_Name__c' , accIds[i]);
                    }
                    else{
                        returnError();
                        return null;
                    }
                    
                    try{
                        if(lstFundDetails.Investment_Category__c!='' && lstFundDetails.Investment_Category__c!=null  && portFolioID != '' && portFolioID != null){
                            Schema.DescribeFieldResult chk_Portfolio_Company = Fundraising__c.Portfolio_Company__c.getDescribe();
                            if(chk_Portfolio_Company.isCreateable()){
                                fobj.put(NameSpacePrefix+'Portfolio_Company__c', Id.valueOf(portFolioID));
                            }
                            else{
                                returnError();
                                return null;
                            }
                        }
                        else
                        {
                            fobj.put(NameSpacePrefix+'Portfolio_Company__c', strBlnkValPC);
                            
                        }
                    }
                    catch(exception ex){
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));                        
                    }
                    
                    try{
                        for(Integer m=0; m<fieldArrayParsed.size(); m++){
                            List<String> values = fieldArrayParsed.get(m);
                            if((values.size() <> 0) && (valueArrayParsed.size() <> 0)){
                                if(values.get(1).toLowerCase()=='date'){
                                    if(valueArrayParsed.get(m) != ''){
                                        date d = date.parse(valueArrayParsed.get(m));
                                        fObj.put(fieldArrayParsed.get(m).get(0),d);
                                    }
                                }
                                else if(values.get(1).toLowerCase()=='datetime'){
                                    if(valueArrayParsed.get(m) != ''){
                                        
                                        date d = date.parse(valueArrayParsed.get(m));
                                        
                                        string ret=string.valueof(d);
                                        ret=ret.substring(0,10)+' 00:00:00';
                                        fObj.put(fieldArrayParsed.get(m).get(0),datetime.valueOf(ret));
                                    }
                                }
                                else if(values.get(1).toLowerCase()=='boolean'){
                                    if(valueArrayParsed.get(m) != ''){
                                        boolean b = boolean.valueOf(valueArrayParsed.get(m)) ;           
                                        fObj.put(fieldArrayParsed.get(m).get(0),b);
                                    }
                                }
                                else if(values.get(1).toLowerCase()=='percent' || values.get(1).toLowerCase()=='currency' || values.get(1).toLowerCase()=='double'){
                                    if(valueArrayParsed.get(m) != ''){
                                        Decimal b = Decimal.valueOf(valueArrayParsed.get(m)) ;           
                                        fObj.put(fieldArrayParsed.get(m).get(0),b);
                                    }
                                }
                                else{
                                    fObj.put(fieldArrayParsed.get(m).get(0),valueArrayParsed.get(m));
                                }
                            }
                        }
                        fndRaisingRecords.add(fObj);   
                        
                    }
                    catch(exception ex){
                        //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Insufficient privilege CMF internal'+ex.getMessage()));
                        fndRaisingRecords.clear();
                        ErrorStatusInsufficient = false; 
                        ErrorStatusDiffAcc = true; 
                        ErrorMsgDiffAcc=ex.getMessage();          
                        clearItems();
                        return null;
                    }
                }
            }
            
            if(ErrorStatusInsufficient){
                if(Schema.sObjectType.Fundraising__c.isCreateable()){
                    insert fndRaisingRecords ;
                }
                else{
                    
                    fndRaisingRecords.clear();
                    ErrorStatusInsufficient = false; 
                    
                    clearItems();
                    return null;
                }   
            }
            else{
                clearItems();
                return null;
            }
        }
        catch(Exception ex){
            fndRaisingRecords.clear();
            ErrorStatusInsufficient = false; 
            ErrorStatusDiffAcc = true; 
            ErrorMsgDiffAcc=ex.getMessage();
            clearItems();
            return null;
        }
        
        list<Fundraising_Contact__c> listFrContact = new list<Fundraising_Contact__c>();
        for(sObject fundR :fndRaisingRecords){
            id LegalNmId= (id)fundR.get(NameSpacePrefix+'Legal_Name__c');
            list<list<string>> lstConData= accIDToFundContacts.get(LegalNmId);
            
            for(integer i=0; i<lstConData.size() ;i++){
                if(lstConData[i][5] != ''){
                    Fundraising_Contact__c singRecord = new Fundraising_Contact__c();
                    if(Schema.sObjectType.Fundraising_Contact__c.fields.Fundraising__c.isCreateable() && Schema.sObjectType.Fundraising_Contact__c.fields.Contact__c.isCreateable() && Schema.sObjectType.Fundraising_Contact__c.fields.Institution__c.isCreateable() && Schema.sObjectType.Fundraising_Contact__c.fields.Role__c.isCreateable() && Schema.sObjectType.Fundraising_Contact__c.fields.IsPrimary__c.isCreateable()){
                        singRecord.Fundraising__c = (id)fundR.get('id');
                        singRecord.Contact__c = lstConData[i][5] ;
                        singRecord.Institution__c = conAccountIdData.get(lstConData[i][5]) ;
                        singRecord.Role__c = lstConData[i][3] ;   
                        singRecord.IsPrimary__c = Boolean.valueOf(lstConData[i][4]) ;
                        listFrContact.add(singRecord);
                    }
                }
                else
                    break;
            }           
        }
       
       
        try{            
            if(listFrContact.size() > 0){
                if(ErrorStatusInsufficient){
                    if(Schema.sObjectType.Fundraising_contact__c.isCreateable()){
                        insert listFrContact;
                    }
                    else
                    {
                        ErrorStatusInsufficient = false;                         
                        clearItems();
                    }
                }
                else
                    return null;
            }    
            triggerenabled = false;   
        }           
        catch(system.DmlException ex){
            removeFundraising();
            ErrorStatusInsufficient = false; 
            ErrorStatusDiffAcc = true; 
            ErrorMsgDiffAcc=ex.getMessage();            
            clearItems();
        }        
        return null;
    }
    
    public void removeFundraising(){
        try{
            if(Schema.sObjectType.Fundraising__c.isDeletable()){
                delete fndRaisingRecords;
            }
        }
        catch(system.DmlException ex){
            ErrorStatusInsufficient = false; 
            ErrorStatusDiffAcc = true; 
            ErrorMsgDiffAcc=ex.getMessage();
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
        }
    }
    
    public void returnError(){
        //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Insufficient privilege'));
        fndRaisingRecords.clear();
        ErrorStatusInsufficient = false; 
        clearItems();
    }
    
    
    // Reset all the parameters 
    public void clearItems(){
        accIDToFundContacts = new Map<Id,List<List<String>>>();
        fieldArrayParsed = new List<List<String>>();
        valueArrayParsed = new List<String>();
        accIds = new List<Id>();
        fndRaisingRecords = new List<Fundraising__c>();
        fObj = new Fundraising__c();
    }
 }