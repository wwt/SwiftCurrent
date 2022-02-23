//
//  MapFeatureOnboardingViewTests.swift
//  SwiftUIExampleTests
//
//  Created by Tyler Thompson on 7/15/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest
import SwiftUI
import Swinject
import ViewInspector

@testable import SwiftCurrent_SwiftUI // 🤮 it sucks that this is necessary
@testable import SwiftUIExample

final class MapFeatureOnboardingViewTests: XCTestCase, View {
    let defaultsKey = "OnboardedToMapFeature"
    override func setUpWithError() throws {
        Container.default.removeAll()
    }

    func testOnboardingInWorkflow() async throws {
        let defaults = try XCTUnwrap(UserDefaults(suiteName: #function))
        defaults.set(false, forKey: defaultsKey)
        Container.default.register(UserDefaults.self) { _ in defaults }
        let workflowFinished = expectation(description: "View Proceeded")

        let view = try await MainActor.run {
            WorkflowView {
                WorkflowItem(MapFeatureOnboardingView.self)
            }.onFinish { _ in
                workflowFinished.fulfill()
            }
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowItem()

        XCTAssertNoThrow(try view.find(ViewType.Text.self))
        XCTAssertEqual(try view.find(ViewType.Text.self).string(), "Learn about our awesome map feature!")
        XCTAssertNoThrow(try view.find(ViewType.Button.self).tap())

        wait(for: [workflowFinished], timeout: TestConstant.timeout)
    }

    func testOnboardingViewLoads_WhenNoValueIsInUserDefaults() throws {
        let defaults = try XCTUnwrap(UserDefaults(suiteName: #function))
        defaults.removeObject(forKey: defaultsKey)
        Container.default.register(UserDefaults.self) { _ in defaults }
        XCTAssert(MapFeatureOnboardingView().shouldLoad(), "Profile onboarding should show if defaults do not exist")
    }

    func testOnboardingViewLoads_WhenValueInUserDefaultsIsFalse() throws {
        let defaults = try XCTUnwrap(UserDefaults(suiteName: #function))
        defaults.set(false, forKey: defaultsKey)
        Container.default.register(UserDefaults.self) { _ in defaults }
        XCTAssert(MapFeatureOnboardingView().shouldLoad(), "Profile onboarding should show if default is false")
    }

    func testOnboardingViewDoesNotLoad_WhenValueInUserDefaultsIsTrue() throws {
        let defaults = try XCTUnwrap(UserDefaults(suiteName: #function))
        defaults.set(true, forKey: defaultsKey)
        Container.default.register(UserDefaults.self) { _ in defaults }
        XCTAssertFalse(MapFeatureOnboardingView().shouldLoad(), "Profile onboarding should not show if default is true")
    }
}
