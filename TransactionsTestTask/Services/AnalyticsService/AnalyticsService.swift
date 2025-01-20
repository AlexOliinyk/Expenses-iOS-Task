//
//  AnalyticsService.swift
//  TransactionsTestTask
//
//

import Foundation

/// Analytics Service is used for events logging
/// The list of reasonable events is up to you
/// It should be possible not only to track events but to get it from the service
/// The minimal needed filters are: event name and date range
/// The service should be covered by unit tests
protocol AnalyticsService: AnyObject {
    func trackEvent(name: String, parameters: [String: String]) async
    func getEvents(name: String?, startDate: Date?, endDate: Date?) -> [AnalyticsEvent]
}

/// Concrete implementation of AnalyticsService
final class AnalyticsServiceImpl: AnalyticsService {
    
    private var events: [AnalyticsEvent] = []
    
    func trackEvent(name: String, parameters: [String: String]) async {
        // Create the event
        let event = AnalyticsEvent(name: name, parameters: parameters, date: .now)
        
        events.append(event)
        
        print("""
                Event Logged:
                - Name: \(event.name)
                - Parameters: \(event.parameters)
                - Date: \(event.date)
                """)
    }
    
    func getEvents(name: String? = nil, startDate: Date? = nil, endDate: Date? = nil) -> [AnalyticsEvent] {
        return events.filter { event in
            var matches = true
            
            // Filter by name if provided
            if let name = name {
                matches = matches && event.name == name
            }
            
            // Filter by date range if provided
            if let startDate = startDate {
                matches = matches && event.date >= startDate
            }
            if let endDate = endDate {
                matches = matches && event.date <= endDate
            }
            
            return matches
        }
    }
}
