public class ResetPasswordHandler
{
    public static void sendResetPasswordEmail(String portalAuthenticationId, String contactId)
    {
        System.debug('Sending reset password email');

        Portal_Authentication__c portalAuthentication =
            [
                SELECT
                        Username__c
                FROM
                        Portal_Authentication__c
                WHERE
                        Id = :portalAuthenticationId
            ];
        System.debug('Value portalAuthentication: ' + portalAuthentication);

        if(portalAuthentication != null)
        {
            EmailTemplate emailTemplate =
                [
                    SELECT
                            Id
                    FROM
                            EmailTemplate
                    WHERE
                            DeveloperName = 'Reset_Password'
                ];
            System.debug('Value emailTemplate: ' + emailTemplate);

            Messaging.SingleEmailMessage singleEmailMessage = new Messaging.SingleEmailMessage();

            String[] toAddresses = new String[1];
            //toAddresses[0] = 'jim.rayhawk@gmail.com';
            toAddresses[0] = portalAuthentication.Username__c;
            singleEmailMessage.setToAddresses(toAddresses);

            singleEmailMessage.setTargetObjectId(contactId);
            singleEmailMessage.setTreatTargetObjectAsRecipient(false);
            singleEmailMessage.setTemplateId(emailTemplate.Id);
            singleEmailMessage.setWhatId(portalAuthenticationId);
            singleEmailMessage.setReplyTo('clients@americordblood.com');
            singleEmailMessage.setSenderDisplayName('Americord - Cord Blood Bank');
            singleEmailMessage.setSaveAsActivity(true);

            if(!Test.isRunningTest())
            {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { singleEmailMessage });
            }

            System.debug('Sending reset password email');
         }
    }
}