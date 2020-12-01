//
//  WorkflowView.swift
//  
//
//  Created by Tyler Thompson on 11/29/20.
//

import Foundation
import SwiftUI
import Workflow
@available(iOS 14.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public extension FlowRepresentable where Self: View {
    var _workflowUnderlyingInstance:Any { AnyView(self) }
}

@available(iOS 14.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public class Holder: ObservableObject {
    let view: AnyView
    let metadata: FlowRepresentableMetaData
    init(view: AnyView, metadata: FlowRepresentableMetaData) {
        self.view = view
        self.metadata = metadata
    }
}

@available(iOS 14.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public class WorkflowModel: ObservableObject, AnyOrchestrationResponder {
    @Published var view:AnyView = AnyView(EmptyView())
    var stack = LinkedList<Holder>()

    var launchStyle:LaunchStyle.PresentationType = .default

    public func launch(to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData)) {
        guard let view = to.instance.value?.underlyingInstance as? AnyView else { return }
        launchStyle = LaunchStyle.PresentationType(rawValue: to.metadata.launchStyle) ?? .default
        self.view = view
        stack.append(Holder(view: view, metadata: to.metadata))
    }

    public func proceed(to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData), from: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData)) {
        guard let next = to.instance.value?.underlyingInstance as? AnyView else { return }
        stack.append(Holder(view: next, metadata: to.metadata))
        var v = next
        _ = stack.last?.traverse(direction: .backward, until: {
            v = AnyView(Wrapper(next: v, current: $0.value.view).environmentObject(self).environmentObject($0.value))
            return false
        })
        view = v
    }

    public func proceedBackward(from: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData), to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData)) {

    }

    public func abandon(_ workflow: AnyWorkflow, animated: Bool, onFinish: (() -> Void)?) {
        view = AnyView(EmptyView())
    }
}

@available(iOS 14.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
struct Wrapper: View {
    @EnvironmentObject var model: WorkflowModel
    let next: AnyView
    let current: AnyView

    var body: some View {
        current.sheet(isPresented: .init(get: { true }, set: { val in
            if !val {
                model.stack.removeLast()
            }
        }), content: {
            next
        })
    }
}

@available(iOS 14.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct WorkflowView: View {
    @ObservedObject var workflowModel:WorkflowModel = WorkflowModel()

    public init(_ workflow:AnyWorkflow, with args:Any? = nil, withLaunchStyle launchStyle:LaunchStyle.PresentationType = .default, onFinish:((Any?) -> Void)? = nil) {
        workflowModel.launchStyle = launchStyle
        workflow.applyOrchestrationResponder(workflowModel)
        workflow.launch(with: args, withLaunchStyle: launchStyle.rawValue, onFinish: onFinish)
    }

    public init(_ workflow:AnyWorkflow, withLaunchStyle launchStyle:LaunchStyle.PresentationType = .default, onFinish:((Any?) -> Void)? = nil) {
        workflowModel.launchStyle = launchStyle
        workflow.applyOrchestrationResponder(workflowModel)
        workflow.launch(withLaunchStyle: launchStyle.rawValue, onFinish: onFinish)
    }

    public var body: some View {
        workflowModel.view
    }
}
