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

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
final class UIKitInteropTests: XCTestCase, View {
    func testPuttingAUIKitViewInsideASwiftUIWorkflow() throws {
        let launchArgs = UUID().uuidString
        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: launchArgs) {
            thenProceed(with: UIKitInteropProgrammaticViewController.self)
        }
        var vc: UIKitInteropProgrammaticViewController!

        let exp = ViewHosting.loadView(workflowView).inspection.inspect { workflowLauncher in
            let wrapper = try workflowLauncher.view(ViewControllerWrapper<UIKitInteropProgrammaticViewController>.self)
            let context = unsafeBitCast(FakeContext(), to: UIViewControllerRepresentableContext<ViewControllerWrapper<UIKitInteropProgrammaticViewController>>.self)
            vc = try wrapper.actualView().makeUIViewController(context: context)
            vc.removeFromParent()
            vc.loadOnDevice()

            XCTAssertUIViewControllerDisplayed(isInstance: vc)

            let proceedCalled = self.expectation(description: "proceedCalled")
            vc.proceedInWorkflowStorage = { args in
                XCTAssertEqual(args.extractArgs(defaultValue: nil) as? String, "Welcome \(launchArgs)!")
                proceedCalled.fulfill()
            }

            XCTAssertEqual(vc.saveButton?.willRespondToUser, true)
            XCTAssertEqual(vc?.emailTextField?.willRespondToUser, true)
            vc.emailTextField?.simulateTouch()
            vc.emailTextField?.simulateTyping(vc?.welcomeLabel?.text)
            vc.saveButton?.simulateTouch()

            self.wait(for: [proceedCalled], timeout: TestConstant.timeout)
        }

