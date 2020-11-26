//
//  File.swift
//  
//
//  Created by Tyler Thompson on 11/24/20.
//

import Foundation
public protocol AnyOrchestrationResponder {
    func proceed(to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData),
                 from: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData)?)
    func abandon(_ workflow: AnyWorkflow, animated: Bool, onFinish: (() -> Void)?)
}
