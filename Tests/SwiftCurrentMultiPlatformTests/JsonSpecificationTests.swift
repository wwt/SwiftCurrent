//
//  JsonSpecificationTests.swift
//  SwiftCurrent
//
//  Created by Nick Kaczmarek on 2/3/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Foundation
import XCTest
import SwiftCurrent_Testing

@testable import SwiftCurrent

final class JsonSpecificationTests: XCTestCase {
#if os(iOS)
    func testWorkflowCanBeInstantiatedFromComplexJSON_for_iOS() throws {
        struct FR1: FlowRepresentable, WorkflowDecodable, TestLookup {
            weak var _workflowPointer: AnyFlowRepresentable?
        }

        let registry = TestRegistry(types: [FR1.self])

        let wf = try JSONDecoder().decodeWorkflow(withAggregator: registry, from: platformSpecificValidWorkflowJSON)
        let or = MockOrchestrationResponder()

        XCTAssertEqual(wf.first?.value.metadata.flowRepresentableTypeDescriptor, FR1.flowRepresentableName)
        XCTAssertIdentical(wf.first?.value.metadata.launchStyle, LaunchStyle.testStyle_iOS)

        wf.launch(withOrchestrationResponder: or, passedArgs: .none)
        XCTAssertIdentical(or.lastTo?.value.metadata.persistence, FlowPersistence.testPersistence_iOS)
    }
#endif

#if os(macOS)
    func testWorkflowCanBeInstantiatedFromComplexJSON_for_macOS() throws {
        struct FR1: FlowRepresentable, WorkflowDecodable, TestLookup {
            weak var _workflowPointer: AnyFlowRepresentable?
        }

        let registry = TestRegistry(types: [FR1.self])

        let wf = try JSONDecoder().decodeWorkflow(withAggregator: registry, from: platformSpecificValidWorkflowJSON)
        let or = MockOrchestrationResponder()

        XCTAssertEqual(wf.first?.value.metadata.flowRepresentableTypeDescriptor, FR1.flowRepresentableName)
        XCTAssertIdentical(wf.first?.value.metadata.launchStyle, LaunchStyle.testStyle_macOS)

        wf.launch(withOrchestrationResponder: or, passedArgs: .none)
        XCTAssertIdentical(or.lastTo?.value.metadata.persistence, FlowPersistence.testPersistence_macOS)
    }
#endif

#if os(watchOS)
    func testWorkflowCanBeInstantiatedFromComplexJSON_for_watchOS() throws {
        struct FR1: FlowRepresentable, WorkflowDecodable, TestLookup {
            weak var _workflowPointer: AnyFlowRepresentable?
        }

        let registry = TestRegistry(types: [FR1.self])

        let wf = try JSONDecoder().decodeWorkflow(withAggregator: registry, from: platformSpecificValidWorkflowJSON)
        let or = MockOrchestrationResponder()

        XCTAssertEqual(wf.first?.value.metadata.flowRepresentableTypeDescriptor, FR1.flowRepresentableName)
        XCTAssertIdentical(wf.first?.value.metadata.launchStyle, LaunchStyle.testStyle_watchOS)

        wf.launch(withOrchestrationResponder: or, passedArgs: .none)
        XCTAssertIdentical(or.lastTo?.value.metadata.persistence, FlowPersistence.testPersistence_watchOS)
    }
#endif

#if os(tvOS)
    func testWorkflowCanBeInstantiatedFromComplexJSON_for_tvOS() throws {
        struct FR1: FlowRepresentable, WorkflowDecodable, TestLookup {
            weak var _workflowPointer: AnyFlowRepresentable?
        }

        let registry = TestRegistry(types: [FR1.self])

        let wf = try JSONDecoder().decodeWorkflow(withAggregator: registry, from: platformSpecificValidWorkflowJSON)
        let or = MockOrchestrationResponder()

        XCTAssertEqual(wf.first?.value.metadata.flowRepresentableTypeDescriptor, FR1.flowRepresentableName)
        XCTAssertIdentical(wf.first?.value.metadata.launchStyle, LaunchStyle.testStyle_tvOS)

        wf.launch(withOrchestrationResponder: or, passedArgs: .none)
        XCTAssertIdentical(or.lastTo?.value.metadata.persistence, FlowPersistence.testPersistence_tvOS)
    }
#endif

#if os(macOS) && targetEnvironment(macCatalyst)
    func testWorkflowCanBeInstantiatedFromComplexJSON_for_macCatalyst() throws {
        struct FR1: FlowRepresentable, WorkflowDecodable, TestLookup {
            weak var _workflowPointer: AnyFlowRepresentable?
        }

        let registry = TestRegistry(types: [FR1.self])

        let wf = try JSONDecoder().decodeWorkflow(withAggregator: registry, from: platformSpecificValidWorkflowJSON)
        let or = MockOrchestrationResponder()

        XCTAssertEqual(wf.first?.value.metadata.flowRepresentableTypeDescriptor, FR1.flowRepresentableName)
        XCTAssertIdentical(wf.first?.value.metadata.launchStyle, LaunchStyle.testStyle_macCatalyst)

        wf.launch(withOrchestrationResponder: or, passedArgs: .none)
        XCTAssertIdentical(or.lastTo?.value.metadata.persistence, FlowPersistence.testPersistence_macCatalyst)
    }
#endif
}

