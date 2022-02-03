//  swiftlint:disable:this file_name
//  DecoderExtensions.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 1/14/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import UIKit



extension JSONDecoder {
    struct WorkflowJSONSpec: Decodable {
        let schemaVersion: AnyWorkflow.JSONSchemaVersion
        let sequence: [Sequence]
    }

    /// Convenience method to decode an ``AnyWorkflow`` from Data.
    public func decodeWorkflow(withAggregator aggregator: FlowRepresentableAggregator, from data: Data) throws -> AnyWorkflow {
        try AnyWorkflow(spec: decode(WorkflowJSONSpec.self, from: data), aggregator: aggregator)
    }
}

extension JSONDecoder.WorkflowJSONSpec {
    struct Sequence: Decodable {
        let flowRepresentableName: String
        let launchStyle: String?
        let flowPersistence: String?

        enum CodingKeys: String, CodingKey {
            case flowRepresentableName
            case launchStyle
            case flowPersistence
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            if let flowRepresentableNameMap = try? container.decode([String: String].self, forKey: .flowRepresentableName) {
                if let value = flowRepresentableNameMap["*"] {
                    self.flowRepresentableName = value
                } else {
                    throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "No FlowRepresentable name found for platform", underlyingError: nil))
                }
            } else {
                self.flowRepresentableName = try container.decode(String.self, forKey: .flowRepresentableName)
            }

            if let launchStyleMap = try? container.decodeIfPresent([String: String].self, forKey: .launchStyle) {
                if let value = launchStyleMap["*"] {
                    self.launchStyle = value
                } else {
                    throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "No \(String(describing: LaunchStyle.self)) found for platform", underlyingError: nil))
                }
            } else {
                self.launchStyle = try container.decodeIfPresent(String.self, forKey: .launchStyle)
            }

            if let flowPersistenceMap = try? container.decodeIfPresent([String: String].self, forKey: .flowPersistence) {
                if let value = flowPersistenceMap["*"] {
                    self.flowPersistence = value
                } else {
                    throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "No \(String(describing: FlowPersistence.self)) found for platform", underlyingError: nil))
                }
            } else {
                self.flowPersistence = try container.decodeIfPresent(String.self, forKey: .flowPersistence)
            }
        }
    }
}

extension AnyWorkflow {
    convenience init(spec: JSONDecoder.WorkflowJSONSpec, aggregator: FlowRepresentableAggregator) throws {
        let typeMap = aggregator.typeMap
        self.init(Workflow<Never>())
        try spec.sequence.forEach {
            if let type = typeMap[$0.flowRepresentableName] {
                let launchStyle = try getLaunchStyle(decodable: type, from: $0)
                let flowPersistence = try getFlowPersistence(decodable: type, from: $0)
                append(type.metadataFactory(launchStyle: launchStyle) { _ in flowPersistence })
            } else {
                throw AnyWorkflow.DecodingError.invalidFlowRepresentable($0.flowRepresentableName)
            }
        }
    }

    private func getLaunchStyle(decodable: WorkflowDecodable.Type, from sequence: JSONDecoder.WorkflowJSONSpec.Sequence) throws -> LaunchStyle {
        guard let launchStyleName = sequence.launchStyle else { return .default }
        return try decodable.decodeLaunchStyle(named: launchStyleName)
    }

    private func getFlowPersistence(decodable: WorkflowDecodable.Type, from sequence: JSONDecoder.WorkflowJSONSpec.Sequence) throws -> FlowPersistence {
        guard let flowPersistenceName = sequence.flowPersistence else { return .default }
        return try decodable.decodeFlowPersistence(named: flowPersistenceName)
    }
}
