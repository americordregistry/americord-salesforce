/**
* GenomeOrderOutboundTest
* ------------------
* @author jseibert
*/
@isTest
private class GenomeOrderOutboundTest {

    static final String SENT_TO_VERITAS = 'Sent To Veritas';
    static final String LAB_SENT_TO_VERITAS = 'Lab Info Sent To Veritas';
    static final String EMAIL_SENT_TO_CUSTOMER = 'Sent Customer Consent Email';    

    
    @testSetup static void setup() {
        AmericordTestDataFactory testData = new AmericordTestDataFactory ();           
    } 

    @isTest
    private static void testSendMyGenome_Success() {
         // Create an account
         Account a = new Account();
         a.Name = 'Test Account';
         insert a;
         
         Account refAccount = new Account();
         refAccount.Name = 'Ref Account';
         insert refAccount;
         
         //create contact
         Contact c = new Contact();
         c.AccountId = a.Id;
         c.FirstName = 'testxx';
         c.LastName = 'testxx';
         c.Email = 'testxx@test.com';
         insert c;
         
         Americord_Settings__c ams = Americord_Settings__c.getOrgDefaults(); 
         ams.Ambassador_Account_ID__c = refAccount.id;
         update ams;
 
         User oppOwner = AmericordTestDataFactory.getCurrentSalesRep();
 
         // Create an opportunity
         Opportunity o = new Opportunity();
         o.Name = 'Test Opportunity';
         o.OwnerId = oppOwner.Id;
         o.StageName = 'Closed';
         o.CloseDate = Date.today();
         o.AccountId = a.Id;
         o.Number_of_Births__c = 'Single';
         o.Cord_Blood_2_0__c = 1;
         o.Storage_Plan__c = '20YPP';
         o.Payment_Plans__c = 'OTP';
         o.Contact__c = c.id;
         o.Email__c = 'mary@test.com';
         o.FirstName__c = 'Mary';
         o.LastName__c = 'Test';
         o.Relation_to_Baby__c = 'Mother';        
         o.Referred_by_email_address__c = 'john@test.com';
         o.Referred_by_First_Name__c = 'JOHN';
         o.Referred_by_Last_Name__c = 'DOE';
         o.Shipping_Street__c = '123 main st';
         o.Shipping_City__c = 'Chicago';
         o.Shipping_Country__c = 'US';
         o.Shipping_State_Province__c = 'IL';
         o.Shipping_Zip__c = '99999';
         o.Authorized_Payment__c = true;
         o.Cord_Tissue__c = 1;
         o.Placenta_2_0__c = 1;        
         o.Enrollment_Flow_Complete__c = true;
         insert o;
        
         o.StageName = 'Enrolled';
         update o;              

        // Set CBO to have My Genome
        fw1__Invoice__c cbo = getInvoice(o.Id);
        cbo.My_Genome_Premium_Ordered__c = 1;
        update cbo;

        // Set Lab to have My Genome Values
        Lab__c lab = getLab(cbo.Id);
        lab.Mothers_Email__c = 'bogus@somesite.com';
        lab.Mothers_Date_Of_Birth__c = System.Date.today();
        lab.Mother_s_Phone__c = '5555551212';
        lab.Shipping_Street__c = '123 Test Ln.';
        lab.Shipping_City__c = 'Testville';
        lab.Shipping_State_New__c = 'NY';
        lab.Shipping_Zip__c = '80403';
        lab.Shipping_Country__c = 'US';
        update lab;

        // Set Baby record to have LPL for MyGenome inserted
        Baby__c baby = [SELECT Id from Baby__c LIMIT 1];
        baby.LPI_My_Genome__c = '1234567';
        baby.Collection_Date__c = Date.today();

        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('callout:VeritasAuth/oauth2/token', 'GenomeMockResponseAuth');
        multimock.setStaticResource('callout:VeritasGenomeOrder/order_create', 'GenomeMockResponseOrder');    
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');   

        Test.setMock(HttpCalloutMock.class, multimock);

        update baby;
        List<String> lstBabyIds = new List<String>();
        List<List<String>> lstBaby = new List<List<String>>();
        lstBabyIds.add(baby.Id);
        lstBaby.add(lstBabyIds);

        Test.startTest();
        GenomeOrderOutbound.sendGenomeOrderWithBabyIds(lstBaby);
        Test.stopTest();

        baby = [SELECT Id, My_Genome_Order_Status__c FROM Baby__c LIMIT 1];

        // test to see if email flow is active
        FlowDefinitionView fdv = [SELECT isactive FROM FlowDefinitionView WHERE apiname ='Genome_Send_Customer_Email' LIMIT 1];
        if(fdv.isactive){
            System.assertEquals(EMAIL_SENT_TO_CUSTOMER,baby.My_Genome_Order_Status__c, 'My Genome Order Status Does Not Match Sent Message');
        }
        else{
            System.assertEquals(SENT_TO_VERITAS,baby.My_Genome_Order_Status__c, 'My Genome Order Status Does Not Match Sent Message');
        }
        
    }

