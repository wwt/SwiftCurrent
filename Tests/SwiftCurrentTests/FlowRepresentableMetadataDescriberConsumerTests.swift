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

        XCTAssertEqual(FRMD.flowRepresentableName, "FR2")
        XCTAssertEqual(FRMD.createMetadata().flowRepresentableTypeDescriptor, "FR2")
    }

    func testExtendingProductsCanProvideUniqueImplementationsForClasses() {
        class ThirdMetada: FlowRepresentableMetadata { }
        class FR1: CustomExtensionClass { }
        class FR2: CustomExtensionClass {
            static var flowRepresentableName: String { "Special FR2"}
            static func createMetadata() -> FlowRepresentableMetadata {
                ThirdMetada(Self.self) { _ in .default }
            }
        }

        let FRMD1 = FR1.self as FlowRepresentableMetadataDescriber.Type
        let FRMD2 = FR2.self as FlowRepresentableMetadataDescriber.Type

        XCTAssertEqual(FR1.flowRepresentableName, "Twice Overridden")
        XCTAssert(FR1.createMetadata() is CustomFlowRepresentableMetadata)
        XCTAssertEqual(FRMD1.flowRepresentableName, "Twice Overridden")
        XCTAssert(FRMD1.createMetadata() is CustomFlowRepresentableMetadata)

        XCTAssertEqual(FR2.flowRepresentableName, "Special FR2")
        XCTAssert(FR2.createMetadata() is ThirdMetada)
        XCTAssertEqual(FRMD2.flowRepresentableName, "Special FR2")
        XCTAssert(FRMD2.createMetadata() is ThirdMetada)
    }

    func testExtendingProductsCanProvideUniqueImplementationsForStructs() {
        class ThirdMetada: FlowRepresentableMetadata { }
        struct FR1: CustomExtensionProtocol {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR2: CustomExtensionProtocol {
            var _workflowPointer: AnyFlowRepresentable?

            static var flowRepresentableName: String { "Special FR2"}
            static func createMetadata() -> FlowRepresentableMetadata {
                ThirdMetada(Self.self) { _ in .default }
            }
        }

        let FRMD1 = FR1.self as FlowRepresentableMetadataDescriber.Type
        let FRMD2 = FR2.self as FlowRepresentableMetadataDescriber.Type

        XCTAssertEqual(FR1.flowRepresentableName, "Twice Overridden for Protocol")
        XCTAssert(FR1.createMetadata() is CustomFlowRepresentableMetadata)
        XCTAssertEqual(FRMD1.flowRepresentableName, "Twice Overridden for Protocol")
        XCTAssert(FRMD1.createMetadata() is CustomFlowRepresentableMetadata)

        XCTAssertEqual(FR2.flowRepresentableName, "Special FR2")
        XCTAssert(FR2.createMetadata() is ThirdMetada)
        XCTAssertEqual(FRMD2.flowRepresentableName, "Special FR2")
        XCTAssert(FRMD2.createMetadata() is ThirdMetada)
    }
}

fileprivate class CustomExtensionClass: FlowRepresentable {
    var _workflowPointer: AnyFlowRepresentable?
    required init() { }
}
fileprivate class CustomFlowRepresentableMetadata: FlowRepresentableMetadata { }
fileprivate extension FlowRepresentable where Self: CustomExtensionClass {
    static var flowRepresentableName: String { "Twice Overridden" }
    static func createMetadata() -> FlowRepresentableMetadata {
        CustomFlowRepresentableMetadata(Self.self) { _ in .default }
    }
}

fileprivate protocol CustomExtensionProtocol: FlowRepresentable { }
fileprivate extension FlowRepresentable where Self: CustomExtensionProtocol {
    static var flowRepresentableName: String { "Twice Overridden for Protocol" }
    static func createMetadata() -> FlowRepresentableMetadata {
        CustomFlowRepresentableMetadata(Self.self) { _ in .default }
    }
}
