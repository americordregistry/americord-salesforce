// Test Data Factory for Americord customizations

public class AmericordTestDataFactory {
    
    // base data
    public AmericordTestDataFactory () {

        // Setup PriceBooks
        Id standardPriceBookId = Test.getStandardPricebookId();
        Pricebook2 customPriceBook = new Pricebook2 (Name = 'Test 2020', 
                                                     Description = 'Test', 
                                                     IsActive = true );
        insert customPriceBook;
        Id customPriceBookId = customPriceBook.Id;

        // Create Products
        List < Product2 > productsForInsert = new List < Product2 > ();
       	Product2 prod = new Product2 (Name = 'Cord Blood 2.0', 
                                      IsActive = true, 
                                      ProductCode='CB',
                                      Family = 'Product',
                                      Is_Biobanking_Product__c=true);
        productsForInsert.add ( prod );

       	prod = new Product2 (Name = 'Cord Tissue', 
                                      IsActive = true, 
                                      ProductCode='CT',
                                      Family = 'Product',
                                      Is_Biobanking_Product__c=true);
        productsForInsert.add ( prod );

       	prod = new Product2 (Name = 'Placenta Tissue', 
                                      IsActive = true, 
                                      ProductCode='PT',
                                      Family = 'Product',
                                      Is_Biobanking_Product__c=true);
        productsForInsert.add ( prod );

        prod = new Product2 (Name = 'Cord Blood + Cord Tissue', 
                             		IsActive = true, 
                                	ProductCode='CBCT',
                                	Family = 'Product',
                                    Is_Biobanking_Product__c=true);
        productsForInsert.add ( prod );
        
        prod = new Product2 (Name = 'Cord Blood + Cord Tissue + Placenta', 
                                	IsActive = true, 
                                	ProductCode='CBCTP',
                                	Family = 'Product',
                                    Is_Biobanking_Product__c=true);
        
        productsForInsert.add ( prod );
        
        prod = new Product2 (Name = 'Cord Blood 20yr Storage', 
                                	IsActive = true, 
                                	ProductCode='CB20Yr',
                                	Family = 'Storage');
        productsForInsert.add ( prod );

        prod = new Product2 (Name = 'Cord Tissue 20yr Storage', 
                                	IsActive = true, 
                                	ProductCode='CT20Yr',
                                	Family = 'Storage');
        productsForInsert.add ( prod );

        prod = new Product2 (Name = 'Cord Tissue Lifetime Storage', 
                                	IsActive = true, 
                                	ProductCode='CTLifetime',
                                	Family = 'Storage');
        productsForInsert.add ( prod );
        
        prod = new Product2 (Name = 'Cord Blood + Cord Tissue 20yr Storage', 
                                	IsActive = true, 
                                	ProductCode='CBCT20Yr',
                                	Family = 'Storage');
        productsForInsert.add ( prod );
        
        prod = new Product2 (Name = 'Cord Blood + Cord Tissue + Placenta 20yr Storage', 
                                	IsActive = true, 
                                	ProductCode='CBCTP20Yr',
                                	Family = 'Storage');
        productsForInsert.add ( prod );

        prod = new Product2 (Name = 'Cord Blood Lifetime Storage', 
                                	IsActive = true, 
                                	ProductCode='CBLifetime',
                                	Family = 'Storage');
        productsForInsert.add ( prod );
        
        prod = new Product2 (Name = 'Cord Blood + Cord Tissue Lifetime Storage', 
                                	IsActive = true, 
                                	ProductCode='CBCTLifetime',
                                	Family = 'Storage');
        productsForInsert.add ( prod );
        
        prod = new Product2 (Name = 'Cord Blood + Cord Tissue + Placenta Lifetime Storage', 
                                	IsActive = true, 
                                	ProductCode='CBCTPLifetime',
                                	Family = 'Storage');
        productsForInsert.add ( prod );

        prod = new Product2 (Name = 'Rush Shipping', 
                                	IsActive = true, 
                                	ProductCode='RushShip',
                                	Family = 'Shipping');
        productsForInsert.add ( prod );

        prod = new Product2 (Name = 'Standard Shipping', 
                                	IsActive = true, 
                                	ProductCode='StndShip',
                                	Family = 'Shipping');
        productsForInsert.add ( prod );

        prod = new Product2 (Name = 'Stem Cell Collection Kit', 
                                	IsActive = true, 
                                	ProductCode='CollKit');
        productsForInsert.add ( prod );
        
        prod = new Product2 (Name = 'Cord Blood + Cord Tissue + Placenta + Exosomes', 
                                	IsActive = true, 
                                	ProductCode='CBCTPEX',
                                    Family = 'Product',
                                    Is_Biobanking_Product__c=true);
        productsForInsert.add ( prod );

        prod = new Product2 (Name = 'Cord Blood + Cord Tissue + Placenta + Exosomes + M&M', 
                                	IsActive = true, 
                                	ProductCode='CBCTPEXMM',
                                    Family = 'Product',
                                    Is_Biobanking_Product__c=true,
                                    Is_Genomics_Product__c=true);
        productsForInsert.add ( prod );

        prod = new Product2 (Name = 'Cord Blood + Cord Tissue + Placenta + Exosomes + M&M 20yr Storage', 
                                	IsActive = true, 
                                	ProductCode='CBCTPEXMM20Yr',
                                	Family = 'Storage');
        productsForInsert.add ( prod );

        prod = new Product2 (Name = 'Cord Blood + Cord Tissue + Placenta + Exosomes + M&M Lifetime Storage', 
                                	IsActive = true, 
                                	ProductCode='CBCTPEXMMLifetime',
                                	Family = 'Storage');
        productsForInsert.add ( prod );

        prod = new Product2 (Name = 'Cord Blood + Cord Tissue + Placenta + Exosomes 20yr Storage', 
                                	IsActive = true, 
                                	ProductCode='CBCTPEX20Yr',
                                	Family = 'Storage');
        productsForInsert.add ( prod );

        prod = new Product2 (Name = 'Cord Blood + Cord Tissue + Placenta + Exosomes Lifetime Storage', 
                                	IsActive = true, 
                                	ProductCode='CBCTPEXLifetime',
                                	Family = 'Storage');
        productsForInsert.add ( prod );

        prod = new Product2 (Name = 'Exosomes', 
                                	IsActive = true, 
                                	ProductCode='EX',
                                	Family = 'Product',
                                    Is_Biobanking_Product__c=true);
        productsForInsert.add ( prod );

        prod = new Product2 (Name = 'Exosomes 20yr Storage', 
                                	IsActive = true, 
                                	ProductCode='EX20Yr',
                                	Family = 'Storage');
        productsForInsert.add ( prod );

        prod = new Product2 (Name = 'Exosomes Lifetime Storage', 
                                	IsActive = true, 
                                	ProductCode='EXLifetime',
                                	Family = 'Storage');
        productsForInsert.add ( prod );

        prod = new Product2 (Name = 'My Genome - Premium', 
                                	IsActive = true, 
                                	ProductCode='MGP',
                                	Family = 'Product',
                                    Is_Genomics_Product__c=true);
        productsForInsert.add ( prod );

        prod = new Product2 (Name = 'My Genome - Premium + Newborn Panel', 
                                	IsActive = true, 
                                	ProductCode='MM',
                                	Family = 'Product',
                                    Is_Genomics_Product__c=true);
        productsForInsert.add ( prod );

        prod = new Product2 (Name = 'My Genome - Standard', 
                                	IsActive = true, 
                                	ProductCode='MGS',
                                	Family = 'Product',
                                    Is_Genomics_Product__c=true);
        productsForInsert.add ( prod );

        prod = new Product2 (Name = 'Newborn Panel', 
                                	IsActive = true, 
                                	ProductCode='NBP',
                                	Family = 'Product',
                                    Is_Genomics_Product__c=true);
        productsForInsert.add ( prod );

        prod = new Product2 (Name = 'Placenta 20yr Storage', 
                                	IsActive = true, 
                                	ProductCode='P20Yr',
                                	Family = 'Storage');
        productsForInsert.add ( prod );

        prod = new Product2 (Name = 'Placenta Lifetime Storage', 
                                	IsActive = true, 
                                	ProductCode='PLifetime',
                                	Family = 'Storage');
        productsForInsert.add ( prod );
        
        insert productsForInsert;
        
        Map < string, sObject > productMap = Toolkit.indexedSObjectMap ( productsForInsert, 'ProductCode' );
        
        // Create Pricebook Entries
        List < PricebookEntry > pricebookEntriesForInsert = new List < PricebookEntry > ();
        
        PricebookEntry standardPrice = new PricebookEntry (Pricebook2Id = standardPriceBookId, 
                                                           Product2Id = (Id) productMap.get ( 'CB' ).get ( 'Id' ),
                                                           UnitPrice = 1600, 
                                                           IsActive = true);
        pricebookEntriesForInsert.add ( standardPrice );

                        standardPrice = new PricebookEntry (Pricebook2Id = customPriceBookId, 
                                                           Product2Id = (Id) productMap.get ( 'CB' ).get ( 'Id' ),
                                                           UnitPrice = 1600, 
                                                           IsActive = true);
        pricebookEntriesForInsert.add ( standardPrice );

                        standardPrice = new PricebookEntry (Pricebook2Id = standardPriceBookId, 
                                                           Product2Id = (Id) productMap.get ( 'CT' ).get ( 'Id' ),
                                                           UnitPrice = 1600, 
                                                           IsActive = true);
        pricebookEntriesForInsert.add ( standardPrice );

                        standardPrice = new PricebookEntry (Pricebook2Id = customPriceBookId, 
                                                           Product2Id = (Id) productMap.get ( 'CT' ).get ( 'Id' ),
                                                           UnitPrice = 1600, 
                                                           IsActive = true);
        pricebookEntriesForInsert.add ( standardPrice );

                        standardPrice = new PricebookEntry (Pricebook2Id = standardPriceBookId, 
                                                            Product2Id = (Id) productMap.get ( 'PT' ).get ( 'Id' ),
                                                            UnitPrice = 1600, 
                                                            IsActive = true);
        pricebookEntriesForInsert.add ( standardPrice );

                        standardPrice = new PricebookEntry (Pricebook2Id = customPriceBookId, 
                                                            Product2Id = (Id) productMap.get ( 'PT' ).get ( 'Id' ),
                                                            UnitPrice = 1600, 
                                                            IsActive = true);
        pricebookEntriesForInsert.add ( standardPrice );

        				standardPrice = new PricebookEntry (Pricebook2Id = standardPriceBookId, 
                                                           Product2Id = (Id) productMap.get ( 'CBCT' ).get ( 'Id' ),
                                                           UnitPrice = 2600, 
                                                           IsActive = true);
        pricebookEntriesForInsert.add ( standardPrice );

                        standardPrice = new PricebookEntry (Pricebook2Id = customPriceBookId, 
                                                           Product2Id = (Id) productMap.get ( 'CBCT' ).get ( 'Id' ),
                                                           UnitPrice = 2600, 
                                                           IsActive = true);
        pricebookEntriesForInsert.add ( standardPrice );
        
        				standardPrice = new PricebookEntry (Pricebook2Id = standardPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'CBCTP' ).get ( 'Id' ),
                                            UnitPrice = 3100, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );

