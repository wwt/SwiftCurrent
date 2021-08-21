//
//  WorkflowItem.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 7/20/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//
//  swiftlint:disable file_types_order

import SwiftUI
import SwiftCurrent

#if (os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)) && canImport(UIKit)
import UIKit
#endif

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
protocol WorkflowModifier {
    func modify(workflow: AnyWorkflow)
}

/**
 A view created by a `WorkflowLauncher`.

 ### Discussion
 You do not instantiate this view directly, rather you call `thenProceed(with:)` on a `WorkflowLauncher`.
 */
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct WorkflowItem<Args, Wrapped: View, Content: View>: View {
    let inspection = Inspection<Self>()
    // These need to be state variables to survive SwiftUI re-rendering. Change under penalty of torture BY the codebase you modified.
    @State private var wrapped: Wrapped?
    @State private var launchArgs: AnyWorkflow.PassedArgs
    @State private var metadata: FlowRepresentableMetadata

    @EnvironmentObject private var model: WorkflowViewModel
    @EnvironmentObject private var launcher: Launcher

    public var body: some View {
        ViewBuilder {
            if model.isLaunched?.wrappedValue == true {
                if let body = model.body as? Content {
                    body
                } else {
                    wrapped
                }
            }
        }
        .onReceive(inspection.notice) { inspection.visit(self, $0) }
        .onChange(of: model.isLaunched?.wrappedValue) { if $0 == false { resetWorkflow() } }
    }

    private init<A, W, C, A1, W1, C1>(previous: WorkflowItem<A, W, C>, _ closure: () -> Wrapped) where Wrapped == WorkflowItem<A1, W1, C1> {
        let wrapped = closure()
        _wrapped = State(initialValue: wrapped)
        _launchArgs = previous._launchArgs
        _model = previous._model
        _launcher = previous._launcher
        _metadata = previous._metadata
    }

    public init(_ item: Content.Type) where Wrapped == Never, Args == Content.WorkflowInput, Content: FlowRepresentable & View {
        _launchArgs = State(initialValue: .none) // default value, overridden later
        let metadata = FlowRepresentableMetadata(Content.self,
                                                 launchStyle: .new,
                                                 flowPersistence: { _ in .default },
                                                 flowRepresentableFactory: {
                                                    let afrv = AnyFlowRepresentableView(type: Content.self, args: $0)
//                                                        modifierClosure?(afrv)
                                                    return afrv
                                                 })
        _metadata = State(initialValue: metadata)
    }

    #if (os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)) && canImport(UIKit)
    /// Creates a `WorkflowItem` from a `UIViewController`.
    @available(iOS 14.0, macOS 11, tvOS 14.0, *)
    public init<VC: FlowRepresentable & UIViewController>(_: VC.Type) where Content == ViewControllerWrapper<VC>, Wrapped == Never, Args == VC.WorkflowInput {
        _launchArgs = State(initialValue: .none)
        let metadata = FlowRepresentableMetadata(ViewControllerWrapper<VC>.self,
                                                 launchStyle: .new,
                                                 flowPersistence: { _ in .default },
                                                 flowRepresentableFactory: {
                                                    let afrv = AnyFlowRepresentableView(type: Content.self, args: $0)
//                                                        modifierClosure?(afrv)
                                                    return afrv
                                                 })
        _metadata = State(initialValue: metadata)
    }
    #endif

    init<A>(_ launcher: WorkflowLauncher<A>, isLaunched: Binding<Bool>, wrap: WorkflowItem<Args, Wrapped, Content>) {
        _launchArgs = State(initialValue: launcher.passedArgs)
        _metadata = wrap._metadata
        _wrapped = wrap._wrapped
    }

    public func thenProceed<A, W, C>(with closure: @autoclosure () -> WorkflowItem<A, W, C>) -> WorkflowItem<Args, WorkflowItem<A, W, C>, Content> where Wrapped == Never {
        WorkflowItem<Args, WorkflowItem<A, W, C>, Content>(previous: self) {
            closure()
        }
    }

    private init(workflowLauncher: Self, onFinish: [(AnyWorkflow.PassedArgs) -> Void], onAbandon: [() -> Void]) {
        _wrapped = workflowLauncher._wrapped
        _launchArgs = workflowLauncher._launchArgs
        _metadata = workflowLauncher._metadata
    }

    private func resetWorkflow() {
        launcher.onFinishCalled = false
        launcher.workflow?.launch(withOrchestrationResponder: model, passedArgs: launchArgs)
    }

    /// Sets persistence on the `FlowRepresentable` of the `WorkflowItem`.
    public func persistence(_ persistence: @escaping @autoclosure () -> FlowPersistence) -> Self {
//        flowPersistenceClosure = { _ in persistence() }
//        metadata = FlowRepresentableMetadata(F.self,
//                                             launchStyle: .new,
//                                             flowPersistence: flowPersistenceClosure,
//                                             flowRepresentableFactory: factory)
        return self
    }

    private func ViewBuilder<V: View>(@ViewBuilder builder: () -> V) -> some View { builder() }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowItem: WorkflowModifier {
    func modify(workflow: AnyWorkflow) {
        workflow.append(metadata)
        (wrapped as? WorkflowModifier)?.modify(workflow: workflow)
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
final class Launcher: ObservableObject {
    var onFinishCalled = false
    var workflow: AnyWorkflow?
    init(workflow: AnyWorkflow?,
         responder: OrchestrationResponder,
         launchArgs: AnyWorkflow.PassedArgs) {
        self.workflow = workflow
        if workflow?.orchestrationResponder == nil {
            workflow?.launch(withOrchestrationResponder: responder, passedArgs: launchArgs)
        }
    }
}

//@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
//extension ModifiedWorkflowView where Args == Never {
//    /**
//     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
//     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
//     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
//     */
//    public func thenProceed<FR: FlowRepresentable & View, T>(with item: WorkflowItem<FR, T>) -> ModifiedWorkflowView<FR.WorkflowOutput, Self, T> where FR.WorkflowInput == Never {
//        ModifiedWorkflowView<FR.WorkflowOutput, Self, T>(self, item: item)
//    }
//}
//
//@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
//extension ModifiedWorkflowView where Args == AnyWorkflow.PassedArgs {
//    /**
//     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
//     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
//     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
//     */
//    public func thenProceed<FR: FlowRepresentable & View, T>(with item: WorkflowItem<FR, T>) -> ModifiedWorkflowView<FR.WorkflowOutput, Self, T> where FR.WorkflowInput == AnyWorkflow.PassedArgs {
//        ModifiedWorkflowView<FR.WorkflowOutput, Self, T>(self, item: item)
//    }
//
//    /**
//     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
//     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
//     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
//     */
//    public func thenProceed<FR: FlowRepresentable & View, T>(with item: WorkflowItem<FR, T>) -> ModifiedWorkflowView<FR.WorkflowOutput, Self, T> where FR.WorkflowInput == Never {
//        ModifiedWorkflowView<FR.WorkflowOutput, Self, T>(self, item: item)
//    }
//
//    /**
//     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
//     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
//     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
//     */
//    public func thenProceed<FR: FlowRepresentable & View, T>(with item: WorkflowItem<FR, T>) -> ModifiedWorkflowView<FR.WorkflowOutput, Self, T> {
//        ModifiedWorkflowView<FR.WorkflowOutput, Self, T>(self, item: item)
//    }
//}
//
//@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
//extension ModifiedWorkflowView {
//    /**
//     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
//     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
//     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
//     */
//    public func thenProceed<FR: FlowRepresentable & View, T>(with item: WorkflowItem<FR, T>) -> ModifiedWorkflowView<FR.WorkflowOutput, Self, T> where Args == FR.WorkflowInput {
//        ModifiedWorkflowView<FR.WorkflowOutput, Self, T>(self, item: item)
//    }
//
//    /**
//     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
//     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
//     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
//     */
//    public func thenProceed<FR: FlowRepresentable & View, T>(with item: WorkflowItem<FR, T>) -> ModifiedWorkflowView<FR.WorkflowOutput, Self, T> where FR.WorkflowInput == AnyWorkflow.PassedArgs {
//        ModifiedWorkflowView<FR.WorkflowOutput, Self, T>(self, item: item)
//    }
//
//    /**
//     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
//     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
//     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
//     */
//    public func thenProceed<FR: FlowRepresentable & View, T>(with item: WorkflowItem<FR, T>) -> ModifiedWorkflowView<FR.WorkflowOutput, Self, T> where FR.WorkflowInput == Never {
//        ModifiedWorkflowView<FR.WorkflowOutput, Self, T>(self, item: item)
//    }
//}
