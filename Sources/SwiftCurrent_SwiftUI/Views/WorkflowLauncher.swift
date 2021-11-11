//
//  WorkflowLauncher.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Tyler Thompson on 8/21/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftUI
import SwiftCurrent

/**
 Used to build a `Workflow` in SwiftUI; call thenProceed to create a SwiftUI view.

 ### Discussion
 The preferred method for creating a `Workflow` with SwiftUI is a combination of `WorkflowLauncher` and `WorkflowItem`. Initialize with arguments if your first `FlowRepresentable` has an input type.

 #### Example
 ```swift
 WorkflowLauncher(isLaunched: $isLaunched.animation(), args: "String in") {
     thenProceed(with: FirstView.self) {
         thenProceed(with: SecondView.self)
             .persistence(.removedAfterProceeding)
             .applyModifiers {
                 $0.SecondViewSpecificModifier()
                     .padding(10)
                     .background(Color.purple)
                     .transition(.opacity)
                     .animation(.easeInOut)
             }
     }.applyModifiers {
         $0.background(Color.gray)
             .transition(.slide)
             .animation(.spring())
     }
 }
 .onAbandon { print("isLaunched is now false") }
 .onFinish { args in print("Finished 1: \(args)") }
 .onFinish { print("Finished 2: \($0)") }
 .background(Color.green)
 ```
 */
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct WorkflowLauncher<Content: View>: View {
    @State private var content: Content
    @State private var onFinish = [(AnyWorkflow.PassedArgs) -> Void]()
    @State private var onAbandon = [() -> Void]()
    @State private var shouldEmbedInNavView = false
    @Binding private var isLaunched: Bool

    @StateObject private var model: WorkflowViewModel
    @StateObject private var launcher: Launcher

    let inspection = Inspection<Self>()

    public var body: some View {
        ViewBuilder {
            if isLaunched {
                if shouldEmbedInNavView {
                    NavigationView {
                        workflowContent
                    }.preferredNavigationStyle()
                } else {
                    workflowContent
                }
            }
        }
        .onChange(of: isLaunched) { if $0 == false { resetWorkflow() } }
    }

    private var workflowContent: some View {
        content
            .environmentObject(model)
            .environmentObject(launcher)
            .onReceive(model.onFinishPublisher, perform: _onFinish)
            .onReceive(model.onAbandonPublisher) { onAbandon.forEach { $0() } }
            .onReceive(inspection.notice) { inspection.visit(self, $0) }
    }

    /**
     Creates a base for proceeding with a `WorkflowItem`.
     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
     - Parameter workflow: workflow to be launched; must contain `FlowRepresentable`s of type `View`
     */
    public init<F: FlowRepresentable & View>(isLaunched: Binding<Bool>, workflow: Workflow<F>) where Content == AnyWorkflowItem {
        self.init(isLaunched: isLaunched, startingArgs: .none, workflow: AnyWorkflow(workflow))
    }

    /**
     Creates a base for proceeding with a `WorkflowItem`.
     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
     - Parameter startingArgs: arguments passed to the first loaded `FlowRepresentable` in the underlying `Workflow`.
     - Parameter workflow: workflow to be launched; must contain `FlowRepresentable`s of type `View`
     */
    public init<F: FlowRepresentable & View>(isLaunched: Binding<Bool>, startingArgs: AnyWorkflow.PassedArgs, workflow: Workflow<F>) where Content == AnyWorkflowItem {
        self.init(isLaunched: isLaunched, startingArgs: startingArgs, workflow: AnyWorkflow(workflow))
    }

    private init(isLaunched: Binding<Bool>, startingArgs: AnyWorkflow.PassedArgs, workflow: AnyWorkflow) where Content == AnyWorkflowItem {
        workflow.forEach {
            assert($0.value.metadata is ExtendedFlowRepresentableMetadata)
        }
        _isLaunched = isLaunched
        let model = WorkflowViewModel(isLaunched: isLaunched, launchArgs: startingArgs)
        _model = StateObject(wrappedValue: model)
        _launcher = StateObject(wrappedValue: Launcher(workflow: workflow,
                                                       responder: model,
                                                       launchArgs: startingArgs))
        _content = State(wrappedValue: WorkflowLauncher.itemToLaunch(from: workflow))
    }

    /**
     Creates a base for proceeding with a `WorkflowItem`.
     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
     - Parameter content: closure that holds the `WorkflowItem`
     */
    public init<F, W, C>(isLaunched: Binding<Bool>, content: () -> Content) where Content == WorkflowItem<F, W, C>, F.WorkflowInput == Never {
        self.init(isLaunched: isLaunched, startingArgs: .none, content: content())
    }

    /**
     Creates a base for proceeding with a `WorkflowItem`.
     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
     - Parameter startingArgs: arguments passed to the first loaded `FlowRepresentable` in the underlying `Workflow`.
     - Parameter content: closure that holds the `WorkflowItem`
     */
    public init<A, F, W, C>(isLaunched: Binding<Bool>, startingArgs: A, content: () -> Content) where Content == WorkflowItem<F, W, C>, F.WorkflowInput == Never {
        self.init(isLaunched: isLaunched, startingArgs: .args(startingArgs), content: content())
    }

    /**
     Creates a base for proceeding with a `WorkflowItem`.
     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
     - Parameter startingArgs: arguments passed to the first loaded `FlowRepresentable` in the underlying `Workflow`.
     - Parameter content: closure that holds the `WorkflowItem`
     */
    public init<F, W, C>(isLaunched: Binding<Bool>, startingArgs: F.WorkflowInput, content: () -> Content) where Content == WorkflowItem<F, W, C> {
        self.init(isLaunched: isLaunched, startingArgs: .args(startingArgs), content: content())
    }

    /**
     Creates a base for proceeding with a `WorkflowItem`.
     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
     - Parameter startingArgs: arguments passed to the first loaded `FlowRepresentable` in the underlying `Workflow`.
     - Parameter content: closure that holds the `WorkflowItem`
     */
    public init<F, W, C>(isLaunched: Binding<Bool>, startingArgs: F.WorkflowInput = .none, content: () -> Content) where Content == WorkflowItem<F, W, C>, F.WorkflowInput == AnyWorkflow.PassedArgs {
        self.init(isLaunched: isLaunched, startingArgs: startingArgs, content: content())
    }

    /**
     Creates a base for proceeding with a `WorkflowItem`.
     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
     - Parameter startingArgs: arguments passed to the first loaded `FlowRepresentable` in the underlying `Workflow`.
     - Parameter content: closure that holds the `WorkflowItem`
     */
    public init<F, W, C>(isLaunched: Binding<Bool>, startingArgs: AnyWorkflow.PassedArgs, content: () -> Content) where Content == WorkflowItem<F, W, C> {
        self.init(isLaunched: isLaunched, startingArgs: startingArgs, content: content())
    }

    /**
     Creates a base for proceeding with a `WorkflowItem`.
     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
     - Parameter startingArgs: arguments passed to the first loaded `FlowRepresentable` in the underlying `Workflow`.
     - Parameter content: closure that holds the `WorkflowItem`
     */
    public init<A, F, W, C>(isLaunched: Binding<Bool>, startingArgs: A, content: () -> Content) where Content == WorkflowItem<F, W, C>, F.WorkflowInput == AnyWorkflow.PassedArgs {
        self.init(isLaunched: isLaunched, startingArgs: .args(startingArgs), content: content())
    }

    private init(current: Self, shouldEmbedInNavView: Bool, onFinish: [(AnyWorkflow.PassedArgs) -> Void], onAbandon: [() -> Void]) {
        _model = current._model
        _launcher = current._launcher
        _content = current._content
        _isLaunched = current._isLaunched
        _shouldEmbedInNavView = State(initialValue: shouldEmbedInNavView)
        _onFinish = State(initialValue: onFinish)
        _onAbandon = State(initialValue: onAbandon)
    }

    private init<F, W, C>(isLaunched: Binding<Bool>, startingArgs: AnyWorkflow.PassedArgs, content: Content) where Content == WorkflowItem<F, W, C> {
        _isLaunched = isLaunched
        let wf = AnyWorkflow.empty
        content.modify(workflow: wf)
        let model = WorkflowViewModel(isLaunched: isLaunched, launchArgs: startingArgs)
        _model = StateObject(wrappedValue: model)
        _launcher = StateObject(wrappedValue: Launcher(workflow: wf,
                                                       responder: model,
                                                       launchArgs: startingArgs))
        _content = State(wrappedValue: content)
    }

    private func resetWorkflow() {
        launcher.workflow.launch(withOrchestrationResponder: model, passedArgs: launcher.launchArgs)
    }

    private func _onFinish(_ args: AnyWorkflow.PassedArgs?) {
        guard let args = args else { return }
        onFinish.forEach { $0(args) }
    }

    private static func itemToLaunch(from workflow: AnyWorkflow) -> AnyWorkflowItem {
        let lastMetadata = workflow.last?.value.metadata as? ExtendedFlowRepresentableMetadata
        let lastItem = lastMetadata?.workflowItemFactory(nil)

        if let headItem = WorkflowLauncher.findHeadItem(element: workflow.last, item: lastItem) {
            return headItem
        } else if let lastItem = lastItem {
            return lastItem
        }

        fatalError("Workflow has no items to launch")
    }

    private static func findHeadItem(element: AnyWorkflow.Element?, item: AnyWorkflowItem?) -> AnyWorkflowItem? {
        guard let previous = element?.previous,
              let previousItem = (previous.value.metadata as? ExtendedFlowRepresentableMetadata)?.workflowItemFactory(item) else { return item }

        return findHeadItem(element: previous, item: previousItem)
    }

    /// Adds an action to perform when this `Workflow` has finished.
    public func onFinish(closure: @escaping (AnyWorkflow.PassedArgs) -> Void) -> Self {
        var onFinish = self.onFinish
        onFinish.append(closure)
        return Self(current: self, shouldEmbedInNavView: shouldEmbedInNavView, onFinish: onFinish, onAbandon: onAbandon)
    }

    /// Adds an action to perform when this `Workflow` has abandoned.
    public func onAbandon(closure: @escaping () -> Void) -> Self {
        var onAbandon = self.onAbandon
        onAbandon.append(closure)
        return Self(current: self, shouldEmbedInNavView: shouldEmbedInNavView, onFinish: onFinish, onAbandon: onAbandon)
    }

    /// Wraps content in a NavigationView.
    public func embedInNavigationView() -> Self {
        Self(current: self, shouldEmbedInNavView: true, onFinish: onFinish, onAbandon: onAbandon)
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension View {
    func preferredNavigationStyle() -> some View {
        #if (os(iOS) || os(tvOS) || os(watchOS) || targetEnvironment(macCatalyst))
        return navigationViewStyle(StackNavigationViewStyle())
        #else
        return navigationViewStyle(DefaultNavigationViewStyle())
        #endif
    }
}
