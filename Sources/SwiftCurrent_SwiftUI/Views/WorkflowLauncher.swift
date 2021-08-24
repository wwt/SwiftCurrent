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
 */
/// ```swift
/// WorkflowLauncher(isLaunched: $isLaunched.animation(), args: "String in")
///     .thenProceed(with: WorkflowItem(FirstView.self)
///                     .applyModifiers {
///             $0.background(Color.gray)
///                 .transition(.slide)
///                 .animation(.spring())
///     }
///     .thenProceed(with: WorkflowItem(SecondView.self)
///                     .persistence(.removedAfterProceeding)
///                     .applyModifiers {
///             $0.SecondViewSpecificModifier()
///                 .padding(10)
///                 .background(Color.purple)
///                 .transition(.opacity)
///                 .animation(.easeInOut)
///     }))
///     .onAbandon { print("isLaunched is now false") }
///     .onFinish { args in print("Finished 1: \(args)") }
///     .onFinish { print("Finished 2: \($0)") }
///     .background(Color.green)
///  ```
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct WorkflowLauncher<Content: View>: View {
    @State private var content: Content
    @StateObject private var model: WorkflowViewModel
    @StateObject private var launcher: Launcher
    @State private var onFinish = [(AnyWorkflow.PassedArgs) -> Void]()
    @State private var onAbandon = [() -> Void]()

    let inspection = Inspection<Self>()

    public var body: some View {
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
     */
    public init<F, W, C>(isLaunched: Binding<Bool>, content: () -> Content) where Content == WorkflowItem<F, W, C>, F.WorkflowInput == Never {
        self.init(isLaunched: isLaunched, startingArgs: .none, content: content())
    }

    /**
     Creates a base for proceeding with a `WorkflowItem`.
     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
     - Parameter startingArgs: arguments passed to the first `FlowRepresentable` in the underlying `Workflow`.
     */
    public init<F, W, C>(isLaunched: Binding<Bool>, startingArgs: F.WorkflowInput, content: () -> Content) where Content == WorkflowItem<F, W, C> {
        self.init(isLaunched: isLaunched, startingArgs: .args(startingArgs), content: content())
    }

    /**
     Creates a base for proceeding with a `WorkflowItem`.
     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
     - Parameter startingArgs: arguments passed to the first `FlowRepresentable` in the underlying `Workflow`.
     */
    public init<F, W, C>(isLaunched: Binding<Bool>, startingArgs: F.WorkflowInput = .none, content: () -> Content) where Content == WorkflowItem<F, W, C>, F.WorkflowInput == AnyWorkflow.PassedArgs {
        self.init(isLaunched: isLaunched, startingArgs: startingArgs, content: content())
    }

    /**
     Creates a base for proceeding with a `WorkflowItem`.
     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
     - Parameter startingArgs: arguments passed to the first `FlowRepresentable` in the underlying `Workflow`.
     */
    public init<A, F, W, C>(isLaunched: Binding<Bool>, startingArgs: A, content: () -> Content) where Content == WorkflowItem<F, W, C>, F.WorkflowInput == AnyWorkflow.PassedArgs {
        self.init(isLaunched: isLaunched, startingArgs: .args(startingArgs), content: content())
    }

    private init(current: Self, onFinish: [(AnyWorkflow.PassedArgs) -> Void], onAbandon: [() -> Void]) {
        _model = current._model
        _launcher = current._launcher
        _content = current._content
        _onFinish = State(initialValue: onFinish)
        _onAbandon = State(initialValue: onAbandon)
    }

    private init<F, W, C>(isLaunched: Binding<Bool>, startingArgs: AnyWorkflow.PassedArgs, content: Content) where Content == WorkflowItem<F, W, C> {
        let wf = AnyWorkflow.empty
        content.modify(workflow: wf)
        let model = WorkflowViewModel(isLaunched: isLaunched, launchArgs: startingArgs)
        _model = StateObject(wrappedValue: model)
        _launcher = StateObject(wrappedValue: Launcher(workflow: wf,
                                                       responder: model,
                                                       launchArgs: startingArgs))
        _content = State(wrappedValue: content)
    }

    private func _onFinish(_ args: AnyWorkflow.PassedArgs?) {
        guard let args = args else { return }
        onFinish.forEach { $0(args) }
    }

    /// Adds an action to perform when this `Workflow` has finished.
    public func onFinish(closure: @escaping (AnyWorkflow.PassedArgs) -> Void) -> Self {
        var onFinish = self.onFinish
        onFinish.append(closure)
        return Self(current: self, onFinish: onFinish, onAbandon: onAbandon)
    }

    /// Adds an action to perform when this `Workflow` has abandoned.
    public func onAbandon(closure: @escaping () -> Void) -> Self {
        var onAbandon = self.onAbandon
        onAbandon.append(closure)
        return Self(current: self, onFinish: onFinish, onAbandon: onAbandon)
    }
}
