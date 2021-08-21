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
    private typealias MapWorkflow = WorkflowItem<Never, WorkflowItem<Never, Never, MapFeatureView>, MapFeatureOnboardingView>
    private typealias QRScannerWorkflow = WorkflowItem<Never, WorkflowItem<Never, Never, QRScannerFeatureView>, QRScannerFeatureOnboardingView>
    private typealias ProfileWorkflow = WorkflowItem<Never, WorkflowItem<Never, Never, ProfileFeatureView>, ProfileFeatureOnboardingView>

    override func setUpWithError() throws {
        Container.default.removeAll()
    }

    func testContentView() throws {
        let defaults = try XCTUnwrap(UserDefaults(suiteName: #function))
        Container.default.register(UserDefaults.self) { _ in defaults }
        var wf1: MapWorkflow!
        var wf2: QRScannerWorkflow!
        var wf3: ProfileWorkflow!
        let exp = ViewHosting.loadView(ContentView()).inspection.inspect { view in
            wf1 = try view.tabView().view(MapWorkflow.self, 0).actualView()
            XCTAssertEqual(try view.tabView().view(MapWorkflow.self, 0).tabItem().label().title().text().string(), "Map")
            wf2 = try view.tabView().view(QRScannerWorkflow.self, 1).actualView()
            XCTAssertEqual(try view.tabView().view(QRScannerWorkflow.self, 1).tabItem().label().title().text().string(), "QR Scanner")
            wf3 = try view.tabView().view(ProfileWorkflow.self, 2).actualView()
            XCTAssertEqual(try view.tabView().view(ProfileWorkflow.self, 2).tabItem().label().title().text().string(), "Profile")
        }
        wait(for: [exp], timeout: TestConstant.timeout)
        XCTAssertNotNil(wf1)
        XCTAssertNotNil(wf2)
        XCTAssertNotNil(wf3)
        wait(for: [
            ViewHosting.loadView(wf1)?.inspection.inspect { WorkflowLauncher in
                XCTAssertNoThrow(try WorkflowLauncher.find(MapFeatureOnboardingView.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try WorkflowLauncher.find(MapFeatureView.self))
            },
            ViewHosting.loadView(wf2)?.inspection.inspect { WorkflowLauncher in
                XCTAssertNoThrow(try WorkflowLauncher.find(QRScannerFeatureOnboardingView.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try WorkflowLauncher.find(QRScannerFeatureView.self))
            },
            ViewHosting.loadView(wf3)?.inspection.inspect { WorkflowLauncher in
                XCTAssertNoThrow(try WorkflowLauncher.find(ProfileFeatureOnboardingView.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try WorkflowLauncher.find(ProfileFeatureView.self))
            }
        ].compactMap { $0 }, timeout: TestConstant.timeout)
    }
}
