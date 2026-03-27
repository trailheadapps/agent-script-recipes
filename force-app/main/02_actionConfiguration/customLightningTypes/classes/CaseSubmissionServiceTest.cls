/**
 * @description Test class for CaseSubmissionService
 * Tests the case submission invocable method with various scenarios
 */
@IsTest
private class CaseSubmissionServiceTest {
    @IsTest
    static void testSubmitCaseSingleRequest() {
        // Create test input
        CaseSubmissionService.CaseInput input = new CaseSubmissionService.CaseInput();
        input.subject = 'Login page not loading';
        input.priority = 'High';
        input.description = 'The login page returns a 500 error when accessed.';

        CaseSubmissionService.SubmitCaseRequest request = new CaseSubmissionService.SubmitCaseRequest();
        request.case_data = input;
        List<CaseSubmissionService.SubmitCaseRequest> requests = new List<CaseSubmissionService.SubmitCaseRequest>{
            request
        };

        // Execute test
        Test.startTest();
        List<CaseSubmissionService.SubmitCaseResponse> responses = CaseSubmissionService.submitCase(
            requests
        );
        Test.stopTest();

        // Verify response
        Assert.areEqual(
            1,
            responses.size(),
            'Response list should contain one response'
        );

        CaseSubmissionService.SubmitCaseResponse response = responses[0];
        Assert.isTrue(
            response.case_number.startsWith('CS-'),
            'Case number should start with CS-'
        );
        Assert.areEqual(
            response.case_number,
            response.case_result.caseNumber,
            'Case number should match between response and result'
        );
        Assert.areEqual(
            'Login page not loading',
            response.case_result.subject,
            'Subject should match input'
        );
        Assert.areEqual(
            'High',
            response.case_result.priority,
            'Priority should match input'
        );
        Assert.areEqual(
            'The login page returns a 500 error when accessed.',
            response.case_result.description,
            'Description should match input'
        );
        Assert.areEqual(
            'New',
            response.case_result.status,
            'Status should be New'
        );
        Assert.areEqual(
            'Within 4 hours',
            response.case_result.estimatedResponse,
            'High priority should have 4-hour response time'
        );
        Assert.isNotNull(
            response.case_result.createdDate,
            'Created date should be populated'
        );
    }

    @IsTest
    static void testSubmitCaseBulkRequests() {
        // Create multiple test requests for bulk testing
        List<CaseSubmissionService.SubmitCaseRequest> requests = new List<CaseSubmissionService.SubmitCaseRequest>();

        CaseSubmissionService.CaseInput input1 = new CaseSubmissionService.CaseInput();
        input1.subject = 'Billing discrepancy';
        input1.priority = 'High';
        input1.description = 'Charged twice for the same subscription.';
        CaseSubmissionService.SubmitCaseRequest request1 = new CaseSubmissionService.SubmitCaseRequest();
        request1.case_data = input1;
        requests.add(request1);

        CaseSubmissionService.CaseInput input2 = new CaseSubmissionService.CaseInput();
        input2.subject = 'Feature request: dark mode';
        input2.priority = 'Low';
        input2.description = 'Would like a dark mode option in the UI.';
        CaseSubmissionService.SubmitCaseRequest request2 = new CaseSubmissionService.SubmitCaseRequest();
        request2.case_data = input2;
        requests.add(request2);

        // Execute test
        Test.startTest();
        List<CaseSubmissionService.SubmitCaseResponse> responses = CaseSubmissionService.submitCase(
            requests
        );
        Test.stopTest();

        // Verify all requests were processed
        Assert.areEqual(2, responses.size(), 'Should return two responses');
        Assert.areEqual(
            'Within 4 hours',
            responses[0].case_result.estimatedResponse,
            'High priority should have 4-hour response time'
        );
        Assert.areEqual(
            'Within 48 hours',
            responses[1].case_result.estimatedResponse,
            'Low priority should have 48-hour response time'
        );
    }

    @IsTest
    static void testSubmitCaseWithDefaults() {
        // Test with minimal input to verify defaults
        CaseSubmissionService.CaseInput input = new CaseSubmissionService.CaseInput();
        input.subject = 'General inquiry';

        CaseSubmissionService.SubmitCaseRequest request = new CaseSubmissionService.SubmitCaseRequest();
        request.case_data = input;
        List<CaseSubmissionService.SubmitCaseRequest> requests = new List<CaseSubmissionService.SubmitCaseRequest>{
            request
        };

        // Execute test
        Test.startTest();
        List<CaseSubmissionService.SubmitCaseResponse> responses = CaseSubmissionService.submitCase(
            requests
        );
        Test.stopTest();

        // Verify defaults are applied
        CaseSubmissionService.SubmitCaseResponse response = responses[0];
        Assert.areEqual(
            'Medium',
            response.case_result.priority,
            'Priority should default to Medium'
        );
        Assert.areEqual(
            'Within 24 hours',
            response.case_result.estimatedResponse,
            'Medium priority should have 24-hour response time'
        );
    }
}
