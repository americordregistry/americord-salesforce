public with sharing class ClientDocumentTracker {
    private static String ATTACHMENT = 'Attachment';
    private static String CONTENT = 'Content';

    public static String doctypeBasedOnDocumentId(String documentId, Client_Document_Tracker__c cdt){
        String strReturnString = 'UNKNOWN';
        if (cdt.Informed_Consent_Document__c == documentId){
            strReturnString = 'INFORMED CONSENT';
        }
        else if (cdt.Surrogate_Informed_Consent_Document__c == documentId){
            strReturnString = 'SURROGATE INFORMED CONSENT';
        }
        else if (cdt.MHQ_Document__c == documentId){
            strReturnString = 'MHQ';
        }
        else if (cdt.Surrogate_MHQ_Document__c == documentId){
            strReturnString = 'SURROGATE MHQ';
        }
        else if (cdt.Biopreservation_Document__c == documentId){
            strReturnString = 'BIOPRESERVATION';
        }
        else if (cdt.Healthcare_Team_Document__c == documentId){
            strReturnString = 'HEALTHCARE TEAM';
        }
        else if (cdt.General_Services_Agreement_Document__c == documentId){
            strReturnString = 'GENERAL SERVICE AGREEMENT';
        }
        else if (cdt.Storage_Agreement_Document__c == documentId){
            strReturnString = 'STORAGE AGREEMENT';
        }
        else if (cdt.Invoice_Document__c == documentId){
            strReturnString = 'INVOICE';
        }
        else if (cdt.Certificate_of_Storage_1__c == documentId){
            strReturnString = 'CERTOFSTORAGE1';
        }
        else if (cdt.Certificate_of_Storage_2__c == documentId){
            strReturnString = 'CERTOFSTORAGE2';
        }
        else if (cdt.Certificate_of_Storage_3__c == documentId){
            strReturnString = 'CERTOFSTORAGE3';
        }
        else if (cdt.Certificate_of_Storage_4__c == documentId){
            strReturnString = 'CERTOFSTORAGE4';
        }
        else if (cdt.Certificate_of_Storage_5__c == documentId){
            strReturnString = 'CERTOFSTORAGE5';
        }
        else if (cdt.Client_Document_1__c == documentId){
            strReturnString = 'DOCUMENT1';
        }
        else if (cdt.Client_Document_2__c == documentId){
            strReturnString = 'DOCUMENT2';
        }
        else if (cdt.Client_Document_3__c == documentId){
            strReturnString = 'DOCUMENT3';
        }
        else if (cdt.Client_Document_4__c == documentId){
            strReturnString = 'DOCUMENT4';
        }
        else if (cdt.Client_Document_5__c == documentId){
            strReturnString = 'DOCUMENT5';
        }
        else if (cdt.Client_Document_6__c == documentId){
            strReturnString = 'DOCUMENT6';
        }
        else if (cdt.Client_Document_7__c == documentId){
            strReturnString = 'DOCUMENT7';
        }
        else if (cdt.Client_Document_8__c == documentId){
            strReturnString = 'DOCUMENT8';
        }
        else if (cdt.Client_Document_9__c == documentId){
            strReturnString = 'DOCUMENT9';
        }
        else if (cdt.Client_Document_10__c == documentId){
            strReturnString = 'DOCUMENT10';
        }
        else if (cdt.Client_Document_11__c == documentId){
            strReturnString = 'DOCUMENT11';
        }
        else if (cdt.Client_Document_12__c == documentId){
            strReturnString = 'DOCUMENT12';
        }
        else if (cdt.Client_Document_13__c == documentId){
            strReturnString = 'DOCUMENT13';
        }
        else if (cdt.Client_Document_14__c == documentId){
            strReturnString = 'DOCUMENT14';
        }
        else if (cdt.Client_Document_15__c == documentId){
            strReturnString = 'DOCUMENT15';
        }
        else if (cdt.Client_Document_16__c == documentId){
            strReturnString = 'DOCUMENT16';
        }
        else if (cdt.Client_Document_17__c == documentId){
            strReturnString = 'DOCUMENT17';
        }
        else if (cdt.Client_Document_18__c == documentId){
            strReturnString = 'DOCUMENT18';
        }
        else if (cdt.Client_Document_19__c == documentId){
            strReturnString = 'DOCUMENT19';
        }
        else if (cdt.Client_Document_20__c == documentId){
            strReturnString = 'DOCUMENT20';
        }

        return strReturnString;
    }

    public static String doctypeBasedOnDocumentName(String documentName, Client_Document_Tracker__c cdt){
        String strReturnString = 'UNKNOWN';
        List<String> lstInformedConsentPatterns = new List<String> {'Informed-Consent','Informed Consent'}; // could we feed this in from a custom metadata type?
        List<String> lstInformedConsentSurrogatePatterns = new List<String> {'Informed Consent - Surrogate','Informed-Consent-Surrogate','Informed Consent 20190621 - Surrogate','Informed Consent 20200427 - Surrogate'};
        List<String> lstMHQPatterns = new List<String> {'Maternal & Family Health Screening Questionnaire','Maternal & Family Health creening Questionnaire','Maternal Health Questionnaire','Americord Questionnaire','Maternal-Health-Questionnaire','Maternal Health Questionnaire'};
        List<String> lstSurrogateMHQPatterns = new List<String> {'Maternal & Family Health Screening Questionnaire 20190621 - Surrogate','Surrogate Health Screening Questionnaire','Maternal-Health-Questionnaire-Surrogate'};
        List<String> lstBioPreservationPatterns = new List<String> {'Bio-Preservation-Services','Biopreservation'};
        List<String> lstHealthCareTeamPattnerns = new List<String> {'Healthcare-Team','Healthcare Team'};
        List<String> lstGeneralServiceAgreementPatterns = new List<String> {'General-Service','General Service'};
        List<String> lstStorageAgreementPatterns = new List<String> {'Storage Agreement','Storage-Agreement'};
        List<String> lstInvoicePatterns = new List<String> {'Invoice','INV-'};
        List<String> lstCertOfStorage = new List<String> {'Certificate_of_Storage'};

        // Loop through lists for name

        // surrogate informed consent
        for (String strPattern: lstInformedConsentSurrogatePatterns){ //!! Must be before parent consent bc of text patterns between parents and surrogate
            if(documentName.contains(strPattern)){
                strReturnString = 'SURROGATE INFORMED CONSENT';
            }
        }
        if (strReturnString == 'UNKNOWN'){ // parental informed consent
            for (String strPattern: lstInformedConsentPatterns){
                if(documentName.contains(strPattern)){
                    strReturnString = 'INFORMED CONSENT';
                }
            }
            if (strReturnString == 'UNKNOWN'){ // surrogate mhq
                for (String strPattern: lstSurrogateMHQPatterns){ //!! Must be before parent bc of text pattern matching
                    if(documentName.contains(strPattern)){
                        strReturnString = 'SURROGATE MHQ';
                    }
                }
                if(strReturnString == 'UNKNOWN'){ //mhq
                    for (String strPattern: lstMHQPatterns){ 
                        if(documentName.contains(strPattern)){
                            strReturnString = 'MHQ';
                        }
                    }
                    if (strReturnString == 'UNKNOWN'){ // bio pres
                        for (String strPattern: lstBioPreservationPatterns){ 
                            if(documentName.contains(strPattern)){
                                strReturnString = 'BIOPRESERVATION';
                            }
                        }
                        if (strReturnString == 'UNKNOWN'){ // healthcare team
                            for (String strPattern: lstHealthCareTeamPattnerns){ 
                                if(documentName.contains(strPattern)){
                                    strReturnString = 'HEALTHCARE TEAM';
                                }
                            }
                            if (strReturnString == 'UNKNOWN'){ // general service agreement
                                for (String strPattern: lstGeneralServiceAgreementPatterns){ 
                                    if(documentName.contains(strPattern)){
                                        strReturnString = 'GENERAL SERVICE AGREEMENT';
                                    }
                                }
                                if (strReturnString == 'UNKNOWN'){ // storage agreement
                                    for (String strPattern: lstStorageAgreementPatterns){ 
                                        if(documentName.contains(strPattern)){
                                            strReturnString = 'STORAGE AGREEMENT';
                                        }
                                    }
                                    if (strReturnString == 'UNKNOWN'){ // invoice
                                        for (String strPattern: lstInvoicePatterns){ 
                                            if(documentName.contains(strPattern)){
                                                strReturnString = 'INVOICE';
                                            }
                                        }
                                        if (strReturnString == 'UNKNOWN'){ // certofstorages
                                            for (String strPattern: lstCertOfStorage){
                                                if(documentName.contains(strPattern)){
                                                    switch on nextAvailableCertOfStorage(cdt){
                                                        when 1 { strReturnString = 'CERTOFSTORAGE1'; }
                                                        when 2 { strReturnString = 'CERTOFSTORAGE2'; }
                                                        when 3 { strReturnString = 'CERTOFSTORAGE3'; }
                                                        when 4 { strReturnString = 'CERTOFSTORAGE4'; }
                                                        when 5 { strReturnString = 'CERTOFSTORAGE5'; }
                                                    }
                                                }
                                            }
                                            if (strReturnString == 'UNKNOWN'){ // generic docs
                                                switch on nextAvailableDocumentSlot(cdt){ 
                                                    when 1 { strReturnString = 'DOCUMENT1'; }
                                                    when 2 { strReturnString = 'DOCUMENT2'; }
                                                    when 3 { strReturnString = 'DOCUMENT3'; }
                                                    when 4 { strReturnString = 'DOCUMENT4'; }
                                                    when 5 { strReturnString = 'DOCUMENT5'; }
                                                    when 6 { strReturnString = 'DOCUMENT6'; }
                                                    when 7 { strReturnString = 'DOCUMENT7'; }
                                                    when 8 { strReturnString = 'DOCUMENT8'; }
                                                    when 9 { strReturnString = 'DOCUMENT9'; }
                                                    when 10 { strReturnString = 'DOCUMENT10'; }
                                                    when 11 { strReturnString = 'DOCUMENT11'; }
                                                    when 12 { strReturnString = 'DOCUMENT12'; }
                                                    when 13 { strReturnString = 'DOCUMENT13'; }
                                                    when 14 { strReturnString = 'DOCUMENT14'; }
                                                    when 15 { strReturnString = 'DOCUMENT15'; }
                                                    when 16 { strReturnString = 'DOCUMENT16'; }
                                                    when 17 { strReturnString = 'DOCUMENT17'; }
                                                    when 18 { strReturnString = 'DOCUMENT18'; }
                                                    when 19 { strReturnString = 'DOCUMENT19'; }
                                                    when 20 { strReturnString = 'DOCUMENT20'; }
                                                    when else {}
                                                }

                                            }

                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return strReturnString;
    }

    private static integer nextAvailableDocumentSlot(Client_Document_Tracker__c cdt){
        Integer intNextOpenSlot = 0;
        if (cdt.Client_Document_1__c == null){
            intNextOpenSlot = 1;
        }
        else {
            if (cdt.Client_Document_2__c == null){
                intNextOpenSlot = 2;
            }
            else{
                if (cdt.Client_Document_3__c == null){
                    intNextOpenSlot = 3;
                }
                else {
                    if (cdt.Client_Document_4__c == null){
                        intNextOpenSlot = 4;
                    }
                    else {
                        if (cdt.Client_Document_5__c == null){
                            intNextOpenSlot = 5;
                        }
                        else {
                            if (cdt.Client_Document_6__c == null){
                                intNextOpenSlot = 6;
                            }
                            else {
                                if (cdt.Client_Document_7__c == null){
                                    intNextOpenSlot = 7;
                                }
                                else {
                                    if (cdt.Client_Document_8__c == null){
                                        intNextOpenSlot = 8;
                                    }
                                    else {
                                        if (cdt.Client_Document_9__c == null){
                                            intNextOpenSlot = 9;
                                        }
                                        else {
                                            if (cdt.Client_Document_10__c == null){
                                                intNextOpenSlot = 10;
                                            }
                                            else {
                                                if (cdt.Client_Document_11__c == null){
                                                    intNextOpenSlot = 11;
                                                }
                                                else {
                                                    if (cdt.Client_Document_12__c == null){
                                                        intNextOpenSlot = 12;
                                                    }
                                                    else {
                                                        if (cdt.Client_Document_13__c == null){
                                                            intNextOpenSlot = 13;
                                                        }
                                                        else {
                                                            if (cdt.Client_Document_14__c == null){
                                                                intNextOpenSlot = 14;
                                                            }
                                                            else {
                                                                if (cdt.Client_Document_15__c == null){
                                                                    intNextOpenSlot = 15;
                                                                }
                                                                else {
                                                                    if (cdt.Client_Document_16__c == null){
                                                                        intNextOpenSlot = 16;
                                                                    }
                                                                    else {
                                                                        if (cdt.Client_Document_17__c == null){
                                                                            intNextOpenSlot = 17;
                                                                        }
                                                                        else {
                                                                            if (cdt.Client_Document_18__c == null){
                                                                                intNextOpenSlot = 18;
                                                                            }
                                                                            else {
                                                                                if (cdt.Client_Document_19__c == null){
                                                                                    intNextOpenSlot = 19;
                                                                                }
                                                                                else {
                                                                                    if (cdt.Client_Document_20__c == null){
                                                                                        intNextOpenSlot = 20;
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                }

            }
        }
        return intNextOpenSlot;
    }

    private static integer nextAvailableCertOfStorage(Client_Document_Tracker__c cdt){
        Integer intNextOpenSlot = 0;
        if (cdt.Certificate_of_Storage_1__c == null){
            intNextOpenSlot = 1;
        }
        else {
            if (cdt.Certificate_of_Storage_2__c == null){
                intNextOpenSlot = 2;
            }
            else{
                if (cdt.Certificate_of_Storage_3__c == null){
                    intNextOpenSlot = 3;
                }
                else {
                    if (cdt.Certificate_of_Storage_4__c == null){
                        intNextOpenSlot = 4;
                    }
                    else {
                        if (cdt.Certificate_of_Storage_5__c == null){
                            intNextOpenSlot = 5;
                        }

                    }
                }

            }
        }
        return intNextOpenSlot;
    }

    public static Client_Document_Tracker__c setTrackerFields(Client_Document_Tracker__c cdt, ContentDocumentLink cdl){
        switch on ClientDocumentTracker.doctypeBasedOnDocumentName(cdl.ContentDocument.Title, cdt) {
            when 'INFORMED CONSENT' {
                cdt.Informed_Consent_Document__c = cdl.ContentDocumentId;
                cdt.Informed_Consent_Document_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Informed_Consent_Document_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Informed_Consent_Document_Name__c = cdl.ContentDocument.Title;
                }
            }
            when 'SURROGATE INFORMED CONSENT'{
                cdt.Surrogate_Informed_Consent_Document__c = cdl.ContentDocumentId;
                cdt.Surrogate_Informed_Consent_Document_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Surrogate_Informed_Consent_Document_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Surrogate_Informed_Consent_Document_Name__c = cdl.ContentDocument.Title;
                }
            }
            when 'MHQ' {
                cdt.MHQ_Document__c = cdl.ContentDocumentId;
                cdt.MHQ_Document_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.MHQ_Document_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.MHQ_Document_Name__c = cdl.ContentDocument.Title;
                }
            }
            when 'SURROGATE MHQ'{
                cdt.Surrogate_MHQ_Document__c = cdl.ContentDocumentId;
                cdt.Surrogate_MHQ_Document_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Surrogate_MHQ_Document_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Surrogate_MHQ_Document_Name__c = cdl.ContentDocument.Title;
                }
            }
            when 'BIOPRESERVATION'{
                cdt.Biopreservation_Document__c = cdl.ContentDocumentId;
                cdt.Biopreservation_Document_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Biopreservation_Document_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Biopreservation_Document_Name__c = cdl.ContentDocument.Title;
                }
            }
            when 'HEALTHCARE TEAM'{
                cdt.Healthcare_Team_Document__c = cdl.ContentDocumentId;
                cdt.Healthcare_Team_Document_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Healthcare_Team_Document_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Healthcare_Team_Document_Name__c = cdl.ContentDocument.Title;
                }
            }
            when 'GENERAL SERVICE AGREEMENT'{
                cdt.General_Services_Agreement_Document__c = cdl.ContentDocumentId;
                cdt.General_Services_Agreement_Document_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.General_Services_Agreement_Document_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.General_Services_Agreement_Document_Name__c = cdl.ContentDocument.Title;
                }
            }
            when 'STORAGE AGREEMENT'{
                cdt.Storage_Agreement_Document__c = cdl.ContentDocumentId;
                cdt.Storage_Agreement_Document_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Storage_Agreement_Document_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Storage_Agreement_Document_Name__c = cdl.ContentDocument.Title;
                }
            }
            when 'INVOICE'{
                cdt.Invoice_Document__c = cdl.ContentDocumentId;
                cdt.Invoice_Document_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Invoice_Document_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Invoice_Document_Name__c = cdl.ContentDocument.Title;
                }
            }
            when 'CERTOFSTORAGE1'{
                cdt.Certificate_of_Storage_1__c = cdl.ContentDocumentId;
                cdt.Certificate_of_Storage_1_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Certificate_of_Storage_1_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                    cdt.Certificate_of_Storage_1_Label__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Certificate_of_Storage_1_Name__c = cdl.ContentDocument.Title;
                    cdt.Certificate_of_Storage_1_Label__c = cdl.ContentDocument.Title;
                }
            }
            when 'CERTOFSTORAGE2'{
                cdt.Certificate_of_Storage_2__c = cdl.ContentDocumentId;
                cdt.Certificate_of_Storage_2_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Certificate_of_Storage_2_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                    cdt.Certificate_of_Storage_2_Label__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Certificate_of_Storage_2_Name__c = cdl.ContentDocument.Title;
                    cdt.Certificate_of_Storage_2_Label__c = cdl.ContentDocument.Title;
                }
            }
            when 'CERTOFSTORAGE3'{
                cdt.Certificate_of_Storage_3__c = cdl.ContentDocumentId;
                cdt.Certificate_of_Storage_3_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Certificate_of_Storage_3_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                    cdt.Certificate_of_Storage_3_Label__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Certificate_of_Storage_3_Name__c = cdl.ContentDocument.Title;
                    cdt.Certificate_of_Storage_3_Label__c = cdl.ContentDocument.Title;
                }
            }
            when 'CERTOFSTORAGE4'{
                cdt.Certificate_of_Storage_4__c = cdl.ContentDocumentId;
                cdt.Certificate_of_Storage_4_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Certificate_of_Storage_4_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                    cdt.Certificate_of_Storage_4_Label__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Certificate_of_Storage_4_Name__c = cdl.ContentDocument.Title;
                    cdt.Certificate_of_Storage_4_Label__c = cdl.ContentDocument.Title;
                }
            }
            when 'CERTOFSTORAGE5'{
                cdt.Certificate_of_Storage_5__c = cdl.ContentDocumentId;
                cdt.Certificate_of_Storage_5_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Certificate_of_Storage_5_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                    cdt.Certificate_of_Storage_5_Label__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Certificate_of_Storage_5_Name__c = cdl.ContentDocument.Title;
                    cdt.Certificate_of_Storage_5_Label__c = cdl.ContentDocument.Title;
                }
            }
            when 'DOCUMENT1'{
                cdt.Client_Document_1__c = cdl.ContentDocumentId;
                cdt.Client_Document_1_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Client_Document_1_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                    cdt.Client_Document_1_Label__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Client_Document_1_Name__c = cdl.ContentDocument.Title;
                    cdt.Client_Document_1_Label__c = cdl.ContentDocument.Title;
                }
            }
            when 'DOCUMENT2'{
                cdt.Client_Document_2__c = cdl.ContentDocumentId;
                cdt.Client_Document_2_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Client_Document_2_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                    cdt.Client_Document_2_Label__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Client_Document_2_Name__c = cdl.ContentDocument.Title;
                    cdt.Client_Document_2_Label__c= cdl.ContentDocument.Title;
                }
            }
            when 'DOCUMENT3'{
                cdt.Client_Document_3__c = cdl.ContentDocumentId;
                cdt.Client_Document_3_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Client_Document_3_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                    cdt.Client_Document_3_Label__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Client_Document_3_Name__c = cdl.ContentDocument.Title;
                    cdt.Client_Document_3_Label__c = cdl.ContentDocument.Title;
                }
            }
            when 'DOCUMENT4'{
                cdt.Client_Document_4__c = cdl.ContentDocumentId;
                cdt.Client_Document_4_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Client_Document_4_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                    cdt.Client_Document_4_Label__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Client_Document_4_Name__c = cdl.ContentDocument.Title;
                    cdt.Client_Document_4_Label__c = cdl.ContentDocument.Title;
                }
            }
            when 'DOCUMENT5'{
                cdt.Client_Document_5__c = cdl.ContentDocumentId;
                cdt.Client_Document_5_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Client_Document_5_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                    cdt.Client_Document_5_Label__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Client_Document_5_Name__c = cdl.ContentDocument.Title;
                    cdt.Client_Document_5_Label__c = cdl.ContentDocument.Title;
                }
            }
            when 'DOCUMENT6'{
                cdt.Client_Document_6__c = cdl.ContentDocumentId;
                cdt.Client_Document_6_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Client_Document_6_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                    cdt.Client_Document_6_Label__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Client_Document_6_Name__c = cdl.ContentDocument.Title;
                    cdt.Client_Document_6_Label__c = cdl.ContentDocument.Title;
                }
            }
            when 'DOCUMENT7'{
                cdt.Client_Document_7__c = cdl.ContentDocumentId;
                cdt.Client_Document_7_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Client_Document_7_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                    cdt.Client_Document_7_Label__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Client_Document_7_Name__c = cdl.ContentDocument.Title;
                    cdt.Client_Document_7_Label__c = cdl.ContentDocument.Title;
                }
            }
            when 'DOCUMENT8'{
                cdt.Client_Document_8__c = cdl.ContentDocumentId;
                cdt.Client_Document_8_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Client_Document_8_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                    cdt.Client_Document_8_Label__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Client_Document_8_Name__c = cdl.ContentDocument.Title;
                    cdt.Client_Document_8_Label__c = cdl.ContentDocument.Title;
                }
            }
            when 'DOCUMENT9'{
                cdt.Client_Document_9__c = cdl.ContentDocumentId;
                cdt.Client_Document_9_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Client_Document_9_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                    cdt.Client_Document_9_Label__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Client_Document_9_Name__c = cdl.ContentDocument.Title;
                    cdt.Client_Document_9_Label__c = cdl.ContentDocument.Title;
                }
            }
            when 'DOCUMENT10'{
                cdt.Client_Document_10__c = cdl.ContentDocumentId;
                cdt.Client_Document_10_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Client_Document_10_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                    cdt.Client_Document_10_Label__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Client_Document_10_Name__c = cdl.ContentDocument.Title;
                    cdt.Client_Document_10_Label__c = cdl.ContentDocument.Title;
                }
            }
            when 'DOCUMENT11'{
                cdt.Client_Document_11__c = cdl.ContentDocumentId;
                cdt.Client_Document_11_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Client_Document_11_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                    cdt.Client_Document_11_Label__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Client_Document_11_Name__c = cdl.ContentDocument.Title;
                    cdt.Client_Document_11_Label__c = cdl.ContentDocument.Title;
                }
            }
            when 'DOCUMENT12'{
                cdt.Client_Document_12__c = cdl.ContentDocumentId;
                cdt.Client_Document_12_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Client_Document_12_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                    cdt.Client_Document_12_Label__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Client_Document_12_Name__c = cdl.ContentDocument.Title;
                    cdt.Client_Document_12_Label__c = cdl.ContentDocument.Title;
                }
            }
            when 'DOCUMENT13'{
                cdt.Client_Document_13__c = cdl.ContentDocumentId;
                cdt.Client_Document_13_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Client_Document_13_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                    cdt.Client_Document_13_Label__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Client_Document_13_Name__c = cdl.ContentDocument.Title;
                    cdt.Client_Document_13_Label__c = cdl.ContentDocument.Title;
                }
            }
            when 'DOCUMENT14'{
                cdt.Client_Document_14__c = cdl.ContentDocumentId;
                cdt.Client_Document_14_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Client_Document_14_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                    cdt.Client_Document_14_Label__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Client_Document_14_Name__c = cdl.ContentDocument.Title;
                    cdt.Client_Document_14_Label__c = cdl.ContentDocument.Title;
                }
            }
            when 'DOCUMENT15'{
                cdt.Client_Document_15__c = cdl.ContentDocumentId;
                cdt.Client_Document_15_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Client_Document_15_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                    cdt.Client_Document_15_Label__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Client_Document_15_Name__c = cdl.ContentDocument.Title;
                    cdt.Client_Document_15_Label__c = cdl.ContentDocument.Title;
                }
            }
            when 'DOCUMENT16'{
                cdt.Client_Document_16__c = cdl.ContentDocumentId;
                cdt.Client_Document_16_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Client_Document_16_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                    cdt.Client_Document_16_Label__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Client_Document_16_Name__c = cdl.ContentDocument.Title;
                    cdt.Client_Document_16_Label__c = cdl.ContentDocument.Title;
                }
            }
            when 'DOCUMENT17'{
                cdt.Client_Document_17__c = cdl.ContentDocumentId;
                cdt.Client_Document_17_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Client_Document_17_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                    cdt.Client_Document_17_Label__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Client_Document_17_Name__c = cdl.ContentDocument.Title;
                    cdt.Client_Document_17_Label__c = cdl.ContentDocument.Title;
                }
            }
            when 'DOCUMENT18'{
                cdt.Client_Document_18__c = cdl.ContentDocumentId;
                cdt.Client_Document_18_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Client_Document_18_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                    cdt.Client_Document_18_Label__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Client_Document_18_Name__c = cdl.ContentDocument.Title;
                    cdt.Client_Document_18_Label__c = cdl.ContentDocument.Title;
                }
            }
            when 'DOCUMENT19'{
                cdt.Client_Document_19__c = cdl.ContentDocumentId;
                cdt.Client_Document_19_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Client_Document_19_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                    cdt.Client_Document_19_Label__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Client_Document_19_Name__c = cdl.ContentDocument.Title;
                    cdt.Client_Document_19_Label__c = cdl.ContentDocument.Title;
                }
            }
            when 'DOCUMENT20'{
                cdt.Client_Document_20__c = cdl.ContentDocumentId;
                cdt.Client_Document_20_Type__c = CONTENT;
                if(cdl.ContentDocument.FileExtension != null){
                    cdt.Client_Document_20_Name__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                    cdt.Client_Document_20_Label__c = cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension;
                }
                else{
                    cdt.Client_Document_20_Name__c = cdl.ContentDocument.Title;
                    cdt.Client_Document_20_Label__c = cdl.ContentDocument.Title;
                }
            }
            when else {
                
            }
        }
        return cdt;
    }
    public static Client_Document_Tracker__c clearTrackerFields(Client_Document_Tracker__c cdt, String strDocType){
        switch on strDocType {
            when 'INFORMED CONSENT' {
                cdt.Informed_Consent_Document__c = null;
                cdt.Informed_Consent_Document_Type__c = null;
                cdt.Informed_Consent_Document_Name__c = null;
            }
            when 'SURROGATE INFORMED CONSENT'{
                cdt.Surrogate_Informed_Consent_Document__c = null;
                cdt.Surrogate_Informed_Consent_Document_Type__c = null;
                cdt.Surrogate_Informed_Consent_Document_Name__c = null;
            }
            when 'MHQ' {
                cdt.MHQ_Document__c = null;
                cdt.MHQ_Document_Type__c = null;
                cdt.MHQ_Document_Name__c = null;
            }
            when 'SURROGATE MHQ'{
                cdt.Surrogate_MHQ_Document__c = null;
                cdt.Surrogate_MHQ_Document_Type__c = null;
                cdt.Surrogate_MHQ_Document_Name__c = null;
            }
            when 'BIOPRESERVATION'{
                cdt.Biopreservation_Document__c = null;
                cdt.Biopreservation_Document_Type__c = null;
                cdt.Biopreservation_Document_Name__c = null;
            }
            when 'HEALTHCARE TEAM'{
                cdt.Healthcare_Team_Document__c = null;
                cdt.Healthcare_Team_Document_Type__c = null;
                cdt.Healthcare_Team_Document_Name__c = null;
            }
            when 'GENERAL SERVICE AGREEMENT'{
                cdt.General_Services_Agreement_Document__c = null;
                cdt.General_Services_Agreement_Document_Type__c = null;
                cdt.General_Services_Agreement_Document_Name__c = null;
            }
            when 'STORAGE AGREEMENT'{
                cdt.Storage_Agreement_Document__c = null;
                cdt.Storage_Agreement_Document_Type__c = null;
                cdt.Storage_Agreement_Document_Name__c = null;
            }
            when 'INVOICE'{
                cdt.Invoice_Document__c = null;
                cdt.Invoice_Document_Type__c = null;
                cdt.Invoice_Document_Name__c = null;
            }
            when 'CERTOFSTORAGE1'{
                cdt.Certificate_of_Storage_1__c = null;
                cdt.Certificate_of_Storage_1_Type__c = null;
                cdt.Certificate_of_Storage_1_Name__c = null;
                cdt.Certificate_of_Storage_1_Label__c = null;
            }
            when 'CERTOFSTORAGE2'{
                cdt.Certificate_of_Storage_2__c = null;
                cdt.Certificate_of_Storage_2_Type__c = null;
                cdt.Certificate_of_Storage_2_Name__c = null;
                cdt.Certificate_of_Storage_2_Label__c = null;
            }
            when 'CERTOFSTORAGE3'{
                cdt.Certificate_of_Storage_3__c = null;
                cdt.Certificate_of_Storage_3_Type__c = null;
                cdt.Certificate_of_Storage_3_Name__c = null;
                cdt.Certificate_of_Storage_3_Label__c = null;
            }
            when 'CERTOFSTORAGE4'{
                cdt.Certificate_of_Storage_4__c = null;
                cdt.Certificate_of_Storage_4_Type__c = null;
                cdt.Certificate_of_Storage_4_Name__c = null;
                cdt.Certificate_of_Storage_4_Label__c = null;
            }
            when 'CERTOFSTORAGE5'{
                cdt.Certificate_of_Storage_5__c = null;
                cdt.Certificate_of_Storage_5_Type__c = null;
                cdt.Certificate_of_Storage_5_Name__c = null;
                cdt.Certificate_of_Storage_5_Label__c = null;
            }
            when 'DOCUMENT1'{
                cdt.Client_Document_1__c = null;
                cdt.Client_Document_1_Type__c = null;
                cdt.Client_Document_1_Name__c = null;
                cdt.Client_Document_1_Label__c = null;
            }
            when 'DOCUMENT2'{
                cdt.Client_Document_2__c = null;
                cdt.Client_Document_2_Type__c = null;
                cdt.Client_Document_2_Name__c = null;
                cdt.Client_Document_2_Label__c = null;
            }
            when 'DOCUMENT3'{
                cdt.Client_Document_3__c = null;
                cdt.Client_Document_3_Type__c = null;
                cdt.Client_Document_3_Name__c = null;
                cdt.Client_Document_3_Label__c = null;
            }
            when 'DOCUMENT4'{
                cdt.Client_Document_4__c = null;
                cdt.Client_Document_4_Type__c = null;
                cdt.Client_Document_4_Name__c = null;
                cdt.Client_Document_4_Label__c = null;
            }
            when 'DOCUMENT5'{
                cdt.Client_Document_5__c = null;
                cdt.Client_Document_5_Type__c = null;
                cdt.Client_Document_5_Name__c = null;
                cdt.Client_Document_5_Label__c = null;
            }
            when 'DOCUMENT6'{
                cdt.Client_Document_6__c = null;
                cdt.Client_Document_6_Type__c = null;
                cdt.Client_Document_6_Name__c = null;
                cdt.Client_Document_6_Label__c = null;
            }
            when 'DOCUMENT7'{
                cdt.Client_Document_7__c = null;
                cdt.Client_Document_7_Type__c = null;
                cdt.Client_Document_7_Name__c = null;
                cdt.Client_Document_7_Label__c = null;
            }
            when 'DOCUMENT8'{
                cdt.Client_Document_8__c = null;
                cdt.Client_Document_8_Type__c = null;
                cdt.Client_Document_8_Name__c = null;
                cdt.Client_Document_8_Label__c = null;
            }
            when 'DOCUMENT9'{
                cdt.Client_Document_9__c = null;
                cdt.Client_Document_9_Type__c = null;
                cdt.Client_Document_9_Name__c = null;
                cdt.Client_Document_9_Label__c = null;
            }
            when 'DOCUMENT10'{
                cdt.Client_Document_10__c = null;
                cdt.Client_Document_10_Type__c = null;
                cdt.Client_Document_10_Name__c = null;
                cdt.Client_Document_10_Label__c = null;
            }
            when 'DOCUMENT11'{
                cdt.Client_Document_11__c = null;
                cdt.Client_Document_11_Type__c = null;
                cdt.Client_Document_11_Name__c = null;
                cdt.Client_Document_11_Label__c = null;
            }
            when 'DOCUMENT12'{
                cdt.Client_Document_12__c = null;
                cdt.Client_Document_12_Type__c = null;
                cdt.Client_Document_12_Name__c = null;
                cdt.Client_Document_12_Label__c = null;
            }
            when 'DOCUMENT13'{
                cdt.Client_Document_13__c = null;
                cdt.Client_Document_13_Type__c = null;
                cdt.Client_Document_13_Name__c = null;
                cdt.Client_Document_13_Label__c = null;
            }
            when 'DOCUMENT14'{
                cdt.Client_Document_14__c = null;
                cdt.Client_Document_14_Type__c = null;
                cdt.Client_Document_14_Name__c = null;
                cdt.Client_Document_14_Label__c = null;
            }
            when 'DOCUMENT15'{
                cdt.Client_Document_15__c = null;
                cdt.Client_Document_15_Type__c = null;
                cdt.Client_Document_15_Name__c = null;
                cdt.Client_Document_15_Label__c = null;
            }
            when 'DOCUMENT16'{
                cdt.Client_Document_16__c = null;
                cdt.Client_Document_16_Type__c = null;
                cdt.Client_Document_16_Name__c = null;
                cdt.Client_Document_16_Label__c = null;
            }
            when 'DOCUMENT17'{
                cdt.Client_Document_17__c = null;
                cdt.Client_Document_17_Type__c = null;
                cdt.Client_Document_17_Name__c = null;
                cdt.Client_Document_17_Label__c = null;
            }
            when 'DOCUMENT18'{
                cdt.Client_Document_18__c = null;
                cdt.Client_Document_18_Type__c = null;
                cdt.Client_Document_18_Name__c = null;
                cdt.Client_Document_18_Label__c = null;
            }
            when 'DOCUMENT19'{
                cdt.Client_Document_19__c = null;
                cdt.Client_Document_19_Type__c = null;
                cdt.Client_Document_19_Name__c = null;
                cdt.Client_Document_19_Label__c = null;
            }
            when 'DOCUMENT20'{
                cdt.Client_Document_20__c = null;
                cdt.Client_Document_20_Type__c = null;
                cdt.Client_Document_20_Name__c = null;
                cdt.Client_Document_20_Label__c = null;
            }
            when else {
                
            }
        }
        return cdt;
    }

    public static Client_Document_Tracker__c clearTrackerFieldsContentDocumentLink(Client_Document_Tracker__c cdt, ContentDocumentLink cdl){
        return clearTrackerFields(cdt,ClientDocumentTracker.docTypeBasedOnDocumentId(cdl.ContentDocumentId, cdt));
    }

    public static Client_Document_Tracker__c clearTrackerFieldsAttachment(Client_Document_Tracker__c cdt, Attachment att){
        return clearTrackerFields(cdt,ClientDocumentTracker.docTypeBasedOnDocumentId(att.Id, cdt));
    }

    public static Client_Document_Tracker__c setTrackerFieldsAttachment(Client_Document_Tracker__c cdt, Attachment att){
        switch on ClientDocumentTracker.doctypeBasedOnDocumentName(att.Name, cdt) {
            when 'INFORMED CONSENT' {
                cdt.Informed_Consent_Document__c = att.Id;
                cdt.Informed_Consent_Document_Type__c = ATTACHMENT;
                cdt.Informed_Consent_Document_Name__c = att.Name;
            }
            when 'SURROGATE INFORMED CONSENT'{
                cdt.Surrogate_Informed_Consent_Document__c = att.Id;
                cdt.Surrogate_Informed_Consent_Document_Type__c = ATTACHMENT;
                cdt.Surrogate_Informed_Consent_Document_Name__c = att.Name;
            }
            when 'MHQ' {
                cdt.MHQ_Document__c = att.Id;
                cdt.MHQ_Document_Type__c = ATTACHMENT;
                cdt.MHQ_Document_Name__c = att.Name;
            }
            when 'SURROGATE MHQ'{
                cdt.Surrogate_MHQ_Document__c = att.Id;
                cdt.Surrogate_MHQ_Document_Type__c = ATTACHMENT;
                cdt.Surrogate_MHQ_Document_Name__c = att.Name;
            }
            when 'BIOPRESERVATION'{
                cdt.Biopreservation_Document__c = att.Id;
                cdt.Biopreservation_Document_Type__c = ATTACHMENT;
                cdt.Biopreservation_Document_Name__c = att.Name;
            }
            when 'HEALTHCARE TEAM'{
                cdt.Healthcare_Team_Document__c = att.Id;
                cdt.Healthcare_Team_Document_Type__c = ATTACHMENT;
                cdt.Healthcare_Team_Document_Name__c = att.Name;
            }
            when 'GENERAL SERVICE AGREEMENT'{
                cdt.General_Services_Agreement_Document__c = att.id;
                cdt.General_Services_Agreement_Document_Type__c = ATTACHMENT;
                cdt.General_Services_Agreement_Document_Name__c = att.Name;
            }
            when 'STORAGE AGREEMENT'{
                cdt.Storage_Agreement_Document__c = att.id;
                cdt.Storage_Agreement_Document_Type__c = ATTACHMENT;
                cdt.Storage_Agreement_Document_Name__c = att.Name;
            }
            when 'INVOICE'{
                cdt.Invoice_Document__c = att.id;
                cdt.Invoice_Document_Type__c = ATTACHMENT;
                cdt.Invoice_Document_Name__c = att.Name;
            }
            when 'CERTOFSTORAGE1'{
                cdt.Certificate_of_Storage_1__c = att.id;
                cdt.Certificate_of_Storage_1_Type__c = ATTACHMENT;
                cdt.Certificate_of_Storage_1_Label__c = att.Name;
                cdt.Certificate_of_Storage_1_Name__c = att.Name;
            }
            when 'CERTOFSTORAGE2'{
                cdt.Certificate_of_Storage_2__c = att.id;
                cdt.Certificate_of_Storage_2_Type__c = ATTACHMENT;
                cdt.Certificate_of_Storage_2_Label__c = att.Name;
                cdt.Certificate_of_Storage_2_Name__c = att.Name;
            }
            when 'CERTOFSTORAGE3'{
                cdt.Certificate_of_Storage_3__c = att.id;
                cdt.Certificate_of_Storage_3_Type__c = ATTACHMENT;
                cdt.Certificate_of_Storage_3_Label__c = att.Name;
                cdt.Certificate_of_Storage_3_Name__c = att.Name;
            }
            when 'CERTOFSTORAGE4'{
                cdt.Certificate_of_Storage_4__c = att.id;
                cdt.Certificate_of_Storage_4_Type__c = ATTACHMENT;
                cdt.Certificate_of_Storage_4_Label__c = att.Name;
                cdt.Certificate_of_Storage_4_Name__c = att.Name;
            }
            when 'CERTOFSTORAGE5'{
                cdt.Certificate_of_Storage_5__c = att.id;
                cdt.Certificate_of_Storage_5_Type__c = ATTACHMENT;
                cdt.Certificate_of_Storage_5_Label__c = att.Name;
                cdt.Certificate_of_Storage_5_Name__c = att.Name;
            }
            when 'DOCUMENT1'{
                cdt.Client_Document_1__c = att.id;
                cdt.Client_Document_1_Type__c = ATTACHMENT;
                cdt.Client_Document_1_Name__c = att.Name;
                cdt.Client_Document_1_Label__c = att.Name;
            }
            when 'DOCUMENT2'{
                cdt.Client_Document_2__c = att.id;
                cdt.Client_Document_2_Type__c = ATTACHMENT;
                cdt.Client_Document_2_Name__c = att.Name;
                cdt.Client_Document_2_Label__c = att.Name;
            }
            when 'DOCUMENT3'{
                cdt.Client_Document_3__c = att.id;
                cdt.Client_Document_3_Type__c = ATTACHMENT;
                cdt.Client_Document_3_Name__c = att.Name;
                cdt.Client_Document_3_Label__c = att.Name;
            }
            when 'DOCUMENT4'{
                cdt.Client_Document_4__c = att.id;
                cdt.Client_Document_4_Type__c = ATTACHMENT;
                cdt.Client_Document_4_Name__c = att.Name;
                cdt.Client_Document_4_Label__c = att.Name;
            }
            when 'DOCUMENT5'{
                cdt.Client_Document_5__c = att.id;
                cdt.Client_Document_5_Type__c = ATTACHMENT;
                cdt.Client_Document_5_Name__c = att.Name;
                cdt.Client_Document_5_Label__c = att.Name;
            }
            when 'DOCUMENT6'{
                cdt.Client_Document_6__c = att.id;
                cdt.Client_Document_6_Type__c = ATTACHMENT;
                cdt.Client_Document_6_Name__c = att.Name;
                cdt.Client_Document_6_Label__c = att.Name;
            }
            when 'DOCUMENT7'{
                cdt.Client_Document_7__c = att.id;
                cdt.Client_Document_7_Type__c = ATTACHMENT;
                cdt.Client_Document_7_Name__c = att.Name;
                cdt.Client_Document_7_Label__c = att.Name;
            }
            when 'DOCUMENT8'{
                cdt.Client_Document_8__c = att.id;
                cdt.Client_Document_8_Type__c = ATTACHMENT;
                cdt.Client_Document_8_Name__c = att.Name;
                cdt.Client_Document_8_Label__c = att.Name;
            }
            when 'DOCUMENT9'{
                cdt.Client_Document_9__c = att.id;
                cdt.Client_Document_9_Type__c = ATTACHMENT;
                cdt.Client_Document_9_Name__c = att.Name;
                cdt.Client_Document_9_Label__c = att.Name;
            }
            when 'DOCUMENT10'{
                cdt.Client_Document_10__c = att.id;
                cdt.Client_Document_10_Type__c = ATTACHMENT;
                cdt.Client_Document_10_Name__c = att.Name;
                cdt.Client_Document_10_Label__c = att.Name;
            }
            when 'DOCUMENT11'{
                cdt.Client_Document_11__c = att.id;
                cdt.Client_Document_11_Type__c = ATTACHMENT;
                cdt.Client_Document_11_Name__c = att.Name;
                cdt.Client_Document_11_Label__c = att.Name;
            }
            when 'DOCUMENT12'{
                cdt.Client_Document_12__c = att.id;
                cdt.Client_Document_12_Type__c = ATTACHMENT;
                cdt.Client_Document_12_Name__c = att.Name;
                cdt.Client_Document_12_Label__c = att.Name;
            }
            when 'DOCUMENT13'{
                cdt.Client_Document_13__c = att.id;
                cdt.Client_Document_13_Type__c = ATTACHMENT;
                cdt.Client_Document_13_Name__c = att.Name;
                cdt.Client_Document_13_Label__c = att.Name;
            }
            when 'DOCUMENT14'{
                cdt.Client_Document_14__c = att.id;
                cdt.Client_Document_14_Type__c = ATTACHMENT;
                cdt.Client_Document_14_Name__c = att.Name;
                cdt.Client_Document_14_Label__c = att.Name;
            }
            when 'DOCUMENT15'{
                cdt.Client_Document_15__c = att.id;
                cdt.Client_Document_15_Type__c = ATTACHMENT;
                cdt.Client_Document_15_Name__c = att.Name;
                cdt.Client_Document_15_Label__c = att.Name;
            }
            when 'DOCUMENT16'{
                cdt.Client_Document_16__c = att.id;
                cdt.Client_Document_16_Type__c = ATTACHMENT;
                cdt.Client_Document_16_Name__c = att.Name;
                cdt.Client_Document_16_Label__c = att.Name;
            }
            when 'DOCUMENT17'{
                cdt.Client_Document_17__c = att.id;
                cdt.Client_Document_17_Type__c = ATTACHMENT;
                cdt.Client_Document_17_Name__c = att.Name;
                cdt.Client_Document_17_Label__c = att.Name;
            }
            when 'DOCUMENT18'{
                cdt.Client_Document_18__c = att.id;
                cdt.Client_Document_18_Type__c = ATTACHMENT;
                cdt.Client_Document_18_Name__c = att.Name;
                cdt.Client_Document_18_Label__c = att.Name;
            }
            when 'DOCUMENT19'{
                cdt.Client_Document_19__c = att.id;
                cdt.Client_Document_19_Type__c = ATTACHMENT;
                cdt.Client_Document_19_Name__c = att.Name;
                cdt.Client_Document_19_Label__c = att.Name;
            }
            when 'DOCUMENT20'{
                cdt.Client_Document_20__c = att.id;
                cdt.Client_Document_20_Type__c = ATTACHMENT;
                cdt.Client_Document_20_Name__c = att.Name;
                cdt.Client_Document_20_Label__c = att.Name;
            }
            when else {
                
            }
        }
        return cdt;
    }

    public static void loadDocumentTrackerForOlderDocuments(Integer intRecordLimit){
        Map<Id,ContentDocumentLink> mapContentDocumentLinksToProcess = new Map<Id,ContentDocumentLink>();
        Map<Id,Attachment> mapAttachmentsToProcess = new Map<Id,Attachment>();
        Set<Id> setIdsWithAttachments = new Set<Id>();

        // get labs without a client document tracker record (not processed yet) - limit to 500
        List<Lab__c> lstLabsToProcess = [
            SELECT Id 
            FROM Lab__c 
            WHERE (Id NOT IN (SELECT Lab__c FROM Client_Document_Tracker__c)) 
            AND Cord_Blood_Order__r.fw1__Is_Voided__c = FALSE
            LIMIT :intRecordLimit];

        Set<Id> setLabIds = new Set<Id>();
        Set<Id> setParentIds = new Set<Id>();

        // for each lab - get contentDocumentlinks and call the updateDocumentTracker method
        for(Lab__c lab : lstLabsToProcess){
            setLabIds.add(lab.Id);
            setParentIds.add(lab.Id);
        }

        for(Baby__c fm: [SELECT Id, Lab__c FROM Baby__c WHERE Lab__c in :setLabIds]){
            setParentIds.add(fm.Id);
        }

        for(ContentDocumentLink cdl: [SELECT Id, LinkedEntityId, ContentDocument.Title, ContentDocument.FileExtension, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId in :setParentIds ORDER BY LinkedEntityId, ContentDocument.LatestPublishedVersion.createddate ASC]){
            mapContentDocumentLinksToProcess.put(cdl.Id,cdl);
            setIdsWithAttachments.add(cdl.LinkedEntityId);
        }
        for(Attachment att: [SELECT Id, Name, ParentID FROM Attachment WHERE Parentid in :setParentIds ORDER BY ParentId, CREATEDDATE ASC]){
            mapAttachmentsToProcess.put(att.Id,att);
            setIdsWithAttachments.add(att.ParentId);
        }
        insertCDTForLabsWithoutDocuments(setLabIds,setIdsWithAttachments);
        AttachmentTriggerHelper.updateClientDocumentTracker(mapAttachmentsToProcess);
        ContentDocumentLinkHelper.updateClientDocumentTracker(mapContentDocumentLinksToProcess);

    }
    
    private static void insertCDTForLabsWithoutDocuments(Set<Id> setLabIds, Set<Id> setIdsWithAttachments){
        List<Client_Document_Tracker__c> lstCDTToInsert = new List<Client_Document_Tracker__c>();
        for(Id labId : setLabIds){
            Client_Document_Tracker__c cdt = new Client_Document_Tracker__c(Lab__c = labId);
            lstCDTToInsert.add(cdt);
        }
        if(lstCDTToInsert.size()>0){
            insert lstCDTToInsert;
        }
    }
}