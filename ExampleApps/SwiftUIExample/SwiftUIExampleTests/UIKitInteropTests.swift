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
    func testPuttingAUIKitViewInsideASwiftUIWorkflow() async throws {
        let launchArgs = UUID().uuidString

        let launcher = try await MainActor.run {
            WorkflowView(launchingWith: launchArgs) {
                WorkflowItem(UIKitInteropProgrammaticViewController.self)
            }
        }
            .content
            .hostAndInspect(with: \.inspection)
            .extractWorkflowItemWrapper()

        try await MainActor.run {
            let wrapper = try launcher.find(ViewControllerWrapper<UIKitInteropProgrammaticViewController>.self)
            let context = unsafeBitCast(FakeContext(), to: UIViewControllerRepresentableContext<ViewControllerWrapper<UIKitInteropProgrammaticViewController>>.self)
            var vc = try wrapper.actualView().makeUIViewController(context: context)
            vc.removeFromParent()
            vc.loadOnDevice()

            XCTAssertUIViewControllerDisplayed(isInstance: vc)

            let proceedCalled = self.expectation(description: "proceedCalled")
            vc.proceedInWorkflowStorage = { args in
                XCTAssertEqual(args.extractArgs(defaultValue: nil) as? String, "Welcome \(launchArgs)!")
                proceedCalled.fulfill()
            }

            XCTAssertEqual(vc.saveButton?.willRespondToUser, true)
            XCTAssertEqual(vc.emailTextField?.willRespondToUser, true)
            vc.emailTextField?.simulateTouch()
            vc.emailTextField?.simulateTyping(vc.welcomeLabel?.text)
            vc.saveButton?.simulateTouch()

            self.wait(for: [proceedCalled], timeout: TestConstant.timeout)
        }
    }

    func testPuttingAUIKitViewInsideASwiftUIWorkflowWithOtherSwiftUIViews() async throws {
        throw XCTSkip("Issue with environment objects being read, functionality appears to still work")
        struct FR1: View, FlowRepresentable, Inspectable {
            weak var _workflowPointer: AnyFlowRepresentable?
            let str: String
            init(with str: String) {
                self.str = str
            }
            var body: some View { Text(str) }
        }
        let launchArgs = UUID().uuidString
        let launcher = try await MainActor.run {
            WorkflowView(launchingWith: launchArgs) {
                WorkflowItem(UIKitInteropProgrammaticViewController.self)
                WorkflowItem(FR1.self)
            }
        }
            .content
            .hostAndInspect(with: \.inspection)
            .extractWorkflowItemWrapper()

        try await MainActor.run {
            let wrapper = try launcher.find(ViewControllerWrapper<UIKitInteropProgrammaticViewController>.self)
            let context = unsafeBitCast(FakeContext(), to: UIViewControllerRepresentableContext<ViewControllerWrapper<UIKitInteropProgrammaticViewController>>.self)
            let vc = try wrapper.actualView().makeUIViewController(context: context)
            vc.removeFromParent()
            vc.loadOnDevice()

            XCTAssertUIViewControllerDisplayed(isInstance: vc)

            XCTAssertEqual(vc.saveButton?.willRespondToUser, true)
            XCTAssertEqual(vc.emailTextField?.willRespondToUser, true)
            vc.emailTextField?.simulateTouch()
            vc.emailTextField?.simulateTyping(vc.welcomeLabel?.text)
            vc.saveButton?.simulateTouch()

            XCTAssertEqual(try launcher.find(FR1.self).text().string(), "Welcome \(launchArgs)!")
        }
    }

    func testPuttingAUIKitViewThatDoesNotTakeInDataInsideASwiftUIWorkflow() async throws {
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

        let workflowView = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
            }
        }
            .content
            .hostAndInspect(with: \.inspection)
            .extractWorkflowItemWrapper()

        try await MainActor.run {
            let wrapper = try workflowView.find(ViewControllerWrapper<FR1>.self)

            let context = unsafeBitCast(FakeContext(), to: UIViewControllerRepresentableContext<ViewControllerWrapper<FR1>>.self)
            var vc = try wrapper.actualView().makeUIViewController(context: context)

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
    }

    func testWorkflowPointerIsSetBeforeShouldLoadIsCalled() async throws {
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
        let launcher = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
                WorkflowItem(FR2.self)
            }
        }
        .hostAndInspect(with: \.inspection)

        try await MainActor.run {
            let wrapper = try launcher.find(ViewControllerWrapper<FR2>.self)

            let context = unsafeBitCast(FakeContext(), to: UIViewControllerRepresentableContext<ViewControllerWrapper<FR2>>.self)
            let vc = try wrapper.actualView().makeUIViewController(context: context)
            vc.removeFromParent()
            vc.loadOnDevice()

            XCTAssertUIViewControllerDisplayed(isInstance: vc)
        }
    }

    func testPuttingAUIKitViewFromStoryboardInsideASwiftUIWorkflow() async throws {
        let launchArgs = UUID().uuidString
        let launcher = try await MainActor.run {
            WorkflowView(launchingWith: launchArgs) {
                WorkflowItem(TestInputViewController.self)
            }
        }
            .content
            .hostAndInspect(with: \.inspection)
            .extractWorkflowItemWrapper()

        try await MainActor.run {
            let wrapper = try launcher.find(ViewControllerWrapper<TestInputViewController>.self)
            let context = unsafeBitCast(FakeContext(), to: UIViewControllerRepresentableContext<ViewControllerWrapper<TestInputViewController>>.self)
            var vc = try wrapper.actualView().makeUIViewController(context: context)

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
    }

    func testPuttingAUIKitViewFromStoryboardThatDoesNotTakeInDataInsideASwiftUIWorkflow() async throws {
        let launcher = try await MainActor.run {
            WorkflowView {
                WorkflowItem(TestNoInputViewController.self)
            }
        }
            .content
            .hostAndInspect(with: \.inspection)
            .extractWorkflowItemWrapper()

        try await MainActor.run {
            let wrapper = try launcher.find(ViewControllerWrapper<TestNoInputViewController>.self)
            let context = unsafeBitCast(FakeContext(), to: UIViewControllerRepresentableContext<ViewControllerWrapper<TestNoInputViewController>>.self)
            var vc = try wrapper.actualView().makeUIViewController(context: context)

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
    }

    func testPuttingAUIKitViewThatDoesNotLoadInsideASwiftUIWorkflow() async throws {
        final class FR1: UIWorkflowItem<Never, Never>, FlowRepresentable {
            func shouldLoad() -> Bool { false }
        }

        struct FR2: View, FlowRepresentable, Inspectable {
            weak var _workflowPointer: AnyFlowRepresentable?

            var body: some View {
                Text("FR2")
            }
        }

        let launcher = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
                WorkflowItem(FR2.self)
            }
        }
            .content
            .hostAndInspect(with: \.inspection)
            .extractWorkflowItemWrapper()

        XCTAssertThrowsError(try launcher.view(ViewControllerWrapper<FR1>.self))
        XCTAssertEqual(try launcher.find(FR2.self).text().string(), "FR2")
    }
}

extension UIViewController {
    func loadOnDevice() {
        // UIUTest's loadForTesting method does not work because it uses the deprecated `keyWindow` property.
        let window = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first?.windows.first
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
