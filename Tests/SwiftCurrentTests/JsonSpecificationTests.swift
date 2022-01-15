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
        XCTAssertEqual(wf.first?.next?.value.metadata.flowRepresentableTypeDescriptor, FR2.flowRepresentableName)
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
        XCTAssertEqual(wf.first?.next?.value.metadata.flowRepresentableTypeDescriptor, FR2.flowRepresentableName)
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

    #warning("TODO: Add tests for extending JSON with new fields")
    #warning("TODO: Add tests for extending each FlowRepresentable in JSON with additional data")
    #warning("TODO: Add tests for FlowPersistence and LaunchStyle")
}

extension JsonSpecificationTests {
    fileprivate var validWorkflowJSON: Data {
        get throws {
            try XCTUnwrap("""
            {
                "schemaVersion": "\(AnyWorkflow.jsonSchemaVersion.rawValue)",
                "sequence" : [
                    {
                        "flowRepresentableName" : "FR1",
                        "flowPersistence" : "default",
                        "launchStyle" : "default"
                    },
                    {
                        "flowRepresentableName" : "FR2"
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