    @isTest
    private static void testSendMyNewborn_Success() {
         // Create an account
         Account a = new Account();
         a.Name = 'Test Account';
         insert a;
         
         Account refAccount = new Account();
         refAccount.Name = 'Ref Account';
         insert refAccount;
         
         //create contact
         Contact c = new Contact();
         c.AccountId = a.Id;
         c.FirstName = 'testxx';
         c.LastName = 'testxx';
         c.Email = 'testxx@test.com';
         insert c;
         
         Americord_Settings__c ams = Americord_Settings__c.getOrgDefaults(); 
         ams.Ambassador_Account_ID__c = refAccount.id;
         update ams;
 
         User oppOwner = AmericordTestDataFactory.getCurrentSalesRep();
 
         // Create an opportunity
         Opportunity o = new Opportunity();
         o.Name = 'Test Opportunity';
         o.OwnerId = oppOwner.Id;
         o.StageName = 'Closed';
         o.CloseDate = Date.today();
         o.AccountId = a.Id;
         o.Number_of_Births__c = 'Single';
         o.Cord_Blood_2_0__c = 1;
         o.Storage_Plan__c = '20YPP';
         o.Payment_Plans__c = 'OTP';
         o.Contact__c = c.id;
         o.Email__c = 'mary@test.com';
         o.FirstName__c = 'Mary';
         o.LastName__c = 'Test';
         o.Relation_to_Baby__c = 'Mother';        
         o.Referred_by_email_address__c = 'john@test.com';
         o.Referred_by_First_Name__c = 'JOHN';
         o.Referred_by_Last_Name__c = 'DOE';
         o.Shipping_Street__c = '123 main st';
         o.Shipping_City__c = 'Chicago';
         o.Shipping_Country__c = 'US';
         o.Shipping_State_Province__c = 'IL';
         o.Shipping_Zip__c = '99999';
         o.Authorized_Payment__c = true;
         o.Cord_Tissue__c = 1;
         o.Placenta_2_0__c = 1;        
         o.Enrollment_Flow_Complete__c = true;
         insert o;
        
         o.StageName = 'Enrolled';
         update o;              

        // Set CBO to have My Genome
        fw1__Invoice__c cbo = getInvoice(o.Id);
        cbo.Newborn_Panel_Ordered__c = 1;
        update cbo;

        // Set Lab to have My Genome Values
        Lab__c lab = getLab(cbo.Id);
        lab.Mothers_Email__c = 'bogus@somesite.com';
        lab.Mothers_Date_Of_Birth__c = System.Date.today();
        lab.Mother_s_Phone__c = '5555551212';
        lab.Shipping_Street__c = '123 Test Ln.';
        lab.Shipping_City__c = 'Testville';
        lab.Shipping_State_New__c = 'NY';
        lab.Shipping_Zip__c = '80403';
        lab.Shipping_Country__c = 'US';
        lab.Birth_Date_from_Courier__c = System.Date.today();  
        lab.Contact__c = c.id;    
        lab.Account__c = refAccount.Id;              
        update lab;        

        // Set Baby record to have LPL for MyGenome inserted
        Baby__c baby = [SELECT Id from Baby__c LIMIT 1];
        baby.LPI_My_Newborn__c = '1234567';
        baby.Sex_of_Child__c = 'Female';

        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('callout:VeritasAuthEU/oauth2/token', 'GenomeMockResponseAuth');
        multimock.setStaticResource('callout:VeritasNewbornOrder/order_create', 'GenomeMockResponseOrder');    
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');   

        Test.setMock(HttpCalloutMock.class, multimock);

        update baby;
        List<String> lstBabyIds = new List<String>();
        List<List<String>> lstBaby = new List<List<String>>();
        lstBabyIds.add(baby.Id);
        lstBaby.add(lstBabyIds);

        Test.startTest();
        GenomeOrderOutbound.sendGenomeOrderWithBabyIds(lstBaby);
        Test.stopTest();

        baby = [SELECT Id, My_Newborn_Order_Status__c FROM Baby__c LIMIT 1];

        // test to see if email flow is active
        FlowDefinitionView fdv = [SELECT isactive FROM FlowDefinitionView WHERE apiname ='Genome_Send_Customer_Email' LIMIT 1];
        if(fdv.isactive){
            System.assertEquals(EMAIL_SENT_TO_CUSTOMER,baby.My_Newborn_Order_Status__c, 'My Genome Order Status Does Not Match Sent Message');
        }
        else{
            System.assertEquals(SENT_TO_VERITAS,baby.My_Newborn_Order_Status__c, 'My Genome Order Status Does Not Match Sent Message');
        }       
    }    

