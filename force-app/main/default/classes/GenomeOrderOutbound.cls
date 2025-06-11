/**
* GenomeOrderOutbound
* ------------------
* @author jseibert
*/
public with sharing class GenomeOrderOutbound {
    public class GenomeOrderCalloutException extends Exception{}

    static final String SENT_TO_VERITAS = 'Sent To Veritas';
    static final String LAB_SENT_TO_VERITAS = 'Lab Info Sent To Veritas';
    static final String EMAIL_SENT_TO_CUSTOMER = 'Sent Customer Consent Email';
    static final String ERROR_SENDING_TO_VERITAS = 'Error: Order Callout Failed. Examine logs.';
    static final String VERITAS_NEW_ORDER = 'New Order';

    static final List<String> lstStatusOKToSendSample = new List<String>{EMAIL_SENT_TO_CUSTOMER,
                                                                        ERROR_SENDING_TO_VERITAS,
                                                                        SENT_TO_VERITAS,
                                                                        VERITAS_NEW_ORDER};
  

    /**
    * sendGenomeOrderWithBabyIds
    * -------
    * @param lstGenomeBabyRecords List of a List of Baby Ids to Proecss
    */
    @InvocableMethod(label='sendGenomeOrderWithBabyIds' description='This method will send the Genome Order for Processing Using the Baby Ids')
    public static void sendGenomeOrderWithBabyIds(List<List<String>> lstGenomeBabyRecords){
        List<String> lstBabyIds = new List<String>();
        List<Baby__c> lstBabyRecordsToProcess = new List<Baby__c>();

        /// get Baby Id List
        for(List<String> lstIds :  lstGenomeBabyRecords){
            lstBabyIds.addAll(lstIds);
        }

        System.debug('List of Baby Ids to Process:'+lstBabyIds);

        // query baby recs
        lstBabyRecordsToProcess = [
            SELECT 
            Id, Name, LPI_My_Genome__c, My_Genome_Order_Status__c, LPI_My_Newborn__c,My_Newborn_Order_Status__c,
            ISBT_My_Genome__c, ISBT_My_Newborn__c
            FROM Baby__c WHERE Id in :lstBabyIds
        ];

        // Loop For Each Baby and Send To Veritas
        for(Baby__c babyRec: lstBabyRecordsToProcess){         

            System.debug('lpimg:'+babyRec.LPI_My_Genome__c+'mgstatus:'+babyRec.My_Genome_Order_Status__c+'lpmn:'+babyRec.LPI_My_Newborn__c+'mnstatus:'+babyRec.My_Newborn_Order_Status__c);
            
            if (babyRec.LPI_My_Genome__c != null && 
                (babyRec.My_Genome_Order_Status__c == null || babyRec.My_Genome_Order_Status__c == ERROR_SENDING_TO_VERITAS) && 
                (babyRec.LPI_My_Newborn__c == null || 
                (babyRec.My_Newborn_Order_Status__c == LAB_SENT_TO_VERITAS || 
                babyRec.My_Newborn_Order_Status__c == EMAIL_SENT_TO_CUSTOMER))){ // mygenome set - initial order                                   
                sendOrder(babyRec.Id, 'MYGENOME',SENT_TO_VERITAS);
            }
            else if (babyRec.LPI_My_Newborn__c != null && 
                    (babyRec.My_Newborn_Order_Status__c == null || babyRec.My_Newborn_Order_Status__c == ERROR_SENDING_TO_VERITAS) && 
                    (babyRec.LPI_My_Genome__c == null || 
                    (babyRec.My_Genome_Order_Status__c == LAB_SENT_TO_VERITAS || 
                    babyRec.My_Genome_Order_Status__c == EMAIL_SENT_TO_CUSTOMER))){ // mynewborn set - intial order
                    sendOrder(babyRec.Id, 'MYNEWBORN',SENT_TO_VERITAS);

            }
            else if (babyRec.LPI_My_Newborn__c != null && 
                    (babyRec.My_Newborn_Order_Status__c == null || babyRec.My_Newborn_Order_Status__c == ERROR_SENDING_TO_VERITAS) && 
                    babyRec.LPI_My_Genome__c != null && 
                    (babyRec.My_Genome_Order_Status__c == null || babyRec.My_Genome_Order_Status__c == ERROR_SENDING_TO_VERITAS)){ // both set - initial order
                    sendOrder(babyRec.Id, 'MYGENOME',SENT_TO_VERITAS);
                    sendOrder(babyRec.Id, 'MYNEWBORN',SENT_TO_VERITAS);                
            }
            else if (babyRec.ISBT_My_Genome__c != null &&  lstStatusOKToSendSample.contains(babyRec.My_Genome_Order_Status__c) &&
                    (babyRec.ISBT_My_Newborn__c == null || babyRec.My_Newborn_Order_Status__c == LAB_SENT_TO_VERITAS)){ // mygenome ISBT set - order update
                        sendOrder(babyRec.Id, 'MYGENOME',LAB_SENT_TO_VERITAS);
             
            }
            else if (babyRec.ISBT_My_Newborn__c != null && lstStatusOKToSendSample.contains(babyRec.My_Newborn_Order_Status__c) && 
                    (babyRec.ISBT_My_Genome__c == null || babyRec.My_Genome_Order_Status__c == LAB_SENT_TO_VERITAS)){ // mynewborn ISBT set - order update
                        sendOrder(babyRec.Id, 'MYNEWBORN',LAB_SENT_TO_VERITAS);

            }    
            else if (babyRec.ISBT_My_Genome__c != null && lstStatusOKToSendSample.contains(babyRec.My_Newborn_Order_Status__c) && 
                    babyRec.ISBT_My_Newborn__c != null && lstStatusOKToSendSample.contains(babyRec.My_Genome_Order_Status__c)){ // both set - order update                        
                        sendOrder(babyRec.Id, 'MYGENOME',LAB_SENT_TO_VERITAS);
                        sendOrder(babyRec.Id, 'MYNEWBORN',LAB_SENT_TO_VERITAS);
            }    
                          

        }
            
    }

    /**
    * sendOrder
    * -------
    * @param babyRecord Baby record to send to Veritas
    * @param strOrderType Order type - MyGenome or MyNewborn
    */
    @future(Callout=true)
    private static void sendOrder(Id idBaby,String strOrderType,String strStatus){
        Boolean boolExceptionEncountered = false;
        String strOrderLevel;

        Baby__c babyRecord = [
            SELECT 
            Id, Name, LPI_My_Genome__c, My_Genome_Order_Status__c, LPI_My_Newborn__c,My_Newborn_Order_Status__c,
            ISBT_My_Genome__c, ISBT_My_Newborn__c,
            Baby_First_Name__c, Mother_s_First_Name__c, Mother_s_Last_Name__c,lab__r.Mother_s_Phone__c,
            lab__r.Shipping_Street__c,  lab__r.Shipping_City__c, lab__r.Shipping_State_new__c, lab__r.Shipping_Zip__c, lab__r.Shipping_Country__c,
            lab__r.Birth_Date_from_Courier__c,lab__r.Mothers_Date_Of_Birth__c,Collection_Date__c,
            Sex_of_Child__c,lab__r.Mothers_Email__c,
            lab__r.Cord_Blood_Order__r.My_Genome_Premium_Ordered__c, lab__r.Cord_Blood_Order__r.My_Genome_Standard_Ordered__c, 
            lab__r.Cord_Blood_Order__r.Newborn_Panel_Ordered__c,lab__r.Cord_Blood_Order__r.fw1__Invoice_Date__c
            FROM Baby__c WHERE Id = :idBaby        
        ];
        
        String strAuthToken = getAuthToken(strOrderType);

        HttpRequest req = new HttpRequest();

        // set endpoint depending on product and state
        if(strOrderType == 'MYGENOME' && babyRecord.ISBT_My_Genome__c != null){
            req.setEndpoint('callout:VeritasGenomeOrder/update_sample'); //TODO Get New Endpoint
        }
        else if(strOrderType == 'MYGENOME' && babyRecord.ISBT_My_Genome__c == null){
            req.setEndpoint('callout:VeritasGenomeOrder/order_create');
        }
        else if(strOrderType == 'MYNEWBORN' && babyRecord.ISBT_My_Newborn__c == null){
            req.setEndpoint('callout:VeritasNewbornOrder/order_create');
        }
        else if(strOrderType == 'MYNEWBORN' && babyRecord.ISBT_My_Newborn__c != null){
            req.setEndpoint('callout:VeritasNewbornOrder/order_create'); // this will be updated to update endpoing
        }

        if(strOrderType == 'MYGENOME' && babyRecord.Lab__r.Cord_Blood_Order__r.My_Genome_Premium_Ordered__c > 0){
            strOrderLevel = 'PREMIUM';
        }
        else if (strOrderType == 'MYGENOME' && babyRecord.Lab__r.Cord_Blood_Order__r.My_Genome_Standard_Ordered__c > 0){
            strOrderLevel = 'STANDARD';
        }
        else if (strOrderType == 'MYNEWBORN' && babyRecord.Lab__r.Cord_Blood_Order__r.Newborn_Panel_Ordered__c > 0){
            strOrderLevel = 'PANEL';
        }        
        
        System.debug('Endpoint:'+req.getEndpoint());
    
        req.setMethod('POST');
        req.setTimeout(30000); //30 seconds        
        req.setHeader('Authorization', 'Bearer '+ strAuthToken);
        req.setHeader('Content-Type', 'application/json');
    


        String strRequestBody = GenomeOrderHelper.constructGenomeOrder(babyRecord,strOrderType,strOrderLevel);
        req.setBody(strRequestBody);
    
        Http http = new Http();
        HttpResponse resp = new HttpResponse();
        String strException;
            
        try {
            resp = http.send(req);        
        }
        catch (Exception ex) {
            strException = ex.getMessage();
        }
        System.debug('response:'+resp.getBody());
        if((resp.getStatusCode() != 200 && resp.getStatusCode() != 201) || resp.getBody().contains('"statusCode": 400')){
            LogHandler.logHTTPResponse('GenomeOrderOutbound', 'sendOrder', 'Callout Failed. Examine Logs'+strException, resp);
            updateGenomeOrderValueSent(babyRecord, strOrderType, 'Error: Order Callout Failed. Examine logs.',null);
            }   
        else {
            if(strStatus == SENT_TO_VERITAS){
            String strSignupURL = GenomeOrderHelper.getSignupURLFromResponse(resp.getBody());
            updateGenomeOrderValueSent(babyRecord, strOrderType ,strStatus,strSignupURL);             
            }
            else if(strStatus == LAB_SENT_TO_VERITAS){
                updateGenomeOrderValueSent(babyRecord, strOrderType ,strStatus,null);             
            }
        }


    }


    /**
    * updateGenomeOrderValueSent
    * -------
    * @param babyRecordToUpdate Baby record that will have its status updated.
    * @param strOrderType Order type - MyGenome, MyNewborn 
    */
    public static void updateGenomeOrderValueSent(Baby__c babyRecordToUpdate, String strOrderType, String strStatus, String strSignupURL){
        if(strOrderType == 'MYGENOME'){
            babyRecordToUpdate.My_Genome_Order_Status__c = strStatus;
            if (strSignupURL != null){
                babyRecordToUpdate.My_Genome_Consent_URL__c = strSignupURL;
            }            
        }
        else if( strOrderType == 'MYNEWBORN'){
            babyRecordToUpdate.My_Newborn_Order_Status__c = strStatus;
            if (strSignupURL != null){
                babyRecordToUpdate.My_Newborn_Consent_URL__c = strSignupURL;
            }
        }

        try{
            update babyRecordToUpdate;
        }
        catch(Exception ex){
            LogHandler.logException('GenomeOrderOutbound', 'updateGenomeOrderValueSent', 'Update Baby Record Failed. Examine Logs'+ex.getMessage(),null);        
        }

        
    }

    /**
    * getAuthToken
    * -------
    * @return strAuthToken String of the Authentication Token
    */
    private static String getAuthToken(String strOrderType){
        String strAuthToken;
        String strBody;

        HttpRequest req = new HttpRequest();

        if(strOrderType == 'MYGENOME'){
            req.setEndpoint('callout:VeritasAuth/oauth2/token');
        }
        else if (strOrderType == 'MYNEWBORN'){
            req.setEndpoint('callout:VeritasAuthEU/oauth2/token');
        }

        req.setMethod('POST');
        strBody = 'grant_type=client_credentials';
        strBody +='&client_id={!$Credential.UserName}';
        strBody += '&client_secret={!$Credential.Password}'; 
        req.setBody(strBody);

        System.debug('reqbody:'+strBody);

        HttpResponse resp = new HttpResponse();
        Http h = new Http();
        resp = h.send(req);

        // Parse the JSON response
        if (resp.getStatusCode() != 201 && resp.getStatusCode() != 200) {            
            System.debug('Auth callout failed. Status code:'+resp.getStatusCode()+' status:'+resp.getStatus()); // will log above
        } else {
            map<string,Object> resultMap = (map<string,Object>)JSON.deserializeUntyped(resp.getBody());
            strAuthToken = (String)resultMap.get('access_token');         
        }

        return strAuthToken;
    }    

}