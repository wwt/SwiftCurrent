//
//  SettingsViewController.swift
//  SwiftCurrent
//
//  Created by Nick Kaczmarek on 3/18/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Foundation
import UIKit
import SwiftCurrent
import SwiftCurrent_UIKit

final class SettingsViewController: UIWorkflowItem<String, Never>, FlowRepresentable {
    required init(with args: String) { // SwiftCurrent
        inputArgs = args
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    let inputArgs: String
    let onboardingLabel = UILabel()

    override func viewDidLoad() {
        onboardingLabel.text = inputArgs
        view.addSubview(onboardingLabel)
        onboardingLabel.translatesAutoresizingMaskIntoConstraints = false
        onboardingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        onboardingLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