    @isTest
    static void testSendBothMyGenomeNewborn_Success(){
         // Create an account
         Account a = new Account();
         a.Name = 'Test Account';
         insert a;
         
         Account refAccount = new Account();
         refAccount.Name = 'Ref Account';
         insert refAccount;
         
         //create contact
         Contact c = new Contact();
         c.AccountId = a.Id;
         c.FirstName = 'testxx';
         c.LastName = 'testxx';
         c.Email = 'testxx@test.com';
         insert c;
         
         Americord_Settings__c ams = Americord_Settings__c.getOrgDefaults(); 
         ams.Ambassador_Account_ID__c = refAccount.id;
         update ams;
 
         User oppOwner = AmericordTestDataFactory.getCurrentSalesRep();
 
         // Create an opportunity
         Opportunity o = new Opportunity();
         o.Name = 'Test Opportunity';
         o.OwnerId = oppOwner.Id;
         o.StageName = 'Closed';
         o.CloseDate = Date.today();
         o.AccountId = a.Id;
         o.Number_of_Births__c = 'Single';
         o.Cord_Blood_2_0__c = 1;
         o.Storage_Plan__c = '20YPP';
         o.Payment_Plans__c = 'OTP';
         o.Contact__c = c.id;
         o.Email__c = 'mary@test.com';
         o.FirstName__c = 'Mary';
         o.LastName__c = 'Test';
         o.Relation_to_Baby__c = 'Mother';        
         o.Referred_by_email_address__c = 'john@test.com';
         o.Referred_by_First_Name__c = 'JOHN';
         o.Referred_by_Last_Name__c = 'DOE';
         o.Shipping_Street__c = '123 main st';
         o.Shipping_City__c = 'Chicago';
         o.Shipping_Country__c = 'US';
         o.Shipping_State_Province__c = 'IL';
         o.Shipping_Zip__c = '99999';
         o.Authorized_Payment__c = true;
         o.Cord_Tissue__c = 1;
         o.Placenta_2_0__c = 1;        
         o.Enrollment_Flow_Complete__c = true;
         insert o;
        
         o.StageName = 'Enrolled';
         update o;              

        // Set CBO to have My Genome
        fw1__Invoice__c cbo = getInvoice(o.Id);
        cbo.Newborn_Panel_Ordered__c = 1;
        cbo.My_Genome_Premium_Ordered__c = 1;
        update cbo;

        // Set Lab to have My Genome Values
        Lab__c lab = getLab(cbo.Id);
        lab.Mothers_Email__c = 'bogus@somesite.com';
        lab.Mothers_Date_Of_Birth__c = System.Date.today();
        lab.Mother_s_Phone__c = '5555551212';
        lab.Shipping_Street__c = '123 Test Ln.';
        lab.Shipping_City__c = 'Testville';
        lab.Shipping_State_New__c = 'NY';
        lab.Shipping_Zip__c = '80403';
        lab.Shipping_Country__c = 'US';
        lab.Birth_Date_from_Courier__c = System.Date.today();
        update lab;        

        // Set Baby record to have LPL for MyGenome inserted
        Baby__c baby = [SELECT Id from Baby__c LIMIT 1];
        baby.Sex_of_Child__c = 'Female';
        baby.LPI_My_Newborn__c = '1234567';
        baby.LPI_My_Genome__c = '7654321';

        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('callout:VeritasAuth/oauth2/token', 'GenomeMockResponseAuth');
        multimock.setStaticResource('callout:VeritasAuthEU/oauth2/token', 'GenomeMockResponseAuth');        
        multimock.setStaticResource('callout:VeritasGenomeOrder/order_create', 'GenomeMockResponseOrder');    
        multimock.setStaticResource('callout:VeritasNewbornOrder/order_create', 'GenomeMockResponseOrder');   
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');   

        Test.setMock(HttpCalloutMock.class, multimock);

        update baby;
        List<String> lstBabyIds = new List<String>();
        List<List<String>> lstBaby = new List<List<String>>();
        lstBabyIds.add(baby.Id);
        lstBaby.add(lstBabyIds);

        Test.startTest();
        GenomeOrderOutbound.sendGenomeOrderWithBabyIds(lstBaby);
        Test.stopTest();

        baby = [SELECT Id, My_Newborn_Order_Status__c,My_Genome_Order_Status__c FROM Baby__c LIMIT 1];

        // test to see if email flow is active
        FlowDefinitionView fdv = [SELECT isactive FROM FlowDefinitionView WHERE apiname ='Genome_Send_Customer_Email' LIMIT 1];
        if(fdv.isactive){
            System.assertEquals(EMAIL_SENT_TO_CUSTOMER,baby.My_Newborn_Order_Status__c, 'My Genome Order Status Does Not Match Sent Message');
            System.assertEquals(EMAIL_SENT_TO_CUSTOMER,baby.My_Genome_Order_Status__c, 'My Genome Order Status Does Not Match Sent Message');
        }
        else{
            System.assertEquals(SENT_TO_VERITAS,baby.My_Newborn_Order_Status__c, 'My Genome Order Status Does Not Match Sent Message');
            System.assertEquals(SENT_TO_VERITAS,baby.My_Genome_Order_Status__c, 'My Genome Order Status Does Not Match Sent Message');            
        }            
    }

