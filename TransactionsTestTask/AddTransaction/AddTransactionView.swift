//
//  AddTransactionView.swift
//  TransactionsTestTask
//
//  Created by Oleksandr Oliinyk on 19/1/25.
//

import UIKit

final class AddTransactionView: UIView {
    // UI елементи
    let amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter amount"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let categorySegmentedControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: ["Groceries", "Taxi", "Electronics", "Restaurant", "Other"])
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.apportionsSegmentWidthsByContent = true
        return segmentControl
    }()
    
    let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let mainStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    init() {
        super.init(frame: .zero)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .systemBackground
        
        addSubview(mainStack)
        mainStack.addArrangedSubview(amountTextField)
        mainStack.addArrangedSubview(categorySegmentedControl)
        mainStack.addArrangedSubview(addButton)
        
        NSLayoutConstraint.activate([
            mainStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            mainStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
}
