//
//  AddTransactionViewController.swift
//  TransactionsTestTask
//
//  Created by Oleksandr Oliinyk on 19/1/25.
//

import UIKit

class AddTransactionViewController: UIViewController {
    private let viewModel: WalletViewModel
    
    private let addTransactionView = AddTransactionView()

    // Ініціалізація з ViewModel
    init(viewModel: WalletViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view = addTransactionView

        // Налаштування кнопки
        addTransactionView.addButton.addTarget(self, action: #selector(addTransactionTapped), for: .touchUpInside)
    }

    @objc private func addTransactionTapped() {
        // Отримання введених даних
        guard let amountText = addTransactionView.amountTextField.text, let amount = Double(amountText), !amountText.isEmpty else {
            showAlert(message: "Please enter a valid amount.")
            return
        }

        let selectedCategoryIndex = addTransactionView.categorySegmentedControl.selectedSegmentIndex
        guard selectedCategoryIndex != UISegmentedControl.noSegment else {
            showAlert(message: "Please select a category.")
            return
        }

        let category = addTransactionView.categorySegmentedControl.titleForSegment(at: selectedCategoryIndex) ?? "Other"

        // Додавання транзакції через ViewModel
        viewModel.decreaseTransaction(amount: amount, category: category)

        // Повернення на головний екран
        dismiss(animated: true)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
