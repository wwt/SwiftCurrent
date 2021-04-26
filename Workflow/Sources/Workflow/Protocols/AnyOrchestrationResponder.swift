//
//  AnyOrchestrationResponder.swift
//  
//
//  Created by Tyler Thompson on 11/24/20.
//

import Foundation
public protocol AnyOrchestrationResponder {
    func launch(to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData))
    func proceed(to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData),
                 from: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData))
    func proceedBackward(from: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData),
                         to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData))
    func abandon(_ workflow: AnyWorkflow, animated: Bool, onFinish: (() -> Void)?)
}

extension AnyOrchestrationResponder {
    func launchOrProceed(to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData),
                         from: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData)?) {
        if let root = from {
            self.proceed(to: to, from: root)
        } else {
            self.launch(to: to)
        }
    }
}
