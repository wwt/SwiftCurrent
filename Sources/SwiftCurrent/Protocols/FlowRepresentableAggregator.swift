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
    var typeMap: [WorkflowDecodable.Type] { get }
}
