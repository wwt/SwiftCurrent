//
//  UIKitInteropProgrammaticViewController.swift
//  SwiftUIExample
//
//  Created by Tyler Thompson on 8/7/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import UIKit
import SwiftCurrent
import SwiftCurrent_UIKit

final class UIKitInteropProgrammaticViewController: UIWorkflowItem<String, String>, FlowRepresentable {
    private let name: String
    private let emailTextField = UITextField()
    private let welcomeLabel = UILabel()
    private let saveButton = UIButton()

    required init(with name: String) { // SwiftCurrent
        self.name = name
        super.init(nibName: nil, bundle: nil)
        configureViews()
    }

    required init?(coder: NSCoder) { nil }

    @objc private func savePressed() {
        proceedInWorkflow(emailTextField.text ?? "") // SwiftCurrent
    }

    private func configureViews() {
        view.backgroundColor = .systemGray5

        welcomeLabel.accessibilityIdentifier = "welcomeLabel"
        welcomeLabel.text = "Welcome \(name)!"

        emailTextField.backgroundColor = .systemGray3
        emailTextField.borderStyle = .roundedRect
        emailTextField.placeholder = "Enter email..."

        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.systemBlue, for: .normal)
        saveButton.addTarget(self, action: #selector(savePressed), for: .touchUpInside)

        view.addSubview(welcomeLabel)
        view.addSubview(emailTextField)
        view.addSubview(saveButton)

        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        welcomeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true

        emailTextField.accessibilityIdentifier = "emailTextField"
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailTextField.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 16).isActive = true
        emailTextField.widthAnchor.constraint(equalToConstant: 300).isActive = true

        saveButton.accessibilityIdentifier = "saveButton"
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        saveButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 24).isActive = true
    }
}
