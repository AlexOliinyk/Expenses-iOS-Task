//
//  WalletViewModel.swift
//  TransactionsTestTask
//
//  Created by Oleksandr Oliinyk on 19/1/25.
//

import Combine
import CoreData

class WalletViewModel: ObservableObject {
    @Published var balance: Double = 0.0 // Current wallet balance
    @Published var transactions: [Transaction] = [] // List of transactions
    @Published var exchangeRate: Double? // Bitcoin to USD exchange rate
    
    private let coreDataManager = CoreDataManager.shared // Core Data manager
    private let bitcoinRateService = ServicesAssembler.bitcoinRateService() // Bitcoin rate service
    private var cancellables = Set<AnyCancellable>() // Combine subscriptions
    
    // Group transactions by date
    var groupedTransactions: [(date: Date, transactions: [Transaction])] {
        let grouped = Dictionary(grouping: transactions) { transaction -> Date in
            // Extract date without time component
            return Calendar.current.startOfDay(for: transaction.date ?? Date())
        }
        
        // Sort by date in descending order
        let sortedGrouped = grouped.keys.sorted(by: >).map { date in
            (date: date, transactions: grouped[date]!)
        }
        
        return sortedGrouped
    }
    
    // MARK: - Initialization
    
    init() {
        loadWallet()
        loadTransactions()
        startFetchingExchangeRate(interval: 60) // Fetch rate every 60 seconds
    }
    
    deinit {
        stopFetchingExchangeRate() // Clean up rate-fetching task
    }
    
    // MARK: - Wallet Management
    
    func loadWallet() {
        if let wallet = coreDataManager.fetchWallet() {
            balance = wallet.balance
            exchangeRate = wallet.cachedExchangeRate
        } else {
            let wallet = coreDataManager.createWallet()
            balance = wallet.balance
            exchangeRate = wallet.cachedExchangeRate
        }
    }
    
    func loadTransactions() {
        // Fetch all transactions from Core Data, sorted by date in descending order
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            transactions = try coreDataManager.context.fetch(request)
        } catch {
            print("Error fetching transactions: \(error)")
        }
    }
    
    func decreaseTransaction(amount: Double, category: String) {
        // Deduct amount from wallet balance and add a new transaction
        if let wallet = coreDataManager.fetchWallet() {
            wallet.balance -= amount
            balance = wallet.balance
            
            let transaction = Transaction(context: coreDataManager.context)
            transaction.id = UUID()
            transaction.amount = amount
            transaction.category = category
            transaction.date = Date()
            
            updateTransactionList()
        }
    }
    
    func increaseTransaction(amount: Double) {
        // Add amount to wallet balance and create a deposit transaction
        if let wallet = coreDataManager.fetchWallet() {
            wallet.balance += amount
            balance = wallet.balance
            
            let transaction = Transaction(context: coreDataManager.context)
            transaction.id = UUID()
            transaction.amount = amount
            transaction.category = "Deposit"
            transaction.date = Date()
            
            updateTransactionList()
        }
    }
    
    private func updateTransactionList() {
        // Save changes to Core Data and reload the transactions list
        coreDataManager.saveContext()
        loadTransactions()
    }
    
    // MARK: - Exchange Rate Management
    
    func startFetchingExchangeRate(interval: TimeInterval) {
        Task {
            await bitcoinRateService.startFetching(interval: interval)
        }
    }
    
    func stopFetchingExchangeRate() {
        bitcoinRateService.stopFetching()
    }
    
    private func updateWalletExchangeRate(_ rate: Double) {
        if let wallet = coreDataManager.fetchWallet() {
            wallet.cachedExchangeRate = rate
            wallet.lastUpdated = Date()
            coreDataManager.saveContext()
        }
    }
}
