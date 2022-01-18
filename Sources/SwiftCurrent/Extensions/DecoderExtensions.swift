//  swiftlint:disable:this file_name
//  DecoderExtensions.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 1/14/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//

import Foundation

extension JSONDecoder {
    struct WorkflowJSONSpec: Decodable {
        let schemaVersion: AnyWorkflow.JSONSchemaVersion
        let sequence: [Sequence]

        struct Sequence: Decodable {
            let flowRepresentableName: String
            let launchStyle: String?
            let flowPersistence: String?
        }
    }

    /// Convenience method to decode an ``AnyWorkflow`` from Data.
    public func decodeWorkflow(withAggregator aggregator: FlowRepresentableAggregator, from data: Data) throws -> AnyWorkflow {
        try AnyWorkflow(spec: decode(WorkflowJSONSpec.self, from: data), aggregator: aggregator)
    }
}

extension AnyWorkflow {
    convenience init(spec: JSONDecoder.WorkflowJSONSpec, aggregator: FlowRepresentableAggregator) throws {
        let typeMap = aggregator.typeMap
        self.init(Workflow<Never>())
        try spec.sequence.forEach {
            if let type = typeMap[$0.flowRepresentableName] {
                let launchStyle = try getLaunchStyle(decodable: type, from: $0)
                append(type.metadataFactory(launchStyle: launchStyle) { _ in .default })
            } else {
                throw AnyWorkflow.DecodingError.invalidFlowRepresentable($0.flowRepresentableName)
            }
        }
    }

    private func getLaunchStyle(decodable: WorkflowDecodable.Type, from sequence: JSONDecoder.WorkflowJSONSpec.Sequence) throws -> LaunchStyle {
        guard let launchStyleName = sequence.launchStyle else { return .default }
        return try decodable.decodeLaunchStyle(named: launchStyleName)
    }
}
