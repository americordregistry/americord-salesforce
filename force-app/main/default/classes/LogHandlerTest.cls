/**
* @description Log Handler Test
* @author jseibert
* @since 2021
*/
@SuppressWarnings('PMD.MethodNamingConventions')
@isTest
public class LogHandlerTest {
    @isTest
    private static void validateLogHandler_Informational(){
        LogHandler.logInformation('LogHandlerTest', 'validateLogHandler_Informational', 'TEST');
        LIST<ERROR_LOG__C> lstLogEntries = [SELECT Class__c,Method__c,Description__c,Type__c FROM ERROR_LOG__C LIMIT 1];

        System.assertEquals('LogHandlerTest', lstLogEntries[0].Class__c, 'ERROR_LOG__C TEST FAILED - CLASS NOT MATCHING');

        System.assertEquals('validateLogHandler_Informational', lstLogEntries[0].Method__c, 'ERROR_LOG__C TEST FAILED - METHOD NOT MATCHING');

        System.assertEquals('TEST', lstLogEntries[0].Description__c, 'ERROR_LOG__C TEST FAILED - DESCRIPTION NOT MATCHING');

        System.assertEquals('Information', lstLogEntries[0].Type__c, 'ERROR_LOG__C TEST FAILED - TYPE NOT MATCHING');

    }

    @isTest
    private static void validateLogHandler_Success(){
        LogHandler.logSuccessData('LogHandlerTest', 'validateLogHandler_Informational', 'TEST');
        LIST<ERROR_LOG__C> lstLogEntries = [SELECT Class__c,Method__c,Description__c,Type__c FROM ERROR_LOG__C LIMIT 1];

        System.assertEquals('LogHandlerTest', lstLogEntries[0].Class__c, 'ERROR_LOG__C TEST FAILED - CLASS NOT MATCHING');

        System.assertEquals('validateLogHandler_Informational', lstLogEntries[0].Method__c, 'ERROR_LOG__C TEST FAILED - METHOD NOT MATCHING');

        System.assertEquals('TEST', lstLogEntries[0].Description__c, 'ERROR_LOG__C TEST FAILED - DESCRIPTION NOT MATCHING');

        System.assertEquals('Success', lstLogEntries[0].Type__c, 'ERROR_LOG__C TEST FAILED - TYPE NOT MATCHING');

    }    

    @isTest
    private static void validateLogHandler_Exception(){
        LogHandler.logException('LogHandlerTest', 'validateLogHandler_Informational', 'TEST',9999);
        LIST<ERROR_LOG__C> lstLogEntries = [SELECT Class__c,Method__c,Description__c,Type__c, Line_Number__c FROM ERROR_LOG__C LIMIT 1];

        System.assertEquals('LogHandlerTest', lstLogEntries[0].Class__c, 'ERROR_LOG__C TEST FAILED - CLASS NOT MATCHING');

        System.assertEquals('validateLogHandler_Informational', lstLogEntries[0].Method__c, 'ERROR_LOG__C TEST FAILED - METHOD NOT MATCHING');

        System.assertEquals('TEST', lstLogEntries[0].Description__c, 'ERROR_LOG__C TEST FAILED - DESCRIPTION NOT MATCHING');

        System.assertEquals(9999, lstLogEntries[0].Line_Number__c, 'ERROR_LOG__C TEST FAILED - LINE NUMBER NOT MATCHING');        

        System.assertEquals('Error', lstLogEntries[0].Type__c, 'ERROR_LOG__C TEST FAILED - TYPE NOT MATCHING');

    }       

    @isTest
    private static void validateLogHandler_HTTPResponse(){
        HttpResponse response = new HttpResponse();
        response.setBody('HTTPBODY');
        response.setStatusCode(9999);

        LogHandler.logHTTPResponse('LogHandlerTest', 'validateLogHandler_Informational', 'TEST',response);
        LIST<ERROR_LOG__C> lstLogEntries = [SELECT Class__c,Method__c,Description__c,Type__c, HTTP_Response__c,HTTP_Status_code__c FROM ERROR_LOG__C LIMIT 1];

        System.assertEquals('LogHandlerTest', lstLogEntries[0].Class__c, 'ERROR_LOG__C TEST FAILED - CLASS NOT MATCHING');

        System.assertEquals('validateLogHandler_Informational', lstLogEntries[0].Method__c, 'ERROR_LOG__C TEST FAILED - METHOD NOT MATCHING');

        System.assertEquals('TEST', lstLogEntries[0].Description__c, 'ERROR_LOG__C TEST FAILED - DESCRIPTION NOT MATCHING');

        System.assertEquals('HTTPBODY', lstLogEntries[0].HTTP_Response__c, 'ERROR_LOG__C TEST FAILED - RESPONSE NOT MATCHING');        

        System.assertEquals(9999, lstLogEntries[0].HTTP_Status_code__c, 'ERROR_LOG__C TEST FAILED - STATUS CODE NOT MATCHING');             

        System.assertEquals('Information', lstLogEntries[0].Type__c, 'ERROR_LOG__C TEST FAILED - TYPE NOT MATCHING');

    }     
}