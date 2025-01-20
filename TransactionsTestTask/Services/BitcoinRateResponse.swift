//
//  BitcoinRateResponse.swift
//  TransactionsTestTask
//
//  Created by Oleksandr Oliinyk on 20/1/25.
//

import Foundation

// Struct to decode Bitcoin exchange rate response from API
struct BitcoinRateResponse: Decodable {
    struct BPI: Decodable {
        struct USD: Decodable {
            let rateFloat: Double
            
            enum CodingKeys: String, CodingKey {
                case rateFloat = "rate_float"
            }
        }
        
        let USD: USD
    }
    
    let bpi: BPI
}
