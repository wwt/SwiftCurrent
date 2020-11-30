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
public class WorkflowModel: ObservableObject, AnyOrchestrationResponder {
    @Published var view:AnyView = AnyView(EmptyView())
    var stack = LinkedList<AnyView>()

    var launchStyle:LaunchStyle.PresentationType = .default

    public func launch(to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData)) {
        guard let view = to.instance.value?.underlyingInstance as? AnyView else { return }
        launchStyle = LaunchStyle.PresentationType(rawValue: to.metadata.launchStyle) ?? .default
        self.view = view
        stack.append(view)
    }

    public func proceed(to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData), from: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData)) {
        guard let next = to.instance.value?.underlyingInstance as? AnyView else { return }
        //first
//        let current = cur
//        var v = AnyView(EmptyView())
//        if let back1 = prev {
//            v = AnyView(Wrapper(next: next, current: current).environmentObject(self))
//            if let _ = prevPrev {
//                v = AnyView(Wrapper(next: v, current: back1).environmentObject(self))
//            }
//        }
        stack.append(next)
        var v = next
        _ = stack.last?.traverse(direction: .backward, until: {
            let current = $0.value
            v = AnyView(Wrapper(next: v, current: current).environmentObject(self))
            return false
        })
        view = v//AnyView(Wrapper(next: next, current: view).environmentObject(self))
    }

    public func proceedBackward(from: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData), to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData)) {
//        workflowModel.view = workflowModel.previousView
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

    @State var showingModal = true

    var body: some View {
        current.sheet(isPresented: $showingModal, content: {
            next
        })
//        .onChange(of: showingModal, perform: { _ in
//            model.stack.removeLast()
//        })
    }
}

@available(iOS 14.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct WorkflowView: View {
    @ObservedObject var workflowModel:WorkflowModel = WorkflowModel()

    public init(_ workflow:AnyWorkflow, with args:Any? = nil, withLaunchStyle launchStyle:LaunchStyle.PresentationType = .default, onFinish:((Any?) -> Void)? = nil) {
//        workflowModel.launchStyle = launchStyle
        workflow.applyOrchestrationResponder(workflowModel)
        workflow.launch(with: args, withLaunchStyle: launchStyle.rawValue, onFinish: onFinish)
    }

    public init(_ workflow:AnyWorkflow, withLaunchStyle launchStyle:LaunchStyle.PresentationType = .default, onFinish:((Any?) -> Void)? = nil) {
//        workflowModel.launchStyle = launchStyle
        workflow.applyOrchestrationResponder(workflowModel)
        workflow.launch(withLaunchStyle: launchStyle.rawValue, onFinish: onFinish)
    }

    public var body: some View {
        workflowModel.view
    }
}
