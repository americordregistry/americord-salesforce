@isTest(SeeAllData=true)
private class updateContactDetailsTest { /*
    @isTest static void TestContactDetails() {
        Account acc = new Account(name = 'Nilesh',AccountNumber='123456');
        insert acc;
        //Inserting contact
        Contact cont1 = new Contact(AccountId=acc.Id,FirstName='Nilesh',LastName='Borse',Phone='8888454455',Type__c = 'Father');
        Contact cont2 = new Contact(AccountId=acc.Id,FirstName='Nilesh',LastName='Borse',Phone='8888454455',Type__c = 'Mother');
        insert cont1;
        insert cont2;
        //Insert Invoice
       fw1__Invoice__c invoice = new fw1__Invoice__c(fw1__Account__c = acc.Id,fw1__Contact__c =cont2.Id);
       insert invoice;
        checkRecursion.isRec = false;
        //Insert lab 
        Lab__c lab = new Lab__c(Cord_Blood_Order__c=invoice.Id,Name='Test Lab');
        insert lab;
        checkRecursion.isRec = false;
        //System.debug('======Record ID-========'+lab.id);
        Lab__c lc = new Lab__c();
        lc.id = lab.id;
        lc.Father_s_First_Name__c = 'Test2';
        lc.Mother_s_First_Name__c = 'Tests';
        update lc;
        
        
        //checkRecursion.isRec = false;
        Account acc1 = new Account(name = 'Nilesh',AccountNumber='123456');
        insert acc1;
        //Inserting contact
        List<Contact> contList = new List<Contact>();
        /*Contact cont3 = new Contact(AccountId=acc1.Id,FirstName='Nilesh',LastName='Borse',Phone='8888454455',Type__c = 'Father');
        insert cont3;
        Contact cont4 = new Contact(AccountId=acc1.Id,FirstName='Nilesh',LastName='Borse',Phone='8888454455',Type__c = 'Mother');
        insert cont4;
        contList.add(new Contact(AccountId=acc1.Id,FirstName='Nilesh',LastName='Borse',Phone='8888454455',Type__c = 'Father'));
        contList.add(new Contact(AccountId=acc1.Id,FirstName='Nilesh',LastName='Borse',Phone='8888454455',Type__c = 'Mother'));
        insert contList;

        //Insert Invoice
       fw1__Invoice__c invoice1 = new fw1__Invoice__c(fw1__Account__c = acc1.Id,fw1__Contact__c = contList[0].Id);
       insert invoice1;
       //checkRecursion.isRec = false;
        //Insert lab 
        Lab__c lab1 = new Lab__c(Cord_Blood_Order__c=invoice1.Id,Name='Test Lab');
        insert lab1;
        checkRecursion.isRec = false;
        Contact con1 = new Contact();
        con1.id = contList[0].id;
        //con1.AccountId = acc1.id;
        con1.FirstName = 'Nil1';
        update con1;
        
    } */
}