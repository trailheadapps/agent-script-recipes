/**
 * @description Test class for Safety and Guardrails Flows
 * Tests all flows used in the safety and guardrails recipe
 */
@IsTest
private class SafetyAndGuardrailsFlowTest {
    @TestSetup
    static void setup() {
        // Create test account with contacts
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = testAccount.Id
        );
        insert testContact;
    }

    @IsTest
    static void testCheckDependenciesHasDependencies() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>{
            'record_id' => testAccount.Id
        };

        // Run the flow
        Test.startTest();
        Flow.Interview.CheckDependencies flowInterview = new Flow.Interview.CheckDependencies(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        Decimal count = (Decimal) flowInterview.getVariableValue('count');
        Assert.areEqual(1, count, 'Should find 1 contact');
    }

    @IsTest
    static void testCheckDependenciesNoDependencies() {
        // Create account without contacts
        Account testAccount = new Account(Name = 'Empty Account');
        insert testAccount;

        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>{
            'record_id' => testAccount.Id
        };

        // Run the flow
        Test.startTest();
        Flow.Interview.CheckDependencies flowInterview = new Flow.Interview.CheckDependencies(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        Decimal count = (Decimal) flowInterview.getVariableValue('count');
        Assert.areEqual(0, count, 'Should find 0 contacts');
    }

    @IsTest
    static void testDeleteRecordConfirmed() {
        Account testAccount = new Account(Name = 'To Delete');
        insert testAccount;
        String accountId = testAccount.Id;

        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>{
            'record_id' => accountId
        };

        // Run the flow
        Test.startTest();
        Flow.Interview.DeleteRecord flowInterview = new Flow.Interview.DeleteRecord(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        Boolean success = (Boolean) flowInterview.getVariableValue('success');
        Assert.areEqual(true, success, 'Record should be deleted successfully');

        // Verify record was deleted
        List<Account> deletedAccounts = [
            SELECT Id
            FROM Account
            WHERE Id = :accountId
        ];
        Assert.areEqual(0, deletedAccounts.size(), 'Account should be deleted');
    }
}
