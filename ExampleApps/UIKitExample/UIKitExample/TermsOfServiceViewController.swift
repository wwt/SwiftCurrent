//
//  TermsOfServiceViewController.swift
//  UIKitExample
//
//  Created by Richard Gist on 7/26/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import UIKit
import SwiftCurrent
import SwiftCurrent_UIKit

class TermsOfServiceViewController: UIViewController, PassthroughFlowRepresentable, StoryboardLoadable {
    weak var _workflowPointer: AnyFlowRepresentable?

    @IBAction private func acceptTerms(_ sender: Any) {
        proceedInWorkflow()
    }

    @IBAction private func rejectTerms(_ sender: Any) {
        abandonWorkflow()
    }
}
