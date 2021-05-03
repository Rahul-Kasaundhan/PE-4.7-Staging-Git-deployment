@istest
public class Test_FileUploaderCtrl {
    static testMethod void test_saveFile () {
        Account objAccount = new Account(name='Nav_account');
        insert objAccount;
        Contact con = new Contact(LastName='Peter',Accountid=objAccount.Id);
        Insert con;
        Contentversion cv = new Contentversion();
        cv.Title = 'ABC';
        cv.PathOnClient = 'test';
        cv.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        insert cv;
        Test.startTest();
        String strFileName ='Test_file';
        String base64Data ='Unit Test';
        String contentVersionID= String.valueOf(cv.id);
        FileUploaderCtrl.saveFile(con.ID, strFileName,base64Data,'Profile_Image__c',contentVersionID);
        system.assertEquals(objAccount.name, 'Nav_account');
        Test.stopTest();  
    }
}