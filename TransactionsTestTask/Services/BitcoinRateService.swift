//
//  BitcoinRateService.swift
//  TransactionsTestTask
//
//

import Foundation

/// Rate Service should fetch data from https://api.coindesk.com/v1/bpi/currentprice.json
/// Fetching should be scheduled with dynamic update interval
/// Rate should be cached for the offline mode
/// Every successful fetch should be logged with analytics service
/// The service should be covered by unit tests
protocol BitcoinRateService: AnyObject {
    func fetchRate() async throws -> Double
    func startFetching(interval: TimeInterval) async
    func stopFetching()
}

/// Concrete implementation of BitcoinRateService
final class BitcoinRateServiceImpl: BitcoinRateService {
    
    // MARK: - Properties
    
    private let analyticsService: AnalyticsService
    private let url = URL(string: "https://api.coindesk.com/v1/bpi/currentprice.json")!
    private var isFetching = false
    private var rateTask: Task<Void, Never>?
    
    // MARK: - Init
    
    init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
    }
    
    // MARK: - Public Methods
    
    func fetchRate() async throws -> Double {
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(BitcoinRateResponse.self, from: data)
        let rate = response.bpi.USD.rateFloat
        
        // Log the event using AnalyticsService
        await analyticsService.trackEvent(
            name: "bitcoin_rate_update",
            parameters: ["rate": String(format: "%.4f", rate)]
        )
        
        return rate
    }
    
    func startFetching(interval: TimeInterval) async {
        guard !isFetching else { return }
        isFetching = true
        
        rateTask = Task {
            while isFetching {
                do {
                    let rate = try await fetchRate()
                    print("Fetched Bitcoin rate: \(rate)")
                } catch {
                    print("Failed to fetch Bitcoin rate: \(error)")
                }
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }
    }
    
    func stopFetching() {
        isFetching = false
        rateTask?.cancel()
    }
}
