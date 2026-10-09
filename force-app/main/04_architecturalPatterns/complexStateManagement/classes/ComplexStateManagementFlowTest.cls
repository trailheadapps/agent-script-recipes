/**
 * @description Test class for Complex State Management Flows
 * Tests the flows that load, complete and summarize task records
 */
@IsTest
private class ComplexStateManagementFlowTest {
    @TestSetup
    static void setup() {
        insert new List<ASR_Task__c>{
            new ASR_Task__c(
                Title__c = 'Write README',
                Status__c = 'Pending',
                Priority__c = 'High',
                External_ID__c = 1
            ),
            new ASR_Task__c(
                Title__c = 'Review flows',
                Status__c = 'Pending',
                Priority__c = 'Medium',
                External_ID__c = 2
            ),
            new ASR_Task__c(
                Title__c = 'Book team sync',
                Status__c = 'Completed',
                Priority__c = 'High',
                External_ID__c = 3
            )
        };
    }

    @IsTest
    static void testLoadTasksWithoutPriority() {
        // Run the flow without a priority filter
        Test.startTest();
        Flow.Interview.LoadTasks flowInterview = new Flow.Interview.LoadTasks(
            new Map<String, Object>()
        );
        flowInterview.start();
        Test.stopTest();

        // Verify every task is returned, sorted by External ID
        List<SObject> tasks = (List<SObject>) flowInterview.getVariableValue(
            'tasks'
        );
        Assert.areEqual(3, tasks.size(), 'All tasks should be loaded');
        Assert.areEqual(
            'Write README',
            ((ASR_Task__c) tasks[0]).Title__c,
            'Tasks should be sorted by External ID'
        );
    }

    @IsTest
    static void testLoadTasksByPriority() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('priority', 'High');

        // Run the flow
        Test.startTest();
        Flow.Interview.LoadTasks flowInterview = new Flow.Interview.LoadTasks(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify only high priority tasks are returned
        List<SObject> tasks = (List<SObject>) flowInterview.getVariableValue(
            'tasks'
        );
        Assert.areEqual(2, tasks.size(), 'Only high priority tasks expected');
        for (SObject task : tasks) {
            Assert.areEqual(
                'High',
                ((ASR_Task__c) task).Priority__c,
                'Every task should be high priority'
            );
        }
    }

    @IsTest
    static void testCompleteTask() {
        ASR_Task__c pendingTask = [
            SELECT Id
            FROM ASR_Task__c
            WHERE Title__c = 'Write README'
            LIMIT 1
        ];

        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('task_id', pendingTask.Id);

        // Run the flow
        Test.startTest();
        Flow.Interview.CompleteTask flowInterview = new Flow.Interview.CompleteTask(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the task is now completed
        Assert.isTrue(
            (Boolean) flowInterview.getVariableValue('success'),
            'Completing an existing task should succeed'
        );
        ASR_Task__c updatedTask = [
            SELECT Status__c
            FROM ASR_Task__c
            WHERE Id = :pendingTask.Id
        ];
        Assert.areEqual(
            'Completed',
            updatedTask.Status__c,
            'Task status should be Completed'
        );
    }

    @IsTest
    static void testCompleteTaskNotFound() {
        // Create and delete a task to get a valid ID that no longer exists
        ASR_Task__c deletedTask = new ASR_Task__c(Title__c = 'Temporary');
        insert deletedTask;
        delete deletedTask;

        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('task_id', deletedTask.Id);

        // Run the flow
        Test.startTest();
        Flow.Interview.CompleteTask flowInterview = new Flow.Interview.CompleteTask(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the flow reports failure
        Assert.isFalse(
            (Boolean) flowInterview.getVariableValue('success'),
            'Completing a missing task should fail'
        );
    }

    @IsTest
    static void testCalculateTaskStats() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('tasks', [SELECT Status__c FROM ASR_Task__c]);

        // Run the flow
        Test.startTest();
        Flow.Interview.CalculateTaskStats flowInterview = new Flow.Interview.CalculateTaskStats(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the counts match the task statuses
        Assert.areEqual(
            1,
            (Decimal) flowInterview.getVariableValue('completed_count'),
            'One task should be completed'
        );
        Assert.areEqual(
            2,
            (Decimal) flowInterview.getVariableValue('pending_count'),
            'Two tasks should be pending'
        );
    }

    @IsTest
    static void testCalculateTaskStatsEmptyList() {
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

        // Verify both counts stay at zero
        Assert.areEqual(
            0,
            (Decimal) flowInterview.getVariableValue('completed_count'),
            'Completed count should be zero'
        );
        Assert.areEqual(
            0,
            (Decimal) flowInterview.getVariableValue('pending_count'),
            'Pending count should be zero'
        );
    }
}
