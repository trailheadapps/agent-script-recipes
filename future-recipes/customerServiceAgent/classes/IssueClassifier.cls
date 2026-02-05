/**
 * @description Classifies issues based on description
 */
public with sharing class IssueClassifier {
    /**
     * @description Classifies the issue based on description
     * @param issueDescriptions List of issue descriptions to classify
     * @return List of IssueResult objects with classification details
     */
    @InvocableMethod(
        label='Classify Issue'
        description='Classifies the issue based on description'
    )
    public static List<IssueResult> classify(List<String> issueDescriptions) {
        List<IssueResult> results = new List<IssueResult>();
        for (String description : issueDescriptions) {
            IssueResult res = new IssueResult();
            res.issueType = 'General';
            res.priority = 'Medium';
            res.suggestedKbArticles = new List<String>{
                'Article 1',
                'Article 2'
            };

            if (
                description.containsIgnoreCase('urgent') ||
                description.containsIgnoreCase('critical')
            ) {
                res.priority = 'High';
            }
            if (
                description.containsIgnoreCase('login') ||
                description.containsIgnoreCase('password')
            ) {
                res.issueType = 'Login Issue';
            }
            results.add(res);
        }
        return results;
    }

    /**
     * @description Result class for issue classification
     */
    public class IssueResult {
        @InvocableVariable
        public String issueType;
        @InvocableVariable
        public String priority;
        @InvocableVariable
        public List<String> suggestedKbArticles;
    }
}
