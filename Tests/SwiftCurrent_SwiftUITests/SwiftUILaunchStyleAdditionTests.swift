//
//  SwiftUILaunchStyleAdditionTests.swift
//  SwiftCurrent_SwiftUITests
//
//  Created by Tyler Thompson on 8/22/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest
import SwiftCurrent
import Algorithms
import SwiftUI

@testable import SwiftCurrent_SwiftUI
import SwiftCurrent_Testing

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
final class LaunchStyleAdditionTests: XCTestCase, View {
    func testPresentationTypeInitializer() {
        XCTAssertNil(LaunchStyle.SwiftUI.PresentationType(rawValue: .new))
        XCTAssertEqual(LaunchStyle.SwiftUI.PresentationType(rawValue: .default), .default)
        XCTAssertEqual(LaunchStyle.SwiftUI.PresentationType(rawValue: ._swiftUI_navigationLink), .navigationLink)
        XCTAssertEqual(LaunchStyle.SwiftUI.PresentationType(rawValue: ._swiftUI_modal), .modal)
        XCTAssertEqual(LaunchStyle.SwiftUI.PresentationType(rawValue: ._swiftUI_modal), .modal())
        XCTAssertEqual(LaunchStyle.SwiftUI.PresentationType(rawValue: ._swiftUI_modal), .modal(.sheet))
        XCTAssertEqual(LaunchStyle.SwiftUI.PresentationType(rawValue: ._swiftUI_modal_fullscreen), .modal(.fullScreenCover))
    }

    func testKnownPresentationTypes_AreUnique() {
        [LaunchStyle.default, LaunchStyle._swiftUI_modal, LaunchStyle._swiftUI_modal_fullscreen, LaunchStyle._swiftUI_navigationLink].permutations().forEach {
            XCTAssertNotIdentical($0[0], $0[1])
        }
        LaunchStyle.SwiftUI.PresentationType.allCases.permutations().forEach {
            XCTAssertNotEqual($0[0], $0[1])
        }
    }

    func testKnownPresentationTypes_CanBeDecoded() throws {
        struct TestView: View, FlowRepresentable, WorkflowDecodable {
            weak var _workflowPointer: AnyFlowRepresentable?
            var body: some View { EmptyView() }
        }
        let validLaunchStyles: [String: LaunchStyle] = [
            "viewSwapping": .default,
            "modal": ._swiftUI_modal,
            "modal(.fullScreen)": ._swiftUI_modal_fullscreen,
            "navigationLink": ._swiftUI_navigationLink
        ]

        let WD: WorkflowDecodable.Type = TestView.self

        try validLaunchStyles.forEach { (key, value) in
            XCTAssertIdentical(try TestView.decodeLaunchStyle(named: key), value)
            XCTAssertIdentical(try WD.decodeLaunchStyle(named: key), value)
        }

        // Metatest, testing we covered all styles
        LaunchStyle.SwiftUI.PresentationType.allCases.forEach { presentationType in
            XCTAssert(validLaunchStyles.values.contains { $0 === presentationType.rawValue }, "dictionary of validLaunchStyles did not contain one for \(presentationType)")
        }
    }

    func testLaunchStyleIsPassedThroughToExtendedFlowRepresentable() throws {
        struct TestView: View, FlowRepresentable, WorkflowDecodable {
            weak var _workflowPointer: AnyFlowRepresentable?
            var body: some View { EmptyView() }
        }

        let WD: WorkflowDecodable.Type = TestView.self

        let launchStyle = LaunchStyle.new
        let flowPersistence = FlowPersistence.new
        let metadata = WD.metadataFactory(launchStyle: launchStyle) { _ in flowPersistence }
        let wf = SwiftCurrent.Workflow<Never>(metadata)
        let orchestrationResponder = MockOrchestrationResponder()

        wf.launch(withOrchestrationResponder: orchestrationResponder)
        XCTAssertIdentical(metadata.launchStyle, launchStyle)
        XCTAssertIdentical(orchestrationResponder.lastTo?.value.metadata.persistence, flowPersistence)
    }

    func testPresentationTypes_AreCorrectlyEquatable() {
        XCTAssertEqual(LaunchStyle.SwiftUI.PresentationType.default, .default)
        XCTAssertEqual(LaunchStyle.SwiftUI.PresentationType.navigationLink, .navigationLink)
        XCTAssertEqual(LaunchStyle.SwiftUI.PresentationType.modal, .modal(.sheet))
        XCTAssertNotEqual(LaunchStyle.SwiftUI.PresentationType.default, .navigationLink)
        XCTAssertNotEqual(LaunchStyle.SwiftUI.PresentationType.modal(.sheet), .modal(.fullScreenCover))
    }
}
