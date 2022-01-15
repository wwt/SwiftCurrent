//
//  TestRegistry.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 1/14/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftCurrent
public struct TestRegistry: FlowRepresentableAggregator {
    public var types: [WorkflowDecodable.Type]

    public init(types: [WorkflowDecodable.Type]) {
        self.types = types
    }
}
