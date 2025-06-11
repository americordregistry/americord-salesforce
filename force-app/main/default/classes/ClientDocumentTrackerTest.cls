@isTest
private class ClientDocumentTrackerTest {

    @TestSetup
    static void testSetup(){ 
        Lab__c lab = new Lab__c();
        lab.name = 'Test';
        insert lab;

        Account acct = new Account();
        acct.name ='TestAcct';
        insert acct;
        
    }

    @isTest
    private static void clientDocumentTracker_doctypeFromDocName() {
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        Attachment att = new Attachment(Name='Maternal & Family Health Screening Questionnaire 20190621 - Surrogate', Parentid = lab.id,Body=bodyBlob);
        insert att;

        Client_Document_Tracker__c testCDT = [
            SELECT Id, Surrogate_MHQ_Document__c,
            Client_Document_1__c,Client_Document_2__c,Client_Document_3__c,
            Client_Document_4__c,Client_Document_5__c,
            Client_Document_6__c,Client_Document_7__c,Client_Document_8__c,Client_Document_9__c,
            Client_Document_10__c,Client_Document_11__c,Client_Document_12__c,Client_Document_13__c,
            Client_Document_14__c,Client_Document_15__c,Client_Document_16__c,Client_Document_17__c,
            Client_Document_18__c,Client_Document_19__c,Client_Document_20__c 
            FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
 
        String strTest = 'UNKNOWN DOCUMENT';
        System.assertEquals('DOCUMENT1', ClientDocumentTracker.doctypeBasedOnDocumentName(strTest,testCDT), 'Client Tracker Document - Doc Type From Name Failed. Expected: UNKNOWN Recevied:'+ClientDocumentTracker.doctypeBasedOnDocumentName(strTest,testCDT));

        strTest = 'Informed-Consent';
        System.assertEquals('INFORMED CONSENT', ClientDocumentTracker.doctypeBasedOnDocumentName(strTest,testCDT), 'Client Tracker Document - Doc Type From Name Failed. Expected: INFORMED CONSENT Recevied:'+ClientDocumentTracker.doctypeBasedOnDocumentName(strTest,testCDT));

        strTest = 'Informed Consent - Surrogate';
        System.assertEquals('SURROGATE INFORMED CONSENT', ClientDocumentTracker.doctypeBasedOnDocumentName(strTest,testCDT), 'Client Tracker Document - Doc Type From Name Failed. Expected: SURROGATE INFORMED CONSENT Recevied:'+ClientDocumentTracker.doctypeBasedOnDocumentName(strTest,testCDT));

        strTest = 'Maternal & Family Health creening Questionnaire';
        System.assertEquals('MHQ', ClientDocumentTracker.doctypeBasedOnDocumentName(strTest,testCDT), 'Client Tracker Document - Doc Type From Name Failed. Expected: MHQ Recevied:'+ClientDocumentTracker.doctypeBasedOnDocumentName(strTest,testCDT));

        strTest = 'Maternal & Family Health Screening Questionnaire 20190621 - Surrogate';
        System.assertEquals('SURROGATE MHQ', ClientDocumentTracker.doctypeBasedOnDocumentName(strTest,testCDT), 'Client Tracker Document - Doc Type From Name Failed. Expected: SURROGATE MHQ Recevied:'+ClientDocumentTracker.doctypeBasedOnDocumentName(strTest,testCDT));

        strTest = 'Bio-Preservation-Services';
        System.assertEquals('BIOPRESERVATION', ClientDocumentTracker.doctypeBasedOnDocumentName(strTest,testCDT), 'Client Tracker Document - Doc Type From Name Failed. Expected: BIOPRESERVATION Recevied:'+ClientDocumentTracker.doctypeBasedOnDocumentName(strTest,testCDT));

        strTest = 'Healthcare-Team';
        System.assertEquals('HEALTHCARE TEAM', ClientDocumentTracker.doctypeBasedOnDocumentName(strTest,testCDT), 'Client Tracker Document - Doc Type From Name Failed. Expected: HEALTHCARE TEAM Recevied:'+ClientDocumentTracker.doctypeBasedOnDocumentName(strTest,testCDT));

        strTest = 'General-Service';
        System.assertEquals('GENERAL SERVICE AGREEMENT', ClientDocumentTracker.doctypeBasedOnDocumentName(strTest,testCDT), 'Client Tracker Document - Doc Type From Name Failed. Expected: GENERAL SERVICE AGREEMENT Recevied:'+ClientDocumentTracker.doctypeBasedOnDocumentName(strTest,testCDT));

        strTest = 'Storage Agreement';
        System.assertEquals('STORAGE AGREEMENT', ClientDocumentTracker.doctypeBasedOnDocumentName(strTest,testCDT), 'Client Tracker Document - Doc Type From Name Failed. Expected: STORAGE AGREEMENT Recevied:'+ClientDocumentTracker.doctypeBasedOnDocumentName(strTest,testCDT));

        strTest = 'Invoice';
        System.assertEquals('INVOICE', ClientDocumentTracker.doctypeBasedOnDocumentName(strTest,testCDT), 'Client Tracker Document - Doc Type From Name Failed. Expected: INVOICE Recevied:'+ClientDocumentTracker.doctypeBasedOnDocumentName(strTest,testCDT));
    }

    // ATTACHMENT TESTS
    @isTest
    private static void clientDocumentTracker_Attachment_MHQ() {
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        Attachment att = new Attachment(Name='Maternal & Family Health creening Questionnaire', Parentid = lab.id,Body=bodyBlob);
        insert att;

        Client_Document_Tracker__c testCDT = [SELECT Id, MHQ_Document__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(att.id, testCDT.MHQ_Document__c, 'Attachment Trigger Failed To Set Document For Lab Attachment.');
    }

    @isTest
    private static void clientDocumentTracker_Attachment_SurrogateMHQ() {
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        Attachment att = new Attachment(Name='Maternal & Family Health Screening Questionnaire 20190621 - Surrogate', Parentid = lab.id,Body=bodyBlob);
        insert att;

        Client_Document_Tracker__c testCDT = [SELECT Id, Surrogate_MHQ_Document__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(att.id, testCDT.Surrogate_MHQ_Document__c, 'Attachment Trigger Failed To Set Document For Lab Attachment.');
    }

    @isTest
    private static void clientDocumentTracker_Attachment_GeneralService() {
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        Attachment att = new Attachment(Name='General-Service', Parentid = lab.id,Body=bodyBlob);
        insert att;

        Client_Document_Tracker__c testCDT = [SELECT Id, General_Services_Agreement_Document__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(att.id, testCDT.General_Services_Agreement_Document__c, 'Attachment Trigger Failed To Set Document For Lab Attachment.');
    }

    @isTest
    private static void clientDocumentTracker_Attachment_Biopreservation() {
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        Attachment att = new Attachment(Name='Bio-Preservation-Services', Parentid = lab.id,Body=bodyBlob);
        insert att;

        Client_Document_Tracker__c testCDT = [SELECT Id, Biopreservation_Document__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(att.id, testCDT.Biopreservation_Document__c, 'Attachment Trigger Failed To Set Document For Lab Attachment.');
    }

    @isTest
    private static void clientDocumentTracker_Attachment_InformedConsent() {
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        Attachment att = new Attachment(Name='Informed-Consent', Parentid = lab.id,Body=bodyBlob);
        insert att;

        Client_Document_Tracker__c testCDT = [SELECT Id, Informed_Consent_Document__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(att.id, testCDT.Informed_Consent_Document__c, 'Attachment Trigger Failed To Set Document For Lab Attachment.');
    }

    @isTest
    private static void clientDocumentTracker_Attachment_SurrogateInformedConsent() {
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        Attachment att = new Attachment(Name='Informed Consent - Surrogate', Parentid = lab.id,Body=bodyBlob);
        insert att;

        Client_Document_Tracker__c testCDT = [SELECT Id, Surrogate_Informed_Consent_Document__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(att.Id, testCDT.Surrogate_Informed_Consent_Document__c, 'Attachment Trigger Failed To Set Document For Lab Attachment.');
    }

    @isTest
    private static void clientDocumentTracker_Attachment_HealthcareTeam() {
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        Attachment att = new Attachment(Name='Healthcare-Team', Parentid = lab.id,Body=bodyBlob);
        insert att;

        Client_Document_Tracker__c testCDT = [SELECT Id, Healthcare_Team_Document__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(att.id, testCDT.Healthcare_Team_Document__c, 'Attachment Trigger Failed To Set Document For Lab Attachment.');
    }

    @isTest
    private static void clientDocumentTracker_Attachment_StorageAgreement() {
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        Attachment att = new Attachment(Name='Storage Agreement', Parentid = lab.id,Body=bodyBlob);
        insert att;

        Client_Document_Tracker__c testCDT = [SELECT Id, Storage_Agreement_Document__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(att.id, testCDT.Storage_Agreement_Document__c, 'Attachment Trigger Failed To Set Document For Lab Attachment.');
    }

    @isTest
    private static void clientDocumentTracker_Attachment_Invoice() {
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        Attachment att = new Attachment(Name='Invoice', Parentid = lab.id,Body=bodyBlob);
        insert att;

        Client_Document_Tracker__c testCDT = [SELECT Id, Invoice_Document__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(att.id, testCDT.Invoice_Document__c, 'Attachment Trigger Failed To Set Document For Lab Attachment.');
    }

    @isTest
    private static void clientDocumentTracker_Attachment_CertOfStorage1() {
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        Attachment att1 = new Attachment(Name='Certificate_of_Storage', Parentid = lab.id,Body=bodyBlob);
        insert att1;

        Client_Document_Tracker__c testCDT1 = [SELECT Id, Certificate_of_Storage_1__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id AND Certificate_of_Storage_1__c = :att1.Id LIMIT 1];
        System.assertEquals(att1.id, testCDT1.Certificate_of_Storage_1__c, 'Attachment Trigger Failed To Set Document For Lab Attachment.');
        
        Attachment att2 = new Attachment(Name='Certificate_of_Storage', Parentid = lab.id,Body=bodyBlob);
        insert att2;
        Client_Document_Tracker__c testCDT2 = [SELECT Id, Certificate_of_Storage_2__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id AND Certificate_of_Storage_2__c = :att2.Id LIMIT 1];
        System.assertEquals(att2.id, testCDT2.Certificate_of_Storage_2__c, 'Attachment Trigger Failed To Set Document For Lab Attachment.');

        Attachment att3 = new Attachment(Name='Certificate_of_Storage', Parentid = lab.id,Body=bodyBlob);
        insert att3;
        Client_Document_Tracker__c testCDT3 = [SELECT Id, Certificate_of_Storage_3__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id AND Certificate_of_Storage_3__c = :att3.Id LIMIT 1];
        System.assertEquals(att3.id, testCDT3.Certificate_of_Storage_3__c, 'Attachment Trigger Failed To Set Document For Lab Attachment.');
  
        Attachment att4 = new Attachment(Name='Certificate_of_Storage', Parentid = lab.id,Body=bodyBlob);
        insert att4;
        Client_Document_Tracker__c testCDT4 = [SELECT Id, Certificate_of_Storage_4__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id AND Certificate_of_Storage_4__c = :att4.Id LIMIT 1];
        System.assertEquals(att4.id, testCDT4.Certificate_of_Storage_4__c, 'Attachment Trigger Failed To Set Document For Lab Attachment.');
  
        Attachment att5 = new Attachment(Name='Certificate_of_Storage', Parentid = lab.id,Body=bodyBlob);
        insert att5;
        Client_Document_Tracker__c testCDT5 = [SELECT Id, Certificate_of_Storage_5__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id AND Certificate_of_Storage_5__c = :att5.Id LIMIT 1];
        System.assertEquals(att5.id, testCDT5.Certificate_of_Storage_5__c, 'Attachment Trigger Failed To Set Document For Lab Attachment.');
  

        delete att5;
        Client_Document_Tracker__c testCDTdel = [SELECT Id, Certificate_of_Storage_5__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(null, testCDTdel.Certificate_of_Storage_5__c, 'Attachment Trigger Failed To Delete Document For Lab Attachment5.');

        delete att4;
        testCDTdel = [SELECT Id, Certificate_of_Storage_4__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(null, testCDTdel.Certificate_of_Storage_4__c, 'Attachment Trigger Failed To Delete Document For Lab Attachment4.');

        delete att3;
        testCDTdel = [SELECT Id, Certificate_of_Storage_3__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(null, testCDTdel.Certificate_of_Storage_3__c, 'Attachment Trigger Failed To Delete Document For Lab Attachment3.');

        delete att2;
        testCDTdel = [SELECT Id, Certificate_of_Storage_2__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(null, testCDTdel.Certificate_of_Storage_2__c, 'Attachment Trigger Failed To Delete Document For Lab Attachment2.');

        delete att1;
        testCDTdel = [SELECT Id, Certificate_of_Storage_1__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(null, testCDTdel.Certificate_of_Storage_1__c, 'Attachment Trigger Failed To Delete Document For Lab Attachment1.');

        Baby__c baby = new Baby__c(Name='Baby Test Record', Lab__c = lab.Id);
        insert baby;

        // baby
        Blob bodyBlobFM=Blob.valueOf('Unit Test Attachment Body - Family Member');
        Attachment attbaby1 = new Attachment(Name='Certificate_of_Storage', Parentid = baby.id,Body=bodyBlobFM);
        insert attbaby1;
        Client_Document_Tracker__c testCDTFM = [SELECT Id, Certificate_of_Storage_1__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(attbaby1.id, testCDTFM.Certificate_of_Storage_1__c, 'Attachment Trigger Failed To Set Document For FM Attachment1.');
 
        Attachment attbaby2 = new Attachment(Name='Certificate_of_Storage', Parentid = baby.id,Body=bodyBlobFM);
        insert attbaby2;
        testCDTFM = [SELECT Id, Certificate_of_Storage_2__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(attbaby2.id, testCDTFM.Certificate_of_Storage_2__c, 'Attachment Trigger Failed To Set Document For FM Attachment2.');

        Attachment attbaby3 = new Attachment(Name='Certificate_of_Storage', Parentid = baby.id,Body=bodyBlobFM);
        insert attbaby3;
        testCDTFM = [SELECT Id, Certificate_of_Storage_3__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(attbaby3.id, testCDTFM.Certificate_of_Storage_3__c, 'Attachment Trigger Failed To Set Document For FM Attachment3.');

        Attachment attbaby4 = new Attachment(Name='Certificate_of_Storage', Parentid = baby.id,Body=bodyBlobFM);
        insert attbaby4;
        testCDTFM = [SELECT Id, Certificate_of_Storage_4__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(attbaby4.id, testCDTFM.Certificate_of_Storage_4__c, 'Attachment Trigger Failed To Set Document For FM Attachment4.');

        Attachment attbaby5 = new Attachment(Name='Certificate_of_Storage', Parentid = baby.id,Body=bodyBlobFM);
        insert attbaby5;
        testCDTFM = [SELECT Id, Certificate_of_Storage_5__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(attbaby5.id, testCDTFM.Certificate_of_Storage_5__c, 'Attachment Trigger Failed To Set Document For FM Attachment5.');

        delete attbaby5;
        testCDTFM = [SELECT Id, Certificate_of_Storage_5__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(null, testCDTFM.Certificate_of_Storage_5__c, 'Attachment Trigger Failed To Delete Document For FM Attachment5.');

        delete attbaby4;
        testCDTFM = [SELECT Id, Certificate_of_Storage_4__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(null, testCDTFM.Certificate_of_Storage_4__c, 'Attachment Trigger Failed To Delete Document For FM Attachment4.');

        delete attbaby3;
        testCDTFM = [SELECT Id, Certificate_of_Storage_3__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(null, testCDTFM.Certificate_of_Storage_3__c, 'Attachment Trigger Failed To Delete Document For FM Attachment3.');

        delete attbaby2;
        testCDTFM = [SELECT Id, Certificate_of_Storage_2__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(null, testCDTFM.Certificate_of_Storage_2__c, 'Attachment Trigger Failed To Delete Document For FM Attachment2.');

        delete attbaby1;
        testCDTFM = [SELECT Id, Certificate_of_Storage_1__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(null, testCDTFM.Certificate_of_Storage_1__c, 'Attachment Trigger Failed To Delete Document For FM Attachment1.');

    }


    // CONTENT DOCUMENT TESTS
    
    @isTest
    private static void clientDocumentTracker_ContentDoc_MHQ() {
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        ContentVersion cv = new ContentVersion(
            Title = 'Maternal & Family Health creening Questionnaire',
            PathOnClient = 'Maternal & Family Health creening Questionnaire.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        insert cdl;

        Client_Document_Tracker__c testCDT = [SELECT Id, MHQ_Document__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(cdl.ContentDocumentId, testCDT.MHQ_Document__c, 'Attachment Trigger Failed To Set Document For Lab Attachment.');
    }

    @isTest
    private static void clientDocumentTracker_ContentDoc_SurrogateMHQ() {
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        ContentVersion cv = new ContentVersion(
            Title = 'Maternal & Family Health Screening Questionnaire 20190621 - Surrogate',
            PathOnClient = 'Maternal & Family Health Screening Questionnaire 20190621 - Surrogate.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        insert cdl;

        Client_Document_Tracker__c testCDT = [SELECT Id, Surrogate_MHQ_Document__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(cdl.ContentDocumentId, testCDT.Surrogate_MHQ_Document__c, 'Attachment Trigger Failed To Set Document For Lab Attachment.');
    }

    @isTest
    private static void clientDocumentTracker_ContentDoc_GeneralService() {
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        ContentVersion cv = new ContentVersion(
            Title = 'General-Service',
            PathOnClient = 'General-Service.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        insert cdl;

        Client_Document_Tracker__c testCDT = [SELECT Id, General_Services_Agreement_Document__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(cdl.ContentDocumentId, testCDT.General_Services_Agreement_Document__c, 'Attachment Trigger Failed To Set Document For Lab Attachment.');
    }

    @isTest
    private static void clientDocumentTracker_ContentDoc_Biopreservation() {
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        ContentVersion cv = new ContentVersion(
            Title = 'Bio-Preservation-Services',
            PathOnClient = 'Bio-Preservation-Services.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        insert cdl;

        Client_Document_Tracker__c testCDT = [SELECT Id, Biopreservation_Document__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(cdl.ContentDocumentId, testCDT.Biopreservation_Document__c, 'Attachment Trigger Failed To Set Document For Lab Attachment.');
    }

    @isTest
    private static void clientDocumentTracker_ContentDoc_InformedConsent() {
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        ContentVersion cv = new ContentVersion(
            Title = 'Informed-Consent',
            PathOnClient = 'Informed-Consent.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        insert cdl;

        Client_Document_Tracker__c testCDT = [SELECT Id, Informed_Consent_Document__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(cdl.ContentDocumentId, testCDT.Informed_Consent_Document__c, 'Attachment Trigger Failed To Set Document For Lab Attachment.');
    }

    @isTest
    private static void clientDocumentTracker_ContentDoc_SurrogateInformedConsent() {
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        ContentVersion cv = new ContentVersion(
            Title = 'Informed Consent - Surrogate',
            PathOnClient = 'Informed Consent - Surrogate.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        insert cdl;

        Client_Document_Tracker__c testCDT = [SELECT Id, Surrogate_Informed_Consent_Document__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(cdl.ContentDocumentId, testCDT.Surrogate_Informed_Consent_Document__c, 'Attachment Trigger Failed To Set Document For Lab Attachment.');
    }

    @isTest
    private static void clientDocumentTracker_ContentDoc_HealthcareTeam() {
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        ContentVersion cv = new ContentVersion(
            Title = 'Healthcare-Team',
            PathOnClient = 'Healthcare-Team.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        insert cdl;

        Client_Document_Tracker__c testCDT = [SELECT Id, Healthcare_Team_Document__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(cdl.ContentDocumentId, testCDT.Healthcare_Team_Document__c, 'Attachment Trigger Failed To Set Document For Lab Attachment.');
    }

    @isTest
    private static void clientDocumentTracker_ContentDoc_StorageAgreement() {
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        ContentVersion cv = new ContentVersion(
            Title = 'Storage Agreement',
            PathOnClient = 'Storage Agreement.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        insert cdl;

        Client_Document_Tracker__c testCDT = [SELECT Id, Storage_Agreement_Document__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(cdl.ContentDocumentId, testCDT.Storage_Agreement_Document__c, 'Attachment Trigger Failed To Set Document For Lab Attachment.');
    }

    @isTest
    private static void clientDocumentTracker_ContentDoc_Invoice() {
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        ContentVersion cv = new ContentVersion(
            Title = 'Invoice',
            PathOnClient = 'Storage Agreement.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        insert cdl;

        Client_Document_Tracker__c testCDT = [SELECT Id, Invoice_Document__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        System.assertEquals(cdl.ContentDocumentId, testCDT.Invoice_Document__c, 'Attachment Trigger Failed To Set Document For Lab Attachment.');
    }

    @isTest
    private static void clientDocumentTracker_attachmentUpdate(){
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        Attachment att1 = new Attachment(Name='Healthcare-Team', Parentid = lab.id,Body=bodyBlob);
        insert att1;
        att1.Name = 'Healthcare-Team-Test';
        update att1;
    }

    @isTest
    private static void clientDocumentTracker_attachmentDelete_HealthcareTeam(){
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        Attachment att1 = new Attachment(Name='Healthcare-Team', Parentid = lab.id,Body=bodyBlob);
        insert att1;
        att1.Name = 'Healthcare-Team-Test';
        update att1;
        Test.startTest();
        delete att1;
        Test.stopTest();
    }

    @isTest
    private static void clientDocumentTracker_attachmentDelete_BioPres(){
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        Attachment att1 = new Attachment(Name='Biopreservation', Parentid = lab.id,Body=bodyBlob);
        insert att1;
        att1.Name = 'Biopreservation';
        update att1;
        Test.startTest();
        delete att1;
        Test.stopTest();
    }

    @isTest
    private static void clientDocumentTracker_attachmentDelete_SurrogateMHQ(){
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        Attachment att1 = new Attachment(Name='Maternal-Health-Questionnaire-Surrogate', Parentid = lab.id,Body=bodyBlob);
        insert att1;
        att1.Name = 'Surrogate MHQ';
        update att1;
        Test.startTest();
        delete att1;
        Test.stopTest();
    }

    @isTest
    private static void clientDocumentTracker_attachmentDelete_InformedConsent(){
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        Attachment att1 = new Attachment(Name='Informed-Consent', Parentid = lab.id,Body=bodyBlob);
        insert att1;
        att1.Name = 'Informed Consent';
        update att1;
        Test.startTest();
        delete att1;
        Test.stopTest();
    }

    @isTest
    private static void clientDocumentTracker_attachmentDelete_InformedConsentSurrogate(){
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        Attachment att1 = new Attachment(Name='Informed Consent - Surrogate', Parentid = lab.id,Body=bodyBlob);
        insert att1;
        att1.Name = 'Informed Consent Surrogate';
        update att1;
        Test.startTest();
        delete att1;
        Test.stopTest();
    }

    @isTest
    private static void clientDocumentTracker_attachmentDelete_MHQ(){
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        Attachment att1 = new Attachment(Name='Maternal Health Questionnaire', Parentid = lab.id,Body=bodyBlob);
        insert att1;
        att1.Name = 'MHQ';
        update att1;
        Test.startTest();
        delete att1;
        Test.stopTest();
    }

    @isTest
    private static void clientDocumentTracker_attachmentDelete_GeneralService(){
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        Attachment att1 = new Attachment(Name='General-Service', Parentid = lab.id,Body=bodyBlob);
        insert att1;
        att1.Name = 'General Service';
        update att1;
        Test.startTest();
        delete att1;
        Test.stopTest();
    }

    @isTest
    private static void clientDocumentTracker_attachmentDelete_StorageAgreement(){
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        Attachment att1 = new Attachment(Name='Storage Agreement', Parentid = lab.id,Body=bodyBlob);
        insert att1;
        att1.Name = 'Storage Agreement';
        update att1;
        Test.startTest();
        delete att1;
        Test.stopTest();
    }

    @isTest
    private static void clientDocumentTracker_attachmentDelete_Invoice(){
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        Attachment att1 = new Attachment(Name='Invoice', Parentid = lab.id,Body=bodyBlob);
        insert att1;
        att1.Name = 'Invoice';
        update att1;
        Test.startTest();
        delete att1;
        Test.stopTest();
    }

    @isTest
    private static void clientDocumentTracker_attachmentDelete_Doc(){
        List<Attachment> lstAttachments = new List<Attachment>();
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        for (Integer i = 0; i < 20; i++) {
            Attachment att = new Attachment(Name='Doc'+i, Parentid = lab.id,Body=bodyBlob);    
            lstAttachments.add(att);
        }
        insert lstAttachments;
        Test.startTest();
        delete lstAttachments;
        Test.stopTest();
    }

    @isTest
    private static void clientDocumentTracker_contentDocumentUpdate(){
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        ContentVersion cv = new ContentVersion(
            Title = 'Invoice',
            PathOnClient = 'Storage Agreement.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        insert cdl;

        cdl.Sharetype = 'I'; // simple update
        update cdl;

        ContentVersion cv2 = new ContentVersion(
            Title = 'Invoice',
            PathOnClient = 'Storage Agreement.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv2;
        documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where LatestPublishedVersionId = :cv2.Id]; 
        ContentDocumentLink cdl2 = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        insert cdl2;

    }

    @isTest
    private static void clientDocumentTracker_contentDocumentDelete(){
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        ContentVersion cv = new ContentVersion(
            Title = 'Invoice',
            PathOnClient = 'Storage Agreement.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where Title = 'Invoice'];
        ContentDocumentLink cdl = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        insert cdl;

        cdl.Sharetype = 'I'; // simple update
        update cdl;

        Test.startTest();
        delete documents;
        Test.stopTest();
    }

    @isTest
    private static void clientDocumentTracker_contentDocumentDelete_Invoice(){
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        ContentVersion cv = new ContentVersion(
            Title = 'Invoice',
            PathOnClient = 'Storage Agreement.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        insert cdl;

        cdl.Sharetype = 'I'; // simple update
        update cdl;

        ContentVersion cv2 = new ContentVersion(
            Title = 'Invoice',
            PathOnClient = 'Storage Agreement.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv2;
        documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where LatestPublishedVersionId = :cv2.Id]; 
        ContentDocumentLink cdl2 = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        insert cdl2;

        Test.startTest();
        delete cdl2;
        Test.stopTest();
    }

    @isTest
    private static void clientDocumentTracker_contentDocumentDelete_MHQ(){
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        ContentVersion cv = new ContentVersion(
            Title = 'Maternal Health Questionnaire',
            PathOnClient = 'Storage Agreement.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        insert cdl;

        cdl.Sharetype = 'I'; // simple update
        update cdl;

        ContentVersion cv2 = new ContentVersion(
            Title = 'Maternal Health Questionnaire',
            PathOnClient = 'Storage Agreement.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv2;
        documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where LatestPublishedVersionId = :cv2.Id]; 
        ContentDocumentLink cdl2 = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        insert cdl2;

        Test.startTest();
        delete cdl2;
        Test.stopTest();
    }

    @isTest
    private static void clientDocumentTracker_contentDocumentDelete_InformedConsent(){
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        ContentVersion cv = new ContentVersion(
            Title = 'Informed Consent',
            PathOnClient = 'Storage Agreement.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        insert cdl;

        cdl.Sharetype = 'I'; // simple update
        update cdl;

        ContentVersion cv2 = new ContentVersion(
            Title = 'Informed Consent',
            PathOnClient = 'Storage Agreement.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv2;
        documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where LatestPublishedVersionId = :cv2.Id]; 
        ContentDocumentLink cdl2 = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        insert cdl2;

        Test.startTest();
        delete cdl2;
        Test.stopTest();
    }

    @isTest
    private static void clientDocumentTracker_contentDocumentDelete_InformedConsentSurrogate(){
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        ContentVersion cv = new ContentVersion(
            Title = 'Informed Consent - Surrogate',
            PathOnClient = 'Storage Agreement.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        insert cdl;

        cdl.Sharetype = 'I'; // simple update
        update cdl;

        ContentVersion cv2 = new ContentVersion(
            Title = 'Informed Consent - Surrogate',
            PathOnClient = 'Storage Agreement.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv2;
        documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where LatestPublishedVersionId = :cv2.Id]; 
        ContentDocumentLink cdl2 = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        insert cdl2;

        Test.startTest();
        delete cdl2;
        Test.stopTest();
    }

    @isTest
    private static void clientDocumentTracker_contentDocumentDelete_SurrogateMHQ(){
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        ContentVersion cv = new ContentVersion(
            Title = 'Surrogate Health Screening Questionnaire',
            PathOnClient = 'Storage Agreement.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        insert cdl;

        cdl.Sharetype = 'I'; // simple update
        update cdl;

        ContentVersion cv2 = new ContentVersion(
            Title = 'Surrogate Health Screening Questionnaire',
            PathOnClient = 'Storage Agreement.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv2;
        documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where LatestPublishedVersionId = :cv2.Id]; 
        ContentDocumentLink cdl2 = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        insert cdl2;

        Test.startTest();
        delete cdl2;
        Test.stopTest();
    }

    @isTest
    private static void clientDocumentTracker_contentDocumentDelete_Biopreservation(){
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        ContentVersion cv = new ContentVersion(
            Title = 'Bio-Preservation-Services',
            PathOnClient = 'Storage Agreement.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        insert cdl;

        cdl.Sharetype = 'I'; // simple update
        update cdl;

        ContentVersion cv2 = new ContentVersion(
            Title = 'Bio-Preservation-Services',
            PathOnClient = 'Storage Agreement.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv2;
        documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where LatestPublishedVersionId = :cv2.Id]; 
        ContentDocumentLink cdl2 = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        insert cdl2;

        Test.startTest();
        delete cdl2;
        Test.stopTest();
    }

    @isTest
    private static void clientDocumentTracker_contentDocumentDelete_HealthcareTeam(){
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        ContentVersion cv = new ContentVersion(
            Title = 'Healthcare-Team',
            PathOnClient = 'Storage Agreement.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        insert cdl;

        cdl.Sharetype = 'I'; // simple update
        update cdl;

        ContentVersion cv2 = new ContentVersion(
            Title = 'Healthcare-Team',
            PathOnClient = 'Storage Agreement.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv2;
        documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where LatestPublishedVersionId = :cv2.Id]; 
        ContentDocumentLink cdl2 = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        insert cdl2;

        Test.startTest();
        delete cdl2;
        Test.stopTest();
    }

    @isTest
    private static void clientDocumentTracker_contentDocumentDelete_GeneralService(){
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        ContentVersion cv = new ContentVersion(
            Title = 'General-Service',
            PathOnClient = 'Storage Agreement.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        insert cdl;

        cdl.Sharetype = 'I'; // simple update
        update cdl;

        ContentVersion cv2 = new ContentVersion(
            Title = 'General-Service',
            PathOnClient = 'Storage Agreement.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv2;
        documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where LatestPublishedVersionId = :cv2.Id]; 
        ContentDocumentLink cdl2 = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        insert cdl2;

        Test.startTest();
        delete cdl2;
        Test.stopTest();
    }

    @isTest
    private static void clientDocumentTracker_contentDocumentDelete_StorageAgreement(){
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        ContentVersion cv = new ContentVersion(
            Title = 'Storage Agreement',
            PathOnClient = 'Storage Agreement.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        insert cdl;

        cdl.Sharetype = 'I'; // simple update
        update cdl;

        ContentVersion cv2 = new ContentVersion(
            Title = 'Storage Agreement',
            PathOnClient = 'Storage Agreement.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv2;
        documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where LatestPublishedVersionId = :cv2.Id]; 
        ContentDocumentLink cdl2 = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        insert cdl2;

        Test.startTest();
        delete cdl2;
        Test.stopTest();
    }

    @isTest
    private static void clientDocumentTracker_contentDocumentCertOfStorageLab(){
        List<ContentVersion> lstContentVersion = new List<ContentVersion>();
        List<ContentDocumentLink> lstContentDocumentLink = new List<ContentDocumentLink>();
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];

        // create docs
        for (Integer i = 0; i < 5; i++) {
            String strDocTitle = 'Certificate_of_Storage'+i;
            ContentVersion cv1 = new ContentVersion(
                Title = strDocTitle,
                PathOnClient = 'Certificate_of_Storage.pdf',
                VersionData = Blob.valueOf('Unit Test Attachment Body - '+strDocTitle),
                IsMajorVersion = true
            );
            lstContentVersion.add(cv1);
        }
        insert lstContentVersion;
        List<ContentDocument> lstContentDocument = [
                SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument
                WHERE Title like 'Cert%'
            ];
        for (ContentDocument doc: lstContentDocument){
            ContentDocumentLink cdl1 = new ContentDocumentLink(
                contentdocumentid = doc.Id,
                LinkedEntityId = lab.Id
            );
            lstContentDocumentLink.add(cdl1);
        }    
        insert lstContentDocumentLink;

        List<ContentDocumentLink> lstCDL = [SELECT Id From ContentDocumentLink];
        Test.startTest();
        delete lstCDL;
        Test.stopTest();
    }

    @isTest
    private static void clientDocumentTracker_contentDocumentCertOfStorageFM(){
        List<ContentVersion> lstContentVersion = new List<ContentVersion>();
        List<ContentDocumentLink> lstContentDocumentLink = new List<ContentDocumentLink>();
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        Baby__c fm = new Baby__c(Name='Baby test', Lab__c=lab.id);
        insert fm;

        // create docs
        for (Integer i = 0; i < 5; i++) {
            String strDocTitle = 'Certificate_of_Storage'+i;
            ContentVersion cv1 = new ContentVersion(
                Title = strDocTitle,
                PathOnClient = 'Certificate_of_Storage.pdf',
                VersionData = Blob.valueOf('Unit Test Attachment Body - '+strDocTitle),
                IsMajorVersion = true
            );
            lstContentVersion.add(cv1);
        }
        insert lstContentVersion;
        List<ContentDocument> lstContentDocument = [
                SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument
                WHERE Title like 'Cert%'
            ];
        for (ContentDocument doc: lstContentDocument){
            ContentDocumentLink cdl1 = new ContentDocumentLink(
                contentdocumentid = doc.Id,
                LinkedEntityId = fm.Id
            );
            lstContentDocumentLink.add(cdl1);
        }    
        insert lstContentDocumentLink;

        List<ContentDocumentLink> lstCDL = [SELECT Id From ContentDocumentLink];
        Test.startTest();
        delete lstCDL;
        Test.stopTest();
    }

    @isTest
    private static void clientDocumentTracker_contentDocumentDelete_Documents(){
        List<ContentVersion> lstContentVersion = new List<ContentVersion>();
        List<ContentDocumentLink> lstContentDocumentLink = new List<ContentDocumentLink>();
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        for (Integer i = 0; i < 20; i++) {
            String strDocTitle = 'Doc'+i;
            ContentVersion cv1 = new ContentVersion(
                Title = strDocTitle,
                PathOnClient = 'Storage Agreement.pdf',
                VersionData = Blob.valueOf('Unit Test Attachment Body - '+strDocTitle),
                IsMajorVersion = true
            );
            lstContentVersion.add(cv1);
        }
        insert lstContentVersion;

        List<ContentDocument> lstContentDocument = [
                SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument
                WHERE Title like 'Doc%'
            ];
        for (ContentDocument doc: lstContentDocument){
            ContentDocumentLink cdl1 = new ContentDocumentLink(
                contentdocumentid = doc.Id,
                LinkedEntityId = lab.Id
            );
            lstContentDocumentLink.add(cdl1);
        }    
        insert lstContentDocumentLink;
                
        List<ContentDocumentLink> lstCDL = [SELECT Id From ContentDocumentLink];
        Test.startTest();
        delete lstCDL;
        Test.stopTest();
    }

    @isTest 
    private static void clientDocumentTracker_contentDocumentInsertBulk(){
        List<ContentDocumentLink> lstcdl = new List<ContentDocumentLink>();
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];
        ContentVersion cv1 = new ContentVersion(
            Title = 'Invoice',
            PathOnClient = 'Invoice.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv1;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where LatestPublishedVersionId = :cv1.Id LIMIT 1];
        ContentDocumentLink cdl1 = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        ContentVersion cv2 = new ContentVersion(
            Title = 'Storage Agreement',
            PathOnClient = 'Storage Agreement.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv2;
        List<ContentDocument> documents2 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where LatestPublishedVersionId = :cv2.Id LIMIT 1];
        ContentDocumentLink cdl2 = new ContentDocumentLink(
            contentdocumentid = documents2[0].Id,
            LinkedEntityId = lab.Id
        );
        lstcdl.add(cdl1);
        lstcdl.add(cdl2);
        insert lstcdl;
    }

    @isTest
    private static void clientDocumentTracker_loadTrackerForOlderDocuments(){
        List<ContentDocumentLink> lstcdl = new List<ContentDocumentLink>();
        Lab__c lab = [SELECT Id FROM Lab__c Limit 1];

        // attachments
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        Attachment att1 = new Attachment(Name='Healthcare-Team', Parentid = lab.id,Body=bodyBlob);
        insert att1;
        Attachment att2 = new Attachment(Name='Informed Consent - Surrogate', Parentid = lab.id,Body=bodyBlob);
        insert att2;
        Attachment att3 = new Attachment(Name='Informed-Consent', Parentid = lab.id,Body=bodyBlob);
        insert att3;

        //ContentDocuments
        ContentVersion cv1 = new ContentVersion(
            Title = 'Healthcare-Team',
            PathOnClient = 'Healthcare-Team.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv1;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where LatestPublishedVersionId = :cv1.Id LIMIT 1];
        ContentDocumentLink cdl1 = new ContentDocumentLink(
            contentdocumentid = documents[0].Id,
            LinkedEntityId = lab.Id
        );
        ContentVersion cv2 = new ContentVersion(
            Title = 'Informed Consent - Surrogate',
            PathOnClient = 'Informed Consent - Surrogate.pdf',
            VersionData = Blob.valueOf('Unit Test Attachment Body'),
            IsMajorVersion = true
        );
        insert cv2;
        List<ContentDocument> documents2 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where LatestPublishedVersionId = :cv2.Id LIMIT 1];
        ContentDocumentLink cdl2 = new ContentDocumentLink(
            contentdocumentid = documents2[0].Id,
            LinkedEntityId = lab.Id
        );
        lstcdl.add(cdl1);
        lstcdl.add(cdl2);
        insert lstcdl;

        Client_Document_Tracker__c testCDT = [SELECT Id, Healthcare_Team_Document__c FROM Client_Document_Tracker__c WHERE Lab__c = :lab.Id LIMIT 1];
        // delete the CDT
        delete testCDT;

        ClientDocumentTracker.loadDocumentTrackerForOlderDocuments(10);

    }
        
}