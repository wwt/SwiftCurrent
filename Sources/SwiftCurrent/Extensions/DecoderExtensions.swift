//  swiftlint:disable:this file_name
//  DecoderExtensions.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 1/14/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  swiftlint:disable file_types_order

import Foundation

extension JSONDecoder {
    fileprivate struct WorkflowJSONSpec: Decodable {
        let schemaVersion: AnyWorkflow.JSONSchemaVersion
        let sequence: [Sequence]

        fileprivate struct Sequence: Decodable {
            let flowRepresentableName: String
        }
    }

    /// Convenience method to decode an ``AnyWorkflow`` from Data.
    public func decodeWorkflow(withAggregator aggregator: FlowRepresentableAggregator, from data: Data) throws -> AnyWorkflow {
        try AnyWorkflow(spec: decode(WorkflowJSONSpec.self, from: data), aggregator: aggregator)
    }
}

@propertyWrapper
public struct DecodeWorkflow<Aggregator: FlowRepresentableAggregator>: Decodable {
    public var wrappedValue: AnyWorkflow

    public init(wrappedValue: AnyWorkflow = .empty, aggregator: Aggregator.Type) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let spec = try container.decode(JSONDecoder.WorkflowJSONSpec.self)
        wrappedValue = try AnyWorkflow(spec: spec, aggregator: Aggregator())
    }
}

extension AnyWorkflow {
    fileprivate convenience init(spec: JSONDecoder.WorkflowJSONSpec, aggregator: FlowRepresentableAggregator) throws {
        let typeMap = aggregator.typeMap
        self.init(Workflow<Never>())
        try spec.sequence.forEach {
            if let type = typeMap[$0.flowRepresentableName] {
                append(type.metadataFactory())
            } else {
                throw AnyWorkflow.DecodingError.invalidFlowRepresentable($0.flowRepresentableName)
            }
        }
    }
}
