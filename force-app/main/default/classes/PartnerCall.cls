/**
* PartnerCall
* ------------------
* @author Jason Seibert
*/
public with sharing class PartnerCall {

    /**
    * sendCallToImpact
    * -------
    * @param lstCallIds List of a List of Task Ids to Proecss
    */
    @InvocableMethod(label='sendCallToImpact' description='This method will send the call data to Impact for processing.')
    public static void sendCallToImpact(List<List<String>> lstCallIds){
        List<Task> lstTasksToProcess = new List<Task>();
        List<String> lstTaskIds = new List<String>();       
        List<Id> lstWhatIds = new List<Id>(); 
        List<Opportunity> lstOpps = new List<Opportunity>();
        Map<Id,Opportunity> mapOpportunities = new Map<Id,Opportunity>();

        // fetch partner custom metadata settings
        Americord_Partner_Setting__mdt partnerSettings = [SELECT
                              Call_Action_Tracker_Id__c, 
                              Campaign_Id__c,
                              Conversion_Action_Tracker_ID__c                         
                              FROM  Americord_Partner_Setting__mdt
                              LIMIT 1];

        /// get Task Id List
        for(List<String> lstIds :  lstCallIds){
            lstTaskIds.addAll(lstIds);
        }

        System.debug('List of Task Ids to Process:'+lstTaskIds);

        // query task recs
        lstTasksToProcess = [
            SELECT 
            Id, 
            Call_Duration_min__c, 
            CreatedDate, 
            aircall__Phone_number__c, 
            aircall__External_contact_phone_number__c, 
            aircall__Waiting_Time__c, 
            whatid, 
            whoid
            FROM TASK WHERE Id in :lstTaskIds
        ];  
        
        // build whatid list 
        for(Task t: lstTasksToProcess){
            lstWhatIds.add(t.whatid);
        }

        // Query Opps using whatid list
        lstOpps = [
            SELECT 
            Id,Campaign_LT__c,Campaign_FT__c
            FROM
            Opportunity
            where id in :lstWhatIds            
        ];
        mapOpportunities.putAll(lstOpps);

        //loop over tasks and call sendCall
        for(Task t: lstTasksToProcess){            
            String strBody;
            strBody  = 'CampaignId='+partnerSettings.Campaign_Id__c;
            strBody += '&EventDate='+t.CreatedDate;
            strBody += '&MediaId='+1111; 
            strBody += '&ActionTrackerId='+partnerSettings.Call_Action_Tracker_Id__c;
            strBody += '&CallProvider='+t.whoid; 
            strBody += '&CallSessionId='+t.id;
            strBody += '&CallerId='+t.aircall__External_contact_phone_number__c;
            strBody += '&Calledphonenumber='+t.aircall__Phone_number__c;
            strBody += '&CallDuration='+t.Call_Duration_min__c;
            strBody += '&TalkDuration='+t.Call_Duration_min__c;        

            System.debug(strBody);
            sendCall(strBody);

        }


    }

    /**
    * sendCall
    * -------
    * @param strRequestBody String containing the key/value pairs for the call
    */
    @future(Callout=true)
    private static void sendCall(String strRequestBody){

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:ImpactLogCallData/calldata/logCallData'); // pulls endpoint from callout
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
                'Unable to send Call Log Data to Impact.', ex);
        }
        if (resp.getStatusCode() != 201 && resp.getStatusCode() != 200) {            
            System.debug('Impact callout failed. Status code:'+resp.getStatusCode()+' status:'+resp.getStatus()); // will log above   
            LogHandler.logHTTPResponse('PartnerCall', 'sendCall', 'Callout Failed. Examine Logs'+'Status:'+resp.getStatusCode()+'Status:'+resp.getStatus(), resp);   
            LogHandler.logException('PartnerCall', 'sendCall', 'Callout Failed. Examine Logs'+'Status:'+resp.getStatusCode()+'Status:'+resp.getStatus(), 0);            
        }              
    }
}