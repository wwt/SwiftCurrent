//
//  WorkflowView.swift
//  
//
//  Created by Tyler Thompson on 11/29/20.
//

import Foundation
import SwiftUI
import Workflow

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct WorkflowView: View {
    @ObservedObject var workflowModel: WorkflowModel = WorkflowModel()

    public init(_ workflow: AnyWorkflow, with args: Any? = nil, withLaunchStyle launchStyle: LaunchStyle.PresentationType = .default, onFinish: ((Any?) -> Void)? = nil) {
        workflowModel.launchStyle = launchStyle
        workflow.applyOrchestrationResponder(workflowModel)
        workflow.launch(with: args, withLaunchStyle: launchStyle.rawValue, onFinish: onFinish)
    }

    public init(_ workflow: AnyWorkflow, withLaunchStyle launchStyle: LaunchStyle.PresentationType = .default, onFinish: ((Any?) -> Void)? = nil) {
        workflowModel.launchStyle = launchStyle
        workflow.applyOrchestrationResponder(workflowModel)
        workflow.launch(withLaunchStyle: launchStyle.rawValue, onFinish: onFinish)
    }

    public var body: some View {
        workflowModel.view
    }
}
