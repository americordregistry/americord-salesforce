public class Invoice {
    private Map<Id, Opportunity> opptyMap = new Map<Id, Opportunity>();
    private Map<Id, Contact> contactMap = new Map<Id, Contact>(); 
    private Map<Id, Contact> refContactMap = new Map<Id, Contact>(); 
    private Map<Id, fw1__PaymentProfile__c> accountProfileMap = new Map<Id, fw1__PaymentProfile__c>();
    private Map<Id, fw1__Payment__c>  opptyPaymentMap  = new Map<Id, fw1__Payment__c>();
    private Map<Id, Lab__c>  opptyLabMap  = new Map<Id, Lab__c>();
    private Map<Id, Id> newRefContactMap = new Map<Id, Id>(); 
        
    private id contactId_1;
    private id contactId_2;
    private Americord_Settings__c ams = Americord_Settings__c.getInstance(); 
   
    
    public void addOpportunityInfo(set<Id> opptyIds, List<fw1__Invoice__c> invs) { 
        List<Lab__c> labs = new List<Lab__c>();     
        List<fw1__PaymentProfile__c> payProfiles = new List<fw1__PaymentProfile__c>();

        RecordType rtOpportunityUpgrade = [SELECT Id FROM Recordtype WHERE DeveloperName = 'Upgrade' AND Sobjecttype = 'Opportunity' LIMIT 1];
                
        getOpportunities(opptyIds);  
        getOpptyContacts();
        
        for (Opportunity o : opptyMap.values()) {            
            whoAreTheParents(o) ;            
            if ((string.isNotEmpty(contactId_1) || string.isNotEmpty(contactId_2)) && rtOpportunityUpgrade != null) { 
                if (o.RecordtypeId != rtOpportunityUpgrade.Id){ // no labs for upgrades
                    labs.add(createLab(o));   
                }
                newRefContactMap.put(o.Id, contactId_1);
            }
        }
        
        if (labs.size() > 0) {
            insert labs;
            getLabs(opptyIds);
        }
        
        for (fw1__Invoice__c inv : invs) {             
            String strOpportunityId;
            if (string.isNotEmpty(inv.fw2__Opportunity__c)){
                strOpportunityId = inv.fw2__Opportunity__c;
            }
            else if (string.isNotEmpty(inv.Upgrade_Opportunity__c)){
                strOpportunityId = inv.Upgrade_Opportunity__c;
            }

            if (string.isNotEmpty(strOpportunityId)) {
                Opportunity oppty = opptyMap.get(strOpportunityId);
                Lab__c lab = opptyLabMap.get(strOpportunityId);
                                            
                setOpportunityInfo(oppty,inv);  
                fw1__PaymentProfile__c payProf = accountProfileMap.get(inv.fw1__Account__c);
                                                
                if (lab != null) {
                    inv.Lab__c = lab.id;
                    inv.fw1__Contact__c = lab.Contact__c;
                    inv.Contact_2__c = lab.Contact_2__c;
                }
                
                if (payProf != null) {                    
                    inv.fw1__Payment_Profile__c = payProf.Id;
                    payProf.fw1__Contact__c = inv.fw1__Contact__c;
                    if (lab != null)
                        payProf.fw1__Email__c = lab.Mothers_Email__c;
                    payProfiles.add(payProf);
                }                                                
            }
            if (string.isEmpty(inv.Price_Book__c))
                inv.Price_Book__c = ams.Current_Price_Book__c;
        }
                        
        if (payProfiles.size() > 0)
            update payProfiles;        
        
    }
    
    public void getOpportunities(set<Id> opptyIds) {
        if (opptyIds != null && opptyIds.size() > 0) {
            opptyMap.putAll([
                SELECT Id, RecordtypeId, Name,Baby_s_Due_Date__c,Bill_Surrogate_Company__c,Ecomm_Status__c,
                    Owner.Alias, Contact2__c,Number_of_Births__c,
                    OwnerId,Payment_Plans__c,Pricebook2Id,
                    Sales_Discount__c,Marketing_Discount__c,Owner.CommunityNickname,Surrogate_Company__c,
                    Surrogate_Liaison__c,Contact__c,fw1__Total_Paid_Amount__c,
                    Shipping_Country__c,Shipping_City__c,Shipping_Zip__c,Shipping_State_Province__c,
                    Shipping_Street__c,Alt_Shipping_Optional_Field__c,Contact2_Relation_to_Baby__c,Egg_Donor_Status__c,Hold_Shipment_Until__c,
                    Numeric_Births__c,Pre_existing_condition__c,Relation_to_Baby__c,Same_Day_Shipping_CS_Team__c,
                    Saturday_Delivery__c,Ship_Kit_to_Surrogate__c,Shipping_Label_Special_Instructions__c,
                    Shipping_Method_new__c,Sperm_Donor_Status__c,AccountId,
                    Surrogate_City__c,Surrogate_Email__c,Surrogate_FirstName__c,Surrogate_LastName__c,
                    Surrogate_Notes__c,Surrogate_Phone__c,Surrogate_Postal_Code__c,Surrogate_State_Province__c,
                    Surrogate_Street_Address__c,Surrogate__c,Opportunity_has_referrer__c,Number_of_Previous_Orders__c,
                    Referred_by_First_Name__c,Referred_by_Last_Name__c,Referred_by_email_address__c,Referring_Contact__c,
                    Dr_provided_info_about_Americord__c,Other_Family_Members_With_Service_Count__c,Total_Monthly_Fees_new__c,
                    Monthly_Payments_new__c,Additional_Amount_on_First_Payment__c,
                    (SELECT ID, Invoice__c, Amount__c, Percentage__c FROM Applied_Discounts__r),
                    (SELECT ID, Invoice__c FROM Applied_Bundles__r)
                FROM Opportunity
                WHERE Id IN :opptyIds]);  
        }
    }
    
    private void setOpportunityInfo(Opportunity oppty, fw1__Invoice__c inv) {
        if (string.isNotEmpty(inv.fw2__Opportunity__c) || string.isNotEmpty(inv.Upgrade_Opportunity__c)) {
            inv.Baby_s_Due_Date__c = oppty.Baby_s_Due_Date__c;
            inv.Bill_Surrogate_Company__c = oppty.Bill_Surrogate_Company__c;
            if (oppty.Ecomm_Status__c == 'Enrolled') {
                inv.Closing_Rep__c = 'Ecomm';
            } 

            inv.Closing_Rep__c = oppty.Owner.CommunityNickname;
            inv.Contact_2__c = oppty.Contact2__c;
            inv.Enroll_Date__c = Date.today();
            inv.Number_of_Births__c = oppty.Number_of_Births__c;
            inv.OwnerId = oppty.OwnerId;
            inv.Price_Book__c = oppty.Pricebook2Id;
            inv.Sales_rep__c = oppty.Owner.CommunityNickname;
            inv.Surrogate_Company__c = oppty.Surrogate_Company__c;
            inv.Surrogate_Liaison__c = oppty.Surrogate_Liaison__c;            
            inv.fw1__Account__c = oppty.AccountId;
            inv.fw1__Contact__c = oppty.Contact__c;
            if (oppty.Baby_s_Due_Date__c != null) inv.fw1__Invoice_Date__c = oppty.Baby_s_Due_Date__c;
            inv.fw1__Total_Paid_Amount__c = oppty.fw1__Total_Paid_Amount__c;
            inv.fw1__Shipping_Street__c = oppty.Shipping_Street__c;
            inv.fw1__Shipping_City__c = oppty.Shipping_City__c;
            inv.fw1__Shipping_State__c = oppty.Shipping_State_Province__c;
            inv.fw1__Shipping_Zip__c = oppty.Shipping_Zip__c;
            inv.fw1__Shipping_Country__c = oppty.Shipping_Country__c;
            inv.Marketing_Discount__c = oppty.Marketing_Discount__c;
            inv.Sales_Discount__c = oppty.Sales_Discount__c;
            inv.Total_Monthly_Fee_new__c = oppty.Total_Monthly_Fees_new__c;
            inv.Monthly_Payments_new__c = oppty.Monthly_Payments_new__c;
            inv.Additional_Amount_on_First_Payment__c = oppty.Additional_Amount_on_First_Payment__c;
        }
    }
    
    private Lab__c createLab(Opportunity oppty) {        
        Contact contact_1;
        Contact contact_2;
        
        if (string.isNotEmpty(contactId_1))
            contact_1 = contactMap.get(contactId_1);
        if (string.isNotEmpty(contactId_2))
            contact_2 = contactMap.get(contactId_2);
        
        Lab__c lab = new Lab__c();
        lab.Account__c = oppty.AccountId;
        lab.Opportunity__c = oppty.Id;
        lab.Baby_s_Due_Date_new__c = oppty.Baby_s_Due_Date__c;
        lab.Contact_2__c = contactId_2;
        lab.Contact__c = contactId_1;        
        lab.Dr_provided_info_about_Americord__c = oppty.Dr_provided_info_about_Americord__c;
        lab.Egg_Donor_Status__c = oppty.Egg_Donor_Status__c;
        
        if (contact_2 != null) {            
            lab.Father_s_First_Name__c = contact_2.FirstName;
            lab.Father_s_Last_Name__c = contact_2.LastName;
            lab.Father_s_Phone__c = contact_2.Phone;
            lab.Father_s_Email__c = contact_2.Email;
            lab.Relation_to_Baby_2__c = contact_2.Type__c;
        }
        
        if (contact_1 != null) {  
            lab.Mother_s_First_Name__c = contact_1.FirstName;
            lab.Mother_s_Last_Name__c = contact_1.LastName;
            lab.Mother_s_Phone__c = contact_1.Phone;
            lab.Mothers_Email__c = contact_1.Email;
            lab.Relation_to_Baby__c = contact_1.Type__c;
            lab.Ship_to_First_Name__c = contact_1.FirstName;
            lab.Ship_to_Last_Name__c  = contact_1.LastName;
            lab.Name = contact_1.FirstName + ' ' + contact_1.LastName + ' Lab' ;
        }
        
        lab.Hold_Shipment_Until__c = oppty.Hold_Shipment_Until__c;
        lab.Kit_Type__c = 'P';
        lab.Number_of_Births_new__c = oppty.Number_of_Births__c;
        lab.Number_of_Kits_FedEx__c = string.valueOf(oppty.Numeric_Births__c);
        lab.Pre_existing_condition__c = oppty.Pre_existing_condition__c;                
        lab.Saturday_Delivery__c = oppty.Saturday_Delivery__c;
        
        if (oppty.Same_Day_Shipping_CS_Team__c) {
            lab.Sender_Name__c = 'Client Service Dept (NYC)';
            lab.Shipping_Method__c = 'Same Day (CS Team)';
            lab.Collection_Kit_Status__c = 'Same Day (CS Team)';
        } else {
            lab.Sender_Name__c = 'Lab Shipped';
            lab.Shipping_Method__c = oppty.Shipping_Method_new__c;
            lab.Collection_Kit_Status__c = 'Ready to Ship';            
        }
        if (oppty.Hold_Shipment_Until__c != null) {
            lab.Collection_Kit_Status__c = 'On Hold';
        }
        
        if (!oppty.Surrogate__c  && !oppty.Ship_Kit_to_Surrogate__c ){
            lab.Ship_kit_to_Surrogate__c = oppty.Ship_Kit_to_Surrogate__c;        
            lab.Shipping_City__c = oppty.Shipping_City__c;
            lab.Shipping_Country_new__c = oppty.Shipping_Country__c;
            lab.Shipping_State_new__c = oppty.Shipping_State_Province__c;
            lab.Shipping_Street__c = oppty.Shipping_Street__c;
            lab.Shipping_Zip__c = oppty.Shipping_Zip__c; 
        }
        else {
            lab.Ship_kit_to_Surrogate__c = oppty.Ship_Kit_to_Surrogate__c;        
            lab.Shipping_City__c = oppty.Surrogate_City__c;
            lab.Shipping_State_new__c = oppty.Surrogate_State_Province__c;
            lab.Shipping_Street__c = oppty.Surrogate_Street_Address__c;
            lab.Shipping_Zip__c = oppty.Surrogate_Postal_Code__c;             
        }
       
        lab.Shipping_Label_Special_Instructions__c = oppty.Shipping_Label_Special_Instructions__c;        
        //lab.Shipping_Notes__c = oppty.Shipping_Notes__c;        
        lab.Sperm_Donor_Status__c = oppty.Sperm_Donor_Status__c;        
        lab.Surrogate__c = oppty.Surrogate__c;
        lab.Surrogates_First_Name__c = oppty.Surrogate_FirstName__c;
        lab.Surrogates_Last_Name__c = oppty.Surrogate_LastName__c;
        lab.Surrogates_Notes__c = oppty.Surrogate_Notes__c;
        lab.Surrogates_Phone__c = oppty.Surrogate_Phone__c;
        lab.Surrogates_Email__c = oppty.Surrogate_Email__c;
        lab.Surrogates_Street_Address__c = oppty.Surrogate_Street_Address__c;
        lab.Surrogates_City__c = oppty.Surrogate_City__c;
        lab.Surrogates_State__c = oppty.Surrogate_State_Province__c;        
        lab.Surrogates_Zip_Code__c = oppty.Surrogate_Postal_Code__c;

        return lab;
    }
    
    

/*    
    public void updateReturningClient(set<Id> accountIds) {
        List<Account> accts = new List<Account>();
        accts = [
            SELECT id,Name,Returning_Client__c
            FROM Account
            WHERE id in :accountIds
            AND Number_of_Orders__c > 2];
        
        if (accts != null && accts.size() > 0)  {
            for (Account a : accts) {
                a.Returning_Client__c = true;
            }
            update accts;
        }
             
            
    }
*/    
    public Contact updateContact(fw1__Invoice__c inv, Id refContactId) {        
        Contact c;
        if(string.isNotEmpty(inv.fw1__Contact__c)) {
            c = contactMap.get(inv.fw1__Contact__c);
            c.MailingStreet = inv.fw1__Shipping_Street__c;
            c.MailingCity = inv.fw1__Shipping_City__c;
            c.MailingState = inv.fw1__Shipping_State__c;
            c.MailingPostalCode = inv.fw1__Shipping_Zip__c;
            c.MailingCountry = inv.fw1__Shipping_Country__c;
            c.OwnerId = inv.OwnerId;
            c.First_CBO__c = inv.Id;
            c.Referring_Contact__c = refContactId;
            return c; 
        } else {
            return null;
        }
                
               
    }
    
       
    private void getOpptyContacts() {
        Set<id> contactIds = new Set<id>();
        for (Opportunity oppty : opptyMap.values()) {
            if(string.isNotEmpty(oppty.Contact__c))
                contactIds.add(oppty.Contact__c);
            
            if(string.isNotEmpty(oppty.Contact2__c))
                contactIds.add(oppty.Contact2__c);

        }
        getContacts(contactIds) ;
       
    }
    
    private void getContacts(Set<id> contactIds) {
         contactMap.putAll( [
            SELECT id,Name,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,
            FirstName,LastName,Email,AccountId,First_CBO__c,OwnerId,Type__c,Phone,
            Referrer__c,Referring_Contact__c
            FROM Contact
            WHERE id IN :contactIDs
        ]);
        
    }
    private void getRefContacts(Set<id> contactIds) {
        refContactMap.putAll( [
            SELECT id,Name,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,
            FirstName,LastName,Email,AccountId,First_CBO__c,OwnerId,Type__c,Phone,
            Referrer__c,Referring_Contact__c
            FROM Contact
            WHERE id IN :contactIDs
        ]);
        
    }
    
    private void whoAreTheParents(Opportunity oppty) {
        
        //mother and father or 2 mothers
        if (oppty.Relation_to_Baby__c == 'Mother' && 
            (oppty.Contact2_Relation_to_Baby__c == 'Father' || oppty.Contact2_Relation_to_Baby__c == 'Mother')) {
                contactId_1 = oppty.Contact__c;
                contactId_2 = oppty.Contact2__c;
            }
                               
        //mother and father
        if (oppty.Relation_to_Baby__c == 'Father' && oppty.Contact2_Relation_to_Baby__c == 'Mother') {          
            contactId_1 = oppty.Contact2__c;
            contactId_2 = oppty.Contact__c;
        }
                        
        //grandparent or other w/ mother or father
        if ((oppty.Relation_to_Baby__c == 'Grandparent' || oppty.Relation_to_Baby__c == 'Other') &&
            (oppty.Contact2_Relation_to_Baby__c == 'Father' || oppty.Contact2_Relation_to_Baby__c == 'Mother')){              
                contactId_1 = oppty.Contact2__c;
            }
        
        //1 mother or father
        if ((oppty.Relation_to_Baby__c == 'Father' || oppty.Relation_to_Baby__c == 'Mother') &&
            (string.isEmpty(oppty.Contact2_Relation_to_Baby__c) || oppty.Contact2_Relation_to_Baby__c == 'Grandparent' || oppty.Contact2_Relation_to_Baby__c == 'Other' )) {                
                contactId_1 = oppty.Contact__c;
            }
        
        //2 fathers
        if (oppty.Relation_to_Baby__c == 'Father' && oppty.Contact2_Relation_to_Baby__c == 'Father')  {             
            contactId_1 = oppty.Contact__c;
            contactId_2 = oppty.Contact2__c;
        }
    }
    
    public void getPaymentProfile(Set<Id> acctIds) {
        List<fw1__PaymentProfile__c> profiles = [
            SELECT Id,Name,fw1__Contact__c,fw1__Account__c,fw1__Email__c
            FROM fw1__PaymentProfile__c
            WHERE fw1__Account__c IN :acctIds
            AND fw1__UseAsDefault__c = true
        ] ;
        
        for (fw1__PaymentProfile__c payProf : profiles) {              
            accountProfileMap.put(payProf.fw1__Account__c,payProf);
        }
    }
    
    private void getOpptyPayment(Set<Id> opptyIds) {
        List<fw1__Payment__c> payments = [
            SELECT Id,Name,fw1__Contact__c,fw1__Invoice__c,fw1__Opportunity__c
            FROM fw1__Payment__c
            WHERE fw1__Opportunity__c IN :opptyIds
        ] ;
        
        for (fw1__Payment__c payment : payments) {              
            opptyPaymentMap.put(payment.fw1__Opportunity__c,payment);
        }
    }
    
    private void getLabs(Set<Id> opptyIds) {
        List<Lab__c> labs = [
            SELECT Id,Name,Contact__c,Cord_Blood_Order__c,Opportunity__c,Contact_2__c,
                Mothers_Email__c,Number_of_Births_new__c,Mother_s_Last_Name__c,Account__c
            FROM Lab__c
            WHERE Opportunity__c IN :opptyIds
        ] ;
        
        for (Lab__c lab : labs) {               
            opptyLabMap.put(lab.Opportunity__c,lab);
        }
    }
    
    private Baby__c createBaby(string babyName, Lab__c lab) {
        Baby__c baby = new Baby__c();
        baby.Lab__c = lab.Id;
        baby.Name = babyName;
        if (string.isNotEmpty(lab.Mother_s_Last_Name__c))
            baby.Name += ' ' + lab.Mother_s_Last_Name__c;
        baby.Account__c = lab.Account__c;
        baby.Contact__c = lab.Contact__c;
        
        return baby;   
    }
    
    public void doCreateLabProcess(List<fw1__Invoice__c> invs) {
        Set<Id> contactIds = new Set<Id>();
        Set<Id> opptyIds = new Set<Id>();
        Set<Id> refContactIds = new Set<Id>();
         
                
        List<fw1__Payment__c> payments = new List<fw1__Payment__c>();
        List<Baby__c> babies = new List<Baby__c>();
        List<Lab__c> labs = new List<Lab__c>();
        List<Contact> newRefContacts = new List<Contact>();
        List<Contact> updateRefContacts = new List<Contact>();
        List<Contact> updateInvoiceContact = new List<Contact>();
        List<Contact> combinedRefContacts = new List<Contact>();
        
        for (fw1__Invoice__c inv : invs) {                
            if (string.isNotEmpty(inv.fw2__Opportunity__c) && !inv.Upgrade__c) {                 
                opptyIds.add(inv.fw2__Opportunity__c); 
                if (string.isNotEmpty(inv.fw1__Contact__c))
                    contactIds.add(inv.fw1__Contact__c);
            }                
        }
        
        if (opptyIds.size() > 0 ) {   
            getContacts(contactIds);            
            getOpportunities(opptyIds);         
            getLabs(opptyIds);
            getOpptyPayment(opptyIds);
            
            for (Opportunity o : opptyMap.values()) {
                if (string.isNotEmpty(o.Referring_Contact__c)) {
                    refContactIds.add(o.Referring_Contact__c);
                }
            }
            if (refContactIds.size() > 0) {
                getRefContacts(refContactIds);
            }
            for (fw1__Invoice__c inv : invs) { 
                Opportunity oppty = opptyMap.get(inv.fw2__Opportunity__c);
                
                fw1__Payment__c payment = opptyPaymentMap.get(inv.fw2__Opportunity__c);
                Lab__c lab = opptyLabMap.get(inv.fw2__Opportunity__c);
                Contact c = updateContact(inv,oppty.Referring_Contact__c);
                if (c!=null) {
                    updateInvoiceContact.add(updateContact(inv,oppty.Referring_Contact__c));
                }
                
                
                
                if (payment != null) {                    
                    payment.fw1__Contact__c = inv.fw1__Contact__c;
                    payment.fw1__Invoice__c = inv.Id;
                    payments.add(payment);
                }
                
                if (lab != null && lab.Number_of_Births_new__c != null) {
                    if (lab.Number_of_Births_new__c.contains('Single')) {
                        babies.add(createBaby('Baby',lab));
                    }
                    if (lab.Number_of_Births_new__c.contains('Twins')) {
                        babies.add(createBaby('Baby A',lab));
                        babies.add(createBaby('Baby B',lab));
                    }
                    if (lab.Number_of_Births_new__c.contains('Triplets')) {
                        babies.add(createBaby('Baby A',lab));
                        babies.add(createBaby('Baby B',lab));
                        babies.add(createBaby('Baby C',lab));
                    }

                    // Create Family Member Records if needed
                    if (oppty.Other_Family_Members_With_Service_Count__c>0) {
                        for (Integer i=1; i<=oppty.Other_Family_Members_With_Service_Count__c; i++) {
                            babies.add(createBaby('Family Member '+i,lab));
                        }
                    }

                    lab.Cord_Blood_Order__c = inv.id;
                    labs.add(lab);
                }
                
                Contact refContact = addReferrer(oppty,inv.id);
                if (refContact != null) {
                    if (string.isNotEmpty(refContact.Id))
                        updateRefContacts.add(refContact);
                    else
                        newRefContacts.add(refContact);
                }
                
            }
        }
         
        
        if (babies.size() > 0){
            insert babies;
        }
        
        if (newRefContacts.size() > 0){
            System.debug('newRefContacts: '+newRefContacts);
            insert newRefContacts;
        }
        
        if (payments.size() > 0){
            update payments;
        }
                        
        if (labs.size() > 0){
            update labs;
        }
        
        if (updateRefContacts.size() > 0){
            update updateRefContacts;
        }
        
        if (updateInvoiceContact.size() > 0) {
            Id refContactId;            
            for (Contact c : updateInvoiceContact) {
                if (c!=null) {
                    combinedRefContacts.addAll(updateRefContacts);
                    combinedRefContacts.addAll(newRefContacts);
                    System.debug('combinedRefContacts: '+combinedRefContacts);
                    System.debug('c: '+c);
                    refContactId = getRefContactByCBOId(combinedRefContacts,c.First_CBO__c);
                    if (refContactId != null){
                        c.Referring_Contact__c = refContactId;
                    }
                }
            }
            if (updateInvoiceContact!=null && updateInvoiceContact.size()>0) {
                update updateInvoiceContact;
            }
            
        }
                         
    }
    
    private id getRefContactByCBOId(List<Contact> refcontacts, id cboId) {
        for (Contact c : refcontacts) {
            if (c.First_CBO__c == cboId){
                return c.Id;
            }
        }
        return null;
        
    }
                            
    private Contact getContactByEmail(string email) {
        List<Contact> contacts = [
            SELECT Id,Name,Referrer__c,First_CBO__c,Referring_Contact__c
            FROM Contact
            WHERE Email = :email];
        
        if (contacts != null && contacts.size() > 0)
            return contacts[0];
        else
            return null;
                                
    }
    
    private Contact addReferrer(Opportunity oppty, string invoiceId) {
        Contact c;
        if (oppty.Opportunity_has_referrer__c && oppty.Number_of_Previous_Orders__c < 2  ) {
            
            if (string.isNotEmpty(oppty.Referring_Contact__c)) {
                c = refContactMap.get(oppty.Referring_Contact__c);
            } else {
                if (string.isNotEmpty(oppty.Referred_by_email_address__c)){
                    c = getContactByEmail(oppty.Referred_by_email_address__c);
                    if (c == null) {
                        c = new Contact();
                        c.AccountId = ams.Ambassador_Account_ID__c;
                        c.Email = oppty.Referred_by_email_address__c;
                        c.FirstName = oppty.Referred_by_First_Name__c;
                        c.LastName = oppty.Referred_by_Last_Name__c;                           
                    }
                }
            }
            c.Referrer__c = true;
            c.First_CBO__c = invoiceId;
            /*
            if (string.isNotEmpty(oppty.LeadSource))
                c.LeadSource = oppty.LeadSource;
            else
                c.LeadSource = 'Client Referral';
            */
            //c.Referring_Contact__c = oppty.Referring_Contact__c;
            
            
        }
        return c;
    }    
}