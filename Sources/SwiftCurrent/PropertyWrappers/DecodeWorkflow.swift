//
//  DecodeWorkflow.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 1/18/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Foundation

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
