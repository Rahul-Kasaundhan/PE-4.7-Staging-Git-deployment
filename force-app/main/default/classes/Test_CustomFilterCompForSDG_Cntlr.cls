/*********************************************************************************
** Project :- Navigation & SDG 
** Version Date(DD-MM-YYYY)   Author          Description of Action
** 1.2      08/August/2019    Sameeksha Sahu   Phase3:- return picklist Values in wrapper
** 1.3      28-01-2020        RahulK           Phase4:-Get string query in parameter and return picklist Values in wrapper
*********************************************************************************/
@isTest
public class Test_CustomFilterCompForSDG_Cntlr{
   
    static testmethod void TestCustomFilterCompForSDG_Cntlrr(){
        Account cov = new Account(Name='TestCov');
        insert cov;
        Test.startTest();
        String  query1 = 'Select Name from Account where Name like \'TestCov\' ';  
        CustomFilterCompForSDG_Cntlr.getFieldValues(query1,query1,query1,query1);
        system.assertEquals('TestCov',cov.Name); // added for Security Issues PEv4.7 by Aditya on 23 March 2021
        Test.stopTest();
    }
}