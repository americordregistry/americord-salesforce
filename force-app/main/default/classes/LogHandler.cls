/**
* @description Log Handler
* @author jseibert
* @since 2021
* Test Class - LogHandlerTest
*/
@SuppressWarnings('PMD.ApexCRUDViolation, PMD.ExcessiveParameterList, PMD.AvoidDebugStatements')
public without sharing class LogHandler
{

    /**
     * @description Save information log
     * @param className name of the class 
     * @param methodName name of the method
     * @param description description of the response 
    */
    public static void logInformation(String className, String methodName, String description){
        Error_Log__c log = new Error_Log__c();
        log.Class__c = className;
        log.Method__c = methodName;
        log.Description__c = description;
        log.Type__c = 'Information';
        Insert log;
    }
     
    /**
     * @description Save success log
     * @param className name of the class 
     * @param methodName name of the method
     * @param description description of the response 
    */
    public static void logSuccessData(String className, String methodName, String description){
        Error_Log__c log = new Error_Log__c();
        log.Class__c = className;
        log.Method__c = methodName;
        log.Description__c = description;
        log.Type__c = 'Success';
        Insert log;
    }
     
    /**
    * @description Save exception log
    * @param className name of the class 
    * @param methodName name of the method
    * @param description description of the response
    * @param lineNumber line where error occurred 
    */
    public static void logException(String className, String methodName, String description, Integer lineNumber){
        Error_Log__c log = new Error_Log__c();
        log.Class__c = className;
        log.Method__c = methodName;
        log.Description__c = description;
        log.Type__c = 'Error';
        log.Line_Number__c = lineNumber;
        Insert log;

        System.debug(LoggingLevel.WARN,'Exception Encocuntered. Investigate Error_Log__c for details. Class:'+className+' method:'+methodName+' line:'+lineNumber+' description:'+description);
    }
     
    /**
     * @description Save HTTP response log
     * @param className name of the class 
     * @param methodName name of the method
     * @param description description of the response
     * @param response response from callout
     */
    public static void logHTTPResponse(String className, String methodName, String description, HttpResponse response){
        Error_Log__c log = new Error_Log__c();
        log.Class__c = className;
        log.Method__c = methodName;
        log.Description__c = description;
        log.Type__c = 'Information';
        if(response != null){
            log.HTTP_Response__c = response.getBody();
            log.HTTP_Status_code__c = response.getStatusCode();         
        }
        Insert log;
    }     

}