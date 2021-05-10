//
//  WorkflowItem.swift
//  Workflow
//
//  Created by Tyler Thompson on 5/10/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//
// swiftlint:disable missing_docs type_name

import Foundation

public class _WorkflowItem {
    public let metadata: FlowRepresentableMetadata
    public internal(set) var instance: AnyFlowRepresentable?

    init(metadata: FlowRepresentableMetadata, instance: AnyFlowRepresentable? = nil) {
        self.metadata = metadata
        self.instance = instance
    }
}