    @isTest
    private static void testSendMyNewbornMultiple_Success() {
         // Create an account
         Account a = new Account();
         a.Name = 'Test Account';
         insert a;
         
         Account refAccount = new Account();
         refAccount.Name = 'Ref Account';
         insert refAccount;
         
         //create contact
         Contact c = new Contact();
         c.AccountId = a.Id;
         c.FirstName = 'testxx';
         c.LastName = 'testxx';
         c.Email = 'testxx@test.com';
         insert c;
         
         Americord_Settings__c ams = Americord_Settings__c.getOrgDefaults(); 
         ams.Ambassador_Account_ID__c = refAccount.id;
         update ams;
 
         User oppOwner = AmericordTestDataFactory.getCurrentSalesRep();
 
         // Create an opportunity
         Opportunity o = new Opportunity();
         o.Name = 'Test Opportunity';
         o.OwnerId = oppOwner.Id;
         o.StageName = 'Closed';
         o.CloseDate = Date.today();
         o.AccountId = a.Id;
         o.Number_of_Births__c = 'Twins';
         o.Cord_Blood_2_0__c = 1;
         o.Storage_Plan__c = '20YPP';
         o.Payment_Plans__c = 'OTP';
         o.Contact__c = c.id;
         o.Email__c = 'mary@test.com';
         o.FirstName__c = 'Mary';
         o.LastName__c = 'Test';
         o.Relation_to_Baby__c = 'Mother';        
         o.Referred_by_email_address__c = 'john@test.com';
         o.Referred_by_First_Name__c = 'JOHN';
         o.Referred_by_Last_Name__c = 'DOE';
         o.Shipping_Street__c = '123 main st';
         o.Shipping_City__c = 'Chicago';
         o.Shipping_Country__c = 'US';
         o.Shipping_State_Province__c = 'IL';
         o.Shipping_Zip__c = '99999';
         o.Authorized_Payment__c = true;
         o.Cord_Tissue__c = 1;
         o.Placenta_2_0__c = 1;        
         o.Enrollment_Flow_Complete__c = true;
         insert o;
        
         o.StageName = 'Enrolled';
         update o;              

        // Set CBO to have My Genome
        fw1__Invoice__c cbo = getInvoice(o.Id);
        cbo.Newborn_Panel_Ordered__c = 1;
        cbo.My_Genome_Premium_Ordered__c = 1;
        update cbo;

        // Set Lab to have My Genome Values
        Lab__c lab = getLab(cbo.Id);
        lab.Mothers_Email__c = 'bogus@somesite.com';
        lab.Mothers_Date_Of_Birth__c = System.Date.today();
        lab.Mother_s_Phone__c = '5555551212';
        lab.Shipping_Street__c = '123 Test Ln.';
        lab.Shipping_City__c = 'Testville';
        lab.Shipping_State_New__c = 'NY';
        lab.Shipping_Zip__c = '80403';
        lab.Shipping_Country__c = 'US';
        lab.Birth_Date_from_Courier__c = System.Date.today();        
        update lab;           

        // Set Baby record to have LPL for MyGenome inserted
        List<Baby__c> lstBaby = [SELECT Id from Baby__c];

        // mom and baby1
        lstBaby[0].LPI_My_Newborn__c = '1234567';
        lstBaby[0].LPI_My_Genome__c = '7654321';
        lstBaby[0].Sex_of_Child__c = 'Female';

        // baby2
        lstBaby[1].LPI_My_Newborn__c = '999999';
        lstBaby[1].Sex_of_Child__c = 'Female';

        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('callout:VeritasAuth/oauth2/token', 'GenomeMockResponseAuth');
        multimock.setStaticResource('callout:VeritasAuthEU/oauth2/token', 'GenomeMockResponseAuth');        
        multimock.setStaticResource('callout:VeritasGenomeOrder/order_create', 'GenomeMockResponseOrder');    
        multimock.setStaticResource('callout:VeritasNewbornOrder/order_create', 'GenomeMockResponseOrder');    
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');   

        Test.setMock(HttpCalloutMock.class, multimock);

        update lstBaby;
        List<String> lstBabyIds = new List<String>();
        List<List<String>> lstBabys = new List<List<String>>();
        lstBabyIds.add(lstBaby[0].Id);
        lstBabyIds.add(lstBaby[1].Id);
        lstBabys.add(lstBabyIds);

        Test.startTest();
        GenomeOrderOutbound.sendGenomeOrderWithBabyIds(lstBabys);
        Test.stopTest();

        Baby__C baby = [SELECT Id, My_Newborn_Order_Status__c,My_Genome_Order_Status__c FROM Baby__c WHERE Id = :lstBaby[0].Id LIMIT 1];
        
        // test to see if email flow is active
        FlowDefinitionView fdv = [SELECT isactive FROM FlowDefinitionView WHERE apiname ='Genome_Send_Customer_Email' LIMIT 1];
        if(fdv.isactive){
            System.assertEquals(EMAIL_SENT_TO_CUSTOMER,baby.My_Newborn_Order_Status__c, 'My Genome Order Status Does Not Match Sent Message');
            System.assertEquals(EMAIL_SENT_TO_CUSTOMER,baby.My_Genome_Order_Status__c, 'My Genome Order Status Does Not Match Sent Message');
        }
        else{
            System.assertEquals(SENT_TO_VERITAS,baby.My_Newborn_Order_Status__c, 'My Genome Order Status Does Not Match Sent Message');
            System.assertEquals(SENT_TO_VERITAS,baby.My_Genome_Order_Status__c, 'My Genome Order Status Does Not Match Sent Message');            
        }   

        baby = [SELECT Id, My_Newborn_Order_Status__c,My_Genome_Order_Status__c FROM Baby__c WHERE Id = :lstBaby[1].Id LIMIT 1];        
        if(fdv.isactive){
            System.assertEquals(EMAIL_SENT_TO_CUSTOMER,baby.My_Newborn_Order_Status__c, 'My Genome Order Status Does Not Match Sent Message');
        }
        else{
            System.assertEquals(SENT_TO_VERITAS,baby.My_Newborn_Order_Status__c, 'My Genome Order Status Does Not Match Sent Message');
        }          

    }    

