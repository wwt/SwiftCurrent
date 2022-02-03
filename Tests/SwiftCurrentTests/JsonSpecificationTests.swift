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
        struct FR1: FlowRepresentable, WorkflowDecodable, TestLookup {
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
        struct FR1: FlowRepresentable, WorkflowDecodable, TestLookup {
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
        struct FR1: FlowRepresentable, WorkflowDecodable {
            weak var _workflowPointer: AnyFlowRepresentable?
        }

        let registry = TestRegistry(types: [ FR1.self ])

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

        XCTAssertThrowsError(try JSONDecoder().decodeWorkflow(withAggregator: registry, from: json)) { error in
            XCTAssertEqual((error as? AnyWorkflow.DecodingError), .invalidLaunchStyle("testStyle"))
        }
    }

    func testCreatingWorkflowWithClassesAndSubclasses_AndJSONLaunchStyles_Works() throws {
        class FR1: FlowRepresentable, WorkflowDecodable, TestLookup {
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

    func testCreatingWorkflowWithFlowPersistence() throws {
        struct FR1: FlowRepresentable, WorkflowDecodable, TestLookup {
            weak var _workflowPointer: AnyFlowRepresentable?
        }

        let json = try XCTUnwrap("""
            {
                "schemaVersion": "\(AnyWorkflow.jsonSchemaVersion.rawValue)",
                "sequence": [
                    {
                        "flowRepresentableName": "FR1",
                        "flowPersistence": "testPersistence"
                    }
                ]
            }
            """.data(using: .utf8))

        let registry = TestRegistry(types: [ FR1.self ])

        let wf = try JSONDecoder().decodeWorkflow(withAggregator: registry, from: json)
        let or = MockOrchestrationResponder()

        XCTAssertEqual(wf.first?.value.metadata.flowRepresentableTypeDescriptor, FR1.flowRepresentableName)

        wf.launch(withOrchestrationResponder: or, passedArgs: .none)
        XCTAssertIdentical(or.lastTo?.value.metadata.persistence, FlowPersistence.testPersistence)
    }

    func testCreatingWorkflowWithInvalidFlowPersistenceOnExtendedType_Rethrows() throws {
        struct FR1: FlowRepresentable, WorkflowDecodable, TestLookup {
            weak var _workflowPointer: AnyFlowRepresentable?
        }

        let json = try XCTUnwrap("""
            {
                "schemaVersion": "\(AnyWorkflow.jsonSchemaVersion.rawValue)",
                "sequence": [
                    {
                        "flowRepresentableName": "FR1",
                        "flowPersistence": "testPersistencez"
                    }
                ]
            }
            """.data(using: .utf8))

        let registry = TestRegistry(types: [ FR1.self ])

        XCTAssertThrowsError(try JSONDecoder().decodeWorkflow(withAggregator: registry, from: json)) { error in
            XCTAssertEqual((error as? URLError), URLError(.badURL))
        }
    }

    func testCreatingWorkflowWithClassesAndSubclasses_AndJSONFlowPersistences_Works() throws {
        class FR1: FlowRepresentable, WorkflowDecodable {
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
                        "flowPersistence": "persistWhenSkipped"
                    },
                    {
                        "flowRepresentableName": "FR2",
                        "flowPersistence": "removedAfterProceeding"
                    },
                    {
                        "flowRepresentableName": "FR2"
                    }
                ]
            }
            """.data(using: .utf8))
        let wf = try JSONDecoder().decodeWorkflow(withAggregator: registry, from: json)
        let orchestrationResponder = MockOrchestrationResponder()

        XCTAssertEqual(wf.first?.value.metadata.flowRepresentableTypeDescriptor, FR1.flowRepresentableName)
        XCTAssertEqual(wf.first?.next?.value.metadata.flowRepresentableTypeDescriptor, FR2.flowRepresentableName)
        XCTAssertEqual(wf.first?.next?.next?.value.metadata.flowRepresentableTypeDescriptor, FR2.flowRepresentableName)

        wf.launch(withOrchestrationResponder: orchestrationResponder, passedArgs: .none)
        XCTAssertIdentical(orchestrationResponder.lastTo?.value.metadata.persistence, FlowPersistence.persistWhenSkipped)

        (orchestrationResponder.lastTo?.value.instance?.underlyingInstance as? FR1)?.proceedInWorkflow()
        XCTAssertIdentical(orchestrationResponder.lastTo?.value.metadata.persistence, FlowPersistence.removedAfterProceeding)

        (orchestrationResponder.lastTo?.value.instance?.underlyingInstance as? FR2)?.proceedInWorkflow()
        XCTAssertIdentical(orchestrationResponder.lastTo?.value.metadata.persistence, FlowPersistence.default)
    }

    func testCreatingWorkflowWithInvalidFlowPersistence_ThrowsError() throws {
        struct FR1: FlowRepresentable, WorkflowDecodable {
            weak var _workflowPointer: AnyFlowRepresentable?
        }

        let registry = TestRegistry(types: [ FR1.self ])

        let json = try XCTUnwrap("""
            {
                "schemaVersion": "\(AnyWorkflow.jsonSchemaVersion.rawValue)",
                "sequence": [
                    {
                        "flowRepresentableName": "FR1",
                        "flowPersistence": "testPersistence"
                    }
                ]
            }
            """.data(using: .utf8))

        XCTAssertThrowsError(try JSONDecoder().decodeWorkflow(withAggregator: registry, from: json)) { error in
            XCTAssertEqual((error as? AnyWorkflow.DecodingError), .invalidFlowPersistence("testPersistence"))
        }
    }
    
    func testWorkflowCanBeInstantiatedFromComplexJSON() throws {
        struct FR2: FlowRepresentable, WorkflowDecodable, TestLookup {
            weak var _workflowPointer: AnyFlowRepresentable?
        }
        
        struct FR3: FlowRepresentable, WorkflowDecodable, TestLookup {
            weak var _workflowPointer: AnyFlowRepresentable?
        }
        
        let registry = TestRegistry(types: [
            FR2.self,
            FR3.self,
        ])
        
        let wf = try JSONDecoder().decodeWorkflow(withAggregator: registry, from: simpleComplexValidWorkflowJSON)
        let or = MockOrchestrationResponder()
        
        XCTAssertEqual(wf.first?.value.metadata.flowRepresentableTypeDescriptor, FR2.flowRepresentableName)
        XCTAssertIdentical(wf.first?.value.metadata.launchStyle, LaunchStyle.testStyle)
        
        wf.launch(withOrchestrationResponder: or, passedArgs: .none)
        XCTAssertIdentical(or.lastTo?.value.metadata.persistence, FlowPersistence.testPersistence)
        
        XCTAssertEqual(wf.first?.next?.value.metadata.flowRepresentableTypeDescriptor, FR3.flowRepresentableName)
    }

    func testCreatingWorkflowWithObject_ThrowsError_IfFlowRepresentableNameDoesNotMatchPlatform() throws {
        let registry = TestRegistry(types: [ ])

        let json = try XCTUnwrap("""
            {
                "schemaVersion": "\(AnyWorkflow.jsonSchemaVersion.rawValue)",
                "sequence": [
                    {
                        "flowRepresentableName": {
                            "notAValidName": "notAValidName"
                        }
                    }
                ]
            }
            """.data(using: .utf8))

        XCTAssertThrowsError(try JSONDecoder().decodeWorkflow(withAggregator: registry, from: json)) { error in
            XCTAssertNotNil((error as? DecodingError))
            if let decodingError = error as? DecodingError {
                XCTAssertEqual("\(decodingError)", "\(DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "No flowRepresentableName found for platform", underlyingError: nil)))")
            }
        }
    }

    func testCreatingWorkflowWithObject_ThrowsError_IfLaunchStyleNameDoesNotMatchPlatform() {
        XCTFail()
    }

    func testCreatingWorkflowWithObject_ThrowsError_IfFlowPersistenceNameDoesNotMatchPlatform() {
        XCTFail()
    }
}

public protocol TestLookup { } // For example: View

extension WorkflowDecodable where Self: TestLookup {
    public static func decodeLaunchStyle(named name: String) throws -> LaunchStyle {
        switch name.lowercased() {
            case "teststyle": return LaunchStyle.testStyle
            default:
                throw URLError(.badURL)
        }
    }
}

extension WorkflowDecodable where Self: TestLookup {
    public static func decodeFlowPersistence(named name: String) throws -> FlowPersistence {
        switch name.lowercased() {
            case "testpersistence": return FlowPersistence.testPersistence
            default:
                throw URLError(.badURL)
        }
    }
}

extension LaunchStyle {
    static var testStyle = LaunchStyle.new
}

extension FlowPersistence {
    static var testPersistence = FlowPersistence.new
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
    
    fileprivate var simpleComplexValidWorkflowJSON: Data {
        get throws {
            try XCTUnwrap("""
            {
                "schemaVersion": "\(AnyWorkflow.jsonSchemaVersion.rawValue)",
                "sequence": [
                    {
                        "flowRepresentableName": "FR2",
                        "launchStyle": "testStyle",
                        "flowPersistence": "testPersistence"
                    },
                    {
                        "flowRepresentableName": {
                            "*": "FR3"
                        },
                        "launchStyle": {
                            "*": "testStyle"
                        },
                        "flowPersistence": {
                            "*": "testPersistence"
                        }
                    }
                ]
            }
""".data(using: .utf8))
        }
    }
    fileprivate var complexValidWorkflowJSON: Data {
        get throws {
            try XCTUnwrap("""
            {
                "schemaVersion": "\(AnyWorkflow.jsonSchemaVersion.rawValue)",
                "sequence": [
                    {
                        "flowRepresentableName": "FR2",
                        "launchStyle": "testStyle",
                        "flowPersistence": "testPersistence"
                    },
                    {
                        "flowRepresentableName": {
                            "watchOS": "FR3",
                            "macOS": "FR3",
                            "iOS": "FR3",
                            "iPadOS": "FR3",
                            "tvOS": "FR3",
                            "android": "FRA3"
                        },
                        "launchStyle": {
                            "watchOS": "modal",
                            "macOS": "modal",
                            "iOS": "modal",
                            "iPadOS": "popover",
                            "tvOS": "modal",
                            "android": "widget"
                        },
                        "flowPersistence": {
                            "watchOS": "removedAfterProceeding",
                            "macOS": "removedAfterProceeding",
                            "iOS": "removedAfterProceeding",
                            "iPadOS": "removedAfterProceeding",
                            "tvOS": "removedAfterProceeding",
                            "android": "somethingElse"
                        }
                    }
                ]
            }
""".data(using: .utf8))
        }
    }
}
