@isTest
public with sharing class ConvertLeadTests {

    /*static testMethod void testConvertLead() {
        // create custom setting
        LeadConversionSettings__c setting = new LeadConversionSettings__c();
        setting.Name = 'Test Setting';
        setting.Turn_On_Lead_Conversion__c = true;
        insert setting;
        
        // create settings
        fw1__Payment_Center_Setting__c s = new fw1__Payment_Center_Setting__c();
        s.Name = 'Default Settings';
        insert s;
        
        // create payment
        fw1__Payment__c p = new fw1__Payment__c();
        p.Name = 'test payment';
        p.fw1__Payment_Date__c = system.now();
        p.fw1__Amount__c = 1;
        p.fw1__Status__c = 'Voided';
        insert p;
        
        // create lead
        Lead l = new Lead();
        l.FirstName = 'Rena';
        l.LastName = 'Hughes';
        l.Company = 'Rena Hughes';
        l.Email = 'test@test.com';
        l.Phone = '1231234321';
        l.Babys_Due_Date__c = system.today();
        l.Father_s_Name__c = 'John Hughes';
        l.Authorization_ID__c = p.Id;
        l.Product1__c = 'Cord Blood 24 month';
        l.Product_List_Price1__c = 800;
        l.Product_Discount_Amount1__c = 200;
        l.Coupon_Code__c = 'ddd';
        l.Hospital_Name__c = 'Cumberland Medical Center';
        l.OBGYN_Name__c = 'Kimberly Johnson';
        l.Returning_Client__c = true;
        l.Referrer_First_Name__c = 'Tina';
        l.Referrer_Last_Name__c = 'Smith';
        l.Referrer_Email__c = 'test3@test3.com';
        l.Follow_up_Subject__c = 'Calling back for credit card';
        l.Rep_Follow_up__c = 'Martin';
        l.Returning_Client__c = true;
        l.Alt_Email__c = 'test4@test4.com';
        l.Alt_Phone__c = '2345678909';
        l.Enrolled_by_email__c = 'test5@test5.com';
        l.Enrolled_by_first_name__c = 'Amanda';
        l.Enrolled_by_last_name__c = 'Jones';
        l.Enrolled_by_phone__c = '3456789098';
        l.relation__c = 'Other';
        l.CC_Call_1__c = false;
        l.CC_Call_2__c = false;
        l.CC_Email_1__c = false;
        l.CC_Email_2__c = false;
        l.Sent_Marketing_Email__c = true;
        l.Email_1x__c = true;
        l.How_did_you_find_us__c = 'sample';
        l.how_did_you_learn_about_americord__c = 'sample';
        l.Shipping_Notes__c = 'sample';
        l.Agreement_Escalation__c = false;
        l.Client_Billed__c = false;
        l.Billing_Address1__c = '1 Main Street';
        l.Billing_Address2__c = 'Apt 2B';
        l.Billing_City__c = 'Anywhere';
        l.Billing_State__c = 'Alaska';
        l.Billing_Zip_Code__c = '11111';
        l.Billing_Notes__c = 'sample';
        l.Billing_Notes_Needs_Review__c = false;
        l.Called_Prospect__c = false;
        l.Called_2x__c = false;
        l.Called_3x__c = false;
        l.Cancellation_Comments__c = 'sample';
        l.CC_Comments_1__c = 'sample';
        l.CC_Comments_2__c = 'sample';
        l.Client_Responded__c = false;
        l.OBGYN_Practice_Name__c = 'My OBGYN';
        l.Hospital_Phone__c = '222-222-2222';
        l.OBGYN_Phone__c = '333-333-3333';
        l.smagicinteract__SMSOptOut__c = true;
        insert l;
        
        l.Status = 'Enrolled';
        Test.startTest();
            update l;
        Test.stopTest();
    }*/
}