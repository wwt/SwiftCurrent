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
            static func metadataFactory() -> FlowRepresentableMetadata { FlowRepresentableMetadata(Self.self) }

            var _workflowPointer: AnyFlowRepresentable?
        }

        let FRMD: FlowRepresentableMetadataDescriber.Type = FR1.self

        XCTAssertEqual(FRMD.flowRepresentableName, "Foo")
        XCTAssertEqual(FRMD.metadataFactory().flowRepresentableTypeDescriptor, "FR1")
    }

    func testFlowRepresentableProvidesConvenientImplementations() {
        struct FR2: FlowRepresentable, FlowRepresentableMetadataDescriber {
            var _workflowPointer: AnyFlowRepresentable?
        }

        let FRMD = FR2.self as FlowRepresentableMetadataDescriber.Type

        XCTAssertEqual(FRMD.flowRepresentableName, "FR2")
        XCTAssertEqual(FRMD.metadataFactory().flowRepresentableTypeDescriptor, "FR2")
    }

    func testProtocolIsCorrectlyExposedForClasses() {
        class ThirdMetadata: FlowRepresentableMetadata { }
        class FourthMetadata: FlowRepresentableMetadata { }
        final class FR1: FlowRepresentable, FlowRepresentableMetadataDescriber { var _workflowPointer: AnyFlowRepresentable? }
        class ParentFR: FlowRepresentable, FlowRepresentableMetadataDescriber {
            var _workflowPointer: AnyFlowRepresentable?
            required init() { }
            class var flowRepresentableName: String { "Parent FR" }
            class func metadataFactory() -> FlowRepresentableMetadata { ThirdMetadata(Self.self) { _ in .default } }
        }
        class ChildFR1: ParentFR { }
        class ChildFR2: ParentFR {
            override class var flowRepresentableName: String { "Child FR2" }
            override class func metadataFactory() -> FlowRepresentableMetadata { FourthMetadata(Self.self) { _ in .default } }
        }

        let fr1AsFRMD = FR1.self as FlowRepresentableMetadataDescriber.Type
        XCTAssertEqual(FR1.flowRepresentableName, "FR1")
        XCTAssertFalse(FR1.metadataFactory() is ThirdMetadata, "Metadata should not be of type ThirdMetadata")
        XCTAssertEqual(fr1AsFRMD.flowRepresentableName, "FR1")
        XCTAssertFalse(fr1AsFRMD.metadataFactory() is ThirdMetadata, "Metadata should not be of type ThirdMetadata")

        let parentFRAsFRMD = ParentFR.self as FlowRepresentableMetadataDescriber.Type
        XCTAssertEqual(ParentFR.flowRepresentableName, "Parent FR")
        XCTAssert(ParentFR.metadataFactory() is ThirdMetadata, "Metadata should be of type ThirdMetadata")
        XCTAssertEqual(parentFRAsFRMD.flowRepresentableName, "Parent FR")
        XCTAssert(parentFRAsFRMD.metadataFactory() is ThirdMetadata, "Metadata should be of type ThirdMetadata")

        let childFR1AsFRMD = ChildFR1.self as FlowRepresentableMetadataDescriber.Type
        XCTAssertEqual(ChildFR1.flowRepresentableName, "Parent FR")
        XCTAssert(ChildFR1.metadataFactory() is ThirdMetadata, "Metadata should be of type ThirdMetadata")
        XCTAssertEqual(childFR1AsFRMD.flowRepresentableName, "Parent FR")
        XCTAssert(childFR1AsFRMD.metadataFactory() is ThirdMetadata, "Metadata should be of type ThirdMetadata")

        let childFR2AsFRMD = ChildFR2.self as FlowRepresentableMetadataDescriber.Type
        XCTAssertEqual(ChildFR2.flowRepresentableName, "Child FR2")
        XCTAssert(ChildFR2.metadataFactory() is FourthMetadata, "Metadata should be of type FourthMetadata")
        XCTAssertEqual(childFR2AsFRMD.flowRepresentableName, "Child FR2")
        XCTAssert(childFR2AsFRMD.metadataFactory() is FourthMetadata, "Metadata should be of type FourthMetadata")
    }

    func testExtendingProductsCanProvideUniqueImplementationsForClasses() {
        class ThirdMetadata: FlowRepresentableMetadata { }
        class FR1: CustomExtensionClass { }
        class FR2: CustomExtensionClass {
            // These implementations only exist when referencing FR2 directly.
            static var flowRepresentableName: String { "Special FR2"}
            static func metadataFactory() -> FlowRepresentableMetadata { ThirdMetadata(Self.self) { _ in .default } }
        }

        let FRMD1 = FR1.self as FlowRepresentableMetadataDescriber.Type
        let FRMD2 = FR2.self as FlowRepresentableMetadataDescriber.Type

        XCTAssertEqual(FR1.flowRepresentableName, "Twice Overridden")
        XCTAssert(FR1.metadataFactory() is CustomFlowRepresentableMetadata)
        XCTAssertEqual(FRMD1.flowRepresentableName, "Twice Overridden")
        XCTAssert(FRMD1.metadataFactory() is CustomFlowRepresentableMetadata)
        XCTAssertEqual(FRMD2.flowRepresentableName, "Twice Overridden")
        XCTAssert(FRMD2.metadataFactory() is CustomFlowRepresentableMetadata)

        XCTAssertEqual(FR2.flowRepresentableName, "Special FR2")
        XCTAssert(FR2.metadataFactory() is ThirdMetadata)
    }

    func testExtendingProductsCanProvideUniqueImplementationsForStructs() {
        class ThirdMetada: FlowRepresentableMetadata { }
        struct FR1: CustomExtensionProtocol { var _workflowPointer: AnyFlowRepresentable? }
        struct FR2: CustomExtensionProtocol {
            static var flowRepresentableName: String { "Special FR2"}
            static func metadataFactory() -> FlowRepresentableMetadata { ThirdMetada(Self.self) { _ in .default } }

            var _workflowPointer: AnyFlowRepresentable?
        }

        let FRMD1 = FR1.self as FlowRepresentableMetadataDescriber.Type
        let FRMD2 = FR2.self as FlowRepresentableMetadataDescriber.Type

        XCTAssertEqual(FR1.flowRepresentableName, "Twice Overridden for Protocol")
        XCTAssert(FR1.metadataFactory() is CustomFlowRepresentableMetadata)
        XCTAssertEqual(FRMD1.flowRepresentableName, "Twice Overridden for Protocol")
        XCTAssert(FRMD1.metadataFactory() is CustomFlowRepresentableMetadata)

        XCTAssertEqual(FR2.flowRepresentableName, "Special FR2")
        XCTAssert(FR2.metadataFactory() is ThirdMetada)
        XCTAssertEqual(FRMD2.flowRepresentableName, "Special FR2")
        XCTAssert(FRMD2.metadataFactory() is ThirdMetada)
    }
}

fileprivate class CustomFlowRepresentableMetadata: FlowRepresentableMetadata { }

fileprivate class CustomExtensionClass: FlowRepresentable, FlowRepresentableMetadataDescriber {
    var _workflowPointer: AnyFlowRepresentable?
    required init() { }
}
fileprivate extension FlowRepresentable where Self: CustomExtensionClass {
    static var flowRepresentableName: String { "Twice Overridden" }
    static func metadataFactory() -> FlowRepresentableMetadata {
        CustomFlowRepresentableMetadata(Self.self) { _ in .default }
    }
}

fileprivate protocol CustomExtensionProtocol: FlowRepresentable, FlowRepresentableMetadataDescriber { }
fileprivate extension FlowRepresentable where Self: CustomExtensionProtocol {
    static var flowRepresentableName: String { "Twice Overridden for Protocol" }
    static func metadataFactory() -> FlowRepresentableMetadata {
        CustomFlowRepresentableMetadata(Self.self) { _ in .default }
    }
}
