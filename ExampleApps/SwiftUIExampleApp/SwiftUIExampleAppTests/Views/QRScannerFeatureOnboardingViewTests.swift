//
//  QRScannerFeatureOnboardingViewTests.swift
//  SwiftUIExampleAppTests
//
//  Created by Tyler Thompson on 7/15/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest
import SwiftUI
import Swinject
import ViewInspector

@testable import SwiftCurrent_SwiftUI // 🤮 it sucks that this is necessary
@testable import SwiftUIExampleApp

final class QRScannerFeatureOnboardingViewTests: XCTestCase {
    let defaultsKey = "OnboardedToQRScanningFeature"
    override func setUpWithError() throws {
        print("!!! \(Self.self).setUpWithError()")
        Container.default.removeAll()
    }

    #warning("Pipeline has a really hard time with this, even though locally it continues to work great, replacement test below this test.")
    func testOnboardingInWorkflow() throws {
        print("!!! \(Self.self).testOnboardingInWorkflow - start")
        let defaults = try XCTUnwrap(UserDefaults(suiteName: #function))
        defaults.set(false, forKey: defaultsKey)
        Container.default.register(UserDefaults.self) { _ in defaults }
        let workflowFinished = expectation(description: "View Proceeded")
        print("!!! \(Self.self).testOnboardingInWorkflow - about to loadView")
        let exp = ViewHosting.loadView(WorkflowView(isLaunched: .constant(true))
                                        .thenProceed(with: WorkflowItem(QRScannerFeatureOnboardingView.self))
                                        .onFinish { _ in
                                            print("!!! \(Self.self).testOnboardingInWorkflow - onFinish")
                                            workflowFinished.fulfill()
                                        }).inspection.inspect { view in
                                            print("!!! \(Self.self).testOnboardingInWorkflow - Inspected")
                                            XCTAssertNoThrow(try view.find(ViewType.Text.self))
                                            XCTAssertEqual(try view.find(ViewType.Text.self).string(), "Learn about our awesome QR scanning feature!")
                                            XCTAssertNoThrow(try view.find(ViewType.Button.self).tap())
                                        }
        wait(for: [exp, workflowFinished], timeout: 1)
        print("!!! \(Self.self).testOnboardingInWorkflow - Complete")
    }

    // This test fails sporadically and the test above is preferred.
//    func testOnboardingProceedsInWorkflow() throws {
//        print("!!! \(Self.self).testOnboardingProceedsInWorkflow - Before setup: \(Container.default) \n\n")
//        let proceedCalled = expectation(description: "Proceed called")
//        let defaults = try XCTUnwrap(UserDefaults(suiteName: #function))
//        defaults.set(false, forKey: defaultsKey)
//        Container.default.register(UserDefaults.self) { _ in defaults }
//        let erased = AnyFlowRepresentableView(type: QRScannerFeatureOnboardingView.self, args: .none)
//        var onboardingView = erased.underlyingInstance as! QRScannerFeatureOnboardingView
//        onboardingView.proceedInWorkflowStorage = { _ in
//            proceedCalled.fulfill()
//        }
//        onboardingView._workflowPointer = erased
//        print("!!! \(Self.self).testOnboardingProceedsInWorkflow - After setup: \(Container.default) \n Using: \(defaults) \n With default: \(defaults.bool(forKey: defaultsKey))\n\n")
//
//        print("!!! \(Self.self).testOnboardingProceedsInWorkflow - about to loadView: \(onboardingView)")
//        let view = ViewHosting.loadView(onboardingView)
//        print("!!! \(Self.self).testOnboardingProceedsInWorkflow - about to add inspection to: \(view)")
//        let inspection = view.inspection
//        print("!!! \(Self.self).testOnboardingProceedsInWorkflow - about to inspect: \(inspection)")
//        let exp = inspection.inspect { view in
//            XCTAssertNoThrow(try view.find(ViewType.Text.self))
//            XCTAssertEqual(try view.find(ViewType.Text.self).string(), "Learn about our awesome QR scanning feature!")
//            XCTAssertNoThrow(try view.find(ViewType.Button.self).tap())
//        }
//        wait(for: [exp, proceedCalled], timeout: 1)
//    }

    func testOnboardingViewLoads_WhenNoValueIsInUserDefaults() throws {
        let defaults = try XCTUnwrap(UserDefaults(suiteName: #function))
        defaults.removeObject(forKey: defaultsKey)
        Container.default.register(UserDefaults.self) { _ in defaults }
        XCTAssert(QRScannerFeatureOnboardingView().shouldLoad(), "Profile onboarding should show if defaults do not exist")
    }

    func testOnboardingViewLoads_WhenValueInUserDefaultsIsFalse() throws {
        let defaults = try XCTUnwrap(UserDefaults(suiteName: #function))
        defaults.set(false, forKey: defaultsKey)
        Container.default.register(UserDefaults.self) { _ in defaults }
        XCTAssert(QRScannerFeatureOnboardingView().shouldLoad(), "Profile onboarding should show if default is false")
    }

    func testOnboardingViewDoesNotLoad_WhenValueInUserDefaultsIsTrue() throws {
        let defaults = try XCTUnwrap(UserDefaults(suiteName: #function))
        defaults.set(true, forKey: defaultsKey)
        Container.default.register(UserDefaults.self) { _ in defaults }
        XCTAssertFalse(QRScannerFeatureOnboardingView().shouldLoad(), "Profile onboarding should not show if default is true")
    }
}
