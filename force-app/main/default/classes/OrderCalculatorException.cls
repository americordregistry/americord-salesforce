// Exception Class for Order Calculator

public class OrderCalculatorException extends Exception {
    
    public enum Severity { INFO, ALERT }
    
    public string host;
    public string userMessage;
    public string message;
    public Severity severity;

    public class ExceptionData {
        public string codeLocation;
        public string title;
        public string variant;
        public string message;
        public string userMessage;
        public string exceptionMessage;
        public integer exceptionCode;
        public List < string > missingRequiredFields;
        public Map < string, string > invalidFields;

        public ExceptionData () {
            this.missingRequiredFields = new List < string > ();
            this.invalidFields = new Map < string, string > ();
        }

    }

    public OrderCalculatorException ( string host, string userMessage, Severity severity ) {
        System.debug ( host + ' ' + userMessage + ' ' + severity.name ()); 
        ExceptionData data = new ExceptionData ();
        data.userMessage = userMessage;
        data.title = 'An error has occurred';
        data.message = userMessage;
        if (severity==OrderCalculatorException.Severity.ALERT) {
            data.variant = 'error'; 
        } else {
            data.variant = 'warning';
        }
        
        OrderCalculatorException.throwAuraHandledException ( data );
    }

    // to inject JSON formatted Exception Data into AuraHandledException, must setMessage
    // https://salesforce.stackexchange.com/questions/253571/custom-message-in-aurahandledexception-is-it-possible

    public static void throwAuraHandledException ( ExceptionData data ) {

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