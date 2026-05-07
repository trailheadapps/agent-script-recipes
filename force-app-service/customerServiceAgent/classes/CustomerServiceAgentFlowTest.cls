/**
 * @description Test class for Customer Service Agent Flows
 * Tests all flows used in the customer service agent recipe
 */
@IsTest
private class CustomerServiceAgentFlowTest {
    @TestSetup
    static void setup() {
        // Create test contact with customer ID
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Customer',
            Email = 'test@example.com',
            Customer_ID__c = 'CUST-12345',
            Loyalty_Tier__c = 'Premium'
        );
        insert testContact;

        // Create test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        testContact.AccountId = testAccount.Id;
        update testContact;
    }

    @IsTest
    static void testFetchCustomerSuccess() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('customer_id', 'CUST-12345');

        // Run the flow
        Test.startTest();
        Flow.Interview.FetchCustomer flowInterview = new Flow.Interview.FetchCustomer(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        String name = (String) flowInterview.getVariableValue('name');
        String email = (String) flowInterview.getVariableValue('email');
        String tier = (String) flowInterview.getVariableValue('tier');

        Assert.areEqual('Customer', name, 'Customer name should match');
        Assert.areEqual('test@example.com', email, 'Email should match');
        Assert.areEqual('Premium', tier, 'Tier should match');
    }

    @IsTest
    static void testCreateCaseSuccess() {
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('subject', 'Test Case Subject');

        Test.startTest();
        Flow.Interview.CreateCase flowInterview = new Flow.Interview.CreateCase(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        String caseNumber = (String) flowInterview.getVariableValue(
            'case_number'
        );
        Assert.areEqual(
            '00001234',
            caseNumber,
            'Case number should be returned'
        );
    }

    @IsTest
    static void testSearchKnowledgeBase() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('issue_type', 'Technical');
        inputs.put('keywords', 'password reset');

        // Run the flow
        Test.startTest();
        Flow.Interview.SearchKnowledgeBase flowInterview = new Flow.Interview.SearchKnowledgeBase(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the flow executes and returns articles
        List<String> articles = (List<String>) flowInterview.getVariableValue(
            'articles'
        );
        Assert.areNotEqual(null, articles, 'Articles should be returned');
        Assert.areEqual(
            true,
            articles.size() > 0,
            'At least one article should be returned'
        );
    }

    @IsTest
    static void testEscalateCase() {
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('case_id', '500000000000001');
        inputs.put('reason', 'Complex technical issue');
        inputs.put('specialist_team', 'Technical Support');

        Test.startTest();
        Flow.Interview.EscalateCase flowInterview = new Flow.Interview.EscalateCase(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        Boolean escalated = (Boolean) flowInterview.getVariableValue(
            'escalated'
        );
        String specialistAssigned = (String) flowInterview.getVariableValue(
            'specialist_assigned'
        );
        Assert.areEqual(true, escalated, 'Case should be escalated');
        Assert.areEqual(
            'Technical Support',
            specialistAssigned,
            'Specialist team should be assigned'
        );
    }
}