                        standardPrice = new PricebookEntry (Pricebook2Id = customPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'CBCTP' ).get ( 'Id' ),
                                            UnitPrice = 3100, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );
                        standardPrice = new PricebookEntry (Pricebook2Id = standardPriceBookId, 
                                    Product2Id = (Id) productMap.get ( 'CBCTPEX' ).get ( 'Id' ),
                                    UnitPrice = 3100, 
                                    IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );

                        standardPrice = new PricebookEntry (Pricebook2Id = customPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'CBCTPEX' ).get ( 'Id' ),
                                            UnitPrice = 3100, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );
                		
        
                        standardPrice = new PricebookEntry (Pricebook2Id = standardPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'CBCTPEXMM' ).get ( 'Id' ),
                                            UnitPrice = 3822, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );

                        standardPrice = new PricebookEntry (Pricebook2Id = customPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'CBCTPEXMM' ).get ( 'Id' ),
                                            UnitPrice = 3822, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );
                				
                        standardPrice = new PricebookEntry (Pricebook2Id = standardPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'EX' ).get ( 'Id' ),
                                            UnitPrice = 3100, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );

                        standardPrice = new PricebookEntry (Pricebook2Id = customPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'EX' ).get ( 'Id' ),
                                            UnitPrice = 3100, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );

                				standardPrice = new PricebookEntry (Pricebook2Id = standardPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'MGP' ).get ( 'Id' ),
                                            UnitPrice = 3100, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );

                        standardPrice = new PricebookEntry (Pricebook2Id = customPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'MGP' ).get ( 'Id' ),
                                            UnitPrice = 3100, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );


                				standardPrice = new PricebookEntry (Pricebook2Id = standardPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'MGS' ).get ( 'Id' ),
                                            UnitPrice = 3100, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );

                        standardPrice = new PricebookEntry (Pricebook2Id = customPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'MGS' ).get ( 'Id' ),
                                            UnitPrice = 3100, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );

                        standardPrice = new PricebookEntry (Pricebook2Id = standardPriceBookId, 
                                                            Product2Id = (Id) productMap.get ( 'NBP' ).get ( 'Id' ),
                                                            UnitPrice = 3100, 
                                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );

                        standardPrice = new PricebookEntry (Pricebook2Id = customPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'NBP' ).get ( 'Id' ),
                                            UnitPrice = 3100, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );

        				standardPrice = new PricebookEntry (Pricebook2Id = standardPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'CB20Yr' ).get ( 'Id' ),
                                            UnitPrice = 1700, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );

                        standardPrice = new PricebookEntry (Pricebook2Id = customPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'CB20Yr' ).get ( 'Id' ),
                                            UnitPrice = 1700, 
                                            IsActive = true);

        pricebookEntriesForInsert.add ( standardPrice );
        
        				standardPrice = new PricebookEntry (Pricebook2Id = standardPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'CBCT20Yr' ).get ( 'Id' ),
                                            UnitPrice = 3100, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );

                        standardPrice = new PricebookEntry (Pricebook2Id = customPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'CBCT20Yr' ).get ( 'Id' ),
                                            UnitPrice = 3100, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );

        				standardPrice = new PricebookEntry (Pricebook2Id = standardPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'CBCTP20Yr' ).get ( 'Id' ),
                                            UnitPrice = 3500, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );

                        standardPrice = new PricebookEntry (Pricebook2Id = customPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'CBCTP20Yr' ).get ( 'Id' ),
                                            UnitPrice = 3500, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );
        
        				
        				standardPrice = new PricebookEntry (Pricebook2Id = standardPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'CBLifetime' ).get ( 'Id' ),
                                            UnitPrice = 3500, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );

                        standardPrice = new PricebookEntry (Pricebook2Id = customPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'CBLifetime' ).get ( 'Id' ),
                                            UnitPrice = 3500, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );
        
        				standardPrice = new PricebookEntry (Pricebook2Id = standardPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'CBCTLifetime' ).get ( 'Id' ),
                                            UnitPrice = 6300, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );

                        standardPrice = new PricebookEntry (Pricebook2Id = customPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'CBCTLifetime' ).get ( 'Id' ),
                                            UnitPrice = 6300, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );
        
        				standardPrice = new PricebookEntry (Pricebook2Id = standardPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'CBCTPLifetime' ).get ( 'Id' ),
                                            UnitPrice = 7100, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );

                        standardPrice = new PricebookEntry (Pricebook2Id = customPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'CBCTPLifetime' ).get ( 'Id' ),
                                            UnitPrice = 7100, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );

        standardPrice = new PricebookEntry (Pricebook2Id = standardPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'CBCTPEXMM20Yr' ).get ( 'Id' ),
                                            UnitPrice = 4399, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );

                        standardPrice = new PricebookEntry (Pricebook2Id = customPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'CBCTPEXMM20Yr' ).get ( 'Id' ),
                                            UnitPrice = 4399, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );

        standardPrice = new PricebookEntry (Pricebook2Id = standardPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'CBCTPEXMMLifetime' ).get ( 'Id' ),
                                            UnitPrice = 9099, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );

                        standardPrice = new PricebookEntry (Pricebook2Id = customPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'CBCTPEXMMLifetime' ).get ( 'Id' ),
                                            UnitPrice = 9099, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );
        
        				standardPrice = new PricebookEntry (Pricebook2Id = standardPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'RushShip' ).get ( 'Id' ),
                                            UnitPrice = 200, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );

                        standardPrice = new PricebookEntry (Pricebook2Id = customPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'RushShip' ).get ( 'Id' ),
                                            UnitPrice = 200, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );
        
                        standardPrice = new PricebookEntry (Pricebook2Id = standardPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'StndShip' ).get ( 'Id' ),
                                            UnitPrice = 79, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );

                        standardPrice = new PricebookEntry (Pricebook2Id = customPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'StndShip' ).get ( 'Id' ),
                                            UnitPrice = 79, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );
        
        				standardPrice = new PricebookEntry (Pricebook2Id = standardPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'CollKit' ).get ( 'Id' ),
                                            UnitPrice = 199, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );

                        standardPrice = new PricebookEntry (Pricebook2Id = customPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'CollKit' ).get ( 'Id' ),
                                            UnitPrice = 199, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );



        standardPrice = new PricebookEntry (Pricebook2Id = standardPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'CBCTPEX20Yr' ).get ( 'Id' ),
                                            UnitPrice = 199, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );

                        standardPrice = new PricebookEntry (Pricebook2Id = customPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'CBCTPEX20Yr' ).get ( 'Id' ),
                                            UnitPrice = 199, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );




        standardPrice = new PricebookEntry (Pricebook2Id = standardPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'CBCTPEXLifetime' ).get ( 'Id' ),
                                            UnitPrice = 199, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );

                        standardPrice = new PricebookEntry (Pricebook2Id = customPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'CBCTPEXLifetime' ).get ( 'Id' ),
                                            UnitPrice = 199, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );


        standardPrice = new PricebookEntry (Pricebook2Id = standardPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'EX20Yr' ).get ( 'Id' ),
                                            UnitPrice = 199, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );

                        standardPrice = new PricebookEntry (Pricebook2Id = customPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'EX20Yr' ).get ( 'Id' ),
                                            UnitPrice = 199, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );


        standardPrice = new PricebookEntry (Pricebook2Id = standardPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'EXLifetime' ).get ( 'Id' ),
                                            UnitPrice = 199, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );

                        standardPrice = new PricebookEntry (Pricebook2Id = customPriceBookId, 
                                            Product2Id = (Id) productMap.get ( 'EXLifetime' ).get ( 'Id' ),
                                            UnitPrice = 199, 
                                            IsActive = true);
        
        pricebookEntriesForInsert.add ( standardPrice );


        insert pricebookEntriesForInsert;

        // Items for Kulterra
        // Payment Center Settings
        fw1__Payment_Center_Setting__c s = new fw1__Payment_Center_Setting__c();
        s.Name = 'Default Settings';
        insert s;
        
        fw1.PackagedData.restoreStripeData();

        // Payment Center Ext Settings
        fw2__Payment_Center_Extension_Settings__c ext = new fw2__Payment_Center_Extension_Settings__c();
        ext.fw2__Do_Not_Copy_Line_Items__c = true;
        insert ext;

        // Create Ambassador Account
        Account ambassador = new Account();
        ambassador.Name = 'Ambassador Account';
        insert ambassador;
        
        // create custom setting - Americord_Settings__c 
        // https://developer.salesforce.com/forums/?id=906F000000092ynIAA
        Americord_Settings__c acs = new Americord_Settings__c();
        	acs.Current_Price_Book__c = customPriceBookId;
            acs.Deposit_Amount__c = 199;
            acs.Ambassador_Account_ID__c = ambassador.id;
 	     	insert acs;
 
			    
    }

    // object creation

    public static Opportunity createOpportunity ( string oppName, string stageName, boolean insertObject ) {

        // Create an account
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;
        
        //create contact
        Contact c = new Contact();
        c.AccountId = a.Id;
        c.FirstName = 'testxx';
        c.LastName = 'testxx';
        c.Email = 'testxx@test.com';
        insert c;

        // Create an opportunity
        User u = getCurrentSalesRep();

        Opportunity o = new Opportunity ();
        o.Name = oppName;
        o.OwnerId = u.Id;
        o.StageName = stageName;
        o.CloseDate = Date.today();
        o.AccountId = a.Id;
        o.Number_of_Births__c = 'Single';
        o.Cord_Blood_2_0__c = 1;
        o.Cord_Tissue__c = 1;
        o.Placenta_2_0__c = 0;
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

        if ( insertObject ) {
            insert o;
        }
        
        return o;
    }

    public static User getCurrentSalesRep() {
        Schema.SObjectType s = Schema.getGlobalDescribe().get('fw1__Invoice__c') ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get('Sales_rep__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        System.debug('ple[0].getLabel() +' +ple[0].getValue());

        User u = [SELECT ID FROM User WHERE CommunityNickname=:ple[0].getValue()];
        return u;
    }

    // getters
    public static fw1__Invoice__c getInvoice(string opptyId) {
        List<fw1__Invoice__c> invs = new List<fw1__Invoice__c>();
        invs = [
            SELECT fw1__Account__c,Cord_Blood_2_0_Stored__c,Cord_Tissue_Stored__c,Placenta_2_0_Stored__c,Placenta_Tissue_Stored__c,
            Cord_Blood_2_0_Ordered__c,Cord_Tissue_Ordered__c,Placenta_2_0_Ordered__c,Placenta_Tissue_Ordered__c,
            Lab__c,Lab__r.Cord_Blood_Collection_Completed__c,Storage_Plan_Ordered__c,Payment_Plan_Ordered__c,
            Storage_Plan_Stored__c,Payment_Plan_Stored__c,fw1__Total_Lines_Count__c
            FROM fw1__Invoice__c
            WHERE fw2__Opportunity__c = :opptyId
        ];
        
        if (invs.size() > 0)
        	return invs[0];
        else
            return null;
    }
}