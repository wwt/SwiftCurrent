//
//  TermsOfServiceViewControllerTests.swift
//  UIKitExampleTests
//
//  Created by Richard Gist on 7/26/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

@testable import UIKitExample
import SwiftCurrent
import SwiftCurrent_Testing

class TermsOfServiceViewControllerTests: ViewControllerTest<TermsOfServiceViewController> {
    func testAcceptingAgreementContinuesForward() {
        var callbackCalled = false
        loadFromStoryboard(args: .none) { viewController in
            viewController._proceedInWorkflow = { _ in
                callbackCalled = true
            }
        }

        testViewController.acceptButton?.simulateTouch()

        XCTAssert(callbackCalled)
    }

    func testRejectingAgreementAbandonsWorkflow() {
        let mockResponder = MockOrchestrationResponder()
        mockResponder.complete_EnableDefaultImplementation = true
        let workflowBeingAbandoned = Workflow(TermsOfServiceViewController.self)
        workflowBeingAbandoned.launch(withOrchestrationResponder: mockResponder) { _ in XCTFail("Should not complete Workflow") }
        testViewController = mockResponder.lastTo?.value.instance?.underlyingInstance as? TermsOfServiceViewController
        testViewController.loadForTesting()

        testViewController.rejectButton?.simulateTouch()

        XCTAssertEqual(mockResponder.abandonCalled, 1)
    }
}

fileprivate extension UIViewController {
    var acceptButton: UIButton? {
        view.viewWithAccessibilityIdentifier("acceptButton") as? UIButton
    }

    var rejectButton: UIButton? {
        view.viewWithAccessibilityIdentifier("rejectButton") as? UIButton
    }
}
