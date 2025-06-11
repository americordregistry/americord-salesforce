public with sharing class DocusignSendMHQ {
    /**
    * sendMHQToRecipient
    * -------
    * @param lstMHQs List of MHQ Ids to use for the send.
    */
    @InvocableMethod(label='Send MHQ' 
                     description='Sends the MHQ document for signing by the Mother/MHQ Recipient'
                     category='Document Signing')
    public static void sendMHQToRecipient(List<Id> lstMHQIds){    

        // GET MHQ Record using ID - assuming one ID is sent
        MHQ__c mhq = [SELECT Id, MHQ_Recipient__c FROM MHQ__C WHERE Id in :lstMHQIds];

        // Add record to the envelope
        dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(mhq.Id));
        
        // Find your contact to add; this is your customer
        Contact myContact = [SELECT Id, Name, Email, Phone FROM Contact WHERE Id = :mhq.MHQ_Recipient__c];       
        
        dfsle.Recipient recipient = dfsle.Recipient.fromSource(
            myContact.Name,
            myContact.Email,
            myContact.Phone,
            'MHQ Recipient',
            new dfsle.Entity(myContact.Id)
        ) ;

        // Add recipient to the envelope
        myEnvelope = myEnvelope.withRecipients(new List<dfsle.Recipient> { recipient });    
        
        // myTemplateId contains the DocuSign ID of the DocuSign template
        dfsle.UUID myTemplateId = dfsle.UUID.parse(DocusignServices.getDocusignTemplateId('MHQ_Template')); // Geoff test template
        
        // Create a new document for the envelope
        dfsle.Document myDocument = dfsle.Document.fromTemplate(
            myTemplateId, // Template ID in dfsle.UUID format
            'Maternal Health Questionnaire'); // Name of the template
        
        myEnvelope = myEnvelope.withDocuments(new List<dfsle.Document> { myDocument });
        
        // Send the envelope
        myEnvelope = dfsle.EnvelopeService.sendEnvelope(
            myEnvelope, // The envelope to send
            true); // Envelope status: send or draft; true = send
        
        System.debug(myEnvelope.Id);        
    }
}