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
    private typealias MapWorkflow = WorkflowLauncher<WorkflowItem<MapFeatureOnboardingView, WorkflowItem<MapFeatureView, Never, MapFeatureView>, MapFeatureOnboardingView>>
    private typealias QRScannerWorkflow = WorkflowLauncher<WorkflowItem<QRScannerFeatureOnboardingView, WorkflowItem<QRScannerFeatureView, Never, QRScannerFeatureView>, QRScannerFeatureOnboardingView>>
    private typealias ProfileWorkflow = WorkflowLauncher<WorkflowItem<ProfileFeatureOnboardingView, WorkflowItem<ProfileFeatureView, Never, ProfileFeatureView>, ProfileFeatureOnboardingView>>

    override func setUpWithError() throws {
        Container.default.removeAll()
    }

    func testContentView() async throws {
        let defaults = try XCTUnwrap(UserDefaults(suiteName: #function))
        Container.default.register(UserDefaults.self) { _ in defaults }

        let contentView = try await ContentView().hostAndInspect(with: \.inspection)
        let wf1 = try contentView.tabView().view(MapWorkflow.self, 0).actualView()
        XCTAssertEqual(try contentView.tabView().view(MapWorkflow.self, 0).tabItem().label().title().text().string(), "Map")
        let wf2 = try contentView.tabView().view(QRScannerWorkflow.self, 1).actualView()
        XCTAssertEqual(try contentView.tabView().view(QRScannerWorkflow.self, 1).tabItem().label().title().text().string(), "QR Scanner")
        let wf3 = try contentView.tabView().view(ProfileWorkflow.self, 2).actualView()
        XCTAssertEqual(try contentView.tabView().view(ProfileWorkflow.self, 2).tabItem().label().title().text().string(), "Profile")

        let wfr1 = try await wf1.hostAndInspect(with: \.inspection)
        try await wfr1.find(MapFeatureOnboardingView.self).proceedInWorkflow()
        XCTAssertNoThrow(try wfr1.find(MapFeatureView.self))

        let wfr2 = try await wf2.hostAndInspect(with: \.inspection)
        try await wfr2.find(QRScannerFeatureOnboardingView.self).proceedInWorkflow()
        XCTAssertNoThrow(try wfr2.find(QRScannerFeatureView.self))

        let wfr3 = try await wf3.hostAndInspect(with: \.inspection)
        try await wfr3.find(ProfileFeatureOnboardingView.self).proceedInWorkflow()
        XCTAssertNoThrow(try wfr3.find(ProfileFeatureView.self))
    }
}
