@isTest
private class CBOLineItemsTest {
    @testSetup static void setup() {
        AmericordTestDataFactory testData = new AmericordTestDataFactory ();           
    }        
    @IsTest
    static void CBOLineItem_create(){
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

        fw1__Invoice__c cbo = getInvoice(o.Id);
        cbo.Cord_Blood_2_0_Ordered__c = 1;
        cbo.Storage_Plan_Ordered__c = '20YPP';
        cbo.Payment_Plan_Ordered__c = 'OTP';
        cbo.Payment_Plan_Stored__c = 'OTP';
        update cbo;

        // Set Lab for Collection Complete
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

        List<fw1__Invoice__c> lstInvoices = new List<fw1__Invoice__c>();
        lstInvoices.add(cbo);
        CBOLineItems cboli = new CBOLineItems();
        OrderCalculator.Input oci = new OrderCalculator.Input();        
        Test.startTest();
        cboli.create(lstInvoices);
        Test.stopTest();
                        
    
    }


    @IsTest
    static void CBOLineItem_getCalcInput(){
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


        fw1__Invoice__c cbo = getInvoice(o.Id);
        cbo.Cord_Blood_2_0_Ordered__c = 1;
        update cbo;

        // Set Lab for Collection Complete
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

        OrderCalculator.Input oci = new OrderCalculator.Input();
        Test.startTest();
        oci = CBOLineItems.getCalcInput(cbo);
        Test.stopTest();
                        
    
    }


    @IsTest
    static void CBOLineItem_getCalcInput_BabyBorn(){
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
        o.Payment_Plans__c = '24M';
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


        fw1__Invoice__c cbo = getInvoice(o.Id);
        cbo.Cord_Blood_2_0_Ordered__c = 1;
        cbo.Storage_Plan_Stored__c = 'LTS';
        cbo.Payment_Plan_Stored__c = '24M';        
        update cbo;

        // Set Lab for Collection Complete
        Lab__c lab = getLab(cbo.Id);
        lab.Mothers_Email__c = 'bogus@somesite.com';
        lab.Mothers_Date_Of_Birth__c = System.Date.today();
        lab.Mother_s_Phone__c = '5555551212';
        lab.Shipping_Street__c = '123 Test Ln.';
        lab.Shipping_City__c = 'Testville';
        lab.Shipping_State_New__c = 'NY';
        lab.Shipping_Zip__c = '80403';
        lab.Shipping_Country__c = 'US';
        lab.Cord_Blood_Collection_Completed__c = true;
        update lab; 

        cbo = getInvoice(o.Id);

        OrderCalculator.Input oci = new OrderCalculator.Input();
        Test.startTest();
        oci = CBOLineItems.getCalcInput(cbo);
        Test.stopTest();
                        
    
    }    

    private static fw1__Invoice__c getInvoice(string opptyId) {
        List<fw1__Invoice__c> invs = new List<fw1__Invoice__c>();
        invs = [
            SELECT fw1__Account__c,Cord_Blood_2_0_Stored__c,Cord_Tissue_Stored__c,Placenta_2_0_Stored__c,Placenta_Tissue_Stored__c,
            Cord_Blood_2_0_Ordered__c,Cord_Tissue_Ordered__c,Placenta_2_0_Ordered__c,Placenta_Tissue_Ordered__c,
            Lab__c,Lab__r.Cord_Blood_Collection_Completed__c,Storage_Plan_Ordered__c,Payment_Plan_Ordered__c,
            Storage_Plan_Stored__c,Payment_Plan_Stored__c,fw1__Total_Lines_Count__c, Monthly_Fees_new2__c,
            My_Genome_Premium_Ordered__c, My_Genome_Standard_Ordered__c, Newborn_Panel_Ordered__c,Deposit__c,
            Numeric_Births__c,Sales_Discount__c,Price_Book__c,Pricing_Version__c,Shipping_Type__c,Baby_Born__c,
            Maternal_Exosomes_Stored__c,Newborn_Panel_Stored__c,Newborn_Genome_Stored__c,My_Genome_Standard_Stored__c,
            My_Genome_Premium_Stored__c,Exosomes_Stored__c,Exosomes_Ordered__c,Newborn_Genome_Ordered__c,
            Maternal_Exosomes_Ordered__c
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