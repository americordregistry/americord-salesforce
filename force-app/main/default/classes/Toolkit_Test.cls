// Unit Tests for Toolkit Helper Class

@isTest
public class Toolkit_Test {
    

    @isTest
    private static void sobjectToMap () {

        Account a = new Account ();
        a.Name = 'Test';
        insert a;

        Test.startTest ();
        Map < string, sObject > testMap = Toolkit.indexedSObjectMap ( [ SELECT Id, Name FROM Account ], 'Name' );
        Test.stopTest ();

        System.AssertEquals ( 'Test', testMap.get ( 'Test' ).get ( 'Name' ));
    }

}