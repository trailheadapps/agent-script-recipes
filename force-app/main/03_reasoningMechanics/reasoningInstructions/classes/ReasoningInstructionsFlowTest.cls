/**
 * @description Test class for Reasoning Instructions Flows
 * Tests all flows used in the reasoning instructions recipe
 */
@IsTest
private class ReasoningInstructionsFlowTest {
    private static final String TEST_ORDER_STATUS = 'Shipped';
    private static final String TEST_TRACKING_NUMBER = '1234567890';

    @TestSetup
    static void setup() {
        // Create test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create test order (OrderNumber is auto-generated)
        ASR_Order__c testOrder = new ASR_Order__c(
            Status__c = TEST_ORDER_STATUS,
            Tracking_Number__c = TEST_TRACKING_NUMBER
        );
        insert testOrder;
    }

    @IsTest
    static void testGetOrderStatusSuccess() {
        // Get the order number from the created order
        ASR_Order__c testOrder = [SELECT Id, Name FROM ASR_Order__c LIMIT 1];

        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('order_id', testOrder.Name);

        // Run the flow
        Test.startTest();
        Flow.Interview.GetOrderStatus flowInterview = new Flow.Interview.GetOrderStatus(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        String status = (String) flowInterview.getVariableValue('status');
        String trackingNumber = (String) flowInterview.getVariableValue(
            'tracking_number'
        );
        SObject details = (SObject) flowInterview.getVariableValue('details');

        Assert.areEqual(TEST_ORDER_STATUS, status);
        Assert.areEqual(TEST_TRACKING_NUMBER, trackingNumber);
        Assert.isNotNull(details, 'Order details should be returned');
    }
}
