//
//  Wallet+CoreDataProperties.swift
//  TransactionsTestTask
//
//  Created by Oleksandr Oliinyk on 19/1/25.
//
//

import Foundation
import CoreData


extension Wallet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Wallet> {
        return NSFetchRequest<Wallet>(entityName: "Wallet")
    }

    @NSManaged public var balance: Double
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var cachedExchangeRate: Double

}

extension Wallet : Identifiable {

}
