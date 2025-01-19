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
    private var cancellables = Set<AnyCancellable>() // Combine subscriptions
    
    init() {
        loadWallet() // Load wallet data from Core Data
        loadTransactions() // Load transactions from Core Data
        fetchExchangeRate() // Fetch the latest Bitcoin exchange rate
    }
    
    func loadWallet() {
        // Fetch existing wallet or create a new one if none exists
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
    
    func fetchExchangeRate() {
        // Fetch the latest Bitcoin exchange rate from the API
        let url = URL(string: "https://api.coindesk.com/v1/bpi/currentprice.json")!
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: BitcoinRateResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching exchange rate: \(error)")
                }
            }, receiveValue: { [weak self] response in
                // Update the exchange rate and cache it in Core Data
                guard let self = self else { return }
                self.exchangeRate = response.bpi.usd.rateFloat
                self.updateWalletExchangeRate(response.bpi.usd.rateFloat)
            })
            .store(in: &cancellables)
    }
    
    private func updateWalletExchangeRate(_ rate: Double) {
        // Cache the latest exchange rate in Core Data
        if let wallet = coreDataManager.fetchWallet() {
            wallet.cachedExchangeRate = rate
            wallet.lastUpdated = Date()
            coreDataManager.saveContext()
        }
    }
}

// Struct to decode Bitcoin exchange rate response from API
struct BitcoinRateResponse: Decodable {
    struct BPI: Decodable {
        struct USD: Decodable {
            let rateFloat: Double
            
            enum CodingKeys: String, CodingKey {
                case rateFloat = "rate_float"
            }
        }
        
        let usd: USD
        
        enum CodingKeys: String, CodingKey {
            case usd = "USD"
        }
    }
    
    let bpi: BPI
}
