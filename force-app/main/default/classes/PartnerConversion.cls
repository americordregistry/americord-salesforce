public with sharing class PartnerConversion {

    /**
    * sendConversionToImpact
    * -------
    * @param lstOrderIds List of a List of Invoice/Cord Blood Order Ids to Proecss
    */
    @InvocableMethod(label='sendConversionToImpact' description='This method will send the conversion data to Impact for processing.')
    public static void sendConversionToImpact(List<List<String>> lstIds){    
        List<fw1__Invoice__c> lstOrdersToProcess = new List<fw1__Invoice__c>();
        List<String> lstOrderIds = new List<String>();        
        List<Id> lstOppIds = new List<Id>();       
        List<Opportunity> lstOpps = new List<Opportunity>();
        Map<Id,Opportunity> mapOpportunities = new Map<Id,Opportunity>();        

        // fetch partner custom metadata settings
        Americord_Partner_Setting__mdt partnerSettings = [SELECT
                              Call_Action_Tracker_Id__c, 
                              Campaign_Id__c,
                              Conversion_Action_Tracker_ID__c                         
                              FROM  Americord_Partner_Setting__mdt
                              LIMIT 1];

        /// get Order Id List
        for(List<String> lstCBOIds :  lstIds){
            lstOrderIds.addAll(lstCBOIds);
        }                              

        System.debug('List of Invoices/Orders Ids to Process:'+lstOrderIds);        

        // query task recs
        lstOrdersToProcess = [
            SELECT 
            Id,
            fw1__Opportunity__c,fw1__Total_Invoice_Amount__c,fw1__Shipping_City__c,fw1__Shipping_State__c,
            lastmodifieddate
            FROM fw1__Invoice__c WHERE Id in :lstOrderIds
        ];          

        // build Opportunity Id list 
        for(fw1__Invoice__c ord: lstOrdersToProcess){
            lstOppIds.add(ord.fw1__Opportunity__c);
        }        

        // Query Opps using oppid list
        lstOpps = [
            SELECT 
            Id,Impact_Partner_Id__c, Phone__c,Email__c
            FROM
            Opportunity
            where id in :lstOppIds            
        ];
        mapOpportunities.putAll(lstOpps);       
        
        //loop over Orders and call sendConversion
        for(fw1__Invoice__c ord: lstOrdersToProcess){            
            
            Opportunity opp = mapOpportunities.get(ord.fw1__Opportunity__c);

            //SHA1 hash of email
            Blob blobEmail = Blob.valueOf(opp.email__c);
            Blob blobEmailHash = Crypto.generateDigest('SHA1', blobEmail);
            String strEmailSHA1HashHex = EncodingUtil.convertToHex(blobEmailHash);
            
            String strBody;
            strBody  = 'CampaignId='+(integer)partnerSettings.Campaign_Id__c;
            strBody += '&EventDate='+ord.lastmodifieddate.format('dd-MMM-yyyy HH:mm:ss z');
            strBody += '&ActionTrackerId='+(integer)partnerSettings.Conversion_Action_Tracker_ID__c;
            strBody += '&MediaId='+opp.Impact_Partner_Id__c;
            strBody += '&OrderId='+ord.Id;            
            strBody += '&CustomerId='+opp.Id;
            strBody += '&Email='+strEmailSHA1HashHex;
            strBody += '&OrderSubTotalPostDiscount='+ord.fw1__Total_Invoice_Amount__c;
            strBody += '&CustomerCity='+ord.fw1__Shipping_City__c;
            strBody += '&CustomerRegion='+ord.fw1__Shipping_State__c;   

            System.debug(strBody);
            sendConversion(strBody); 
            
        }    
        
        

    }
    /**
    * sendOrder
    * -------
    * @param strRequestBody Body containing the request key/value pairs
    */
    @future(Callout=true)
    private static void sendConversion(String strRequestBody){

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:ImpactLogConversionData'); // pulls endpoint from callout
        System.debug('Endpoint:'+req.getEndpoint());
    
        req.setMethod('POST');
        req.setTimeout(30000); //30 seconds        
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded'); 
    
        req.setBody(strRequestBody);
    
        Http http = new Http();
        HttpResponse resp = new HttpResponse();
        String strException;

        try {
            resp = http.send(req);        
            System.debug('response:'+resp.getBody());
        }
        catch (Exception ex) {
            System.debug('response:'+resp.getBody());
            throw new PartnerException(
                'Unable to send Conversion Log Data to Impact.', ex);
        }
        if (resp.getStatusCode() != 201 && resp.getStatusCode() != 200) {            
            System.debug('Impact callout failed. Status code:'+resp.getStatusCode()+' status:'+resp.getStatus()); // will log above   
            LogHandler.logHTTPResponse('PartnerConversion', 'sendConversion', 'Callout Failed. Examine Logs'+'Status:'+resp.getStatusCode()+'Status:'+resp.getStatus(), resp);   
            LogHandler.logException('PartnerConversion', 'sendConversion', 'Error sending conversion data. Check logs.'+resp.getStatusCode()+'Status:'+resp.getStatus(), 0);
        }    
                  
    }        
}