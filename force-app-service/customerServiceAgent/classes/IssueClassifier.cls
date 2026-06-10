/**
 * @description Classifies issues based on description
 */
public with sharing class IssueClassifier {
    /**
     * @description Classifies the issue based on description
     * @param requests List of IssueRequest objects
     * @return List of IssueResult objects with classification details
     */
    @InvocableMethod(
        label='Classify Issue'
        description='Classifies the issue based on description'
    )
    public static List<IssueResult> classify(List<IssueRequest> requests) {
        List<IssueResult> results = new List<IssueResult>();
        for (IssueRequest req : requests) {
            String description = req.issueDescription != null
                ? req.issueDescription
                : '';
            IssueResult res = new IssueResult();
            res.issueType = 'account';
            res.priority = 'medium';

            if (
                description.containsIgnoreCase('urgent') ||
                description.containsIgnoreCase('critical')
            ) {
                res.priority = 'high';
            }
            if (
                description.containsIgnoreCase('login') ||
                description.containsIgnoreCase('password')
            ) {
                res.issueType = 'technical';
            }
            if (
                description.containsIgnoreCase('bill') ||
                description.containsIgnoreCase('charge') ||
                description.containsIgnoreCase('invoice') ||
                description.containsIgnoreCase('pricing')
            ) {
                res.issueType = 'billing';
            }
            if (
                description.containsIgnoreCase('feature') ||
                description.containsIgnoreCase('product') ||
                description.containsIgnoreCase('update')
            ) {
                res.issueType = 'product';
            }
            results.add(res);
        }
        return results;
    }

    /**
     * @description Input class for issue classification
     */
    public class IssueRequest {
        @InvocableVariable(required=true)
        public String issueDescription;
    }

    /**
     * @description Result class for issue classification
     */
    public class IssueResult {
        @InvocableVariable
        public String issueType;
        @InvocableVariable
        public String priority;
    }
}
