//
//  TransactionsTestTaskTests.swift
//  TransactionsTestTaskTests
//
//

import XCTest
@testable import TransactionsTestTask

final class AnalyticsServiceTests: XCTestCase {
    
    var analyticsService: AnalyticsServiceImpl!
    
    override func setUp() {
        super.setUp()
        analyticsService = AnalyticsServiceImpl()
    }
    
    override func tearDown() {
        analyticsService = nil
        super.tearDown()
    }
    
    // Single test to cover tracking events and filtering by name and date range
    func testTrackAndRetrieveEvents() async {
        // Arrange
        // Track multiple events with different names and parameters
        let eventName1 = "bitcoin_rate_update"
        let eventParams1: [String: String] = ["rate": "103840.8103"]
        await analyticsService.trackEvent(name: eventName1, parameters: eventParams1)
        
        let eventName2 = "bitcoin_rate_test"
        let eventParams2: [String: String] = ["rate": "103840.8301"]
        await analyticsService.trackEvent(name: eventName2, parameters: eventParams2)
        
        let eventName3 = "bitcoin_rate_update"  // Same name as the first event
        let eventParams3: [String: String] = ["rate": "103840.8103"]
        await analyticsService.trackEvent(name: eventName3, parameters: eventParams3)
        
        // Wait for the async operations to complete
        await Task.yield()
        
        // Retrieve all events of name "bitcoin_rate_update"
        let eventsByName = analyticsService.getEvents(name: "bitcoin_rate_update", startDate: nil, endDate: nil)
        
        // Retrieve events with a date range (get events before current date)
        let pastDate = Date().addingTimeInterval(-3600) // 1 hour ago
        let eventsByDateRange = analyticsService.getEvents(name: nil, startDate: pastDate, endDate: Date())
        
        // Ensure that only the "bitcoin_rate_update" events are returned for the name filter
        XCTAssertEqual(eventsByName.count, 2, "There should be 2 events with the name 'bitcoin_rate_update'.")
        
        // Ensure that both events are within the date range (since all were created within the last hour)
        XCTAssertEqual(eventsByDateRange.count, 3, "All 3 events should be retrieved within the specified date range.")
    }
}
