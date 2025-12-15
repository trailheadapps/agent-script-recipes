/**
 * @description Test class for Advanced Reasoning Patterns Flows
 * Tests all flows used in the advanced reasoning patterns recipe
 */
@IsTest
private class AdvancedReasoningPatternsFlowTest {
    @TestSetup
    static void setup() {
        // Create test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create test contact with user ID
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            AccountId = testAccount.Id,
            User_ID__c = 'USER-12345',
            Loyalty_Status__c = 'Gold',
            Lifetime_Value__c = 1500.00
        );
        insert testContact;

        // Create test orders
        ASR_Order__c order1 = new ASR_Order__c(
            AccountId__c = testAccount.Id,
            TotalAmount__c = 500.00,
            EffectiveDate__c = Date.today()
        );
        ASR_Order__c order2 = new ASR_Order__c(
            AccountId__c = testAccount.Id,
            TotalAmount__c = 750.00,
            EffectiveDate__c = Date.today().addDays(-30)
        );
        insert new List<ASR_Order__c>{ order1, order2 };

        // Create test cases
        Case testCase1 = new Case(
            Subject = 'Test Case 1',
            Status = 'Open',
            ContactId = testContact.Id
        );
        Case testCase2 = new Case(
            Subject = 'Test Case 2',
            Status = 'Closed',
            ContactId = testContact.Id
        );
        insert new List<Case>{ testCase1, testCase2 };
    }

    @IsTest
    static void testFetchAccountDataSuccess() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('user_id', 'USER-12345');

        // Run the flow
        Test.startTest();
        Flow.Interview.FetchAccountData flowInterview = new Flow.Interview.FetchAccountData(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        SObject account = (SObject) flowInterview.getVariableValue('account');
        Assert.areNotEqual(null, account, 'Account should be returned');
    }

    @IsTest
    static void testFetchOrderHistorySuccess() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('user_id', 'USER-12345');
        inputs.put('limit', 10);

        // Run the flow
        Test.startTest();
        Flow.Interview.FetchOrderHistory flowInterview = new Flow.Interview.FetchOrderHistory(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        List<SObject> orders = (List<SObject>) flowInterview.getVariableValue(
            'orders'
        );
        Assert.areNotEqual(null, orders, 'Orders should be returned');
        Assert.areEqual(2, orders.size(), 'Should return 2 orders');
    }

    @IsTest
    static void testFetchSupportHistorySuccess() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('user_id', 'USER-12345');

        // Run the flow
        Test.startTest();
        Flow.Interview.FetchSupportHistory flowInterview = new Flow.Interview.FetchSupportHistory(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        List<SObject> tickets = (List<SObject>) flowInterview.getVariableValue(
            'tickets'
        );
        Assert.areNotEqual(null, tickets, 'Tickets should be returned');
        Assert.areEqual(2, tickets.size(), 'Should return 2 tickets');
    }

    @IsTest
    static void testFetchUserProfileSuccess() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('user_id', 'USER-12345');

        // Run the flow
        Test.startTest();
        Flow.Interview.FetchUserProfile flowInterview = new Flow.Interview.FetchUserProfile(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        SObject profile = (SObject) flowInterview.getVariableValue('profile');
        Assert.areNotEqual(null, profile, 'Profile should be returned');
    }

    @IsTest
    static void testCalculateCustomerValue() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('user_id', 'USER-12345');
        inputs.put('orders', new List<SObject>());

        // Run the flow
        Test.startTest();
        Flow.Interview.CalculateCustomerValue flowInterview = new Flow.Interview.CalculateCustomerValue(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        Decimal clv = (Decimal) flowInterview.getVariableValue('clv');
        String loyaltyTier = (String) flowInterview.getVariableValue(
            'loyalty_tier'
        );

        Assert.areNotEqual(null, clv, 'CLV should be returned');
        Assert.areEqual(1500.0, clv, 'CLV should match');
        Assert.areEqual('Gold', loyaltyTier, 'Loyalty tier should match');
    }

    @IsTest
    static void testAssessChurnRisk() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        inputs.put('account', testAccount);
        inputs.put('orders', new List<SObject>());
        inputs.put('support_tickets', new List<SObject>());

        // Run the flow
        Test.startTest();
        Flow.Interview.AssessChurnRisk flowInterview = new Flow.Interview.AssessChurnRisk(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        Decimal riskScore = (Decimal) flowInterview.getVariableValue(
            'risk_score'
        );
        List<String> riskFactors = (List<String>) flowInterview.getVariableValue(
            'risk_factors'
        );

        Assert.areNotEqual(null, riskScore, 'Risk score should be returned');
        Assert.areEqual(85.0, riskScore, 'Risk score should match');
        Assert.areNotEqual(
            null,
            riskFactors,
            'Risk factors should be returned'
        );
    }

    @IsTest
    static void testGenerateRecommendations() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        inputs.put('profile', testContact);
        inputs.put('clv', 1500.00);
        inputs.put('churn_risk', 85.0);

        // Run the flow
        Test.startTest();
        Flow.Interview.GenerateRecommendations flowInterview = new Flow.Interview.GenerateRecommendations(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        List<String> recommendations = (List<String>) flowInterview.getVariableValue(
            'recommendations'
        );
        Assert.areNotEqual(
            null,
            recommendations,
            'Recommendations should be returned'
        );
        Assert.areEqual(
            1,
            recommendations.size(),
            'Should return at least one recommendation'
        );
    }
}
