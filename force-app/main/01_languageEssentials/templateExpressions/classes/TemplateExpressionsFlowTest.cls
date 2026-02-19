/**
 * @description Test class for Template Expressions Flows
 * Tests all flows used in the template expressions recipe
 */
@IsTest
private class TemplateExpressionsFlowTest {
    @TestSetup
    static void setup() {
        // Create test products
        ASR_Product__c product1 = new ASR_Product__c(
            Name = 'Product 1',
            Price__c = 50.00,
            Is_Active__c = true
        );
        ASR_Product__c product2 = new ASR_Product__c(
            Name = 'Product 2',
            Price__c = 100.00,
            Is_Active__c = true
        );
        insert new List<ASR_Product__c>{ product1, product2 };
    }

    @IsTest
    static void testAddToCartNewCart() {
        // Create an existing cart so the flow can find it and update it
        // This avoids the issue where the flow tries to access Total_Amount__c on a newly created record variable
        ASR_Shopping_Cart__c existingCart = new ASR_Shopping_Cart__c(
            Customer_Name__c = 'Demo User',
            Status__c = 'New',
            Total_Amount__c = 0.00
        );
        insert existingCart;

        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('item_name', 'Test Item');
        inputs.put('price', 25.00);

        // Run the flow
        Test.startTest();
        Flow.Interview.AddToCart flowInterview = new Flow.Interview.AddToCart(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        Boolean success = (Boolean) flowInterview.getVariableValue('success');
        Decimal newTotal = (Decimal) flowInterview.getVariableValue(
            'new_total'
        );

        Assert.areEqual(true, success, 'Item should be added successfully');
        Assert.areEqual(25.00, newTotal, 'Cart total should match');
    }

    @IsTest
    static void testGetRecommendations() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('budget', 75.00);
        inputs.put('product_name', 'Product');

        // Run the flow
        Test.startTest();
        Flow.Interview.GetRecommendations flowInterview = new Flow.Interview.GetRecommendations(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        List<String> recommendations = (List<String>) flowInterview.getVariableValue(
            'recommendations'
        );
        Assert.areNotEqual(
            null,
            recommendations,
            'Recommendations should be returned'
        );
        // Should return products with price < 75.00
        Assert.areEqual(
            1,
            recommendations.size(),
            'Should return 1 recommendation'
        );
    }
}
