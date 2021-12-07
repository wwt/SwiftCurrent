//
//  FlowRepresentableMetadataDescriberConsumerTests.swift
//  SwiftCurrent
//
//  Created by Richard Gist on 12/6/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftCurrent
import XCTest

class FlowRepresentableMetadataDescriberConsumerTests: XCTestCase {
    func testProtocolIsCorrectlyExposed() {
        struct FR1: FlowRepresentable, FlowRepresentableMetadataDescriber {
            static var flowRepresentableName: String { "Foo" }
            static func createMetadata() -> FlowRepresentableMetadata {
                FlowRepresentableMetadata(Self.self) { _ in .default }
            }

            var _workflowPointer: AnyFlowRepresentable?
        }

        let FRMD: FlowRepresentableMetadataDescriber.Type = FR1.self

        XCTAssertEqual(FRMD.flowRepresentableName, "Foo")
        XCTAssertEqual(FRMD.createMetadata().flowRepresentableTypeDescriptor, "FR1")
    }

    func testFlowRepresentableProvidesConvenientImplementations() {
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }

        let FRMD = FR2.self as FlowRepresentableMetadataDescriber.Type

        XCTAssertEqual(FRMD?.flowRepresentableName, "FR2")
        XCTAssertEqual(FRMD?.createMetadata().flowRepresentableTypeDescriptor, "FR2")
    }
}
