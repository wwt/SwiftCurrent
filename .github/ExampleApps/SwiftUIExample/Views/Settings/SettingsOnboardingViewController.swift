//
//  SettingsOnboardingViewController.swift
//  SwiftCurrent
//
//  Created by Nick Kaczmarek on 3/18/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Foundation
import UIKit
import SwiftCurrent
import SwiftCurrent_UIKit

final class SettingsOnboardingViewController: UIWorkflowItem<Never, String>, FlowRepresentable { // SwiftCurrent
    typealias WorkflowOutput = String
    let nextButton = UIButton()
    let onboardingLabel = UILabel()

    @objc private func nextPressed() {
        proceedInWorkflow("Check out all these settings!")
    }

    override func viewDidLoad() {
        nextButton.setTitle("Continue", for: .normal)
        nextButton.setTitleColor(.systemBlue, for: .normal)
        nextButton.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
        view.addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nextButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        onboardingLabel.text = "This is a settings onboarding view in UIKit"
        view.addSubview(onboardingLabel)
        onboardingLabel.translatesAutoresizingMaskIntoConstraints = false
        onboardingLabel.centerXAnchor.constraint(equalTo: nextButton.centerXAnchor).isActive = true
        onboardingLabel.centerYAnchor.constraint(equalTo: nextButton.centerYAnchor, constant: -44).isActive = true
    }
}
