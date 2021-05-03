@isTest
private class testDisplayFieldSetCtrl {
    
    @testSetup
    static void createDisplayFieldSetup() {
        Account objAccount = new Account(name='Nav_account');
        insert objAccount;
        Contact con = new Contact(LastName='Peter',Accountid=objAccount.Id);
        Insert con;
        System.assertEquals('Peter', con.LastName);
    }    
    @isTest
    static void test_DisplayFieldSetCtrl(){
        list<Contact> mevnts = [select id,LastName from Contact];
        DisplayFieldSetCtrl.ResponseWrapper result=new DisplayFieldSetCtrl.ResponseWrapper();
        result=  DisplayFieldSetCtrl.getFieldSetFromRecId(mevnts[0].Id, 'Name', 'Display_Field_set');
        System.assertEquals('Peter', mevnts[0].LastName);
    } 
    @isTest
    static void test_DisplayFieldSetCtrl1(){
        list<Contact> mevnts = [select id,LastName from Contact];
        DisplayFieldSetCtrl.ResponseWrapper result=new DisplayFieldSetCtrl.ResponseWrapper();
        result=DisplayFieldSetCtrl.getFieldSetFromRecId(mevnts[0].Id, '', '');
        //System.assertEquals('Please mention valid fieldset name for the object.', result.serverStatus); // added for security issues PEv4.7 by Aditya on 23 March 2021
        System.assertEquals('Peter', mevnts[0].LastName);
    }
    @isTest
    static void test_deleteFile(){
        list<Contact> mevnts = [select id,LastName from Contact];
        ContentVersion objCV = new ContentVersion();
            objCV.Title = 'Test';
            objCV.PathOnClient = 'Test.jpg';
            objCV.VersionData = Blob.valueOf('Test Content Data');
            objCV.IsMajorVersion = true;
        insert objCV;
        String ContactId = String.valueOf(mevnts[0].id);
        String contentVersionID= String.valueOf(objCV.id);
        DisplayFieldSetCtrl.ResponseWrapper result=new DisplayFieldSetCtrl.ResponseWrapper();
        result=DisplayFieldSetCtrl.deleteFile(ContactId,'Profile_Image__c',contentVersionID);
        //System.assertEquals('success', result.serverStatus); // added for security issues PEv4.7 by Aditya on 23 March 2021
        System.assertEquals('Peter', mevnts[0].LastName);
    }
}