/**
 * @description Test class for Action Description Overrides Flows
 * Tests all flows used in the action description overrides recipe
 */
@IsTest
private class ActionDescriptionOverridesFlowTest {
    @IsTest
    static void testCreateRecord() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('record_type', 'Account');
        inputs.put('data', '{"Name":"Test Account"}');

        // Run the flow
        Test.startTest();
        Flow.Interview.CreateRecord flowInterview = new Flow.Interview.CreateRecord(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        String recordId = (String) flowInterview.getVariableValue('record_id');
        Assert.areNotEqual(null, recordId, 'Record ID should be returned');
    }

    @IsTest
    static void testPerformSearch() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('query', 'test search');
        inputs.put('filters', 'status=active');

        // Run the flow
        Test.startTest();
        Flow.Interview.PerformSearch flowInterview = new Flow.Interview.PerformSearch(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        List<String> results = (List<String>) flowInterview.getVariableValue(
            'results'
        );
        Assert.areNotEqual(null, results, 'Results should be returned');
        Assert.areEqual(1, results.size(), 'Should return at least one result');
    }

    @IsTest
    static void testGenerateReport() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('report_type', 'Sales Report');
        inputs.put('include_charts', true);
        inputs.put('user_id', UserInfo.getUserId());
        inputs.put('format', 'PDF');
        inputs.put('start_date', '2024-01-01');
        inputs.put('end_date', '2024-12-31');

        // Run the flow
        Test.startTest();
        Flow.Interview.GenerateReport flowInterview = new Flow.Interview.GenerateReport(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        String reportUrl = (String) flowInterview.getVariableValue(
            'report_url'
        );
        Assert.areNotEqual(null, reportUrl, 'Report URL should be returned');
        Assert.isTrue(
            reportUrl.startsWith('https://'),
            'Report URL should be a valid URL'
        );
    }
}
