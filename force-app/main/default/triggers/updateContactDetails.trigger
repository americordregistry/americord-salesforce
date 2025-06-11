trigger updateContactDetails on Lab__c (after update,before insert) 
{
  /*   for(Lab__c T_lab: Trigger.new)
    {
        if(T_lab.Skip_Trigger__c == true)
            continue;
            
        List<Contact> conList =new List<Contact>(); 
        //List<Contact> conListInsert = new List<Contact>();
        //Checking if trigger is fired only one time
        if(checkRecursion.isRec != true)
        {
            checkRecursion.isRec = true;
            if (Trigger.isUpdate)
            {   
                Lab__c l = [Select Id,Name,Father_s_First_Name__c,Father_s_Last_Name__c,Father_s_Phone__c,Father_s_Email__c,Mother_s_First_Name__c,Mother_s_Last_Name__c,Mother_s_Phone__c,Mothers_Email__c,Cord_Blood_Order__r.fw1__Account__r.Id,Cord_Blood_Order__r.fw1__Contact__r.Id from Lab__c where Id =: T_lab.Id];
                Id contactId = l.Cord_Blood_Order__r.fw1__Contact__r.Id;
                System.debug('----contact id----'+contactId);
                Id accountId = l.Cord_Blood_Order__r.fw1__Account__r.Id;
                List<Contact> con = [Select Id,Type__c,FirstName,LastName,Phone,Email from Contact where Id=: contactId limit 1];
                if(con.size() > 0)
                {
                    if(con[0].Type__c == 'Mother')
                    {
                        Contact conNew =  new Contact();
                        conNew.id = con[0].id;
                        conNew.AccountId = accountId;
                        conNew.FirstName = l.Mother_s_First_Name__c;
                        
                        if(l.Mother_s_First_Name__c != null)
                            conNew.FirstName = l.Mother_s_First_Name__c;
                        else 
                            conNew.FirstName = con[0].FirstName;
                        
                        if(l.Mother_s_Last_Name__c != null)
                            conNew.LastName = l.Mother_s_Last_Name__c;
                        else 
                            conNew.LastName = con[0].LastName; 
                        
                        if(l.Mother_s_Phone__c != null)
                            conNew.Phone = l.Mother_s_Phone__c;
                        else 
                            conNew.Phone = con[0].Phone; 
                        
                        if(l.Mothers_Email__c != null)
                            conNew.Email = l.Mothers_Email__c;
                        else 
                            conNew.Email = con[0].Email; 
                        conList.add(conNew);
                    }
                }
                //Updating father details
                if(accountId != null)
                {
                    List<Contact> conFather = [Select Id,Type__c,LastName,FirstName,Phone,Email from Contact where Type__c =: 'Father' and AccountId =: accountId limit 1];
                    Contact conFa =  new Contact();
                    if(conFather.size() > 0 )
                    {
                        conFa.id = conFather[0].id;
                        conFa.AccountId = accountId;
                        
                        if(l.Father_s_First_Name__c != null)
                            conFa.FirstName = l.Father_s_First_Name__c;
                        else 
                            conFa.FirstName = conFather[0].FirstName;
                        
                        if(l.Father_s_Last_Name__c != null)
                            conFa.LastName = l.Father_s_Last_Name__c;
                        else 
                            conFa.LastName = conFather[0].LastName;
                        
                        if(l.Father_s_Phone__c != null)
                            conFa.Phone = l.Father_s_Phone__c;
                        else 
                            conFa.Phone = conFather[0].Phone;
                        
                        if(l.Father_s_Email__c != null)
                            conFa.Email = l.Father_s_Email__c;
                        else 
                            conFa.Email = conFather[0].Email;
                        conList.add(conFa);
                    }
                   
                }
                if(conList.size() > 0)
                    update conList;
            } 
            else if(Trigger.isInsert)
            {    
                Lab__c lab = T_lab;
                //System.debug('------Trigger.New--------'+trigger.New[0]);
                Id invoice_id = T_lab.Cord_Blood_Order__c;
                List<fw1__Invoice__c> inv = [Select Id,Name,fw1__Account__c from fw1__Invoice__c where Id =: invoice_id];
                if(inv.size() > 0)
                {    
                    String mother_fname,mother_lname,father_fname,father_lname;
                    Account accDet = [Select Name,(Select Id,FirstName,LastName,Type__c,Phone,Email from Contacts) from Account where Id =: inv[0].fw1__Account__c];
                    Contact[] contList = accDet.Contacts;
                    
                    for(Contact con: contList)
                    {
                        if(con.Type__c == 'Mother')
                        {
                            lab.Mother_s_First_Name__c = con.FirstName;
                            lab.Mother_s_Last_Name__c = con.LastName;
                            lab.Mother_s_Phone__c = con.Phone;
                            lab.Mothers_Email__c = con.Email;
                        }
                        if(con.Type__c == 'Father')
                        {
                            lab.Father_s_First_Name__c = con.FirstName;
                            lab.Father_s_Last_Name__c= con.LastName;
                            lab.Father_s_Phone__c = con.Phone;
                            lab.Father_s_Email__c = con.Email;
                        }
                    } 
                }
            }
        }
    } */
}