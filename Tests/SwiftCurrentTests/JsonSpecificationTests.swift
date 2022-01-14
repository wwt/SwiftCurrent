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

        let registry = TestRegistry(typeMap: [
            FR1.self,
            FR2.self
        ])

        let wf = try JSONDecoder().decodeWorkflow(withAggregator: registry, from: validWorkflowJSON)

        XCTAssertEqual(wf.first?.value.metadata.flowRepresentableTypeDescriptor, FR1.flowRepresentableName)
        XCTAssertEqual(wf.first?.next?.value.metadata.flowRepresentableTypeDescriptor, FR2.flowRepresentableName)
        XCTAssertNil(wf.first?.next?.next)
    }

    // TODO: Add tests for extending JSON with new fields
    // TODO: Add tests for extending each FlowRepresentable in JSON with additional data
}

struct TestRegistry: FlowRepresentableAggregator {
    var typeMap: [WorkflowDecodable.Type]
}

extension JsonSpecificationTests {
    fileprivate var validWorkflowJSON: Data {
        get throws {
            try XCTUnwrap("""
            {
                "schemaVersion": "\(AnyWorkflow.jsonSchemaVersion)",
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
}
