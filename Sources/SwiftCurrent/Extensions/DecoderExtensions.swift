//  swiftlint:disable:this file_name
//  DecoderExtensions.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 1/14/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

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
        let spec = try decode(WorkflowJSONSpec.self, from: data)
        let typeMap = aggregator.typeMap

        return try spec.sequence.reduce(into: AnyWorkflow.empty) {
            if let type = typeMap[$1.flowRepresentableName] {
                $0.append(type.metadataFactory())
            } else {
                throw AnyWorkflow.DecodingError.invalidFlowRepresentable($1.flowRepresentableName)
            }
        }
    }
}
