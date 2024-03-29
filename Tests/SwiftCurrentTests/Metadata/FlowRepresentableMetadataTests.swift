//
//  FlowRepresentableMetadataTests.swift
//  SwiftCurrent
//
//  Created by Richard Gist on 12/15/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//  

import XCTest
@testable import SwiftCurrent

extension FlowRepresentableMetadata {
    convenience init<FR: FlowRepresentable>(_ flowRepresentableType: FR.Type) {
        self.init(flowRepresentableType,
                  launchStyle: .default,
                  flowPersistence: { _ in .default }) { args in
            AnyFlowRepresentable(FR.self, args: args)
        }
    }
}

class FlowRepresentableMetadataTests : XCTestCase {
    func testDefaultsUseDefaultProperty() {
        final class FR1: FlowRepresentable { var _workflowPointer: AnyFlowRepresentable? }

        let actual = FlowRepresentableMetadata(FR1.self)
        _ = actual.setPersistence(.none)

        XCTAssertEqual(actual.launchStyle, .default)
        XCTAssertEqual(actual.persistence, .default)
    }

    func testFactoryInitDefaultsUseDefaultProperty() {
        final class FR2: FlowRepresentable { var _workflowPointer: AnyFlowRepresentable? }
        final class FR1: FlowRepresentable { var _workflowPointer: AnyFlowRepresentable? }

        let actual = FlowRepresentableMetadata(FR1.self, launchStyle: .default, flowPersistence: { _ in .default }) { _ in
            AnyFlowRepresentable(FR2.self, args: .none)
        }
        _ = actual.setPersistence(.none)

        XCTAssertEqual(actual.launchStyle, .default)
        XCTAssertEqual(actual.persistence, .default)
    }
}
