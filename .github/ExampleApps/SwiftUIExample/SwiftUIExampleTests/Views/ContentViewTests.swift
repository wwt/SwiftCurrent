//
//  ContentViewTests.swift
//  SwiftUIExampleTests
//
//  Created by Tyler Thompson on 7/15/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest
import ViewInspector
import Swinject

@testable import SwiftCurrent_SwiftUI
@testable import SwiftUIExample

final class ContentViewTests: XCTestCase {
    override func setUpWithError() throws {
        Container.default.removeAll()
    }

    func testContentView() async throws {
        let defaults = try XCTUnwrap(UserDefaults(suiteName: #function))
        Container.default.register(UserDefaults.self) { _ in defaults }

        let contentView = try await ContentView().hostAndInspect(with: \.inspection)
        let wf1 = try await MainActor.run {
            try contentView.tabView().workflow(0) {
                WorkflowItem(MapFeatureOnboardingView.self)
                WorkflowItem(MapFeatureView.self)
            }
        }
        XCTAssertEqual(try wf1.tabItem().label().title().text().string(), "Map")
        let wf2 = try await MainActor.run {
            try contentView.tabView().workflow(1) {
                WorkflowItem(QRScannerFeatureOnboardingView.self)
                WorkflowItem(QRScannerFeatureView.self)
            }
        }
        XCTAssertEqual(try wf2.tabItem().label().title().text().string(), "QR Scanner")
        let wf3 = try await MainActor.run {
            try contentView.tabView().workflow(2) {
                WorkflowItem(ProfileFeatureOnboardingView.self)
                WorkflowItem(ProfileFeatureView.self)
            }
        }
        XCTAssertEqual(try wf3.tabItem().label().title().text().string(), "Profile")

        let wfr1 = try await wf1.actualView().hostAndInspect(with: \.inspection)
        try await wfr1.find(MapFeatureOnboardingView.self).proceedInWorkflow()
        XCTAssertNoThrow(try wfr1.find(MapFeatureView.self))

        let wfr2 = try await wf2.actualView().hostAndInspect(with: \.inspection)
        try await wfr2.find(QRScannerFeatureOnboardingView.self).proceedInWorkflow()
        XCTAssertNoThrow(try wfr2.find(QRScannerFeatureView.self))

        let wfr3 = try await wf3.actualView().hostAndInspect(with: \.inspection)
        try await wfr3.find(ProfileFeatureOnboardingView.self).proceedInWorkflow()
        XCTAssertNoThrow(try wfr3.find(ProfileFeatureView.self))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension InspectableView where View: SingleViewContent {
    func workflow<T: Inspectable & _WorkflowItemProtocol>(@WorkflowBuilder builder: () -> T) throws -> InspectableView<ViewType.View<WorkflowView<WorkflowLauncher<T>>>> {
        try view(WorkflowView<WorkflowLauncher<T>>.self)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension InspectableView where View: MultipleViewContent {
    func workflow<T: Inspectable & _WorkflowItemProtocol>(_ index: Int, @WorkflowBuilder builder: () -> T) throws -> InspectableView<ViewType.View<WorkflowView<WorkflowLauncher<T>>>> {
        try view(WorkflowView<WorkflowLauncher<T>>.self, index)
    }
}
