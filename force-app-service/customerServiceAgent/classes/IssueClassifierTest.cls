/**
 * @description Test class for IssueClassifier
 * Tests the issue classification invocable method
 */
@IsTest
private class IssueClassifierTest {
    @IsTest
    static void testClassifyAccountIssue() {
        IssueClassifier.IssueRequest req = new IssueClassifier.IssueRequest();
        req.issueDescription = 'I need help with my account';

        Test.startTest();
        List<IssueClassifier.IssueResult> results = IssueClassifier.classify(
            new List<IssueClassifier.IssueRequest>{ req }
        );
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Should return one result');
        Assert.areEqual(
            'account',
            results[0].issueType,
            'Default issue type should be account'
        );
        Assert.areEqual(
            'medium',
            results[0].priority,
            'Default priority should be medium'
        );
    }

    @IsTest
    static void testClassifyUrgentIssue() {
        IssueClassifier.IssueRequest req = new IssueClassifier.IssueRequest();
        req.issueDescription = 'This is an urgent matter that needs immediate attention';

        Test.startTest();
        List<IssueClassifier.IssueResult> results = IssueClassifier.classify(
            new List<IssueClassifier.IssueRequest>{ req }
        );
        Test.stopTest();

        Assert.areEqual(
            'high',
            results[0].priority,
            'Priority should be high for urgent issue'
        );
        Assert.areEqual(
            'account',
            results[0].issueType,
            'Issue type should remain account'
        );
    }

    @IsTest
    static void testClassifyTechnicalIssue() {
        IssueClassifier.IssueRequest req = new IssueClassifier.IssueRequest();
        req.issueDescription = 'I cannot login to my account';

        Test.startTest();
        List<IssueClassifier.IssueResult> results = IssueClassifier.classify(
            new List<IssueClassifier.IssueRequest>{ req }
        );
        Test.stopTest();

        Assert.areEqual(
            'technical',
            results[0].issueType,
            'Login issues should be technical'
        );
        Assert.areEqual(
            'medium',
            results[0].priority,
            'Priority should be medium'
        );
    }

    @IsTest
    static void testClassifyPasswordIssue() {
        IssueClassifier.IssueRequest req = new IssueClassifier.IssueRequest();
        req.issueDescription = 'I forgot my password and need to reset it';

        Test.startTest();
        List<IssueClassifier.IssueResult> results = IssueClassifier.classify(
            new List<IssueClassifier.IssueRequest>{ req }
        );
        Test.stopTest();

        Assert.areEqual(
            'technical',
            results[0].issueType,
            'Password issues should be technical'
        );
    }

    @IsTest
    static void testClassifyBillingIssue() {
        IssueClassifier.IssueRequest req = new IssueClassifier.IssueRequest();
        req.issueDescription = 'I was incorrectly charged on my bill';

        Test.startTest();
        List<IssueClassifier.IssueResult> results = IssueClassifier.classify(
            new List<IssueClassifier.IssueRequest>{ req }
        );
        Test.stopTest();

        Assert.areEqual(
            'billing',
            results[0].issueType,
            'Billing keywords should classify as billing'
        );
    }

    @IsTest
    static void testClassifyProductIssue() {
        IssueClassifier.IssueRequest req = new IssueClassifier.IssueRequest();
        req.issueDescription = 'I have a question about a product feature';

        Test.startTest();
        List<IssueClassifier.IssueResult> results = IssueClassifier.classify(
            new List<IssueClassifier.IssueRequest>{ req }
        );
        Test.stopTest();

        Assert.areEqual(
            'product',
            results[0].issueType,
            'Product keywords should classify as product'
        );
    }

    @IsTest
    static void testClassifyNullDescription() {
        IssueClassifier.IssueRequest req = new IssueClassifier.IssueRequest();
        req.issueDescription = null;

        Test.startTest();
        List<IssueClassifier.IssueResult> results = IssueClassifier.classify(
            new List<IssueClassifier.IssueRequest>{ req }
        );
        Test.stopTest();

        Assert.areEqual(
            'account',
            results[0].issueType,
            'Null description should default to account'
        );
        Assert.areEqual(
            'medium',
            results[0].priority,
            'Null description should default to medium'
        );
    }

    @IsTest
    static void testClassifyBulkIssues() {
        List<IssueClassifier.IssueRequest> requests = new List<IssueClassifier.IssueRequest>();

        IssueClassifier.IssueRequest req1 = new IssueClassifier.IssueRequest();
        req1.issueDescription = 'General question about my account';
        requests.add(req1);

        IssueClassifier.IssueRequest req2 = new IssueClassifier.IssueRequest();
        req2.issueDescription = 'URGENT: System is down';
        requests.add(req2);

        IssueClassifier.IssueRequest req3 = new IssueClassifier.IssueRequest();
        req3.issueDescription = 'I cannot login';
        requests.add(req3);

        Test.startTest();
        List<IssueClassifier.IssueResult> results = IssueClassifier.classify(
            requests
        );
        Test.stopTest();

        Assert.areEqual(3, results.size(), 'Should return three results');
        Assert.areEqual(
            'account',
            results[0].issueType,
            'First should be account'
        );
        Assert.areEqual(
            'high',
            results[1].priority,
            'Second should be high priority'
        );
        Assert.areEqual(
            'technical',
            results[2].issueType,
            'Third should be technical'
        );
    }
}
