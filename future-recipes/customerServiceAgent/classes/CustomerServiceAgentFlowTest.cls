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
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('customer_id', 'CUST-12345');
        inputs.put('subject', 'Test Case Subject');
        inputs.put('case_description', 'Test Case Description');
        inputs.put('priority', 'High');
        inputs.put('issue_type', 'Technical');

        // Run the flow
        Test.startTest();
        Flow.Interview.CreateCase flowInterview = new Flow.Interview.CreateCase(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        String caseId = (String) flowInterview.getVariableValue('case_id');
        Assert.areNotEqual(null, caseId, 'Case ID should be returned');

        // Verify case was created
        Case createdCase = [
            SELECT Id, Subject, Description, Priority, Type, ContactId
            FROM Case
            WHERE Id = :caseId
        ];
        Assert.areEqual(
            'Test Case Subject',
            createdCase.Subject,
            'Subject should match'
        );
        Assert.areEqual(
            'Test Case Description',
            createdCase.Description,
            'Description should match'
        );
        Assert.areEqual('High', createdCase.Priority, 'Priority should match');
        Assert.areEqual('Technical', createdCase.Type, 'Type should match');
    }

    @IsTest
    static void testUpdateCaseSuccess() {
        // Create a test case first
        Contact testContact = [
            SELECT Id
            FROM Contact
            WHERE Customer_ID__c = 'CUST-12345'
            LIMIT 1
        ];
        Case testCase = new Case(
            Subject = 'Original Subject',
            Description = 'Original Description',
            ContactId = testContact.Id,
            Status = 'New'
        );
        insert testCase;

        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('case_id', testCase.Id);
        inputs.put('status', 'In Progress');
        inputs.put('notes', 'Updated notes');

        // Run the flow
        Test.startTest();
        Flow.Interview.UpdateCase flowInterview = new Flow.Interview.UpdateCase(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        Boolean updated = (Boolean) flowInterview.getVariableValue('updated');
        Assert.areEqual(true, updated, 'Update should be successful');

        // Verify case was updated
        Case updatedCase = [
            SELECT Id, Status
            FROM Case
            WHERE Id = :testCase.Id
        ];
        Assert.areEqual(
            'In Progress',
            updatedCase.Status,
            'Status should be updated'
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
        // Create a test case first
        Contact testContact = [
            SELECT Id
            FROM Contact
            WHERE Customer_ID__c = 'CUST-12345'
            LIMIT 1
        ];
        Case testCase = new Case(
            Subject = 'Test Case',
            ContactId = testContact.Id,
            Status = 'New'
        );
        insert testCase;

        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('case_id', testCase.Id);
        inputs.put('reason', 'Complex technical issue');
        inputs.put('specialist_team', 'Technical Support');

        // Run the flow
        Test.startTest();
        Flow.Interview.EscalateCase flowInterview = new Flow.Interview.EscalateCase(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
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

        // Verify case was updated
        Case escalatedCase = [
            SELECT Id, Status
            FROM Case
            WHERE Id = :testCase.Id
        ];
        Assert.areEqual(
            'Escalated',
            escalatedCase.Status,
            'Status should be Escalated'
        );
    }

    @IsTest
    static void testSendSatisfactionSurvey() {
        // Create a test case first
        Contact testContact = [
            SELECT Id
            FROM Contact
            WHERE Customer_ID__c = 'CUST-12345'
            LIMIT 1
        ];
        Case testCase = new Case(
            Subject = 'Test Case',
            ContactId = testContact.Id,
            Status = 'Closed'
        );
        insert testCase;

        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('case_id', testCase.Id);
        inputs.put('customer_email', 'test@example.com');

        // Run the flow
        Test.startTest();
        Flow.Interview.SendSatisfactionSurvey flowInterview = new Flow.Interview.SendSatisfactionSurvey(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        Boolean sent = (Boolean) flowInterview.getVariableValue('sent');
        Assert.areEqual(true, sent, 'Survey should be sent');

        // Verify survey log was created
        List<ASR_Survey_Log__c> surveyLogs = [
            SELECT Id
            FROM ASR_Survey_Log__c
            WHERE Case__c = :testCase.Id
        ];
        Assert.areEqual(1, surveyLogs.size(), 'Survey log should be created');
    }
}
