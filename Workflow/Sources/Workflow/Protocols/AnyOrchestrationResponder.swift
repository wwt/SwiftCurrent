//
//  AnyOrchestrationResponder.swift
//  
//
//  Created by Tyler Thompson on 11/24/20.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
public protocol AnyOrchestrationResponder {
    func launch(to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetadata))
    func proceed(to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetadata),
                 from: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetadata))
    func proceedBackward(from: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetadata),
                         to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetadata))
    func abandon(_ workflow: AnyWorkflow, animated: Bool, onFinish: (() -> Void)?)
}

extension AnyOrchestrationResponder {
    func launchOrProceed(to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetadata),
                         from: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetadata)?) {
        if let root = from {
            proceed(to: to, from: root)
        } else {
            launch(to: to)
        }
    }
}
