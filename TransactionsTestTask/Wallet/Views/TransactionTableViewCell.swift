//
//  TransactionTableViewCell.swift
//  TransactionsTestTask
//
//  Created by Oleksandr Oliinyk on 19/1/25.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    
    static let identifier = "TransactionTableViewCell"
    
    // UI elements
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setup
    
    private func setupUI() {
        // Add elements to the content view hierarchy
        contentView.addSubview(categoryLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(dateLabel)

        // Set up layout constraints
        NSLayoutConstraint.activate([
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            categoryLabel.trailingAnchor.constraint(lessThanOrEqualTo: dateLabel.leadingAnchor, constant: -8),

            amountLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
            amountLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 4),
            amountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    // MARK: - Data Configuration
    
    /// Configures the cell with transaction data.
    /// - Parameter transaction: The transaction to display.
    func configure(with transaction: Transaction) {
        // Set the category text
        categoryLabel.text = transaction.category
        
        // Format and set the amount text
        amountLabel.text = String(format: "%.2f BTC", transaction.amount)
        
        // Format and set the date text
        dateLabel.text = formatDate(transaction.date)
        
        // Assign colors based on transaction type
        if transaction.category == "Deposit" {
            amountLabel.textColor = .green // Green for deposits
        } else {
            amountLabel.textColor = .red // Red for expenses
        }
    }
    
    /// Formats a `Date` object into a readable string.
    /// - Parameter date: The date to format.
    /// - Returns: A formatted date string or an empty string if the date is nil.
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy HH:mm" // "19.01.25 15:30"
        return formatter.string(from: date)
    }
}

