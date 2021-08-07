//
//  UIKitInteropTests.swift
//  SwiftUIExampleTests
//
//  Created by Tyler Thompson on 8/7/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//
//  swiftlint:disable file_types_order

import XCTest
import SwiftUI
import UIKit

import UIUTest
import ViewInspector

import SwiftCurrent
import SwiftCurrent_UIKit
@testable import SwiftCurrent_SwiftUI
@testable import SwiftUIExample

final class UIKitInteropTests: XCTestCase {
    func testPuttingAUIKitViewInsideASwiftUIWorkflow() throws {
        let launchArgs = UUID().uuidString
        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: launchArgs)
            .thenProceed(with: WorkflowItem(UIKitInteropProgrammaticViewController.self))
        var vc: UIKitInteropProgrammaticViewController!

        let exp = ViewHosting.loadView(workflowView).inspection.inspect { workflowLauncher in
            let wrapper = try workflowLauncher.view(ViewControllerWrapper<UIKitInteropProgrammaticViewController>.self)
            let context = unsafeBitCast(FakeContext(), to: UIViewControllerRepresentableContext<ViewControllerWrapper<UIKitInteropProgrammaticViewController>>.self)
            vc = try wrapper.actualView().makeUIViewController(context: context)
        }

        wait(for: [exp], timeout: TestConstant.timeout)

        // UIUTest's loadForTesting method does not work because it uses the deprecated `keyWindow` property.
        let window = UIApplication.shared.windows.first
        window?.removeViewsFromRootViewController()

        window?.rootViewController = vc
        vc.loadViewIfNeeded()
        vc.view.layoutIfNeeded()

        CATransaction.flush()   // flush pending CoreAnimation operations to display the new view controller

        XCTAssertUIViewControllerDisplayed(isInstance: vc)

        let proceedCalled = expectation(description: "proceedCalled")
        vc.proceedInWorkflowStorage = { args in
            XCTAssertEqual(args.extractArgs(defaultValue: nil) as? String, "Welcome \(launchArgs)!")
            proceedCalled.fulfill()
        }

        XCTAssertEqual(vc.saveButton?.willRespondToUser, true)
        XCTAssertEqual(vc?.emailTextField?.willRespondToUser, true)
        vc.emailTextField?.simulateTouch()
        vc.emailTextField?.simulateTyping(vc?.welcomeLabel?.text)
        vc.saveButton?.simulateTouch()

        wait(for: [proceedCalled], timeout: TestConstant.timeout)
    }

    func testPuttingAUIKitViewThatDoesNotTakeInDataInsideASwiftUIWorkflow() throws {
        final class FR1: UIWorkflowItem<Never, Never>, FlowRepresentable {
            let nextButton = UIButton()

            @objc private func nextPressed() {
                proceedInWorkflow()
            }

            override func viewDidLoad() {
                nextButton.setTitle("Next", for: .normal)
                nextButton.setTitleColor(.systemBlue, for: .normal)
                nextButton.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)

                view.addSubview(nextButton)

                nextButton.translatesAutoresizingMaskIntoConstraints = false
                nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
                nextButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            }
        }
        let workflowView = WorkflowLauncher(isLaunched: .constant(true))
            .thenProceed(with: WorkflowItem(FR1.self))
        var vc: FR1!

        let exp = ViewHosting.loadView(workflowView).inspection.inspect { workflowLauncher in
            let wrapper = try workflowLauncher.view(ViewControllerWrapper<FR1>.self)
            let context = unsafeBitCast(FakeContext(), to: UIViewControllerRepresentableContext<ViewControllerWrapper<FR1>>.self)
            vc = try wrapper.actualView().makeUIViewController(context: context)
        }

        wait(for: [exp], timeout: TestConstant.timeout)

        // UIUTest's loadForTesting method does not work because it uses the deprecated `keyWindow` property.
        let window = UIApplication.shared.windows.first
        window?.removeViewsFromRootViewController()

        window?.rootViewController = vc
        vc.loadViewIfNeeded()
        vc.view.layoutIfNeeded()

        CATransaction.flush()   // flush pending CoreAnimation operations to display the new view controller

        XCTAssertUIViewControllerDisplayed(isInstance: vc)

        let proceedCalled = expectation(description: "proceedCalled")
        vc.proceedInWorkflowStorage = { _ in
            proceedCalled.fulfill()
        }

        XCTAssertEqual(vc.nextButton.willRespondToUser, true)
        vc.nextButton.simulateTouch()

        wait(for: [proceedCalled], timeout: TestConstant.timeout)
    }
}

extension UIKitInteropProgrammaticViewController {
    var welcomeLabel: UILabel? {
        view.viewWithAccessibilityIdentifier("welcomeLabel") as? UILabel
    }

    var saveButton: UIButton? {
        view.viewWithAccessibilityIdentifier("saveButton") as? UIButton
    }

    var emailTextField: UITextField? {
        view.viewWithAccessibilityIdentifier("emailTextField") as? UITextField
    }
}

struct FakeContext {
    let coordinator: (String, String) = ("", "")
}