    @isTest
    private static void testSendMyGenomeISBT_Success() {
         // Create an account
         Account a = new Account();
         a.Name = 'Test Account';
         insert a;
         
         Account refAccount = new Account();
         refAccount.Name = 'Ref Account';
         insert refAccount;
         
         //create contact
         Contact c = new Contact();
         c.AccountId = a.Id;
         c.FirstName = 'testxx';
         c.LastName = 'testxx';
         c.Email = 'testxx@test.com';
         insert c;
         
         Americord_Settings__c ams = Americord_Settings__c.getOrgDefaults(); 
         ams.Ambassador_Account_ID__c = refAccount.id;
         update ams;
 
         User oppOwner = AmericordTestDataFactory.getCurrentSalesRep();
 
         // Create an opportunity
         Opportunity o = new Opportunity();
         o.Name = 'Test Opportunity';
         o.OwnerId = oppOwner.Id;
         o.StageName = 'Closed';
         o.CloseDate = Date.today();
         o.AccountId = a.Id;
         o.Number_of_Births__c = 'Single';
         o.Cord_Blood_2_0__c = 1;
         o.Storage_Plan__c = '20YPP';
         o.Payment_Plans__c = 'OTP';
         o.Contact__c = c.id;
         o.Email__c = 'mary@test.com';
         o.FirstName__c = 'Mary';
         o.LastName__c = 'Test';
         o.Relation_to_Baby__c = 'Mother';        
         o.Referred_by_email_address__c = 'john@test.com';
         o.Referred_by_First_Name__c = 'JOHN';
         o.Referred_by_Last_Name__c = 'DOE';
         o.Shipping_Street__c = '123 main st';
         o.Shipping_City__c = 'Chicago';
         o.Shipping_Country__c = 'US';
         o.Shipping_State_Province__c = 'IL';
         o.Shipping_Zip__c = '99999';
         o.Authorized_Payment__c = true;
         o.Cord_Tissue__c = 1;
         o.Placenta_2_0__c = 1;        
         o.Enrollment_Flow_Complete__c = true;
         insert o;
        
         o.StageName = 'Enrolled';
         update o;              

        // Set CBO to have My Genome
        fw1__Invoice__c cbo = getInvoice(o.Id);
        cbo.My_Genome_Standard_Ordered__c = 1;
        update cbo;

        // Set Lab to have My Genome Values
        Lab__c lab = getLab(cbo.Id);
        lab.Mothers_Email__c = 'bogus@somesite.com';
        lab.Mothers_Date_Of_Birth__c = System.Date.today();
        lab.Mother_s_Phone__c = '5555551212';
        lab.Shipping_Street__c = '123 Test Ln.';
        lab.Shipping_City__c = 'Testville';
        lab.Shipping_State_New__c = 'NY';
        lab.Shipping_Zip__c = '80403';
        lab.Shipping_Country__c = 'US';
        lab.Birth_Date_from_Courier__c = System.Date.today();        
        update lab;         

        // Set Baby record to have LPL for MyGenome inserted
        Baby__c baby = [SELECT Id from Baby__c LIMIT 1];
        baby.LPI_My_Genome__c = '1234567';
        update baby;
        baby.ISBT_My_Genome__c = '223344';
        baby.Collection_Date__c = System.Date.today();
        baby.My_Genome_Order_Status__c = EMAIL_SENT_TO_CUSTOMER;        

        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('callout:VeritasAuth/oauth2/token', 'GenomeMockResponseAuth');
        multimock.setStaticResource('callout:VeritasGenomeOrder/update_sample', 'GenomeMockResponseOrder');    
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');   

        Test.setMock(HttpCalloutMock.class, multimock);

        update baby;
        List<String> lstBabyIds = new List<String>();
        List<List<String>> lstBaby = new List<List<String>>();
        lstBabyIds.add(baby.Id);
        lstBaby.add(lstBabyIds);

        Test.startTest();
        GenomeOrderOutbound.sendGenomeOrderWithBabyIds(lstBaby);
        Test.stopTest();

        baby = [SELECT Id, My_Genome_Order_Status__c FROM Baby__c LIMIT 1];
        System.assertEquals(LAB_SENT_TO_VERITAS, baby.My_Genome_Order_Status__c,'My Genome Order Status Does Not Match Sent Message');
    }

