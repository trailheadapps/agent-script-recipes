/**
 * @description Test class for the AnalyzeBillingHistory flow
 * used in the subagent delegation recipe
 */
@IsTest
private class AnalyzeBillingHistoryFlowTest {
    @IsTest
    static void testAnalyzeBillingHistory() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('customer_id', 'CUST-12345');
        inputs.put('issue_description', 'I was charged twice this month');

        // Run the flow
        Test.startTest();
        Flow.Interview.AnalyzeBillingHistory flowInterview = new Flow.Interview.AnalyzeBillingHistory(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        String findings = (String) flowInterview.getVariableValue('findings');
        Boolean discrepancyFound = (Boolean) flowInterview.getVariableValue(
            'discrepancy_found'
        );

        Assert.isNotNull(findings, 'Findings should be returned');
        Assert.isTrue(
            discrepancyFound,
            'Should indicate a discrepancy was found'
        );
    }
}
