trigger updateLabDetailsFromContact on Contact (after update,after insert){
    /*Checking if trigger is fired only one time
     if(checkRecursion.isRec != true)
    {
        checkRecursion.isRec = true;
        if(trigger.isUpdate)
        {   
            system.debug('I must be when update Fire!');
            //Checking if this contact is referred on any lab record
            Contact con = trigger.New[0];
            List<Lab__c> updateList = new List<Lab__c>();
            List<Lab__c> l = [Select Id,Cord_Blood_Order__r.fw1__Account__r.Id,Cord_Blood_Order__r.fw1__Contact__r.Id from Lab__c where Cord_Blood_Order__r.fw1__Account__r.Id =: con.AccountId];
            if(l.size() > 0)
            {
                for(Lab__c la: l)
                {
                    Lab__c labObj = new Lab__c();
                    if(con.Type__c == 'Mother')
                    {   
                        labObj.id = la.id;
                        labObj.Mother_s_First_Name__c = con.FirstName;
                        labObj.Mother_s_Last_Name__c = con.LastName;
                        labObj.Mother_s_Phone__c = con.Phone;
                        labObj.Mothers_Email__c = con.Email;
                        updateList.add(labObj);
                    }
                    if(con.Type__c == 'Father')
                    {   
                        labObj.id = la.id;
                        labObj.Father_s_First_Name__c = con.FirstName;
                        labObj.Father_s_Last_Name__c = con.LastName;
                        labObj.Father_s_Phone__c = con.Phone;
                        labObj.Father_s_Email__c = con.Email;
                        updateList.add(labObj);
                    }
                }
            }
            System.debug('-------updateList-------'+updateList);
            if(updateList.size() > 0)
                    update updateList;
        }
        if(trigger.isInsert)
        {
            Contact newContact = trigger.New[0];
            System.debug('------Trigger.New--------'+trigger.New[0]);
            if(newContact.Type__c == 'Mother' || newContact.Type__c == 'Father')  
            {
                //Get account id and lab obejct record
                Id accountid = newContact.AccountId;
                if(accountid != null)
                {
                    //Fetch lab from Cord blood order whose accountid = accountid
                    List<Id> CBOListId = new List<Id>();
                    for(fw1__Invoice__c cbo: [Select Id from fw1__Invoice__c where fw1__Account__c =: accountid])
                    {
                        CBOListId.add(cbo.Id);
                    }
                    if(CBOListId.size() > 0)
                    {   
                        List<Lab__c> labList = new List<Lab__c>();
                        Lab__c labObj;
                         for(Lab__c la: [Select Id from Lab__c where Cord_Blood_Order__c in : CBOListId])
                         {  
                             
                             if(newContact.Type__c == 'Mother')
                             {      
                                //Lab__c labObj = new Lab__c();
                                labObj = new Lab__c();
                                labObj.id = la.id;
                                labObj.Mother_s_First_Name__c = newContact.FirstName;
                                labObj.Mother_s_Last_Name__c = newContact.LastName;
                                labObj.Mother_s_Phone__c = newContact.Phone;
                                labObj.Mothers_Email__c = newContact.Email;
                                labList.add(labObj);
                             }
                             if(newContact.Type__c == 'Father')
                             {      
                                // = new Lab__c();
                                labObj = new Lab__c();
                                labObj.id = la.id;
                                labObj.Father_s_First_Name__c = newContact.FirstName;
                                labObj.Father_s_Last_Name__c= newContact.LastName;
                                labObj.Father_s_Phone__c = newContact.Phone;
                                labObj.Father_s_Email__c = newContact.Email;
                                labList.add(labObj);
                             }
                         }
                        System.debug('---ListData-----'+labList);
                         //if(labList.size() > 0)
                         update labList;
                    }
                 }
            }
        }
    } */   
}