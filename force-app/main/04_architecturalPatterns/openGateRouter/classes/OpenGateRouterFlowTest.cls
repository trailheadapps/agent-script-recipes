@IsTest
private class OpenGateRouterFlowTest {
    @IsTest
    static void testCheckCustomerAuthentication() {
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('account_number', 'AC-5678');
        inputs.put('verification_code', '991234');

        Test.startTest();
        Flow.Interview.CheckCustomerAuthentication flowInterview = new Flow.Interview.CheckCustomerAuthentication(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        Boolean isAuthenticated = (Boolean) flowInterview.getVariableValue(
            'is_authenticated'
        );
        String customerId = (String) flowInterview.getVariableValue(
            'customer_id'
        );
        String customerName = (String) flowInterview.getVariableValue(
            'customer_name'
        );

        Assert.areEqual(true, isAuthenticated, 'Authentication should succeed');
        Assert.areEqual(
            'CUST-001234',
            customerId,
            'Customer ID should be returned'
        );
        Assert.areEqual(
            'Alex Johnson',
            customerName,
            'Customer name should be returned'
        );
    }

    @IsTest
    static void testProcessProductReturn() {
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('customer_id', 'CUST-001234');
        inputs.put('order_id', 'ORD-44521');
        inputs.put('reason', 'screen has dead pixels');

        Test.startTest();
        Flow.Interview.ProcessProductReturn flowInterview = new Flow.Interview.ProcessProductReturn(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        String confirmationNumber = (String) flowInterview.getVariableValue(
            'confirmation_number'
        );
        Boolean success = (Boolean) flowInterview.getVariableValue('success');

        Assert.areEqual(
            'RTN-2024-78432',
            confirmationNumber,
            'Confirmation number should be returned'
        );
        Assert.areEqual(
            true,
            success,
            'Return should be processed successfully'
        );
    }
}