    @isTest
    private static void testSendMyNewbornISBT_Success() {
         // Create an account
         Account a = new Account();
         a.Name = 'Test Account';
         insert a;
         
         Account refAccount = new Account();
         refAccount.Name = 'Ref Account';
         insert refAccount;
         
         //create contact
         Contact c = new Contact();
         c.AccountId = a.Id;
         c.FirstName = 'testxx';
         c.LastName = 'testxx';
         c.Email = 'testxx@test.com';
         insert c;
         
         Americord_Settings__c ams = Americord_Settings__c.getOrgDefaults(); 
         ams.Ambassador_Account_ID__c = refAccount.id;
         update ams;
 
         User oppOwner = AmericordTestDataFactory.getCurrentSalesRep();
 
         // Create an opportunity
         Opportunity o = new Opportunity();
         o.Name = 'Test Opportunity';
         o.OwnerId = oppOwner.Id;
         o.StageName = 'Closed';
         o.CloseDate = Date.today();
         o.AccountId = a.Id;
         o.Number_of_Births__c = 'Single';
         o.Cord_Blood_2_0__c = 1;
         o.Storage_Plan__c = '20YPP';
         o.Payment_Plans__c = 'OTP';
         o.Contact__c = c.id;
         o.Email__c = 'mary@test.com';
         o.FirstName__c = 'Mary';
         o.LastName__c = 'Test';
         o.Relation_to_Baby__c = 'Mother';        
         o.Referred_by_email_address__c = 'john@test.com';
         o.Referred_by_First_Name__c = 'JOHN';
         o.Referred_by_Last_Name__c = 'DOE';
         o.Shipping_Street__c = '123 main st';
         o.Shipping_City__c = 'Chicago';
         o.Shipping_Country__c = 'US';
         o.Shipping_State_Province__c = 'IL';
         o.Shipping_Zip__c = '99999';
         o.Authorized_Payment__c = true;
         o.Cord_Tissue__c = 1;
         o.Placenta_2_0__c = 1;        
         o.Enrollment_Flow_Complete__c = true;
         insert o;
        
         o.StageName = 'Enrolled';
         update o;              

        // Set CBO to have My Genome
        fw1__Invoice__c cbo = getInvoice(o.Id);
        cbo.Newborn_Panel_Ordered__c = 1;
        update cbo;

        // Set Lab to have My Genome Values
        Lab__c lab = getLab(cbo.Id);
        lab.Mothers_Email__c = 'bogus@somesite.com';
        lab.Mothers_Date_Of_Birth__c = System.Date.today();
        lab.Mother_s_Phone__c = '5555551212';
        lab.Shipping_Street__c = '123 Test Ln.';
        lab.Shipping_City__c = 'Testville';
        lab.Shipping_State_New__c = 'NY';
        lab.Shipping_Zip__c = '80403';
        lab.Shipping_Country__c = 'US';
        lab.Birth_Date_from_Courier__c = System.Date.today();        
        update lab;         

        // Set Baby record to have LPL for MyGenome inserted
        Baby__c baby = [SELECT Id from Baby__c LIMIT 1];
        baby.LPI_My_Newborn__c = '1234567';
        baby.Sex_of_Child__c = 'Female';
        update baby;
        baby.ISBT_My_Newborn__c = '223344';
        baby.Collection_Date__c = System.Date.today();
        baby.My_Newborn_Order_Status__c = EMAIL_SENT_TO_CUSTOMER;

        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('callout:VeritasAuthEU/oauth2/token', 'GenomeMockResponseAuth');
        multimock.setStaticResource('callout:VeritasNewbornOrder/order_create', 'GenomeMockResponseOrder');    
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');   

        Test.setMock(HttpCalloutMock.class, multimock);

        update baby;
        List<String> lstBabyIds = new List<String>();
        List<List<String>> lstBaby = new List<List<String>>();
        lstBabyIds.add(baby.Id);
        lstBaby.add(lstBabyIds);

        Test.startTest();
        GenomeOrderOutbound.sendGenomeOrderWithBabyIds(lstBaby);
        Test.stopTest();

        baby = [SELECT Id, My_Newborn_Order_Status__c FROM Baby__c LIMIT 1];
        System.assertEquals(LAB_SENT_TO_VERITAS, baby.My_Newborn_Order_Status__c, 'My Genome Order Status Does Not Match Sent Message');
    }    

