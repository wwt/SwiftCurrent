//
//  GenericOnboardingViewTests.swift
//  SwiftCurrent
//
//  Created by Richard Gist on 10/7/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//  

import XCTest
import SwiftUI
import Swinject
import ViewInspector

@testable import SwiftCurrent_SwiftUI // 🤮 it sucks that this is necessary
@testable import SwiftUIExample

final class GenericOnboardingViewTests: XCTestCase, View {
    let defaultModel = OnboardingData(previewImage: .logo,
                                      previewAccent: .blue,
                                      featureTitle: UUID().uuidString,
                                      featureSummary: UUID().uuidString,
                                      appStorageKey: UUID().uuidString,
                                      appStorageStore: .fromDI)

    override func setUpWithError() throws {
        Container.default.removeAll()
    }

    func testOnboardingInWorkflow() throws {
        let defaults = try XCTUnwrap(UserDefaults(suiteName: #function))
        defaults.set(false, forKey: defaultModel.appStorageKey)
        Container.default.register(UserDefaults.self) { _ in defaults }
        let workflowFinished = expectation(description: "View Proceeded")
        let exp = ViewHosting.loadView(WorkflowLauncher(isLaunched: .constant(true), startingArgs: defaultModel) {
            thenProceed(with: GenericOnboardingView.self)
        }.onFinish { _ in
            workflowFinished.fulfill()
        }).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(ViewType.Text.self))
            XCTAssertEqual(try view.find(ViewType.Text.self).string(), self.defaultModel.featureTitle)
            XCTAssertNoThrow(try view.find(ViewType.Button.self).tap())
        }
        wait(for: [exp, workflowFinished], timeout: TestConstant.timeout)
    }

    func testOnboardingViewLoads_WhenNoValueIsInUserDefaults() throws {
        let defaults = try XCTUnwrap(UserDefaults(suiteName: #function))
        defaults.removeObject(forKey: defaultModel.appStorageKey)
        Container.default.register(UserDefaults.self) { _ in defaults }
        XCTAssert(GenericOnboardingView(with: defaultModel).shouldLoad(), "Profile onboarding should show if defaults do not exist")
    }

    func testOnboardingViewLoads_WhenValueInUserDefaultsIsFalse() throws {
        let defaults = try XCTUnwrap(UserDefaults(suiteName: #function))
        defaults.set(false, forKey: defaultModel.appStorageKey)
        Container.default.register(UserDefaults.self) { _ in defaults }
        XCTAssert(GenericOnboardingView(with: defaultModel).shouldLoad(), "Profile onboarding should show if default is false")
    }

    func testOnboardingViewDoesNotLoad_WhenValueInUserDefaultsIsTrue() throws {
        let defaults = try XCTUnwrap(UserDefaults(suiteName: #function))
        defaults.set(true, forKey: defaultModel.appStorageKey)
        Container.default.register(UserDefaults.self) { _ in defaults }
        XCTAssertFalse(GenericOnboardingView(with: defaultModel).shouldLoad(), "Profile onboarding should not show if default is true")
    }

    func testOnboardingAsView() throws {
        let defaults = try XCTUnwrap(UserDefaults(suiteName: #function))
        defaults.set(true, forKey: defaultModel.appStorageKey)
        Container.default.register(UserDefaults.self) { _ in defaults }

        let onboardingActionExpectation = expectation(description: "View Proceeded")
        let genericOnboardingView = GenericOnboardingView(model: defaultModel) {
            onboardingActionExpectation.fulfill()
        }

        let exp = ViewHosting.loadView(genericOnboardingView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(ViewType.Text.self))
            XCTAssertEqual(try view.find(ViewType.Text.self).string(), self.defaultModel.featureTitle)
            XCTAssertNoThrow(try view.find(ViewType.Button.self).tap())
        }

        wait(for: [exp, onboardingActionExpectation], timeout: TestConstant.timeout)
    }
}
