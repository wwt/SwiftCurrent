//
//  WorkflowItem.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 7/20/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftUI
import SwiftCurrent

#if (os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)) && canImport(UIKit)
import UIKit
#endif

/**
 A view created by a `WorkflowLauncher`.

 ### Discussion
 You do not instantiate this view directly, rather you call `thenProceed(with:)` on a `WorkflowLauncher`.
 */
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct WorkflowItem<F: FlowRepresentable & View, Wrapped: View, Content: View>: View {
    // These need to be state variables to survive SwiftUI re-rendering. Change under penalty of torture BY the codebase you modified.
    @State private var wrapped: Wrapped?
    @State private var metadata: FlowRepresentableMetadata!
    @State private var modifierClosure: ((AnyFlowRepresentableView) -> Void)?
    @State private var flowPersistenceClosure: (AnyWorkflow.PassedArgs) -> FlowPersistence = { _ in .default }

    @EnvironmentObject private var model: WorkflowViewModel
    @EnvironmentObject private var launcher: Launcher

    public var body: some View {
        ViewBuilder {
            if model.isLaunched == true {
                if let body = model.body as? Content {
                    body
                } else {
                    wrapped
                }
            }
        }
        .onChange(of: model.isLaunched) { if $0 == false { resetWorkflow() } }
    }

    private init<A, W, C, A1, W1, C1>(previous: WorkflowItem<A, W, C>, _ closure: () -> Wrapped) where Wrapped == WorkflowItem<A1, W1, C1> {
        let wrapped = closure()
        _wrapped = State(initialValue: wrapped)
        _model = previous._model
        _launcher = previous._launcher
        _metadata = previous._metadata
        _modifierClosure = previous._modifierClosure
        _flowPersistenceClosure = previous._flowPersistenceClosure
    }

    private init<C>(previous: WorkflowItem<F, Wrapped, C>,
                    modifierClosure: @escaping ((AnyFlowRepresentableView) -> Void),
                    flowPersistenceClosure: @escaping (AnyWorkflow.PassedArgs) -> FlowPersistence) {
        _wrapped = previous._wrapped
        _model = previous._model
        _launcher = previous._launcher
        _modifierClosure = State(initialValue: modifierClosure)
        _flowPersistenceClosure = State(initialValue: flowPersistenceClosure)
        let metadata = FlowRepresentableMetadata(F.self,
                                                 launchStyle: .new,
                                                 flowPersistence: flowPersistenceClosure,
                                                 flowRepresentableFactory: factory)
        _metadata = State(initialValue: metadata)
    }

    public init(_ item: F.Type) where Wrapped == Never, Content == F, Content: FlowRepresentable & View {
        let metadata = FlowRepresentableMetadata(Content.self,
                                                 launchStyle: .new,
                                                 flowPersistence: flowPersistenceClosure,
                                                 flowRepresentableFactory: factory)
        _metadata = State(initialValue: metadata)
    }

    #if (os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)) && canImport(UIKit)
    /// Creates a `WorkflowItem` from a `UIViewController`.
    @available(iOS 14.0, macOS 11, tvOS 14.0, *)
    public init<VC: FlowRepresentable & UIViewController>(_: VC.Type) where Content == ViewControllerWrapper<VC>, Wrapped == Never, F == ViewControllerWrapper<VC> {
        let metadata = FlowRepresentableMetadata(ViewControllerWrapper<VC>.self,
                                                 launchStyle: .new,
                                                 flowPersistence: flowPersistenceClosure,
                                                 flowRepresentableFactory: factory)
        _metadata = State(initialValue: metadata)
    }
    #endif

    init<A>(_ launcher: WorkflowLauncher<A>, isLaunched: Binding<Bool>, wrap: WorkflowItem<F, Wrapped, Content>) {
        _metadata = wrap._metadata
        _wrapped = wrap._wrapped
    }

    /**
     Provides a way to apply modifiers to your `FlowRepresentable` view.

     ### Important: The most recently defined (or last) use of this, is the only one that applies modifiers, unlike onAbandon or onFinish.
     */
    public func applyModifiers<V: View>(@ViewBuilder _ closure: @escaping (F) -> V) -> WorkflowItem<F, Wrapped, V> {
        WorkflowItem<F, Wrapped, V>(previous: self,
                                    modifierClosure: {
                                        // We are essentially casting this to itself, that cannot fail. (Famous last words)
                                        // swiftlint:disable:next force_cast
                                        let instance = $0.underlyingInstance as! F
                                        $0.changeUnderlyingView(to: closure(instance))
                                    },
                                    flowPersistenceClosure: flowPersistenceClosure)
    }

    private func resetWorkflow() {
        launcher.workflow.launch(withOrchestrationResponder: model, passedArgs: launcher.launchArgs)
    }

    private func ViewBuilder<V: View>(@ViewBuilder builder: () -> V) -> some View { builder() }

    private func factory(args: AnyWorkflow.PassedArgs) -> AnyFlowRepresentable {
        let afrv = AnyFlowRepresentableView(type: F.self, args: args)
        modifierClosure?(afrv)
        return afrv
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowItem: WorkflowModifier {
    func modify(workflow: AnyWorkflow) {
        workflow.append(metadata)
        (wrapped as? WorkflowModifier)?.modify(workflow: workflow)
    }
}

// swiftlint:disable line_length
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowItem where F.WorkflowOutput == Never {
    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable, W, C>(with closure: @autoclosure () -> WorkflowItem<FR, W, C>) -> WorkflowItem<F, WorkflowItem<FR, W, C>, Content> where Wrapped == Never, FR.WorkflowInput == Never {
        WorkflowItem<F, WorkflowItem<FR, W, C>, Content>(previous: self, closure)
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowItem where F.WorkflowOutput == AnyWorkflow.PassedArgs {
    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable, W, C>(with closure: @autoclosure () -> WorkflowItem<FR, W, C>) -> WorkflowItem<F, WorkflowItem<FR, W, C>, Content> where Wrapped == Never, FR.WorkflowInput == AnyWorkflow.PassedArgs {
        WorkflowItem<F, WorkflowItem<FR, W, C>, Content>(previous: self, closure)
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable, W, C>(with closure: @autoclosure () -> WorkflowItem<FR, W, C>) -> WorkflowItem<F, WorkflowItem<FR, W, C>, Content> where Wrapped == Never, FR.WorkflowInput == Never {
        WorkflowItem<F, WorkflowItem<FR, W, C>, Content>(previous: self, closure)
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable, W, C>(with closure: @autoclosure () -> WorkflowItem<FR, W, C>) -> WorkflowItem<F, WorkflowItem<FR, W, C>, Content> where Wrapped == Never {
        WorkflowItem<F, WorkflowItem<FR, W, C>, Content>(previous: self, closure)
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowItem {
    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable, W, C>(with closure: @autoclosure () -> WorkflowItem<FR, W, C>) -> WorkflowItem<F, WorkflowItem<FR, W, C>, Content> where Wrapped == Never, F.WorkflowOutput == FR.WorkflowInput {
        WorkflowItem<F, WorkflowItem<FR, W, C>, Content>(previous: self, closure)
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable, W, C>(with closure: @autoclosure () -> WorkflowItem<FR, W, C>) -> WorkflowItem<F, WorkflowItem<FR, W, C>, Content> where Wrapped == Never, FR.WorkflowInput == AnyWorkflow.PassedArgs {
        WorkflowItem<F, WorkflowItem<FR, W, C>, Content>(previous: self, closure)
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable, W, C>(with closure: @autoclosure () -> WorkflowItem<FR, W, C>) -> WorkflowItem<F, WorkflowItem<FR, W, C>, Content> where Wrapped == Never, FR.WorkflowInput == Never {
        WorkflowItem<F, WorkflowItem<FR, W, C>, Content>(previous: self, closure)
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowItem {
    // swiftlint:disable trailing_closure
    /// Sets persistence on the `FlowRepresentable` of the `WorkflowItem`.
    public func persistence(_ persistence: @escaping @autoclosure () -> FlowPersistence) -> Self {
        Self(previous: self,
             modifierClosure: modifierClosure ?? { _ in },
             flowPersistenceClosure: { _ in persistence() })
    }

    /// Sets persistence on the `FlowRepresentable` of the `WorkflowItem`.
    public func persistence(_ persistence: @escaping (F.WorkflowInput) -> FlowPersistence) -> Self {
        Self(previous: self,
             modifierClosure: modifierClosure ?? { _ in },
             flowPersistenceClosure: {
                guard case .args(let arg as F.WorkflowInput) = $0 else {
                    fatalError("Could not cast \(String(describing: $0)) to expected type: \(F.WorkflowInput.self)")
                }
                return persistence(arg)
             })
    }

    /// Sets persistence on the `FlowRepresentable` of the `WorkflowItem`.
    public func persistence(_ persistence: @escaping (F.WorkflowInput) -> FlowPersistence) -> Self where F.WorkflowInput == AnyWorkflow.PassedArgs {
        Self(previous: self,
             modifierClosure: modifierClosure ?? { _ in },
             flowPersistenceClosure: persistence)
    }

    /// Sets persistence on the `FlowRepresentable` of the `WorkflowItem`.
    public func persistence(_ persistence: @escaping () -> FlowPersistence) -> Self where F.WorkflowInput == Never {
        Self(previous: self,
             modifierClosure: modifierClosure ?? { _ in },
             flowPersistenceClosure: { _ in persistence() })
    }
    // swiftlint:enable trailing_closure
}

// swiftlint:enable line_length
