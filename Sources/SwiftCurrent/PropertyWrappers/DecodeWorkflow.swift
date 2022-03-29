//
//  DecodeWorkflow.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 1/18/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Foundation

/**
 A property wrapper to easily conform `AnyWorkflow` to `Decodable`.

 ### Discussion
 Swift's `Decodable` implementation is often more friendly when all your properties conform to `Decodable`. While `AnyWorkflow` does not directly conform to `Decodable`, the `DecodeWorkflow` property wrapper makes it conform. This provides a convenient way for you to decode workflows as part of other payloads.

 #### Example
 A struct that decodes a workflow and some metadata
 ```swift
 struct WorkflowServerResponse: Decodable {
    @DecodeWorkflow<MyCustomAggregator> var workflow: AnyWorkflow
    var workflowID: UUID
 }
 ```
 */
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
