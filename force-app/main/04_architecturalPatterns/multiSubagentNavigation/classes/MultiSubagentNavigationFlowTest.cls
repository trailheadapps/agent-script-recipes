/**
 * @description Test class for Multi-Subagent Navigation Flows
 * Tests all flows used in the multi-subagent navigation recipe
 */
@IsTest
private class MultiSubagentNavigationFlowTest {
    @TestSetup
    static void setup() {
        // Create test hotel records
        ASR_Hotel__c hotel1 = new ASR_Hotel__c(
            Name = 'Test Hotel 1',
            City__c = 'San Francisco',
            Location__c = 'Downtown'
        );
        ASR_Hotel__c hotel2 = new ASR_Hotel__c(
            Name = 'Test Hotel 2',
            City__c = 'San Francisco',
            Location__c = 'Airport'
        );
        insert new List<ASR_Hotel__c>{ hotel1, hotel2 };
    }

    @IsTest
    static void testSearchHotelsSuccess() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('location', 'San Francisco');
        inputs.put('check_in', '2024-01-15');
        inputs.put('check_out', '2024-01-20');

        // Run the flow
        Test.startTest();
        Flow.Interview.SearchHotels flowInterview = new Flow.Interview.SearchHotels(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        List<SObject> hotels = (List<SObject>) flowInterview.getVariableValue(
            'hotels'
        );
        Assert.areNotEqual(null, hotels, 'Hotels should be returned');
        Assert.areEqual(2, hotels.size(), 'Should return 2 hotels');
    }

    @IsTest
    static void testCreateBookingSuccess() {
        // Set input variables for the flow
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('hotel_name', 'Test Hotel 1');
        inputs.put('check_in', '2024-01-15');
        inputs.put('check_out', '2024-01-20');

        // Run the flow
        Test.startTest();
        Flow.Interview.CreateBooking flowInterview = new Flow.Interview.CreateBooking(
            inputs
        );
        flowInterview.start();
        Test.stopTest();

        // Verify the expected outcome
        String bookingId = (String) flowInterview.getVariableValue(
            'booking_id'
        );
        Boolean success = (Boolean) flowInterview.getVariableValue('success');

        Assert.areNotEqual(null, bookingId, 'Booking ID should be returned');
        Assert.areEqual(true, success, 'Booking should succeed');

        // Verify booking was created
        List<ASR_Hotel_Booking__c> bookings = [
            SELECT Id, Hotel__c, Check_In__c, Check_Out__c
            FROM ASR_Hotel_Booking__c
            WHERE Id = :bookingId
        ];
        Assert.areEqual(1, bookings.size(), 'Booking should be created');
    }
}
