/**
 * @description Test class for Subagent Delegation Flows
 * Tests all flows used in the subagent delegation recipe
 */
@IsTest
private class SubagentDelegationFlowTest {
    @IsTest
    static void testCreateEscalationTicket() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('issue_description', 'Test escalation issue');
        inputs.put('issue_type', 'Technical');
        inputs.put('customer_id', 'CUST-12345');

        // Run the flow
        Test.startTest();
        Flow.Interview.CreateEscalationTicket flowInterview = new Flow.Interview.CreateEscalationTicket(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        String ticketId = (String) flowInterview.getVariableValue('ticket_id');
        Assert.areNotEqual(null, ticketId, 'Ticket ID should be returned');

        // Verify case was created
        Case createdCase = [
            SELECT Id, Subject, Description, Type
            FROM Case
            WHERE Id = :ticketId
        ];
        Assert.areEqual(
            'Escalated Issue',
            createdCase.Subject,
            'Subject should match'
        );
        Assert.areEqual(
            'Test escalation issue',
            createdCase.Description,
            'Description should match'
        );
        Assert.areEqual('Technical', createdCase.Type, 'Type should match');
    }

    @IsTest
    static void testAnalyzeTechnicalIssue() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('issue_description', 'System is not responding');

        // Run the flow
        Test.startTest();
        Flow.Interview.AnalyzeTechnicalIssue flowInterview = new Flow.Interview.AnalyzeTechnicalIssue(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        String assessment = (String) flowInterview.getVariableValue(
            'assessment'
        );
        Boolean canResolve = (Boolean) flowInterview.getVariableValue(
            'can_resolve'
        );

        Assert.areNotEqual(null, assessment, 'Assessment should be returned');
        Assert.areEqual(false, canResolve, 'Should indicate cannot resolve');
    }

    @IsTest
    static void testAnalyzeBillingIssue() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('issue_description', 'Incorrect charge on account');
        inputs.put('customer_id', 'CUST-12345');

        // Run the flow
        Test.startTest();
        Flow.Interview.AnalyzeBillingIssue flowInterview = new Flow.Interview.AnalyzeBillingIssue(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        String analysis = (String) flowInterview.getVariableValue('analysis');
        Boolean resolved = (Boolean) flowInterview.getVariableValue('resolved');

        Assert.areNotEqual(null, analysis, 'Analysis should be returned');
        Assert.areEqual(true, resolved, 'Should indicate resolved');
    }
}
