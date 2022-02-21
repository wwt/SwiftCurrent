//
//  WorkflowBuilder.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 2/21/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Foundation

@resultBuilder
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
enum WorkflowBuilder {
    static func buildBlock<F, V>(_ component: WorkflowItem<F, Never, V>) -> WorkflowItem<F, Never, V> {
        component
    }

    public static func buildBlock<F0, V0, F1, V1>(_ f0: WorkflowItem<F0, Never, V0>,
                                                  _ f1: WorkflowItem<F1, Never, V1>) -> WorkflowItem<F0, WorkflowItem<F1, Never, V1>, V0> {
        .init()
    }

    public static func buildBlock<F0, V0, F1, V1, F2, V2>(_ f0: WorkflowItem<F0, Never, V0>,
                                                          _ f1: WorkflowItem<F1, Never, V1>,
                                                          _ f2: WorkflowItem<F2, Never, V2>) -> WorkflowItem<F0, WorkflowItem<F1, WorkflowItem<F2, Never, V2>, V1>, V0> {
        .init()
    }
}
