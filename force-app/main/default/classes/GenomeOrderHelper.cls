public with sharing class GenomeOrderHelper {
    /**
    * constructGenomeOrder
    * -------
    * @param babyRecord Baby record to use for the order.
    * @param strOrderType Order type    
    * @param strOrderLevel Order level (Premium, Standard)
    * @return strBody Formatted body for callout.
    */
    public static String constructGenomeOrder(Baby__c babyRecord, String strOrderType, String strOrderLevel){
        String strBody;
        
        Americord_Integration_Setting__mdt americordIntegSetting = getCurrentIntegrationSettings();

        // HEADER
        GenomeOrder.GenomeOrderMessageHeaderResourceEventCoding genmsghdrec = new GenomeOrder.GenomeOrderMessageHeaderResourceEventCoding();
        genmsghdrec.system_AMERICORD = americordIntegSetting.Genome_Header_System__c;
        genmsghdrec.code = americordIntegSetting.Genome_Header_Code__c ;

        GenomeOrder.GenomeOrderMessageHeaderSource genmsghdsrc = new GenomeOrder.GenomeOrderMessageHeaderSource();
        genmsghdsrc.endpoint = americordIntegSetting.Genome_Header_Endpoint__c;

        GenomeOrder.GenomeOrderMessageHeaderResource genmsghdres = new GenomeOrder.GenomeOrderMessageHeaderResource();
        genmsghdres.eventCoding = genmsghdrec;
        genmsghdres.source = genmsghdsrc;
        genmsghdres.resourceType = 'MessageHeader';

        GenomeOrder.GenomeOrderMessageHeader genmsghdr = new GenomeOrder.GenomeOrderMessageHeader();
        genmsghdr.fullUrl = americordIntegSetting.Genome_Header_FullURL__c;
        genmsghdr.resource = genmsghdres;

        // PATIENT
        GenomeOrder.GenomePatientIdentifier genpid = new GenomeOrder.GenomePatientIdentifier();
        if (strOrderType == 'MYGENOME'){
            genpid.value = babyRecord.LPI_My_Genome__c;
        }
        if (strOrderType == 'MYNEWBORN') {
            genpid.value = babyRecord.LPI_My_Newborn__c;
        }

        GenomeOrder.GenomePatientName genpname = new GenomeOrder.GenomePatientName();
        List<String> lstGivenNames = new List<String>();     
        genpname.family = babyRecord.Mother_s_Last_Name__c;
        if(strOrderType == 'MYGENOME'){
            lstGivenNames.add(babyRecord.Mother_s_First_Name__c);
        }
        if(strOrderType == 'MYNEWBORN'){
            if (babyRecord.Baby_First_Name__c == null){
                lstGivenNames.add(babyRecord.Name.replace(' '+babyRecord.Mother_s_Last_Name__c, '')); //tricky subst here
            }
            else{
                lstGivenNames.add(babyRecord.Baby_First_Name__c);
            }            
        }
        genpname.given = lstGivenNames;

        GenomeOrder.GenomePatientTelecom genptel = new GenomeOrder.GenomePatientTelecom();
        genptel.system_AMERICORD = 'phone';
        genptel.value = babyRecord.Lab__r.Mother_s_Phone__c;

        GenomeOrder.GenomePatientTelecom genptelemail = new GenomeOrder.GenomePatientTelecom();
        genptelemail.system_AMERICORD = 'email';
        genptelemail.value = babyRecord.Lab__r.Mothers_Email__c;

        GenomeOrder.GenomePatientAddress genpadd = new GenomeOrder.GenomePatientAddress();
        List<String> lstAddressLine = new List<String>();
        lstAddressLine.add(babyRecord.Lab__r.Shipping_Street__c);
        genpadd.line = lstAddressLine;
        genpadd.city = babyRecord.Lab__r.Shipping_City__c;
        genpadd.state = babyRecord.Lab__r.Shipping_State_new__c;
        genpadd.postalCode = babyRecord.Lab__r.Shipping_Zip__c;
        genpadd.country = babyRecord.Lab__r.Shipping_Country__c;

        GenomeOrder.GenomePatientExtension genpext = new GenomeOrder.GenomePatientExtension();

        GenomeOrder.GenomePatientResource genpres = new GenomeOrder.GenomePatientResource();
        List<GenomeOrder.GenomePatientAddress> lstPatAddress = new List<GenomeOrder.GenomePatientAddress>();
        List<GenomeOrder.GenomePatientExtension> lstPatExt = new List<GenomeOrder.GenomePatientExtension>();
        List<GenomeOrder.GenomePatientIdentifier> lstPatId = new LIst<GenomeOrder.GenomePatientIdentifier>();
        List<GenomeOrder.GenomePatientName> lstPatName = new List<GenomeOrder.GenomePatientName>();
        List<GenomeOrder.GenomePatientTelecom> lstPatTel = new List<GenomeOrder.GenomePatientTelecom>();

        lstPatAddress.add(genpadd);
        genpres.address = lstPatAddress;

        lstPatExt.add(genpext);
        genpres.extension = lstPatExt;

        lstPatId.add(genpid);
        genpres.identifier = lstPatId;

        lstPatName.add(genpname);
        genpres.name = lstPatName;

        lstPatTel.add(genptel);
        lstPatTel.add(genptelemail);
        genpres.telecom = lstPatTel;

        if(strOrderType == 'MYGENOME'){
            genpres.birthDate = String.valueOf(babyRecord.Lab__r.Mothers_Date_Of_Birth__c);
            genpres.gender = 'Female';
        }
        if(strOrderType == 'MYNEWBORN'){
            if(babyRecord.Lab__r.Birth_Date_from_Courier__c == null){
                genpres.birthDate = String.valueOf(babyRecord.Lab__r.Cord_Blood_Order__r.fw1__Invoice_Date__c);
            }
            else{
                genpres.birthDate = String.valueOf(babyRecord.Lab__r.Birth_Date_from_Courier__c);
            }
            
            if(babyRecord.Sex_of_Child__c == null){
                genpres.gender = 'Unavailable';
            }
            else{
                genpres.gender = babyRecord.Sex_of_Child__c;
            }
            
        }        

        

        // DEMOGRAPHICS NOT USED - FILLING OUT OF COMPLETENESS
        GenomeOrder.GenomePatientExtension genpextdemorace = new GenomeOrder.GenomePatientExtension();
        GenomeOrder.GenomePatientExtension genpextdemoeth = new GenomeOrder.GenomePatientExtension();
        String strDemoRace = americordIntegSetting.Genome_Patient_Extension_Race__c;
        String strDemoEth = americordIntegSetting.Genome_Patient_Extension_Ethnicity__c;

        List<String> lstDemoRace = new List<String>();
        List<String> lstDemoEth = new List<String>();
        lstDemoRace.add(strDemoRace);        
        genpextdemorace.extension = lstDemoRace;
        genpextdemorace.url = americordIntegSetting.Genome_Patient_Extension_Race_URL__c;

        lstDemoEth.add(strDemoEth);
        genpextdemoeth.extension = lstDemoEth;
        genpextdemoeth.url = americordIntegSetting.Genome_Patient_Extension_Ethnicity_URL__c;

        genpres.extension.add(genpextdemorace);        
        genpres.extension.add(genpextdemoeth);

        genpres.resourceType = 'Patient';

        GenomeOrder.GenomePatient genp = new GenomeOrder.GenomePatient();
        genp.fullURL = americordIntegSetting.Genome_Patient_FullURL__c;
        genp.resource = genpres;        

        // SERIVCE REQUEST
        GenomeOrder.GenomeServiceRequestSubject gensrvreqsub = new GenomeOrder.GenomeServiceRequestSubject();
        if(strOrderType == 'MYGENOME'){
            gensrvreqsub.reference = 'Patient\\'+babyRecord.LPI_My_Genome__c;
        }
        if(strOrderType == 'MYNEWBORN'){
            gensrvreqsub.reference = 'Patient\\'+babyRecord.LPI_My_Newborn__c;
        }
        
        GenomeOrder.GenomeServiceRequestCodeEntry gensrvreqcodeentry_product = new GenomeOrder.GenomeServiceRequestCodeEntry();
        if(strOrderType == 'MYGENOME'){
            gensrvreqcodeentry_product.code=americordIntegSetting.Genome_Service_Request_Product_Code_MyG__c;
        }
        if(strOrderType == 'MYNEWBORN'){
            gensrvreqcodeentry_product.code=americordIntegSetting.Genome_Service_Request_Product_Code_MyN__c;
        }

        gensrvreqcodeentry_product.system_AMERICORD = americordIntegSetting.Genome_Service_Request_Product_System__c;

        GenomeOrder.GenomeServiceRequestCodeEntry gensrvreqcodeentry_program = new GenomeOrder.GenomeServiceRequestCodeEntry();

        if(strOrderType == 'MYGENOME' && strOrderLevel == 'STANDARD'){
            gensrvreqcodeentry_program.code=americordIntegSetting.Genome_Service_Request_Program_MyG_Stnd__c;    
        }
        else if (strOrderType == 'MYGENOME' && strOrderLevel == 'PREMIUM'){
            gensrvreqcodeentry_program.code=americordIntegSetting.Genome_Service_Request_Program_MyG_Prem__c;    
        }
        else if(strOrderType == 'MYNEWBORN' && strOrderLevel == 'PANEL'){
            gensrvreqcodeentry_program.code=americordIntegSetting.Genome_Service_Request_Program_MyN_Panel__c;  
        }
        
        gensrvreqcodeentry_program.system_AMERICORD = americordIntegSetting.Genome_Service_Request_Program_System__c;

        GenomeOrder.GenomeServiceRequestCodeEntry gensrvreqcodeentry_client = new GenomeOrder.GenomeServiceRequestCodeEntry();
        if(strOrderType == 'MYGENOME' && strOrderLevel == 'STANDARD'){
            gensrvreqcodeentry_client.code=americordIntegSetting.Genome_Service_Request_Client_Code__c; 
        }
        else if (strOrderType == 'MYGENOME' && strOrderLevel == 'PREMIUM'){
            gensrvreqcodeentry_client.code=americordIntegSetting.Genome_Service_Request_Client_Code__c;    
        }
        else if(strOrderType == 'MYNEWBORN' && strOrderLevel == 'PANEL'){
            gensrvreqcodeentry_client.code=americordIntegSetting.Genome_Service_Request_Client_Code_Nwbrn__c;  
        }        
        
        gensrvreqcodeentry_client.system_AMERICORD = americordIntegSetting.Genome_Service_Request_Client_System__c;
        
        GenomeOrder.GenomeServiceRequestCode gensrvreqcode = new GenomeOrder.GenomeServiceRequestCode();
        List<GenomeOrder.GenomeServiceRequestCodeEntry> lstCodeEntry = new List<GenomeOrder.GenomeServiceRequestCodeEntry>();
        lstCodeEntry.add(gensrvreqcodeentry_product);
        lstCodeEntry.add(gensrvreqcodeentry_program);
        lstCodeEntry.add(gensrvreqcodeentry_client);
        gensrvreqcode.coding = lstCodeEntry;

        GenomeOrder.GenomeServiceRequestResourceIdentifier gensrvreqresid = new GenomeOrder.GenomeServiceRequestResourceIdentifier();
        if(strOrderType == 'MYGENOME'){
            gensrvreqresid.value = babyRecord.LPI_My_Genome__c;
        }
        if(strOrderType == 'MYNEWBORN'){
            gensrvreqresid.value = babyRecord.LPI_My_Newborn__c;
        }

        GenomeOrder.GenomeServiceRequestResource gensrvreqres = new GenomeOrder.GenomeServiceRequestResource();
        List<GenomeOrder.GenomeServiceRequestResourceIdentifier> lstServReqResId = new List<GenomeOrder.GenomeServiceRequestResourceIdentifier>();
        lstServReqResId.add(gensrvreqresid);        
        gensrvreqres.resourceType = 'ServiceRequest';
        gensrvreqres.identifier = lstServReqResId;
        gensrvreqres.intent = americordIntegSetting.Genome_Service_Request_Resource_Intent__c;
        gensrvreqres.status = americordIntegSetting.Genome_Service_Request_Resource_Status__c;
        gensrvreqres.code = gensrvreqcode;
        gensrvreqres.subject = gensrvreqsub;

        GenomeOrder.GenomeServiceRequest gensrvreq = new GenomeOrder.GenomeServiceRequest();
        gensrvreq.fullUrl = americordIntegSetting.Genome_Service_Request_FullURL__c;
        gensrvreq.resource = gensrvreqres;        

        // PRACTITIONER -- not used but build out for complete message
        GenomeOrder.GenomePractitionerIdentifier genprid = new GenomeOrder.GenomePractitionerIdentifier();
        genprid.system_AMERICORD = null;
        genprid.value = null;
        List<GenomeOrder.GenomePractitionerIdentifier> lstgenprid = new List<GenomeOrder.GenomePractitionerIdentifier>();
        lstgenprid.add(genprid);

        GenomeOrder.GenomePractitionerName genprname = new GenomeOrder.GenomePractitionerName();
        genprname.family = null;
        List<String> lstPrGivenNames = new List<String>();
        genprname.given = lstPrGivenNames;
        
        List<GenomeOrder.GenomePractitionerName> lstgenprname = new List<GenomeOrder.GenomePractitionerName>();
        lstgenprname.add(genprname);

        GenomeOrder.GenomePractitionerResource genprres = new GenomeOrder.GenomePractitionerResource();
        GenomeOrder.GenomePracticioner genpr = new GenomeOrder.GenomePracticioner();
        genprres.identifier = lstgenprid;
        genprres.name = lstgenprname;
        genprres.resourceType = 'Practitioner';
        genpr.fullUrl = americordIntegSetting.Genome_Practitioner_FullURL__c;
        genpr.resource = genprres;
        
        // SPECIMEN
        GenomeOrder.GenomeSpecimenResourceCollection genspecrescol = new GenomeOrder.GenomeSpecimenResourceCollection();
        if(babyRecord.Collection_Date__c != null){
            genspecrescol.collectedDateTime = babyRecord.Collection_Date__c.year()+'-'+babyRecord.Collection_Date__c.month()+'-'+babyRecord.Collection_Date__c.day()+'T00:00:00.000Z'; //we dont have a datetime collection field
        }        

        GenomeOrder.GenomeSpecimenResourceTypeCoding genspecrestypecode = new GenomeOrder.GenomeSpecimenResourceTypeCoding();
        genspecrestypecode.code = americordIntegSetting.Genome_Specimen_Resource_Code_Code__c;
        genspecrestypecode.display = americordIntegSetting.Genome_Specimen_Resource_Code_Display__c;
        genspecrestypecode.system_AMERICORD = americordIntegSetting.Genome_Specimen_Resource_Code_System__c;

        GenomeOrder.GenomeSpecimenResourceType genspecrestype = new GenomeOrder.GenomeSpecimenResourceType();
        List<GenomeOrder.GenomeSpecimenResourceTypeCoding> lstspeccode = new List<GenomeOrder.GenomeSpecimenResourceTypeCoding>();
        lstspeccode.add(genspecrestypecode);
        genspecrestype.coding = lstspeccode;

        GenomeOrder.GenomeSpecimenResourceIdentifier genspecresid = new GenomeOrder.GenomeSpecimenResourceIdentifier();
        if(strOrderType == 'MYGENOME'){
            genspecresid.value = babyRecord.ISBT_My_Genome__c;
        }
        if(strOrderType == 'MYNEWBORN'){
            genspecresid.value = babyRecord.ISBT_My_Newborn__c;
        }

        GenomeOrder.GenomeSpecimenResource genspecres = new GenomeOrder.GenomeSpecimenResource();
        List<GenomeOrder.GenomeSpecimenResourceIdentifier> lstSpecResIds = new List<GenomeOrder.GenomeSpecimenResourceIdentifier>();
        lstSpecResIds.add(genspecresid);
        genspecres.collection = genspecrescol;
        genspecres.identifier = lstSpecResIds;
        genspecres.type = genspecrestype;
        genspecres.resourceType = 'Specimen';

        GenomeOrder.GenomeSpecimen genspec = new GenomeOrder.GenomeSpecimen();
        genspec.fullUrl = americordIntegSetting.Genome_Specimen_FullURL__c;
        genspec.resource = genspecres;

        // Build Entries
        List<String> lstEntry = new List<String>(); 

        lstEntry.add(cleanReservedWordsInString(JSON.serialize(genmsghdr)));
        lstEntry.add(cleanReservedWordsInString(JSON.serialize(genp)));
        lstEntry.add(cleanReservedWordsInString(JSON.serialize(gensrvreq)));
        lstEntry.add(cleanReservedWordsInString(JSON.serialize(genpr)));
        lstEntry.add(cleanReservedWordsInString(JSON.serialize(genspec)));

        

        // main message
        GenomeOrder.GenomeOrderMessage genmsg = new GenomeOrder.GenomeOrderMessage();
        genmsg.entry = lstEntry;
        genmsg.resourceType = 'Bundle';
        genmsg.type = 'message';

        strBody = cleanDoubleQuotesInJSONString(JSON.serialize(genmsg));
        
        System.debug('==== Genome Integration Values ====');
        System.debug('Order Type:'+strOrderType);
        System.debug('Order Level:'+strOrderLevel);
        System.debug('Client Code:'+gensrvreqcodeentry_client.code);
        System.debug('Program ID:'+gensrvreqcodeentry_program.code);
        System.debug('Genome FHIR Message:'+strBody);

        return strBody;
    }

    /**
    * clearReservedWordsInString
    * -------
    * @param strInput incoming string to clean
    * @return strReturnString return string cleaned
    */
    private static String cleanReservedWordsInString(String strInput){
        String strReturnString = strInput.replaceAll('_AMERICORD', '');
        strReturnString = strReturnString.replaceAll(':null', ':""');
        return strReturnString;
    }    

    /**
    * getSignupURLFromResponse
    * -------
    * @param strResponse Response from callout
    * @return strSignupURL URL that will be used to send to cusomer for singup.
    */
    public static String getSignupURLFromResponse(String strResponse){
        String strSignupURL;
        List<Map<String,Object>> mapEntryData = new List<Map<String,Object>>();
        List<Object> lstID = new List<Object>();
        List<Object> lstURL = new List<Object>();        
        String strResponseClean = cleanDoubleQuotesInJSONString(strResponse);
        Map<String,Object> mapResponse = (Map<String,Object>)JSON.deserializeUntyped(strResponseClean);
        Map<String,Object> mapBody = (Map<String,Object>)mapResponse.get('body');
        List<Object> lstEntry = (List<Object>)mapBody.get('entry');


        for(Object obj : lstEntry){
            mapEntryData.add((Map<String,Object>)obj);    
        }
        for(Map<String,Object> mapEntry : mapEntryData){
            for(String strKey :  mapEntry.keySet()){
                if(strKey == 'resourceType'){
                    if((String)mapEntry.get(strKey) == 'SignupURL'){
                        lstID = (List<Object>)mapEntry.get('identifier');
                    }
                    if(!lstID.isEmpty()){
                        Map<String,Object> mapURL = (Map<String,Object>)lstID[0];
                        strSignupURL = (String)mapURL.get('value');
                    }
                    
                }
            }
        }        

        return strSignupURL;
    }

    /**
    * cleanDoubleQuotesInJSONString
    * -------
    * @param strInput String to be cleaned
    * @return strReturnString String cleaned
    */
    private static String cleanDoubleQuotesInJSONString(String strInput){
        String strReturnString = strInput.replaceAll('\\\\', '');
        strReturnString = strReturnString.replaceAll('"\\{','\\{');
        strReturnString = strReturnString.replaceAll('\\}"','\\}');    
        return strReturnString;  
    }

    /**
    * getCurrentIntegrationSettings
    * -------
    * returns the custom metadata values for use in by apex.
    */
    private static Americord_Integration_Setting__mdt getCurrentIntegrationSettings(){
        Americord_Integration_Setting__mdt americordIntegSetting = [
            SELECT 
            Genome_Header_Code__c,
            Genome_Header_Endpoint__c,
            Genome_Header_FullURL__c,
            Genome_Header_System__c,
            Genome_Patient_Extension_Ethnicity__c,
            Genome_Patient_Extension_Ethnicity_URL__c,
            Genome_Patient_Extension_Race__c,
            Genome_Patient_Extension_Race_URL__c,
            Genome_Patient_FullURL__c,
            Genome_Practitioner_FullURL__c,
            Genome_Service_Request_Client_Code__c,
            Genome_Service_Request_Client_Code_Nwbrn__c,
            Genome_Service_Request_Client_System__c,
            Genome_Service_Request_FullURL__c,
            Genome_Service_Request_Product_Code_MyN__c,
            Genome_Service_Request_Product_Code_MyG__c,
            Genome_Service_Request_Product_System__c,
            Genome_Service_Request_Program_System__c,
            Genome_Service_Request_Resource_Intent__c,
            Genome_Service_Request_Resource_Status__c,
            Genome_Service_Request_Program_MyG_Prem__c,
            Genome_Service_Request_Program_MyG_Stnd__c,
            Genome_Service_Request_Program_MyN_Geno__c,
            Genome_Service_Request_Program_MyN_Panel__c,
            Genome_Specimen_FullURL__c,
            Genome_Specimen_Resource_Code_Code__c,
            Genome_Specimen_Resource_Code_Display__c,
            Genome_Specimen_Resource_Code_System__c
            FROM Americord_Integration_Setting__mdt 
            WHERE label = 'CurrentSettings' LIMIT 1];
            
            return americordIntegSetting;
    }
}