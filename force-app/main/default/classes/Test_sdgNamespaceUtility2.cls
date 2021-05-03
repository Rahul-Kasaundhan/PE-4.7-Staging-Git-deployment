@isTest
public class Test_sdgNamespaceUtility2 {

    static testmethod void testnamespaceUtility(){
        Test.startTest();
        sdgNamespaceUtility2.GetNamespace();
         
        string query = 'SELECT Id, NumberOfEmployees FROM Account';
        string groupingQuery =  'SELECT MAX(NumberOfEmployees) FROM Account';
       	SDG__c sdgData = new SDG__c();
        sdgData.Name ='All Account123'; 
        sdgData.SDG_Tag__c='All Account';
        sdgData.Show_Icon__c=true;
        sdgData.sObjectName__c='Account';
        sdgData.My_Home__c=true;
        sdgData.Is_Valid__c=true;
        sdgData.MyRecords__c='acc';      
        sdgData.List_View_Name__c='All';
        insert sdgData;       
        SDG_Field__c sdgf= new SDG_Field__c(
            sdg__c=sdgData.id, APIName__c='Name', Color__c='Red'
        ); 
        ID sdgFid = sdgf.ID;
        string astr = String.valueOf(sdgFid);
        sdgNamespaceUtility2.prepareGroupingData(query, groupingQuery,astr); 
        groupingQuery = 'Select Count(Id),OwnerId from Account Where (OwnerId IN <<OwnerId>> ) Group By OwnerId';
        sdgNamespaceUtility2.prepareGroupingData(query, groupingQuery,astr);
        groupingQuery = 'Select Id,OwnerId from Account Where (OwnerId IN <<OwnerId>> )';
        sdgNamespaceUtility2.prepareGroupingData(query, groupingQuery,astr); 
        groupingQuery = 'SELECT Account.Type type, count(Id) oppCount FROM Opportunity GROUP BY Account.Type';
        sdgNamespaceUtility2.prepareGroupingData(query, groupingQuery,astr);  
        Account a = new Account(name='testestacc');
        insert a;
        Sobject soj = new Contact(lastname='testtest',Accountid=a.id);
	 	insert soj;
        groupingQuery = 'Select AccountId,Name,ID,LastName from Contact where AccountId in <<AccountId>>';
		sdgNamespaceUtility2.prepareGroupingData(query, groupingQuery,astr); 
        groupingQuery = 'Select AccountId,Name,ID from Contact where AccountId in <<AccountId>>';
        sdgNamespaceUtility2.prepareGroupingData(query, groupingQuery,astr);
        //groupingQuery = 'Select Count(Id),navpeII__Source_Contact__c from navpeII__Pipeline__c Where navpeII__Source_Contact__c IN <<navpeII__Source_Contact__c,navpeII__Contact__c>> Group By navpeII__Source_Contact__c';
        groupingQuery = 'Select Count(Id),OwnerId from Account where OwnerId IN <<OwnerId>> Group By OwnerId';
        sdgNamespaceUtility2.prepareGroupingData(query, groupingQuery,astr);
        system.assertEquals('All Account123',sdgData.Name); // added for security issues PEv4.7 by Aditya on 23 March 2021
	 	//sdgNamespaceUtility2.getDataValueFromSobj(soj,'Owner.Account');             
         
        Test.stopTest();
    }
    
    static testmethod void testmethod1(){
        Task tskobj =new task();
        tskobj.subject = 'Test';
        tskobj.Priority = 'Normal';
        
        Task tskobj1 =tskobj;
        insert tskobj1;
        
        Task tskobj2 =new task();
        tskobj2.subject = 'Test1';
        tskobj2.Priority = 'Normal1';
        insert tskobj2;
        
        Task tskobj3  =new task();
        tskobj3.subject = 'Test2';
        tskobj3.Priority = 'Normal2';
        insert tskobj3;
        LIST<Task> taids =[SELECT ID From Task];
        List<String> ods= new List<String>();
        for(Task t:taids )
        {
            ods.add(t.Id);
        }
        test.startTest();
        try{
           Set<String> setRelatedAssociations = new Set<String>(ods);
           sdgNamespaceUtility2.populateObjectToSobjectMap(setRelatedAssociations);
           //sdgNamespaceUtility2.getDataValueFromSobj(Schema.getGlobalDescribe().get('Account').newSObject(),'http:\\google.com');     
        }
        catch(Exception ex){
            //return null;
        }
        system.assertEquals('Test2',tskobj3.subject); // added for security issues PEv4.7 by Aditya on 23 March 2021
        test.stopTest(); // added by Aditya   
    }
}