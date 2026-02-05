/**
 * @description Test class for Complex State Management Flows
 * Tests all flows used in the complex state management recipe
 */
@IsTest
private class ComplexStateManagementFlowTest {
    @IsTest
    static void testCalculateTaskStats() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('tasks', new List<SObject>());

        // Run the flow
        Test.startTest();
        Flow.Interview.CalculateTaskStats flowInterview = new Flow.Interview.CalculateTaskStats(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        String statsJson = (String) flowInterview.getVariableValue(
            'stats_json'
        );
        Assert.isNotNull(statsJson, 'Stats JSON should be returned');
        Assert.isTrue(
            statsJson.contains('completed'),
            'Stats should contain completed count'
        );
    }

    @IsTest
    static void testSaveTasks() {
        // Create and insert test tasks first (the flow uses recordUpdates which requires IDs)
        List<ASR_Task__c> tasks = new List<ASR_Task__c>();
        for (Integer i = 0; i < 3; i++) {
            tasks.add(new ASR_Task__c(Status__c = 'Pending'));
        }
        insert tasks;

        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('tasks', tasks);

        // Run the flow
        Test.startTest();
        Flow.Interview.SaveTasks flowInterview = new Flow.Interview.SaveTasks(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        Boolean success = (Boolean) flowInterview.getVariableValue('success');
        Decimal taskCount = (Decimal) flowInterview.getVariableValue(
            'task_count'
        );

        Assert.isTrue(success, 'Tasks should be saved successfully');
        Assert.areEqual(3, taskCount, 'Task count should match');
    }
}
