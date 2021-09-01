//
//  WorkflowItem.swift
//  SwiftCurrent_SwiftUI
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
 A concrete type used to modify a `FlowRepresentable` in a workflow.
 ### Discussion
 `WorkflowItem` gives you the ability to specify changes you'd like to apply to a specific `FlowRepresentable` when it is time to present it in a `Workflow`. You should create `WorkflowItem`s inside a `thenProceed(with:)` call on `WorkflowLauncher`.
 #### Example
 ```swift
 thenProceed(FirstView.self)
            .persistence(.removedAfterProceeding) // affects only FirstView
            .applyModifiers {
                $0.background(Color.gray) // $0 is a FirstView instance
                    .transition(.slide)
                    .animation(.spring())
            }
  ```
 */
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct WorkflowItem<F: FlowRepresentable & View, Wrapped: View, Content: View>: View {
    // These need to be state variables to survive SwiftUI re-rendering. Change under penalty of torture BY the codebase you modified.
    @State private var content: Content?
    @State private var wrapped: Wrapped?
    @State private var metadata: FlowRepresentableMetadata!
    @State private var modifierClosure: ((AnyFlowRepresentableView) -> Void)?
    @State private var flowPersistenceClosure: (AnyWorkflow.PassedArgs) -> FlowPersistence = { _ in .default }
    @State private var launchStyle: LaunchStyle.SwiftUI.PresentationType = .default
    @State private var persistence: FlowPersistence = .default
    @State private var elementRef: AnyWorkflow.Element?
    @State private var isActive = false
    @EnvironmentObject private var model: WorkflowViewModel
    @EnvironmentObject private var launcher: Launcher
    @Environment(\.presentationMode) var presentation

    let inspection = Inspection<Self>()

    public var body: some View {
        ViewBuilder {
            if launchStyle == .navigationLink, let content = content {
                content.navLink(to: nextView, isActive: $isActive)
            } else if (wrapped as? WorkflowItemPresentable)?.workflowLaunchStyle == .modal, let content = content {
                content.testableSheet(isPresented: $isActive) { nextView }
            } else if (wrapped as? WorkflowItemPresentable)?.workflowLaunchStyle == .modal(.fullScreenCover), let content = content {
                content.fullScreenCover(isPresented: $isActive) { nextView }
            } else if let body = model.body?.extractErasedView() as? Content, elementRef == nil || elementRef === model.body, launchStyle != .navigationLink {
                content ?? body
            } else {
                nextView
            }
        }
        .onReceive(model.$body, perform: activateIfNeeded)
        .onReceive(model.$body, perform: proceedInWorkflow)
        .onReceive(model.onBackUpPublisher, perform: backUpInWorkflow)
        .onReceive(inspection.notice) { inspection.visit(self, $0) }
    }

    @ViewBuilder private var nextView: some View {
        wrapped?.environmentObject(model).environmentObject(launcher)
    }

    private init<A, W, C, A1, W1, C1>(previous: WorkflowItem<A, W, C>, _ closure: () -> Wrapped) where Wrapped == WorkflowItem<A1, W1, C1> {
        let wrapped = closure()
        _wrapped = State(initialValue: wrapped)
        _metadata = previous._metadata
        _modifierClosure = previous._modifierClosure
        _flowPersistenceClosure = previous._flowPersistenceClosure
        _launchStyle = previous._launchStyle
    }

    private init<C>(previous: WorkflowItem<F, Wrapped, C>,
                    launchStyle: LaunchStyle.SwiftUI.PresentationType,
                    modifierClosure: @escaping ((AnyFlowRepresentableView) -> Void),
                    flowPersistenceClosure: @escaping (AnyWorkflow.PassedArgs) -> FlowPersistence) {
        _wrapped = previous._wrapped
        _modifierClosure = State(initialValue: modifierClosure)
        _flowPersistenceClosure = State(initialValue: flowPersistenceClosure)
        _launchStyle = State(initialValue: launchStyle)
        let metadata = FlowRepresentableMetadata(F.self,
                                                 launchStyle: launchStyle.rawValue,
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

    init(_ item: F.Type, wrapped: () -> Wrapped) where Content == F, Content: FlowRepresentable & View {
        let metadata = FlowRepresentableMetadata(Content.self,
                                                 launchStyle: .new,
                                                 flowPersistence: flowPersistenceClosure,
                                                 flowRepresentableFactory: factory)
        _metadata = State(initialValue: metadata)
        _wrapped = State(initialValue: wrapped())
    }

    #if (os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)) && canImport(UIKit)
    /// Creates a `WorkflowItem` from a `UIViewController`.
    @available(iOS 14.0, macOS 11, tvOS 14.0, *)
    init<VC: FlowRepresentable & UIViewController>(_: VC.Type) where Content == ViewControllerWrapper<VC>, Wrapped == Never, F == ViewControllerWrapper<VC> {
        let metadata = FlowRepresentableMetadata(ViewControllerWrapper<VC>.self,
                                                 launchStyle: .new,
                                                 flowPersistence: flowPersistenceClosure,
                                                 flowRepresentableFactory: factory)
        _metadata = State(initialValue: metadata)
    }

    /// Creates a `WorkflowItem` from a `UIViewController`.
    @available(iOS 14.0, macOS 11, tvOS 14.0, *)
    init<VC: FlowRepresentable & UIViewController>(_: VC.Type, wrapped: () -> Wrapped) where Content == ViewControllerWrapper<VC>, F == ViewControllerWrapper<VC> {
        let wrapped = wrapped()
        _wrapped = State(initialValue: wrapped)
        let metadata = FlowRepresentableMetadata(ViewControllerWrapper<VC>.self,
                                                 launchStyle: .new,
                                                 flowPersistence: flowPersistenceClosure,
                                                 flowRepresentableFactory: factory)
        _metadata = State(initialValue: metadata)
    }
    #endif

    /**
     Provides a way to apply modifiers to your `FlowRepresentable` view.
     ### Important: The most recently defined (or last) use of this, is the only one that applies modifiers, unlike onAbandon or onFinish.
     */
    public func applyModifiers<V: View>(@ViewBuilder _ closure: @escaping (F) -> V) -> WorkflowItem<F, Wrapped, V> {
        WorkflowItem<F, Wrapped, V>(previous: self,
                                    launchStyle: launchStyle,
                                    modifierClosure: {
                                        // We are essentially casting this to itself, that cannot fail. (Famous last words)
                                        // swiftlint:disable:next force_cast
                                        let instance = $0.underlyingInstance as! F
                                        $0.changeUnderlyingView(to: closure(instance))
                                    },
                                    flowPersistenceClosure: flowPersistenceClosure)
    }

    private func ViewBuilder<V: View>(@ViewBuilder builder: () -> V) -> some View { builder() }

    private func factory(args: AnyWorkflow.PassedArgs) -> AnyFlowRepresentable {
        let afrv = AnyFlowRepresentableView(type: F.self, args: args)
        modifierClosure?(afrv)
        return afrv
    }

    private func activateIfNeeded(element: AnyWorkflow.Element?) {
        if elementRef != nil, elementRef === element?.previouslyLoadedElement {
            isActive = true
        }
    }

    private func backUpInWorkflow(element: AnyWorkflow.Element?) {
        // We have found no satisfactory way to test this...we haven't even really found unsatisfactory ways to test it.
        // See: https://github.com/nalexn/ViewInspector/issues/131
        if elementRef === element {
            presentation.wrappedValue.dismiss()
        }
    }

    private func proceedInWorkflow(element: AnyWorkflow.Element?) {
        if let body = element?.extractErasedView() as? Content, elementRef === element || elementRef == nil {
            elementRef = element
            content = body
            persistence = element?.value.metadata.persistence ?? .default
        } else if persistence == .removedAfterProceeding {
            content = nil
            elementRef = nil
        }
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowItem: WorkflowItemPresentable {
    var workflowLaunchStyle: LaunchStyle.SwiftUI.PresentationType {
        launchStyle
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowItem: WorkflowModifier {
    func modify(workflow: AnyWorkflow) {
        workflow.append(metadata)
        (wrapped as? WorkflowModifier)?.modify(workflow: workflow)
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowItem {
    // swiftlint:disable trailing_closure
    /// Sets persistence on the `FlowRepresentable` of the `WorkflowItem`.
    public func persistence(_ persistence: @escaping @autoclosure () -> FlowPersistence) -> Self {
        Self(previous: self,
             launchStyle: launchStyle,
             modifierClosure: modifierClosure ?? { _ in },
             flowPersistenceClosure: { _ in persistence() })
    }

    /// Sets persistence on the `FlowRepresentable` of the `WorkflowItem`.
    public func persistence(_ persistence: @escaping (F.WorkflowInput) -> FlowPersistence) -> Self {
        Self(previous: self,
             launchStyle: launchStyle,
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
             launchStyle: launchStyle,
             modifierClosure: modifierClosure ?? { _ in },
             flowPersistenceClosure: persistence)
    }

    /// Sets persistence on the `FlowRepresentable` of the `WorkflowItem`.
    public func persistence(_ persistence: @escaping () -> FlowPersistence) -> Self where F.WorkflowInput == Never {
        Self(previous: self,
             launchStyle: launchStyle,
             modifierClosure: modifierClosure ?? { _ in },
             flowPersistenceClosure: { _ in persistence() })
    }
    // swiftlint:enable trailing_closure
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowItem {
    /// Sets the presentationType on the `FlowRepresentable` of the `WorkflowItem`.
    public func presentationType(_ presentationType: @escaping @autoclosure () -> LaunchStyle.SwiftUI.PresentationType) -> Self {
        Self(previous: self,
             launchStyle: presentationType(),
             modifierClosure: modifierClosure ?? { _ in },
             flowPersistenceClosure: flowPersistenceClosure)
    }
}
// swiftlint:enable line_length
