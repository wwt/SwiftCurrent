//
//  ProfileFeatureOnboardingViewTests.swift
//  SwiftUIExampleAppTests
//
//  Created by Tyler Thompson on 7/15/21.
//
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.

import XCTest
import SwiftUI
import Swinject
import ViewInspector

@testable import SwiftCurrent_SwiftUI // 🤮 it sucks that this is necessary
@testable import SwiftUIExampleApp

final class ProfileFeatureOnboardingViewTests: XCTestCase {
    override func setUpWithError() throws {
        Container.default.removeAll()
    }

    func testOnboardingInWorkflow() throws {
        let defaults = try XCTUnwrap(UserDefaults(suiteName: #function))
        defaults.set(false, forKey: "OnboardedToProfileFeature")
        Container.default.register(UserDefaults.self) { _ in defaults }
        let workflowFinished = expectation(description: "View Proceeded")
        let exp = ViewHosting.loadView(WorkflowView(isPresented: .constant(true))
                                        .thenProceed(with: WorkflowItem(ProfileFeatureOnboardingView.self))
                                        .onFinish { _ in
            workflowFinished.fulfill()
        }).inspection.inspect { view in // swiftlint:disable:this closure_end_indentation
            XCTAssertNoThrow(try view.find(ViewType.Text.self))
            XCTAssertEqual(try view.find(ViewType.Text.self).string(), "Learn about our awesome profile feature!")
            XCTAssertNoThrow(try view.find(ViewType.Button.self).tap())
        } // swiftlint:disable:this closure_end_indentation
        wait(for: [exp, workflowFinished], timeout: 0.3)
    }

    func testOnboardingViewLoads_WhenNoValueIsInUserDefaults() throws {
        let defaults = try XCTUnwrap(UserDefaults(suiteName: #function))
        defaults.removeObject(forKey: "OnboardedToProfileFeature")
        Container.default.register(UserDefaults.self) { _ in defaults }
        XCTAssert(ProfileFeatureOnboardingView().shouldLoad(), "Profile onboarding should show if defaults do not exist")
    }

    func testOnboardingViewLoads_WhenValueInUserDefaultsIsFalse() throws {
        let defaults = try XCTUnwrap(UserDefaults(suiteName: #function))
        defaults.set(false, forKey: "OnboardedToProfileFeature")
        Container.default.register(UserDefaults.self) { _ in defaults }
        XCTAssert(ProfileFeatureOnboardingView().shouldLoad(), "Profile onboarding should show if default is false")
    }

    func testOnboardingViewDoesNotLoad_WhenValueInUserDefaultsIsTrue() throws {
        let defaults = try XCTUnwrap(UserDefaults(suiteName: #function))
        defaults.set(true, forKey: "OnboardedToProfileFeature")
        Container.default.register(UserDefaults.self) { _ in defaults }
        XCTAssertFalse(ProfileFeatureOnboardingView().shouldLoad(), "Profile onboarding should not show if default is true")
    }
}