public protocol TestLookup { } // For example: View

extension WorkflowDecodable where Self: TestLookup {
    public static func decodeLaunchStyle(named name: String) throws -> LaunchStyle {
        switch name.lowercased() {
            case "teststyle_ios".lowercased(): return .testStyle_iOS
            case "teststyle_ipados".lowercased(): return .testStyle_iPadOS
            case "teststyle_macos".lowercased(): return .testStyle_macOS
            case "teststyle_watchos".lowercased(): return .testStyle_watchOS
            case "teststyle_tvos".lowercased(): return .testStyle_tvOS
            case "testStyle_macCatalyst".lowercased(): return .testStyle_macCatalyst
            default:
                throw URLError(.badURL)
        }
    }
}

extension WorkflowDecodable where Self: TestLookup {
    public static func decodeFlowPersistence(named name: String) throws -> FlowPersistence {
        switch name.lowercased() {
            case "testpersistence_ios".lowercased(): return .testPersistence_iOS
            case "testpersistence_ipados".lowercased(): return .testPersistence_iPadOS
            case "testpersistence_macos".lowercased(): return .testPersistence_macOS
            case "testpersistence_watchos".lowercased(): return .testPersistence_watchOS
            case "testpersistence_tvos".lowercased(): return .testPersistence_tvOS
            case "testStyle_macCatalyst".lowercased(): return .testPersistence_macCatalyst

            default:
                throw URLError(.badURL)
        }
    }
}

extension LaunchStyle {
    static var testStyle_iOS = LaunchStyle.new
    static var testStyle_iPadOS = LaunchStyle.new
    static var testStyle_macOS = LaunchStyle.new
    static var testStyle_watchOS = LaunchStyle.new
    static var testStyle_tvOS = LaunchStyle.new
    static var testStyle_macCatalyst = LaunchStyle.new
}

extension FlowPersistence {
    static var testPersistence_iOS = FlowPersistence.new
    static var testPersistence_iPadOS = FlowPersistence.new
    static var testPersistence_macOS = FlowPersistence.new
    static var testPersistence_watchOS = FlowPersistence.new
    static var testPersistence_tvOS = FlowPersistence.new
    static var testPersistence_macCatalyst = FlowPersistence.new
}

extension JsonSpecificationTests {
    fileprivate var platformSpecificValidWorkflowJSON: Data {
        get throws {
            try XCTUnwrap("""
                {
                    "schemaVersion": "\(AnyWorkflow.jsonSchemaVersion.rawValue)",
                    "sequence": [
                        {
                            "flowRepresentableName": {
                                "watchOS": "FR1",
                                "macOS": "FR1",
                                "iOS": "FR1",
                                "iPadOS": "FR1",
                                "tvOS": "FR1",
                                "macCatalyst": "FR1"
                            },
                            "launchStyle": {
                                "iOS": "testStyle_iOS",
                                "iPadOS": "testStyle_iPadOS",
                                "macOS": "testStyle_macOS",
                                "watchOS": "testStyle_watchOS",
                                "tvOS": "testStyle_tvOS",
                                "macCatalyst": "testStyle_macCatalyst"
                            },
                            "flowPersistence": {
                                "iOS": "testPersistence_iOS",
                                "iPadOS": "testPersistence_iPadOS",
                                "macOS": "testPersistence_macOS",
                                "watchOS": "testPersistence_watchOS",
                                "tvOS": "testPersistence_tvOS",
                                "macCatalyst": "testPersistence_macCatalyst"
                            }
                        }
                    ]
                }
        """.data(using: .utf8))
        }
    }
}
