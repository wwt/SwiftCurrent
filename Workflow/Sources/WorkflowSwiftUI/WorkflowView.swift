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
public class Holder: ObservableObject {
    let view: AnyView
    let metadata: FlowRepresentableMetaData
    init(view: AnyView, metadata: FlowRepresentableMetaData) {
        self.view = view
        self.metadata = metadata
    }
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public class WorkflowModel: ObservableObject, AnyOrchestrationResponder {
    @Published var view:AnyView = AnyView(EmptyView())
    var stack = LinkedList<Holder>()

    var launchStyle:LaunchStyle.PresentationType = .default

    public func launch(to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData)) {
        guard let next = to.instance.value?.underlyingInstance as? AnyView else { return }
        stack.append(Holder(view: next, metadata: to.metadata))

        var v = next

        switch LaunchStyle.PresentationType(rawValue: to.metadata.launchStyle) ?? .default {
            case .modal(let style): v = AnyView(ModalWrapper(next: v, current: AnyView(EmptyView()), style: style).environmentObject(self).environmentObject(stack.first!.value))
            default: break
        }

        switch launchStyle {
            case .modal(let style): self.view = AnyView(ModalWrapper(next: v, current: AnyView(EmptyView()), style: style).environmentObject(self).environmentObject(stack.first!.value))
            default: self.view = v
        }
    }

    public func proceed(to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData), from: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData)) {
        guard let next = to.instance.value?.underlyingInstance as? AnyView else { return }
        stack.append(Holder(view: next, metadata: to.metadata))
        present(view: next)
    }
    
    private func present(view next:AnyView) {
        var v = next
        _ = stack.last?.traverse(direction: .backward, until: {
            guard let nextNode = $0.next else { return false } //NOTE: Barring some threading crazy, this should never be nil
            
            let launchStyle = LaunchStyle.PresentationType(rawValue: nextNode.value.metadata.launchStyle) ?? .default
            switch launchStyle {
                case .modal(let style): v = AnyView(ModalWrapper(next: v, current: $0.value.view, style: style).environmentObject(self).environmentObject($0.value))
                default: return false //v = $0.value.view
            }
            
            if $0 === stack.first,
               case .modal(let style) = self.launchStyle {
                v = AnyView(ModalWrapper(next: v, current: AnyView(EmptyView()), style: style).environmentObject(self).environmentObject($0.value))
            }
            
            return false
        })
        view = v
    }

//    #warning("TEST THIS, also it only kinda works")
    public func proceedBackward(from: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData), to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData)) {
//        stack.removeLast()
//        guard let prev = to.instance.value?.underlyingInstance as? AnyView else { return }
//        present(view: prev)
    }

    public func abandon(_ workflow: AnyWorkflow, animated: Bool, onFinish: (() -> Void)?) {
        view = AnyView(EmptyView())
    }
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
struct ModalWrapper: View {
    @EnvironmentObject var model: WorkflowModel
    @EnvironmentObject var holder: Holder
    
    let next: AnyView
    let current: AnyView
    let style: LaunchStyle.PresentationType.ModalPresentationStyle

    var body: some View {
        #warning("Is there a way to test the boolean value here?")
        switch style {
            case .default:
                current.sheet(isPresented: .init(get: {
                    model.stack.contains(where: { $0.value === holder })
                }, set: { val in
                    if !val {
                        model.stack.removeLast()
                    }
                }), content: {
                    next
                })
            case .fullScreen: if #available(iOS 14.0, *) {
                current.fullScreenCover(isPresented: .init(get: {
                    model.stack.contains(where: { $0.value === holder })
                }, set: { val in
                    if !val {
                        model.stack.removeLast()
                    }
                }), content: {
                    next
                })
            }
        }
    }
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
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
