/**
* ws_PortalUserEmailValidate
* ------------------
* @author jseibert
* @desc Class containing REST post service to send email to portal users
* TestClass: ws_PortalUserEmailValidateTest
*/
@RestResource(urlMapping='/portalUserEmailValidate/*')
global with sharing class ws_PortalUserEmailValidate {

    global class PortalEmailValidate {
        public String email {get;set;}
        public String subject {get;set;}
        public String body {get;set;}
    }

    global class PortalEmailValidateResponse{
        public String message {get;set;}
    }

        /**
        * PortalEmailValidateResponse
        * -------
        * @return PortalEmailValidateResponse Message indicating email send success
        */
        @HttpPost
        global static PortalEmailValidateResponse sendPortalEmailValidate() {
            //deserialize             
            RestRequest req = RestContext.request;
            String strRequestbody = req.requestBody.toString();
            PortalEmailValidate portEmail = (PortalEmailValidate)JSON.deserialize(strRequestBody, PortalEmailValidate.class);

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
            String[] toAddresses = new String[] {portEmail.email};             
            mail.setToAddresses(toAddresses);
            mail.setReplyTo('clients@americordblood.com');
            mail.setSubject(portEmail.subject);
            mail.setBccSender(false);
            mail.setUseSignature(false);

            // GET Org Wide Address for Clients
            OrgWideEmailAddress owa = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where Address = 'clients@americordblood.com' LIMIT 1];
            mail.setOrgWideEmailAddressId(owa.Id); 

            mail.setHtmlBody(portEmail.body);

            PortalEmailValidateResponse response = new PortalEmailValidateResponse();
            
            if (emailDeliverabilityEnabled()){
                try {
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    response.message = 'Message Successfully Sent';
                } catch (Exception e) {
                    System.debug(e.getMessage());
                    response.message = 'An Error Occurred Sending Email'+e.getMessage();
                }  
            }
            else{
                response.message = 'Email Deliverability Is Not Enabled - No Emails Can Be Sent Out.';
            }
          
            return response;
        }

        private static Boolean emailDeliverabilityEnabled(){
            Boolean EmailDeliverabilityEnabled = true;
            try {
                Messaging.reserveSingleEmailCapacity(1);
            } catch (System.NoAccessException e) {
                EmailDeliverabilityEnabled = false;
            }            
            return EmailDeliverabilityEnabled;
        }
}