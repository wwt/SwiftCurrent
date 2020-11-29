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
public extension FlowRepresentable where Self: View {
    var _workflowUnderlyingInstance:Any { AnyView(self) }
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public class WorkflowModel: ObservableObject {
    @Published var view:AnyView = AnyView(EmptyView())
//    @Published var currentNode:WorkflowNode?
//    @Published var previousView:AnyView = AnyView(EmptyView())
//    @Published var launchStyle:PresentationType = .default// {
//        willSet(this) {
//            shouldPresentModally = this == .modal
//            shouldPresentWithNavigationStack = this == .navigationStack
//        }
//    }
//    @Published var shouldPresentModally = false
//    @Published var shouldPresentWithNavigationStack = false
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct WorkflowView: View, AnyOrchestrationResponder {
    @ObservedObject var workflowModel:WorkflowModel = WorkflowModel()

    public init(_ workflow:AnyWorkflow, with args:Any? = nil, withLaunchStyle launchStyle:LaunchStyle = .default, onFinish:((Any?) -> Void)? = nil) {
        workflow.applyOrchestrationResponder(self)
        workflow.launch(with: args, withLaunchStyle: launchStyle, onFinish: onFinish)
    }

    public init(_ workflow:AnyWorkflow, withLaunchStyle launchStyle:LaunchStyle = .default, onFinish:((Any?) -> Void)? = nil) {
        workflow.applyOrchestrationResponder(self)
        workflow.launch(withLaunchStyle: launchStyle, onFinish: onFinish)
    }

    public func launch(to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData)) {
        guard let view = to.instance.value?.underlyingInstance as? AnyView else { return }
        workflowModel.view = view
    }

    public func proceed(to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData), from: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData)) {
        guard let view = to.instance.value?.underlyingInstance as? AnyView else { return }
        workflowModel.view = view
    }

    public func proceedBackward(from: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData), to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData)) {
        guard let view = to.instance.value?.underlyingInstance as? AnyView else { return }
        workflowModel.view = view
    }

    public func abandon(_ workflow: AnyWorkflow, animated: Bool, onFinish: (() -> Void)?) {
        workflowModel.view = AnyView(EmptyView())
    }

    public var body: some View {
        workflowModel.view
    }
}
