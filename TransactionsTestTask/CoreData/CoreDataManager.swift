//
//  CoreDataManager.swift
//  TransactionsTestTask
//
//  Created by Oleksandr Oliinyk on 19/1/25.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        // Initialize a Core Data persistent container with the name of the data model
        let container = NSPersistentContainer(name: "TransactionsTestTask")
        // Load the persistent stores
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // Handle any errors during loading, terminating the app if necessary
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // for saving context
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Core Data save error: \(error)")
        }
    }
    
    // to get the balance in wallet
    func fetchWallet() -> Wallet? {
        let request: NSFetchRequest<Wallet> = Wallet.fetchRequest()
        do {
            let wallets = try context.fetch(request)
            return wallets.first
        } catch {
            print("Error fetching wallet: \(error)")
            return nil
        }
    }
    
    // Create a new wallet
    func createWallet() -> Wallet {
        let wallet = Wallet(context: context)
        wallet.balance = 0.0
        wallet.cachedExchangeRate = 0.0
        wallet.lastUpdated = Date()
        saveContext()
        return wallet
    }
}
