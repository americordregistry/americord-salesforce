public with sharing class ConsumerAffairsConversion {

    private class ConsumerAffairRecord{
        String conversion_uuid;
        String phone_number;
        Datetime sale_date;

        public ConsumerAffairRecord(String strConvUUID, String strPhone, Datetime dtEnrollDate)
        {
            conversion_uuid = strConvUUID;
            phone_number = strPhone;
            sale_date = dtEnrollDate;
        }
    }

    /**
    * sendConversionToConsumerAffairs
    * -------
    * @param lstOrderIds List of a List of Invoice/Cord Blood Order Ids to Proecss
    */
    @InvocableMethod(label='sendConversionToConsumerAffairs' description='This method will send the conversion data to Consumer Affairs for processing.')
    public static void sendConversionToConsumerAffairs(List<List<String>> lstIds){      
        List<String> lstOpportunityIds = new List<String>();  
        List<Opportunity> lstOpportunityRecordsToProcess = new List<Opportunity>();

        /// get Opportunity Id List
        for(List<String> lstOppIds :  lstIds){
            lstOpportunityIds.addAll(lstOppIds);
        } 

        System.debug('List of Opportunities Ids to Process:'+lstOpportunityIds); 

        // query opp recs
        lstOpportunityRecordsToProcess = [
            SELECT 
            Id,
            LastStageChangeDate,
            Consumer_Affairs_UUID__c,
            Phone__c,
            Contact2_Phone__c
            FROM Opportunity WHERE Id in :lstOpportunityIds
        ];    

        String strRequestBody = prepareRequestFromOpportunities(lstOpportunityRecordsToProcess);
        sendConversion(strRequestBody);
    }

    /**
     * prepareRequestFromOpportunities
     * -------------------------------
     */
    private static String prepareRequestFromOpportunities(List<Opportunity> lstOppForProcessing){
        List<ConsumerAffairRecord> lstConsumerAffairsRecords = new List<ConsumerAffairRecord>();
        String strRequestBody;
        for(Opportunity opp: lstOppForProcessing){
            if(opp.Phone__c != null ){
                lstConsumerAffairsRecords.add(new ConsumerAffairRecord(opp.Consumer_Affairs_UUID__c,opp.Phone__c,opp.LastStageChangeDate));
            }
            else if(opp.Contact2_Phone__c != null){
                lstConsumerAffairsRecords.add(new ConsumerAffairRecord(opp.Consumer_Affairs_UUID__c,opp.Contact2_Phone__c,opp.LastStageChangeDate));
            }
            else {
                System.debug('No Phone Number for Opp:'+opp.Id);
                LogHandler.logInformation('ConsumerAffairsConversion', 'prepareRequestFromOpportunities', 'No Email Provided for Opportunity:'+Opp.Id);
            }
            
        }
        strRequestBody = JSON.serialize(lstConsumerAffairsRecords);
        System.debug('Serialized JSON for request:'+strRequestBody);
        return strRequestBody;
    }
    /**
    * sendConversion
    * -------
    * @param strRequestBody Body containing the request key/value pairs
    */
    @future(Callout=true)
    private static void sendConversion(String strRequestBody){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:ConsumerAffairsConversion'); // pulls endpoint from callout
        System.debug('Endpoint:'+req.getEndpoint());
    
        req.setMethod('POST');
        req.setTimeout(30000); //30 seconds        
        req.setHeader('Content-Type', 'application/json'); 
    
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
            throw new ConsumerAffairsException(
                'Unable to send Conversion Log Data to Consumer Affairs.', ex);
        }
        if (resp.getStatusCode() != 201 && resp.getStatusCode() != 200) {            
            System.debug('Consumer Affairs callout failed. Status code:'+resp.getStatusCode()+' status:'+resp.getStatus()); // will log above   
            LogHandler.logHTTPResponse('ConsumerAffairsConversion', 'sendConversion', 'Callout Failed. Examine Logs'+'Status:'+resp.getStatusCode()+'Status:'+resp.getStatus(), resp);   
            LogHandler.logException('ConsumerAffairsConversion', 'sendConversion', 'Error sending conversion data. Check logs.'+resp.getStatusCode()+'Status:'+resp.getStatus(), 0);
        }  
           
                  
    }        
}