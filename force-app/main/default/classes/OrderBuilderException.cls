// Exception Class for Order Calculator

global class OrderBuilderException extends Exception {
    
    global enum Severity { INFO, ALERT }


    global class ExceptionData {
        global string codeLocation;
        global string title;
        global string variant;
        global string mode;
        global string message;
        global List < string > missingRequiredFields;
        global Map < string, string > invalidFields;

        global ExceptionData () {
            this.missingRequiredFields = new List < string > ();
            this.invalidFields = new Map < string, string > ();
        }

    }

    global OrderBuilderException ( Exception e, String source ) {

        ExceptionData data = new ExceptionData ();
        data.codeLocation = source;
        data.title = 'An unexpected error has occurred. Refresh this page and re-try. If error persists, submit a help request with the details below.';
        data.message = 'Developer Details: ' + e.getMessage() + ' at ' + e.getStackTraceString();
        data.variant = 'error'; 
        data.mode = 'sticky';
        
        OrderBuilderException.throwAuraHandledException ( data );
    }

    global OrderBuilderException ( string userMessage, Severity severity ) {
        System.debug ( userMessage + ' ' + severity.name ()); 
        ExceptionData data = new ExceptionData ();
        data.title = 'An error has occurred';
        data.message = userMessage;
        if (severity==OrderBuilderException.Severity.ALERT) {
            data.variant = 'error'; 
            data.mode = 'sticky';
        } else {
            data.variant = 'warning';
            data.mode = 'dismissible';
        }
        
        OrderBuilderException.throwAuraHandledException ( data );
    }

    // to inject JSON formatted Exception Data into AuraHandledException, must setMessage
    // https://salesforce.stackexchange.com/questions/253571/custom-message-in-aurahandledexception-is-it-possible

    global static void throwAuraHandledException ( ExceptionData data ) {

        //can't get session in test mode
        String sessionType;
        if (UserInfo.getSessionId() != Null && !Test.isRunningTest() && !System.isFuture() && !System.isBatch() && !System.isScheduled())   {
            sessionType = Auth.SessionManagement.getCurrentSession().get('SessionType');
        } else {
            sessionType = 'Test context/No Session Available';
        }

        if (sessionType=='Aura' || sessionType=='ChatterNetworks') {
            AuraHandledException e = new AuraHandledException ( JSON.serialize ( data ));
            e.setMessage(data.message);
            throw e;
        } else {
            System.debug('throwAuraHandledException called but not in aura context: '+data);
            System.debug('throwAuraHandledException called but not in aura context: '+JSON.serialize ( data ));
        }
    }
}