    @isTest
    private static void testSendMyGenomeStandardISBT_Success() {
         // Create an account
         Account a = new Account();
         a.Name = 'Test Account';
         insert a;
         
         Account refAccount = new Account();
         refAccount.Name = 'Ref Account';
         insert refAccount;
         
         //create contact
         Contact c = new Contact();
         c.AccountId = a.Id;
         c.FirstName = 'testxx';
         c.LastName = 'testxx';
         c.Email = 'testxx@test.com';
         insert c;
         
         Americord_Settings__c ams = Americord_Settings__c.getOrgDefaults(); 
         ams.Ambassador_Account_ID__c = refAccount.id;
         update ams;
 
         User oppOwner = AmericordTestDataFactory.getCurrentSalesRep();
 
         // Create an opportunity
         Opportunity o = new Opportunity();
         o.Name = 'Test Opportunity';
         o.OwnerId = oppOwner.Id;
         o.StageName = 'Closed';
         o.CloseDate = Date.today();
         o.AccountId = a.Id;
         o.Number_of_Births__c = 'Single';
         o.Cord_Blood_2_0__c = 1;
         o.Storage_Plan__c = '20YPP';
         o.Payment_Plans__c = 'OTP';
         o.Contact__c = c.id;
         o.Email__c = 'mary@test.com';
         o.FirstName__c = 'Mary';
         o.LastName__c = 'Test';
         o.Relation_to_Baby__c = 'Mother';        
         o.Referred_by_email_address__c = 'john@test.com';
         o.Referred_by_First_Name__c = 'JOHN';
         o.Referred_by_Last_Name__c = 'DOE';
         o.Shipping_Street__c = '123 main st';
         o.Shipping_City__c = 'Chicago';
         o.Shipping_Country__c = 'US';
         o.Shipping_State_Province__c = 'IL';
         o.Shipping_Zip__c = '99999';
         o.Authorized_Payment__c = true;
         o.Cord_Tissue__c = 1;
         o.Placenta_2_0__c = 1;        
         o.Enrollment_Flow_Complete__c = true;
         insert o;
        
         o.StageName = 'Enrolled';
         update o;              

        // Set CBO to have My Genome
        fw1__Invoice__c cbo = getInvoice(o.Id);
        cbo.My_Genome_Standard_Ordered__c = 1;
        update cbo;

        // Set Lab to have My Genome Values
        Lab__c lab = getLab(cbo.Id);
        lab.Mothers_Email__c = 'bogus@somesite.com';
        lab.Mothers_Date_Of_Birth__c = System.Date.today();
        lab.Mother_s_Phone__c = '5555551212';
        lab.Shipping_Street__c = '123 Test Ln.';
        lab.Shipping_City__c = 'Testville';
        lab.Shipping_State_New__c = 'NY';
        lab.Shipping_Zip__c = '80403';
        lab.Shipping_Country__c = 'US';
        lab.Birth_Date_from_Courier__c = System.Date.today();        
        update lab;         

        // Set Baby record to have LPL for MyGenome inserted
        Baby__c baby = [SELECT Id from Baby__c LIMIT 1];
        baby.LPI_My_Genome__c = '1234567';
        update baby;
        baby.ISBT_My_Genome__c = '223344';
        baby.Collection_Date__c = System.Date.today();
        baby.My_Genome_Order_Status__c = EMAIL_SENT_TO_CUSTOMER;

        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('callout:VeritasAuth/oauth2/token', 'GenomeMockResponseAuth');
        multimock.setStaticResource('callout:VeritasGenomeOrder/update_sample', 'GenomeMockResponseOrder');    
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');   

        Test.setMock(HttpCalloutMock.class, multimock);

        update baby;
        List<String> lstBabyIds = new List<String>();
        List<List<String>> lstBaby = new List<List<String>>();
        lstBabyIds.add(baby.Id);
        lstBaby.add(lstBabyIds);

        Test.startTest();
        GenomeOrderOutbound.sendGenomeOrderWithBabyIds(lstBaby);
        Test.stopTest();

        baby = [SELECT Id, My_Genome_Order_Status__c FROM Baby__c LIMIT 1];
        System.assertEquals(LAB_SENT_TO_VERITAS, baby.My_Genome_Order_Status__c,'My Genome Order Status Does Not Match Sent Message');
    }    