        wait(for: [exp], timeout: TestConstant.timeout)
    }

    func testPuttingAUIKitViewInsideASwiftUIWorkflowWithOtherSwiftUIViews() throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            weak var _workflowPointer: AnyFlowRepresentable?
            var body: some View { EmptyView() }
        }
        let launchArgs = UUID().uuidString
        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: launchArgs) {
            thenProceed(with: UIKitInteropProgrammaticViewController.self) {
                thenProceed(with: FR1.self)
            }
        }
        var vc: UIKitInteropProgrammaticViewController!

        let exp = ViewHosting.loadView(workflowView).inspection.inspect { workflowLauncher in
            let wrapper = try workflowLauncher.view(ViewControllerWrapper<UIKitInteropProgrammaticViewController>.self)
            let context = unsafeBitCast(FakeContext(), to: UIViewControllerRepresentableContext<ViewControllerWrapper<UIKitInteropProgrammaticViewController>>.self)
            vc = try wrapper.actualView().makeUIViewController(context: context)
            vc.removeFromParent()
            vc.loadOnDevice()

            XCTAssertUIViewControllerDisplayed(isInstance: vc)

            let proceedCalled = self.expectation(description: "proceedCalled")
            vc.proceedInWorkflowStorage = { args in
                XCTAssertEqual(args.extractArgs(defaultValue: nil) as? String, "Welcome \(launchArgs)!")
                proceedCalled.fulfill()
            }

            XCTAssertEqual(vc.saveButton?.willRespondToUser, true)
            XCTAssertEqual(vc?.emailTextField?.willRespondToUser, true)
            vc.emailTextField?.simulateTouch()
            vc.emailTextField?.simulateTyping(vc?.welcomeLabel?.text)
            vc.saveButton?.simulateTouch()

            self.wait(for: [proceedCalled], timeout: TestConstant.timeout)

            try workflowLauncher.actualView().inspectWrapped { fr1 in
                XCTAssertNoThrow(try fr1.find(FR1.self))
            }
        }

        wait(for: [exp], timeout: TestConstant.timeout)
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
        let workflowView = WorkflowLauncher(isLaunched: .constant(true)) {
            thenProceed(with: FR1.self)
        }
        var vc: FR1!

        let exp = ViewHosting.loadView(workflowView).inspection.inspect { workflowLauncher in
            let wrapper = try workflowLauncher.view(ViewControllerWrapper<FR1>.self)

            let context = unsafeBitCast(FakeContext(), to: UIViewControllerRepresentableContext<ViewControllerWrapper<FR1>>.self)
            vc = try wrapper.actualView().makeUIViewController(context: context)
        }

        wait(for: [exp], timeout: TestConstant.timeout)

        vc.removeFromParent()
        vc.loadOnDevice()

        XCTAssertUIViewControllerDisplayed(isInstance: vc)

        let proceedCalled = expectation(description: "proceedCalled")
        vc.proceedInWorkflowStorage = { _ in
            proceedCalled.fulfill()
        }

        XCTAssertEqual(vc.nextButton.willRespondToUser, true)
        vc.nextButton.simulateTouch()

        wait(for: [proceedCalled], timeout: TestConstant.timeout)
    }

    func testWorkflowPointerIsSetBeforeShouldLoadIsCalled() throws {
        final class FR1: UIWorkflowItem<Never, String>, FlowRepresentable {
            func shouldLoad() -> Bool {
                proceedInWorkflow("FR1")
                return false
            }
        }
        final class FR2: UIWorkflowItem<String, Never>, FlowRepresentable {
            init(with args: String) {
                XCTAssertEqual(args, "FR1")
                super.init(nibName: nil, bundle: nil)
            }
            required init?(coder: NSCoder) { nil }
        }
        let workflowView = WorkflowLauncher(isLaunched: .constant(true)) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }
        }
        var vc: FR2!

        let exp = ViewHosting.loadView(workflowView).inspection.inspect { workflowLauncher in
            let wrapper = try workflowLauncher.find(ViewControllerWrapper<FR2>.self)

            let context = unsafeBitCast(FakeContext(), to: UIViewControllerRepresentableContext<ViewControllerWrapper<FR2>>.self)
            vc = try wrapper.actualView().makeUIViewController(context: context)
        }

        wait(for: [exp], timeout: TestConstant.timeout)

        vc.removeFromParent()
        vc.loadOnDevice()

        XCTAssertUIViewControllerDisplayed(isInstance: vc)
    }

    func testPuttingAUIKitViewFromStoryboardInsideASwiftUIWorkflow() throws {
        let launchArgs = UUID().uuidString
        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: launchArgs) {
            thenProceed(with: TestInputViewController.self)
        }
        var vc: TestInputViewController!

        let exp = ViewHosting.loadView(workflowView).inspection.inspect { workflowLauncher in
            let wrapper = try workflowLauncher.view(ViewControllerWrapper<TestInputViewController>.self)
            let context = unsafeBitCast(FakeContext(), to: UIViewControllerRepresentableContext<ViewControllerWrapper<TestInputViewController>>.self)
            vc = try wrapper.actualView().makeUIViewController(context: context)
        }

        wait(for: [exp], timeout: TestConstant.timeout)

        vc.removeFromParent()
        vc.loadOnDevice()

        XCTAssertUIViewControllerDisplayed(isInstance: vc)

        let proceedCalled = expectation(description: "proceedCalled")
        vc.proceedInWorkflowStorage = { _ in
            proceedCalled.fulfill()
        }

        vc.proceedInWorkflow()

        wait(for: [proceedCalled], timeout: TestConstant.timeout)
    }

    func testPuttingAUIKitViewFromStoryboardThatDoesNotTakeInDataInsideASwiftUIWorkflow() throws {
        let workflowView = WorkflowLauncher(isLaunched: .constant(true)) {
            thenProceed(with: TestNoInputViewController.self)
        }
        var vc: TestNoInputViewController!

        let exp = ViewHosting.loadView(workflowView).inspection.inspect { workflowLauncher in
            let wrapper = try workflowLauncher.view(ViewControllerWrapper<TestNoInputViewController>.self)
            let context = unsafeBitCast(FakeContext(), to: UIViewControllerRepresentableContext<ViewControllerWrapper<TestNoInputViewController>>.self)
            vc = try wrapper.actualView().makeUIViewController(context: context)
        }

        wait(for: [exp], timeout: TestConstant.timeout)

        vc.removeFromParent()
        vc.loadOnDevice()

        XCTAssertUIViewControllerDisplayed(isInstance: vc)

        let proceedCalled = expectation(description: "proceedCalled")
        vc.proceedInWorkflowStorage = { _ in
            proceedCalled.fulfill()
        }

        vc.proceedInWorkflow()

        wait(for: [proceedCalled], timeout: TestConstant.timeout)
    }

    func testPuttingAUIKitViewThatDoesNotLoadInsideASwiftUIWorkflow() throws {
        final class FR1: UIWorkflowItem<Never, Never>, FlowRepresentable {
            func shouldLoad() -> Bool { false }
        }

        struct FR2: View, FlowRepresentable, Inspectable {
            weak var _workflowPointer: AnyFlowRepresentable?

            var body: some View {
                Text("FR2")
            }
        }
        let workflowView = WorkflowLauncher(isLaunched: .constant(true)) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }
        }

        let exp = ViewHosting.loadView(workflowView).inspection.inspect { workflowLauncher in
            XCTAssertThrowsError(try workflowLauncher.view(ViewControllerWrapper<FR1>.self))
            XCTAssertEqual(try workflowLauncher.find(FR2.self).text().string(), "FR2")
        }

        wait(for: [exp], timeout: TestConstant.timeout)
    }
}

extension UIViewController {
    func loadOnDevice() {
        // UIUTest's loadForTesting method does not work because it uses the deprecated `keyWindow` property.
        let window = UIApplication.shared.windows.first
        window?.removeViewsFromRootViewController()

        window?.rootViewController = self
        loadViewIfNeeded()
        view.layoutIfNeeded()

        CATransaction.flush()   // flush pending CoreAnimation operations to display the new view controller
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

class TestNoInputViewController: UIWorkflowItem<Never, Never>, StoryboardLoadable {
    static var storyboardId: String {
        String(describing: Self.self)
    }
    static var storyboard: UIStoryboard {
        UIStoryboard(name: "UIKitInterop", bundle: Bundle(for: Self.self))
    }
}

class TestInputViewController: UIWorkflowItem<String, Never>, StoryboardLoadable {
    static var storyboardId: String {
        String(describing: Self.self)
    }
    static var storyboard: UIStoryboard {
        UIStoryboard(name: "UIKitInterop", bundle: Bundle(for: Self.self))
    }

    required init?(coder: NSCoder, with name: String) {
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) { nil }
}
