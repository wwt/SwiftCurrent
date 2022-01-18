//
//  JsonSpecificationTests.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 1/14/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import XCTest
import SwiftCurrent
import SwiftCurrent_Testing

final class JsonSpecificationTests: XCTestCase {
    func testWorkflowCanBeInstantiatedFromJSON() throws {
        struct FR1: FlowRepresentable, WorkflowDecodable {
            weak var _workflowPointer: AnyFlowRepresentable?
        }

        final class FR2: FlowRepresentable, WorkflowDecodable {
            weak var _workflowPointer: AnyFlowRepresentable?
        }

        let registry = TestRegistry(types: [
            FR1.self,
            FR2.self
        ])

        let wf = try JSONDecoder().decodeWorkflow(withAggregator: registry, from: validWorkflowJSON)
        XCTAssertEqual(wf.first?.value.metadata.flowRepresentableTypeDescriptor, FR1.flowRepresentableName)
        XCTAssertIdentical(wf.first?.value.metadata.launchStyle, LaunchStyle.default)
        XCTAssertEqual(wf.first?.next?.value.metadata.flowRepresentableTypeDescriptor, FR2.flowRepresentableName)
        XCTAssertIdentical(wf.first?.next?.value.metadata.launchStyle, LaunchStyle.default)
        XCTAssertNil(wf.first?.next?.next)
    }

    func testWorkflowCanBeInstantiatedFromJSON_WithSubclasses() throws {
        class FR1: FlowRepresentable, WorkflowDecodable {
            weak var _workflowPointer: AnyFlowRepresentable?
            required init() { }
        }

        class FR2: FR1 { }

        let registry = TestRegistry(types: [
            FR1.self,
            FR2.self
        ])

        let wf = try JSONDecoder().decodeWorkflow(withAggregator: registry, from: validWorkflowJSON)
        XCTAssertEqual(wf.first?.value.metadata.flowRepresentableTypeDescriptor, FR1.flowRepresentableName)
        XCTAssertIdentical(wf.first?.value.metadata.launchStyle, LaunchStyle.default)
        XCTAssertEqual(wf.first?.next?.value.metadata.flowRepresentableTypeDescriptor, FR2.flowRepresentableName)
        XCTAssertIdentical(wf.first?.next?.value.metadata.launchStyle, LaunchStyle.default)
        XCTAssertNil(wf.first?.next?.next)
    }

    func testWorkflowThrowsAnErrorWhenGivenMalformedJSON() {
        XCTAssertThrowsError(try JSONDecoder().decodeWorkflow(withAggregator: TestRegistry(types: []), from: malformedWorkflowJSON))
    }

    func testWorkflowThrowsAnErrorWhenItCannotMatchTheCorrespondingSequenceType() {
        XCTAssertThrowsError(try JSONDecoder().decodeWorkflow(withAggregator: TestRegistry(types: []), from: validWorkflowJSON)) { error in
            XCTAssertEqual((error as? AnyWorkflow.DecodingError), .invalidFlowRepresentable("FR1"))
        }
    }

    func testWorkflowCanBeDecodedAlongWithAnyOtherJSONBlob() throws {
        struct FR1: FlowRepresentable, WorkflowDecodable {
            weak var _workflowPointer: AnyFlowRepresentable?
        }

        struct CustomRegistry: FlowRepresentableAggregator {
            let types: [WorkflowDecodable.Type] = [ FR1.self ]
        }

        struct CustomDecodableObject: Decodable {
            let someAdditionalThing: Int
            @DecodeWorkflow(aggregator: CustomRegistry.self) var workflow: AnyWorkflow
        }

        let json = try XCTUnwrap("""
            {
                "someAdditionalThing" : 24,
                "workflow" : {
                    "schemaVersion": "\(AnyWorkflow.jsonSchemaVersion.rawValue)",
                    "sequence" : [ { "flowRepresentableName" : "FR1" } ]
                }
            }
            """.data(using: .utf8))

        let object = try JSONDecoder().decode(CustomDecodableObject.self, from: json)
        let wf = object.workflow
        XCTAssertEqual(object.someAdditionalThing, 24)
        XCTAssertEqual(wf.first?.value.metadata.flowRepresentableTypeDescriptor, FR1.flowRepresentableName)
        XCTAssertNil(wf.first?.next)
    }

