//
//  OrchestrationResponder.swift
//  
//
//  Created by Tyler Thompson on 11/24/20.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
public protocol OrchestrationResponder {
    func launch(to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetadata))
    func proceed(to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetadata),
                 from: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetadata))
    func backUp(from: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetadata),
                to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetadata))
    func abandon(_ workflow: AnyWorkflow, animated: Bool, onFinish: (() -> Void)?)
}

extension OrchestrationResponder {
    func launchOrProceed(to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetadata),
                         from: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetadata)?) {
        if let root = from {
            proceed(to: to, from: root)
        } else {
            launch(to: to)
        }
    }
}
