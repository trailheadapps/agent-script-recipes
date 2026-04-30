/**
 * @description Test class for Action Callbacks Flows
 * Tests all flows used in the action callbacks recipe
 */
@IsTest
private class ActionCallbacksFlowTest {
    @IsTest
    static void testProcessPaymentSuccess() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('amount', 99.99);
        inputs.put('method', 'Credit Card');

        // Run the flow
        Test.startTest();
        Flow.Interview.ProcessPayment flowInterview = new Flow.Interview.ProcessPayment(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        Boolean success = (Boolean) flowInterview.getVariableValue('success');
        String transactionId = (String) flowInterview.getVariableValue(
            'transaction_id'
        );

        Assert.areEqual(
            true,
            success,
            'Payment should be processed successfully'
        );
        Assert.areNotEqual(
            null,
            transactionId,
            'Transaction ID should be returned'
        );
        Assert.isTrue(
            transactionId.startsWith('TXN-'),
            'Transaction ID should start with TXN-'
        );

        // Verify transaction was created
        List<ASR_Payment_Transaction__c> transactions = [
            SELECT Id, Amount__c, Payment_Method__c, Status__c
            FROM ASR_Payment_Transaction__c
            WHERE Transaction_ID__c = :transactionId
        ];
        Assert.areEqual(
            1,
            transactions.size(),
            'Transaction should be created'
        );
        Assert.areEqual(
            99.99,
            transactions[0].Amount__c,
            'Amount should match'
        );
    }

    @IsTest
    static void testSendReceipt() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('transaction_id', 'TXN-12345');
        inputs.put('email', 'customer@example.com');

        // Run the flow
        Test.startTest();
        Flow.Interview.SendReceipt flowInterview = new Flow.Interview.SendReceipt(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the flow executes without errors
        Assert.areNotEqual(
            null,
            flowInterview,
            'Flow should execute successfully'
        );
    }

    @IsTest
    static void testAwardLoyaltyPoints() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('customer_id', 'CUST-12345');
        inputs.put('points', 100);

        // Run the flow
        Test.startTest();
        Flow.Interview.AwardLoyaltyPoints flowInterview = new Flow.Interview.AwardLoyaltyPoints(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the flow executes without errors
        Assert.areNotEqual(
            null,
            flowInterview,
            'Flow should execute successfully'
        );
    }

    @IsTest
    static void testLogTransaction() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('transaction_id', 'TXN-12345');
        inputs.put('action', 'Payment Processed');

        // Run the flow
        Test.startTest();
        Flow.Interview.LogTransaction flowInterview = new Flow.Interview.LogTransaction(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the flow executes without errors
        Assert.areNotEqual(
            null,
            flowInterview,
            'Flow should execute successfully'
        );
    }
}
