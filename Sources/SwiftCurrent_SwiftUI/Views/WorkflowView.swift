//
//  WorkflowView.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 2/21/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Combine
import SwiftUI
import SwiftCurrent

/**
 Used to build a `Workflow` in SwiftUI; Embed `WorkflowItem`s in a `WorkflowView` to create a SwiftUI view.

 ### Discussion
 The preferred method for creating a `Workflow` with SwiftUI is a combination of `WorkflowView` and `WorkflowItem`. Initialize with arguments if your first `FlowRepresentable` has an input type.

 #### Example
 ```swift
 WorkflowView(isLaunched: $isLaunched.animation(), launchingWith: "String in") {
     WorkflowItem(FirstView.self)
         .applyModifiers {
             $0.background(Color.gray)
             .transition(.slide)
             .animation(.spring())
         }
     WorkflowItem(SecondView.self)
         .persistence(.removedAfterProceeding)
         .applyModifiers {
             $0.SecondViewSpecificModifier()
             .padding(10)
             .background(Color.purple)
             .transition(.opacity)
             .animation(.easeInOut)
         }
 }
 .onAbandon { print("isLaunched is now false") }
 .onFinish { args in print("Finished 1: \(args)") }
 .onFinish { print("Finished 2: \($0)") }
 .background(Color.green)
 ```
 */
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct WorkflowView<Content: View>: View {
    @StateObject private var proxy = WorkflowProxy()
    @State private var id = UUID()
    @Binding private var isLaunched: Bool
    @State private var args: AnyWorkflow.PassedArgs
    @State private var onFinish = [(AnyWorkflow.PassedArgs) -> Void]()
    @State private var onAbandon = [() -> Void]()
    @State private var abandonOnPublisher: AnyPublisher<Void, Never> = Empty(completeImmediately: false).eraseToAnyPublisher()

    @WorkflowBuilder private var workflow: Content
    let inspection = Inspection<Self>() // needed?

    /**
     Creates a base for proceeding with a `WorkflowItem`.
     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
     - Parameter content: `WorkflowBuilder` consisting of `WorkflowItem`s that define your workflow.
     */
    public init(isLaunched: Binding<Bool> = .constant(true),
                @WorkflowBuilder content: () -> Content) {
        self.init(isLaunched: isLaunched, launchingWith: .none, content: content)
    }

    /**
     Creates a base for proceeding with a `WorkflowItem`.
     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
     - Parameter launchingWith: arguments passed to the first loaded `FlowRepresentable` in the underlying `Workflow`.
     - Parameter content: `WorkflowBuilder` consisting of `WorkflowItem`s that define your workflow.
     */
    public init<T>(isLaunched: Binding<Bool> = .constant(true),
                   launchingWith args: T,
                   @WorkflowBuilder content: () -> Content) {
        self.init(isLaunched: isLaunched, launchingWith: .args(args), content: content)
    }

    /**
     Creates a base for proceeding with a `WorkflowItem`.
     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
     - Parameter launchingWith: arguments passed to the first loaded `FlowRepresentable` in the underlying `Workflow`.
     - Parameter content: `WorkflowBuilder` consisting of `WorkflowItem`s that define your workflow.
     */
    public init(isLaunched: Binding<Bool> = .constant(true),
                launchingWith args: AnyWorkflow.PassedArgs,
                @WorkflowBuilder content: () -> Content) {
        workflow = content()
        _args = State(wrappedValue: args)
        _isLaunched = isLaunched
    }

    private init(current: Self,
                 onFinish: [(AnyWorkflow.PassedArgs) -> Void],
                 onAbandon: [() -> Void],
                 abandonOnPublisher: AnyPublisher<Void, Never>) {
        workflow = current.workflow
        _args = current._args
        _isLaunched = current._isLaunched
        _onFinish = State(wrappedValue: onFinish)
        _onAbandon = State(wrappedValue: onAbandon)
    }

    /// Adds an action to perform when this `Workflow` has finished.
    public func onFinish(_ closure: @escaping (AnyWorkflow.PassedArgs) -> Void) -> Self {
        var onFinish = self.onFinish
        onFinish.append(closure)
        return Self(current: self, onFinish: onFinish, onAbandon: onAbandon, abandonOnPublisher: abandonOnPublisher)
    }

    /// Adds an action to perform when this `Workflow` has abandoned.
    public func onAbandon(_ closure: @escaping () -> Void) -> Self {
        var onAbandon = self.onAbandon
        onAbandon.append(closure)
        return Self(current: self, onFinish: onFinish, onAbandon: onAbandon, abandonOnPublisher: abandonOnPublisher)
    }

    /// Subscribers to a combine publisher, when a value is emitted the workflow will abandon.
    public func abandonOn<P: Publisher>(_ publisher: P) -> Self where P.Failure == Never {
        Self(current: self, onFinish: onFinish, onAbandon: onAbandon, abandonOnPublisher: publisher.map { _ in () }.eraseToAnyPublisher())
    }

    public var body: some View {
        if isLaunched {
            workflow
                .environment(\.workflowArgs, args)
                .environment(\.workflowProxy, proxy)
                .environment(\.workflowHasProceeded, nil)
                .onReceive(abandonOnPublisher, perform: proxy.abandonWorkflow)
                .onReceive(proxy.abandonPublisher) {
                    isLaunched = false
                    onAbandon.forEach { $0() }
                    id = UUID()
                }
                .onReceive(proxy.onFinishPublisher, perform: finish)
                .onReceive(inspection.notice) { inspection.visit(self, $0) }
                .id(id)
        }
    }

    func finish(_ args: AnyWorkflow.PassedArgs?) {
        guard let args = args else { return }
        onFinish.forEach { $0(args) }
    }
}

//    /// Wraps content in a NavigationView.
//    public func embedInNavigationView<WI: _WorkflowItemProtocol>() -> Self where Content == WorkflowLauncher<WI> {
//        Self(self, newContent: _content.wrappedValue.embedInNavigationView())
//    }
