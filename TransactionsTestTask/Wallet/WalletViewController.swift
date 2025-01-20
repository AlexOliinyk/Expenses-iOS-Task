//
//  WalletViewController.swift
//  TransactionsTestTask
//
//  Created by Oleksandr Oliinyk on 19/1/25.
//

import UIKit
import Combine

class WalletViewController: UIViewController {
    private var viewModel = WalletViewModel() // ViewModel to manage data and logic
    private var cancellables = Set<AnyCancellable>() // Stores Combine subscriptions
    
    private let walletView = WalletView() // Custom view for the wallet screen
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the transactions table view
        walletView.transactionsTableView.dataSource = self
        walletView.transactionsTableView.delegate = self
        walletView.transactionsTableView.register(TransactionTableViewCell.self, forCellReuseIdentifier: TransactionTableViewCell.identifier)
        
        setupUI() // Configure UI elements
        setupBindings() // Bind ViewModel to UI
    }
    
    private func setupUI() {
        view = walletView // Use WalletView as the main view
        
        // Configure button actions
        walletView.addBalanceButton.addTarget(self, action: #selector(addBalanceTapped), for: .touchUpInside)
        walletView.addTransactionButton.addTarget(self, action: #selector(addTransactionTapped), for: .touchUpInside)
    }
    
    private func setupBindings() {
        // Update balance label whenever the balance changes
        viewModel.$balance
            .map { "Balance: \($0) BTC" }
            .assign(to: \.text, on: walletView.balanceLabel)
            .store(in: &cancellables)
        
        // Update exchange rate label or show a loading message
        viewModel.$exchangeRate
            .map { $0 != nil ? "BTC/USD: \($0!)" : "Loading exchange rate..." }
            .assign(to: \.text, on: walletView.exchangeRateLabel)
            .store(in: &cancellables)
        
        // Reload transactions table when the transaction list updates
        viewModel.$transactions
            .sink { [weak self] _ in
                self?.walletView.transactionsTableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    @objc private func addTransactionTapped() {
        // Present the Add Transaction screen
        let addVC = AddTransactionViewController(viewModel: viewModel)
        present(addVC, animated: true)
    }
    
    @objc private func addBalanceTapped() {
        // Show an alert to enter the amount to add to the balance
        let alert = UIAlertController(title: "Add Balance", message: "Enter the amount of Bitcoin to add:", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Enter Amount"
            textField.keyboardType = .decimalPad
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self,
                  let text = alert.textFields?.first?.text,
                  let amount = Double(text), amount > 0 else {
                self?.showAlert(message: "Please enter a valid amount.")
                return
            }
            
            // Update balance via the ViewModel
            self.viewModel.increaseTransaction(amount: amount)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func showAlert(message: String) {
        // Show an error alert with the provided message
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension WalletViewController: UITableViewDelegate { }

extension WalletViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of date sections
        return viewModel.groupedTransactions.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of transactions in each date section
        return viewModel.groupedTransactions[section].transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue and configure the transaction cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.identifier, for: indexPath) as? TransactionTableViewCell else {
            return UITableViewCell()
        }
        
        let transaction = viewModel.groupedTransactions[indexPath.section].transactions[indexPath.row]
        cell.configure(with: transaction)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Return a formatted date for the section header
        let date = viewModel.groupedTransactions[section].date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
}
