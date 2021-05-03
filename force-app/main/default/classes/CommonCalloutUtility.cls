public with sharing class CommonCalloutUtility {
    public static String fireRequest(String domain, String endPoint, String authToken, String methodType) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(domain + endPoint);
        request.setMethod(methodType);
        request.setHeader('Authorization', authToken);

        Http http = new Http();
        HTTPResponse response = http.send(request);
        return response.getBody();
    }

    public static String getSalesforceSessionId() {
        String content;
        if(Test.isRunningTest()) {
            return UserInfo.getSessionId();
        }else{
         content = Page.PageWithSessionId.getContent().toString();
            return (content.substring(content.indexOf('Start_Of_Session_Id') 
                + 'Start_Of_Session_Id'.length(), content.indexOf('End_Of_Session_Id')));
        }
    }
}