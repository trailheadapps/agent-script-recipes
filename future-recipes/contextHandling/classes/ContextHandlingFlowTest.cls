/**
 * @description Test class for Context Handling Flows
 * Tests all flows used in the context handling recipe
 */
@IsTest
private class ContextHandlingFlowTest {
    @TestSetup
    static void setup() {
        // Create test contact with user ID
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            User_ID__c = 'USER-12345'
        );
        insert testContact;
    }

    @IsTest
    static void testLoadUserProfileSuccess() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('user_id', 'USER-12345');

        // Run the flow
        Test.startTest();
        Flow.Interview.LoadUserProfile flowInterview = new Flow.Interview.LoadUserProfile(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        String name = (String) flowInterview.getVariableValue('name');
        Assert.areEqual('User', name, 'Name should match');
    }

    @IsTest
    static void testLogInteractionSuccess() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('session_id', 'SESSION-12345');
        inputs.put('user_id', 'USER-12345');
        inputs.put('channel', 'Web');

        // Run the flow
        Test.startTest();
        Flow.Interview.LogInteraction flowInterview = new Flow.Interview.LogInteraction(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        Boolean success = (Boolean) flowInterview.getVariableValue('success');
        Assert.areEqual(
            true,
            success,
            'Interaction should be logged successfully'
        );

        // Verify interaction log was created
        List<ASR_Interaction_Log__c> logs = [
            SELECT Id, Session_ID__c, User_ID__c, Channel__c
            FROM ASR_Interaction_Log__c
            WHERE Session_ID__c = 'SESSION-12345'
        ];
        Assert.areEqual(1, logs.size(), 'Interaction log should be created');
    }
}
