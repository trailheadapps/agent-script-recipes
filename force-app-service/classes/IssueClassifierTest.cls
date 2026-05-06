/**
 * @description Test class for IssueClassifier
 * Tests the issue classification invocable method
 */
@IsTest
private class IssueClassifierTest {
    @IsTest
    static void testClassifyGeneralIssue() {
        // Test with general issue description
        List<String> descriptions = new List<String>{
            'I need help with my account'
        };

        // Execute test
        Test.startTest();
        List<IssueClassifier.IssueResult> results = IssueClassifier.classify(
            descriptions
        );
        Test.stopTest();

        // Verify results
        Assert.areEqual(1, results.size(), 'Should return one result');
        Assert.areEqual(
            'General',
            results[0].issueType,
            'Issue type should be General'
        );
        Assert.areEqual(
            'Medium',
            results[0].priority,
            'Priority should be Medium'
        );
        Assert.areNotEqual(
            null,
            results[0].suggestedKbArticles,
            'KB articles should be provided'
        );
        Assert.areEqual(
            2,
            results[0].suggestedKbArticles.size(),
            'Should have two KB articles'
        );
    }

    @IsTest
    static void testClassifyUrgentIssue() {
        // Test with urgent keyword
        List<String> descriptions = new List<String>{
            'This is an urgent matter that needs immediate attention'
        };

        // Execute test
        Test.startTest();
        List<IssueClassifier.IssueResult> results = IssueClassifier.classify(
            descriptions
        );
        Test.stopTest();

        // Verify priority is set to High
        Assert.areEqual(1, results.size(), 'Should return one result');
        Assert.areEqual(
            'High',
            results[0].priority,
            'Priority should be High for urgent issue'
        );
        Assert.areEqual(
            'General',
            results[0].issueType,
            'Issue type should remain General'
        );
    }

    @IsTest
    static void testClassifyCriticalIssue() {
        // Test with critical keyword
        List<String> descriptions = new List<String>{
            'This is a critical system failure'
        };

        // Execute test
        Test.startTest();
        List<IssueClassifier.IssueResult> results = IssueClassifier.classify(
            descriptions
        );
        Test.stopTest();

        // Verify priority is set to High
        Assert.areEqual(1, results.size(), 'Should return one result');
        Assert.areEqual(
            'High',
            results[0].priority,
            'Priority should be High for critical issue'
        );
    }

    @IsTest
    static void testClassifyLoginIssue() {
        // Test with login keyword
        List<String> descriptions = new List<String>{
            'I cannot login to my account'
        };

        // Execute test
        Test.startTest();
        List<IssueClassifier.IssueResult> results = IssueClassifier.classify(
            descriptions
        );
        Test.stopTest();

        // Verify issue type is Login Issue
        Assert.areEqual(1, results.size(), 'Should return one result');
        Assert.areEqual(
            'Login Issue',
            results[0].issueType,
            'Issue type should be Login Issue'
        );
        Assert.areEqual(
            'Medium',
            results[0].priority,
            'Priority should be Medium'
        );
    }

    @IsTest
    static void testClassifyPasswordIssue() {
        // Test with password keyword
        List<String> descriptions = new List<String>{
            'I forgot my password and need to reset it'
        };

        // Execute test
        Test.startTest();
        List<IssueClassifier.IssueResult> results = IssueClassifier.classify(
            descriptions
        );
        Test.stopTest();

        // Verify issue type is Login Issue
        Assert.areEqual(1, results.size(), 'Should return one result');
        Assert.areEqual(
            'Login Issue',
            results[0].issueType,
            'Issue type should be Login Issue'
        );
    }

    @IsTest
    static void testClassifyUrgentLoginIssue() {
        // Test with both urgent and login keywords
        List<String> descriptions = new List<String>{
            'This is an urgent login problem that needs immediate attention'
        };

        // Execute test
        Test.startTest();
        List<IssueClassifier.IssueResult> results = IssueClassifier.classify(
            descriptions
        );
        Test.stopTest();

        // Verify both conditions are met
        Assert.areEqual(1, results.size(), 'Should return one result');
        Assert.areEqual(
            'Login Issue',
            results[0].issueType,
            'Issue type should be Login Issue'
        );
        Assert.areEqual(
            'High',
            results[0].priority,
            'Priority should be High for urgent issue'
        );
    }

    @IsTest
    static void testClassifyBulkIssues() {
        // Test bulk processing with multiple descriptions
        List<String> descriptions = new List<String>{
            'General question about my account',
            'URGENT: System is down',
            'I cannot login',
            'Critical security breach detected',
            'Password reset needed'
        };

        // Execute test
        Test.startTest();
        List<IssueClassifier.IssueResult> results = IssueClassifier.classify(
            descriptions
        );
        Test.stopTest();

        // Verify all issues were classified
        Assert.areEqual(5, results.size(), 'Should return five results');

        // Verify first issue (General)
        Assert.areEqual(
            'General',
            results[0].issueType,
            'First issue should be General'
        );
        Assert.areEqual(
            'Medium',
            results[0].priority,
            'First issue priority should be Medium'
        );

        // Verify second issue (Urgent)
        Assert.areEqual(
            'High',
            results[1].priority,
            'Second issue priority should be High'
        );

        // Verify third issue (Login)
        Assert.areEqual(
            'Login Issue',
            results[2].issueType,
            'Third issue should be Login Issue'
        );

        // Verify fourth issue (Critical)
        Assert.areEqual(
            'High',
            results[3].priority,
            'Fourth issue priority should be High'
        );

        // Verify fifth issue (Password)
        Assert.areEqual(
            'Login Issue',
            results[4].issueType,
            'Fifth issue should be Login Issue'
        );
    }

    @IsTest
    static void testClassifyCaseInsensitive() {
        // Test case-insensitive matching
        List<String> descriptions = new List<String>{
            'URGENT issue',
            'CRITICAL problem',
            'LOGIN error',
            'PASSWORD reset'
        };

        // Execute test
        Test.startTest();
        List<IssueClassifier.IssueResult> results = IssueClassifier.classify(
            descriptions
        );
        Test.stopTest();

        // Verify case-insensitive matching works
        Assert.areEqual(4, results.size(), 'Should return four results');
        Assert.areEqual(
            'High',
            results[0].priority,
            'URGENT should be detected'
        );
        Assert.areEqual(
            'High',
            results[1].priority,
            'CRITICAL should be detected'
        );
        Assert.areEqual(
            'Login Issue',
            results[2].issueType,
            'LOGIN should be detected'
        );
        Assert.areEqual(
            'Login Issue',
            results[3].issueType,
            'PASSWORD should be detected'
        );
    }
}