    func testCreatingWorkflowWithLaunchStyle() throws {
        struct FR1: FlowRepresentable, WorkflowDecodable, TestStyleLookup {
            weak var _workflowPointer: AnyFlowRepresentable?
        }

        let json = try XCTUnwrap("""
            {
                "schemaVersion": "\(AnyWorkflow.jsonSchemaVersion.rawValue)",
                "sequence": [
                    {
                        "flowRepresentableName": "FR1",
                        "launchStyle": "testStyle"
                    }
                ]
            }
            """.data(using: .utf8))

        let registry = TestRegistry(types: [ FR1.self ])

        let wf = try JSONDecoder().decodeWorkflow(withAggregator: registry, from: json)
        XCTAssertEqual(wf.first?.value.metadata.flowRepresentableTypeDescriptor, FR1.flowRepresentableName)
        XCTAssertIdentical(wf.first?.value.metadata.launchStyle, LaunchStyle.testStyle)
    }

    func testCreatingWorkflowWithInvalidLaunchStyleOnExtendedType_Rethrows() throws {
        struct FR1: FlowRepresentable, WorkflowDecodable, TestStyleLookup {
            weak var _workflowPointer: AnyFlowRepresentable?
        }

        let json = try XCTUnwrap("""
            {
                "schemaVersion": "\(AnyWorkflow.jsonSchemaVersion.rawValue)",
                "sequence": [
                    {
                        "flowRepresentableName": "FR1",
                        "launchStyle": "testStylez"
                    }
                ]
            }
            """.data(using: .utf8))

        let registry = TestRegistry(types: [ FR1.self ])

        XCTAssertThrowsError(try JSONDecoder().decodeWorkflow(withAggregator: registry, from: json)) { error in
            XCTAssertEqual((error as? URLError), URLError(.badURL))
        }
    }

    func testCreatingWorkflowWithInvalidLaunchStyle_ThrowsError() throws {
        class FR1: FlowRepresentable, WorkflowDecodable, TestStyleLookup {
            weak var _workflowPointer: AnyFlowRepresentable?
            required init() { }
        }

        class FR2: FR1 { }

        let registry = TestRegistry(types: [ FR1.self, FR2.self ])

        let json = try XCTUnwrap("""
            {
                "schemaVersion": "\(AnyWorkflow.jsonSchemaVersion.rawValue)",
                "sequence": [
                    {
                        "flowRepresentableName": "FR1",
                        "launchStyle": "testStyle"
                    },
                    {
                        "flowRepresentableName": "FR2",
                        "launchStyle": "testStyle"
                    },
                    {
                        "flowRepresentableName": "FR2"
                    }
                ]
            }
            """.data(using: .utf8))

        let wf = try JSONDecoder().decodeWorkflow(withAggregator: registry, from: json)
        XCTAssertEqual(wf.first?.value.metadata.flowRepresentableTypeDescriptor, FR1.flowRepresentableName)
        XCTAssertIdentical(wf.first?.value.metadata.launchStyle, LaunchStyle.testStyle)
        XCTAssertEqual(wf.first?.next?.value.metadata.flowRepresentableTypeDescriptor, FR2.flowRepresentableName)
        XCTAssertIdentical(wf.first?.next?.value.metadata.launchStyle, LaunchStyle.testStyle)
        XCTAssertEqual(wf.first?.next?.next?.value.metadata.flowRepresentableTypeDescriptor, FR2.flowRepresentableName)
        XCTAssertIdentical(wf.first?.next?.next?.value.metadata.launchStyle, LaunchStyle.default)
    }

    func testCreatingWorkflowWithFlowPersistence() {
        XCTFail("TODO: Add test for this")
    }
}

public protocol TestStyleLookup { } // For example: View

extension WorkflowDecodable where Self: TestStyleLookup {
    public static func decodeLaunchStyle(named name: String) throws -> LaunchStyle {
        switch name.lowercased() {
            case "teststyle": return LaunchStyle.testStyle
            default:
                throw URLError.init(.badURL)
        }
    }
}

extension LaunchStyle {
    static var testStyle = LaunchStyle.new
}

extension JsonSpecificationTests {
    fileprivate var validWorkflowJSON: Data {
        get throws {
            try XCTUnwrap("""
            {
                "schemaVersion": "\(AnyWorkflow.jsonSchemaVersion.rawValue)",
                "sequence": [
                    {
                        "flowRepresentableName": "FR1"
                    },
                    {
                        "flowRepresentableName": "FR2"
                    }
                ]
            }
            """.data(using: .utf8))
        }
    }

    fileprivate var malformedWorkflowJSON: Data {
        get throws {
            try XCTUnwrap("""
            {
                "iAmATeapot": true,
                "thisIsValid": 0
            }
            """.data(using: .utf8))
        }
    }
}
