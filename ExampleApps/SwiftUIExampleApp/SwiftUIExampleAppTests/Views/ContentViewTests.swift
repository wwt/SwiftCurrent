//
//  ContentViewTests.swift
//  SwiftUIExampleAppTests
//
//  Created by Tyler Thompson on 7/15/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest
import ViewInspector
import Swinject

@testable import SwiftCurrent_SwiftUI
@testable import SwiftUIExampleApp

final class ContentViewTests: XCTestCase {
    override func setUpWithError() throws {
        Container.default.removeAll()
    }

    func testContentView() throws {
        let defaults = try XCTUnwrap(UserDefaults(suiteName: #function))
        Container.default.register(UserDefaults.self) { _ in defaults }
        var wf1: WorkflowView<Never>!
        var wf2: WorkflowView<Never>!
        var wf3: WorkflowView<Never>!
        let exp = ViewHosting.loadView(ContentView()).inspection.inspect { view in
            wf1 = try view.tabView().view(WorkflowView<Never>.self, 0).actualView()
            XCTAssertEqual(try view.tabView().view(WorkflowView<Never>.self, 0).tabItem().label().title().text().string(), "Map")
            wf2 = try view.tabView().view(WorkflowView<Never>.self, 1).actualView()
            XCTAssertEqual(try view.tabView().view(WorkflowView<Never>.self, 1).tabItem().label().title().text().string(), "QR Scanner")
            wf3 = try view.tabView().view(WorkflowView<Never>.self, 2).actualView()
            XCTAssertEqual(try view.tabView().view(WorkflowView<Never>.self, 2).tabItem().label().title().text().string(), "Profile")
        }
        wait(for: [exp], timeout: 1)
        XCTAssertNotNil(wf1)
        XCTAssertNotNil(wf2)
        XCTAssertNotNil(wf3)
        wait(for: [
            ViewHosting.loadView(wf1)?.inspection.inspect { workflowView in
                XCTAssertNoThrow(try workflowView.find(MapFeatureOnboardingView.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try workflowView.find(MapFeatureView.self))
            },
            ViewHosting.loadView(wf2)?.inspection.inspect { workflowView in
                XCTAssertNoThrow(try workflowView.find(QRScannerFeatureOnboardingView.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try workflowView.find(QRScannerFeatureView.self))
            },
            ViewHosting.loadView(wf3)?.inspection.inspect { workflowView in
                XCTAssertNoThrow(try workflowView.find(ProfileFeatureOnboardingView.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try workflowView.find(ProfileFeatureView.self))
            }
        ].compactMap { $0 }, timeout: 1)
    }
}
