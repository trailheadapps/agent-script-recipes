/**
 * @description Test class for Dynamic Action Routing Flows
 * Tests all flows used in the dynamic action routing recipe
 */
@IsTest
private class DynamicActionRoutingFlowTest {
    @TestSetup
    static void setup() {
        // Create test account and contact
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = testAccount.Id
        );
        insert testContact;

        // Create test cases
        Case testCase1 = new Case(
            Subject = 'Test Ticket 1',
            Status = 'New',
            Priority = 'Medium',
            ContactId = testContact.Id
        );
        Case testCase2 = new Case(
            Subject = 'Test Ticket 2',
            Status = 'Open',
            Priority = 'High',
            ContactId = testContact.Id
        );
        insert new List<Case>{ testCase1, testCase2 };
    }

    @IsTest
    static void testViewTicketSuccess() {
        Case testCase = [SELECT Id, CaseNumber FROM Case LIMIT 1];

        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('ticket_number', testCase.CaseNumber);

        // Run the flow
        Test.startTest();
        Flow.Interview.ViewTicket flowInterview = new Flow.Interview.ViewTicket(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        SObject ticketInfo = (SObject) flowInterview.getVariableValue(
            'ticket_info'
        );
        Assert.isNotNull(ticketInfo, 'Ticket info should be returned');
    }

    @IsTest
    static void testAddTicketCommentSuccess() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];

        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('ticket_id', testCase.Id);
        inputs.put('comment', 'Test comment');

        // Run the flow
        Test.startTest();
        Flow.Interview.AddTicketComment flowInterview = new Flow.Interview.AddTicketComment(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        Boolean success = (Boolean) flowInterview.getVariableValue('success');
        Assert.isTrue(success, 'Comment should be added successfully');
    }

    @IsTest
    static void testAssignTicketSuccess() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];

        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('ticket_id', testCase.Id);
        inputs.put('agent', 'Agent123');

        // Run the flow
        Test.startTest();
        Flow.Interview.AssignTicket flowInterview = new Flow.Interview.AssignTicket(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        Boolean success = (Boolean) flowInterview.getVariableValue('success');
        Assert.isTrue(success, 'Ticket should be assigned successfully');

        // Verify ticket was updated
        Case updatedCase = [
            SELECT Id, Assigned_Agent__c
            FROM Case
            WHERE Id = :testCase.Id
        ];
        Assert.areEqual(
            'Agent123',
            updatedCase.Assigned_Agent__c,
            'Agent should be assigned'
        );
    }

    @IsTest
    static void testEscalateTicketSuccess() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];

        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('ticket_id', testCase.Id);
        inputs.put('reason', 'Complex issue requiring escalation');

        // Run the flow
        Test.startTest();
        Flow.Interview.EscalateTicket flowInterview = new Flow.Interview.EscalateTicket(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        Boolean success = (Boolean) flowInterview.getVariableValue('success');
        Assert.isTrue(success, 'Ticket should be escalated successfully');

        // Verify ticket was updated
        Case escalatedCase = [
            SELECT Id, Status
            FROM Case
            WHERE Id = :testCase.Id
        ];
        Assert.areEqual(
            'Escalated',
            escalatedCase.Status,
            'Status should be Escalated'
        );
    }

    @IsTest
    static void testUpdateTicketStatusSuccess() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];

        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('ticket_id', testCase.Id);
        inputs.put('new_status', 'In Progress');

        // Run the flow
        Test.startTest();
        Flow.Interview.UpdateTicketStatus flowInterview = new Flow.Interview.UpdateTicketStatus(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        Boolean success = (Boolean) flowInterview.getVariableValue('success');
        Assert.isTrue(success, 'Status should be updated successfully');

        // Verify ticket was updated
        Case updatedCase = [
            SELECT Id, Status
            FROM Case
            WHERE Id = :testCase.Id
        ];
        Assert.areEqual(
            'In Progress',
            updatedCase.Status,
            'Status should be In Progress'
        );
    }

    @IsTest
    static void testReassignTicketSuccess() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];

        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('ticket_id', testCase.Id);
        inputs.put('new_agent', 'NewAgent456');

        // Run the flow
        Test.startTest();
        Flow.Interview.ReassignTicket flowInterview = new Flow.Interview.ReassignTicket(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        Boolean success = (Boolean) flowInterview.getVariableValue('success');
        Assert.isTrue(success, 'Ticket should be reassigned successfully');

        // Verify ticket was updated
        Case reassignedCase = [
            SELECT Id, Assigned_Agent__c
            FROM Case
            WHERE Id = :testCase.Id
        ];
        Assert.areEqual(
            'NewAgent456',
            reassignedCase.Assigned_Agent__c,
            'New agent should be assigned'
        );
    }

    @IsTest
    static void testCloseTicketSuccess() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];

        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('ticket_id', testCase.Id);

        // Run the flow
        Test.startTest();
        Flow.Interview.CloseTicket flowInterview = new Flow.Interview.CloseTicket(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        Boolean success = (Boolean) flowInterview.getVariableValue('success');
        Assert.isTrue(success, 'Ticket should be closed successfully');

        // Verify ticket was updated
        Case closedCase = [SELECT Id, Status FROM Case WHERE Id = :testCase.Id];
        Assert.areEqual('Closed', closedCase.Status, 'Status should be Closed');
    }

    @IsTest
    static void testDeleteTicketSuccess() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        String caseId = testCase.Id;

        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('ticket_id', caseId);

        // Run the flow
        Test.startTest();
        Flow.Interview.DeleteTicket flowInterview = new Flow.Interview.DeleteTicket(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        Boolean success = (Boolean) flowInterview.getVariableValue('success');
        Assert.isTrue(success, 'Ticket should be deleted successfully');

        // Verify ticket was deleted
        List<Case> deletedCases = [SELECT Id FROM Case WHERE Id = :caseId];
        Assert.areEqual(0, deletedCases.size(), 'Ticket should be deleted');
    }
}
