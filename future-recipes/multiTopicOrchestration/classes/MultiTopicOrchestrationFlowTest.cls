/**
 * @description Test class for Multi-Topic Orchestration Flows
 * Tests all flows used in the multi-topic orchestration recipe
 */
@IsTest
private class MultiTopicOrchestrationFlowTest {
    @IsTest
    static void testBookFlight() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('dummy_input', 'test');

        // Run the flow
        Test.startTest();
        Flow.Interview.BookFlight flowInterview = new Flow.Interview.BookFlight(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        String confirmationNumber = (String) flowInterview.getVariableValue(
            'confirmation_number'
        );
        Boolean success = (Boolean) flowInterview.getVariableValue('success');

        Assert.areNotEqual(
            null,
            confirmationNumber,
            'Confirmation number should be returned'
        );
        Assert.isTrue(
            confirmationNumber.startsWith('CONF-'),
            'Confirmation number should start with CONF-'
        );
        Assert.areEqual(true, success, 'Booking should succeed');
    }

    @IsTest
    static void testBookHotel() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('dummy_input', 'test');

        // Run the flow
        Test.startTest();
        Flow.Interview.BookHotel flowInterview = new Flow.Interview.BookHotel(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        String confirmationNumber = (String) flowInterview.getVariableValue(
            'confirmation_number'
        );
        Boolean success = (Boolean) flowInterview.getVariableValue('success');

        Assert.areNotEqual(
            null,
            confirmationNumber,
            'Confirmation number should be returned'
        );
        Assert.isTrue(
            confirmationNumber.startsWith('CONF-'),
            'Confirmation number should start with CONF-'
        );
        Assert.areEqual(true, success, 'Booking should succeed');
    }

    @IsTest
    static void testBookCar() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('dummy_input', 'test');

        // Run the flow
        Test.startTest();
        Flow.Interview.BookCar flowInterview = new Flow.Interview.BookCar(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        String confirmationNumber = (String) flowInterview.getVariableValue(
            'confirmation_number'
        );
        Boolean success = (Boolean) flowInterview.getVariableValue('success');

        Assert.areNotEqual(
            null,
            confirmationNumber,
            'Confirmation number should be returned'
        );
        Assert.isTrue(
            confirmationNumber.startsWith('CONF-'),
            'Confirmation number should start with CONF-'
        );
        Assert.areEqual(true, success, 'Booking should succeed');
    }

    @IsTest
    static void testSendItinerary() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('email', 'customer@example.com');
        inputs.put('flight_conf', 'CONF-FLIGHT-123');
        inputs.put('hotel_conf', 'CONF-HOTEL-456');
        inputs.put('car_conf', 'CONF-CAR-789');

        // Run the flow
        Test.startTest();
        Flow.Interview.SendItinerary flowInterview = new Flow.Interview.SendItinerary(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        Boolean sent = (Boolean) flowInterview.getVariableValue('sent');
        Assert.areEqual(true, sent, 'Itinerary should be sent successfully');
    }
}