    @isTest
    private static void testSendBothISBT_Success() {
         // Create an account
         Account a = new Account();
         a.Name = 'Test Account';
         insert a;
         
         Account refAccount = new Account();
         refAccount.Name = 'Ref Account';
         insert refAccount;
         
         //create contact
         Contact c = new Contact();
         c.AccountId = a.Id;
         c.FirstName = 'testxx';
         c.LastName = 'testxx';
         c.Email = 'testxx@test.com';
         insert c;
         
         Americord_Settings__c ams = Americord_Settings__c.getOrgDefaults(); 
         ams.Ambassador_Account_ID__c = refAccount.id;
         update ams;
 
         User oppOwner = AmericordTestDataFactory.getCurrentSalesRep();
 
         // Create an opportunity
         Opportunity o = new Opportunity();
         o.Name = 'Test Opportunity';
         o.OwnerId = oppOwner.Id;
         o.StageName = 'Closed';
         o.CloseDate = Date.today();
         o.AccountId = a.Id;
         o.Number_of_Births__c = 'Single';
         o.Cord_Blood_2_0__c = 1;
         o.Storage_Plan__c = '20YPP';
         o.Payment_Plans__c = 'OTP';
         o.Contact__c = c.id;
         o.Email__c = 'mary@test.com';
         o.FirstName__c = 'Mary';
         o.LastName__c = 'Test';
         o.Relation_to_Baby__c = 'Mother';        
         o.Referred_by_email_address__c = 'john@test.com';
         o.Referred_by_First_Name__c = 'JOHN';
         o.Referred_by_Last_Name__c = 'DOE';
         o.Shipping_Street__c = '123 main st';
         o.Shipping_City__c = 'Chicago';
         o.Shipping_Country__c = 'US';
         o.Shipping_State_Province__c = 'IL';
         o.Shipping_Zip__c = '99999';
         o.Authorized_Payment__c = true;
         o.Cord_Tissue__c = 1;
         o.Placenta_2_0__c = 1;        
         o.Enrollment_Flow_Complete__c = true;
         insert o;
        
         o.StageName = 'Enrolled';
         update o;              

        // Set CBO to have My Genome
        fw1__Invoice__c cbo = getInvoice(o.Id);
        cbo.My_Genome_Premium_Ordered__c = 1;
        cbo.Newborn_Panel_Ordered__c = 1;
        update cbo;

        // Set Lab to have My Genome Values
        Lab__c lab = getLab(cbo.Id);
        lab.Mothers_Email__c = 'bogus@somesite.com';
        lab.Mothers_Date_Of_Birth__c = System.Date.today();
        lab.Mother_s_Phone__c = '5555551212';
        lab.Shipping_Street__c = '123 Test Ln.';
        lab.Shipping_City__c = 'Testville';
        lab.Shipping_State_New__c = 'NY';
        lab.Shipping_Zip__c = '80403';
        lab.Shipping_Country__c = 'US';
        lab.Birth_Date_from_Courier__c = System.Date.today();        
        update lab;         

        // Set Baby record to have LPL for MyGenome inserted
        Baby__c baby = [SELECT Id from Baby__c LIMIT 1];
        baby.LPI_My_Newborn__c = '1234567';
        baby.LPI_My_Genome__c = '456789';
        baby.Sex_of_Child__c = 'Female';
        update baby;
        baby.ISBT_My_Newborn__c = '223344';
        baby.ISBT_My_Genome__c = '456546';
        baby.Collection_Date__c = System.Date.today();
        baby.My_Genome_Order_Status__c = EMAIL_SENT_TO_CUSTOMER;
        baby.My_Newborn_Order_Status__c = EMAIL_SENT_TO_CUSTOMER;

        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('callout:VeritasAuth/oauth2/token', 'GenomeMockResponseAuth');
        multimock.setStaticResource('callout:VeritasAuthEU/oauth2/token', 'GenomeMockResponseAuth');
        multimock.setStaticResource('callout:VeritasGenomeOrder/update_sample', 'GenomeMockResponseOrder');    
        multimock.setStaticResource('callout:VeritasNewbornOrder/order_create', 'GenomeMockResponseOrder');  
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');   

        Test.setMock(HttpCalloutMock.class, multimock);

        update baby;
        List<String> lstBabyIds = new List<String>();
        List<List<String>> lstBaby = new List<List<String>>();
        lstBabyIds.add(baby.Id);
        lstBaby.add(lstBabyIds);

        Test.startTest();
        GenomeOrderOutbound.sendGenomeOrderWithBabyIds(lstBaby);
        Test.stopTest();

        baby = [SELECT Id, My_Newborn_Order_Status__c, My_Genome_Order_Status__c FROM Baby__c LIMIT 1];
        System.assertEquals(LAB_SENT_TO_VERITAS,baby.My_Newborn_Order_Status__c, 'My Genome Order Status Does Not Match Sent Message');
        System.assertEquals(LAB_SENT_TO_VERITAS,baby.My_Genome_Order_Status__c,  'My Genome Order Status Does Not Match Sent Message');
    }        


    @isTest
    private static void testSendMyGenome_Failure_Callout() {

    }    

    @isTest
    private static void testSendMyGenome_Failure_BadStatusCode() {

    }        

    private static fw1__Invoice__c getInvoice(string opptyId) {
        List<fw1__Invoice__c> invs = new List<fw1__Invoice__c>();
        invs = [
            SELECT fw1__Account__c,Cord_Blood_2_0_Stored__c,Cord_Tissue_Stored__c,Placenta_2_0_Stored__c,Placenta_Tissue_Stored__c,
            Cord_Blood_2_0_Ordered__c,Cord_Tissue_Ordered__c,Placenta_2_0_Ordered__c,Placenta_Tissue_Ordered__c,
            Lab__c,Lab__r.Cord_Blood_Collection_Completed__c,Storage_Plan_Ordered__c,Payment_Plan_Ordered__c,
            Storage_Plan_Stored__c,Payment_Plan_Stored__c,fw1__Total_Lines_Count__c, Monthly_Fees_new2__c,
            My_Genome_Premium_Ordered__c, My_Genome_Standard_Ordered__c, Newborn_Panel_Ordered__c
            FROM fw1__Invoice__c
            WHERE fw2__Opportunity__c = :opptyId
        ];
        
        if (invs.size() > 0)
        	return invs[0];
        else
            return null;
    }    

    private static Lab__c getLab(string cboId) {
        List<Lab__c> lstLab = new List<lab__c>();
        lstLab = [
            SELECT id
            FROM Lab__c
            where Cord_Blood_Order__c = :cboId   
        ];     
        if (lstLab.size() > 0)
        	return lstLab[0];
        else
            return null;
    }        
    

}