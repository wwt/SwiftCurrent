//
//  FlowRepresentableAggregator.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 1/14/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

/**
 Aggregates ``WorkflowDecodable`` types for decoding.
 */
public protocol FlowRepresentableAggregator {
    /// A list of ``WorkflowDecodable`` types to use when decoding a workflow
    var types: [WorkflowDecodable.Type] { get }

    /**
     A dictionary representation of flowRepresentableName to ``WorkflowDecodable``
     - NOTE: This is auto-generated unless you override the behavior
     */
    var typeMap: [String: WorkflowDecodable.Type] { get }

    /**
     Creates a FlowRepresentableAggregator with default types.
     - NOTE: Convenience methods use this empty initializer; alternative public methods exist for an already initialized aggregator.
     */
    init()
}

extension FlowRepresentableAggregator {
    /**
     A dictionary representation of flowRepresentableName to ``WorkflowDecodable``
     - NOTE: This is auto-generated unless you override the behavior
     */
    public var typeMap: [String: WorkflowDecodable.Type] {
        types.reduce(into: [:]) { $0[$1.flowRepresentableName] = $1 }
    }
}
