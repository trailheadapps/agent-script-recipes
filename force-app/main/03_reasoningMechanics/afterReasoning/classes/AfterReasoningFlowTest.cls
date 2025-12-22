/**
 * @description Test class for After Reasoning Flows
 * Tests all flows used in the after reasoning recipe
 */
@IsTest
private class AfterReasoningFlowTest {
    @IsTest
    static void testGetCurrentTimestamp() {
        // Run the flow (no inputs required)
        Map<String, Object> inputs = new Map<String, Object>();

        Test.startTest();
        Flow.Interview.GetCurrentTimestamp flowInterview = new Flow.Interview.GetCurrentTimestamp(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        String currentTimestamp = (String) flowInterview.getVariableValue(
            'current_timestamp'
        );
        Assert.areNotEqual(
            null,
            currentTimestamp,
            'Timestamp should be returned'
        );
    }

    @IsTest
    static void testLogEvent() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('event_type', 'User Action');
        inputs.put('event_data', 'Test event description');

        // Run the flow
        Test.startTest();
        Flow.Interview.LogEvent flowInterview = new Flow.Interview.LogEvent(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        Boolean logged = (Boolean) flowInterview.getVariableValue('logged');
        Assert.areEqual(true, logged, 'Event should be logged successfully');

        // Verify event log was created
        List<ASR_Agent_Event_Log__c> logs = [
            SELECT Id, Event_Type__c, Event_Data__c
            FROM ASR_Agent_Event_Log__c
            WHERE Event_Type__c = 'User Action'
        ];
        Assert.areEqual(1, logs.size(), 'Event log should be created');
    }
}
