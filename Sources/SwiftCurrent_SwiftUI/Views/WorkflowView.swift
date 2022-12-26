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
    @State private var args: AnyWorkflow.PassedArgs
    @WorkflowBuilder private var workflow: Content
    #warning("Needed?")
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
    }

    private init(_ other: WorkflowView<Content>,
                 newContent: Content) {
        workflow = newContent
        _args = other._args
    }

    /// Adds an action to perform when this `Workflow` has finished.
    public func onFinish(_ closure: @escaping (AnyWorkflow.PassedArgs) -> Void) -> Self {
        self
//        Self(self, newContent: _content.wrappedValue.onFinish(closure: closure))
    }

    /// Adds an action to perform when this `Workflow` has abandoned.
    public func onAbandon(_ closure: @escaping () -> Void) -> Self {
        self
//        Self(self, newContent: _content.wrappedValue.onAbandon(closure: closure))
    }

    /// Subscribers to a combine publisher, when a value is emitted the workflow will abandon.
    public func abandonOn<P: Publisher>(_ publisher: P) -> Self where P.Failure == Never {
        self
//        Self(self, newContent: _content.wrappedValue.abandonOn(publisher))
    }

    public var body: some View {
        workflow
            .environment(\.workflowArgs, args)
            .onReceive(inspection.notice) { inspection.visit(self, $0) }
    }
}
//public struct WorkflowView<Content: View>: View {
//    @State var content: Content
//
//    let inspection = Inspection<Self>()
//
//    public var body: some View {
//        content
//            .onReceive(inspection.notice) { inspection.visit(self, $0) }
//    }
//
//    private static func itemToLaunch(from workflow: AnyWorkflow) -> AnyWorkflowItem {
//        let lastMetadata = workflow.last?.value.metadata as? ExtendedFlowRepresentableMetadata
//        let lastItem = lastMetadata?.workflowItemFactory(nil)
//
//        if let headItem = Self.findHeadItem(element: workflow.last, item: lastItem) {
//            return headItem
//        } else if let lastItem = lastItem {
//            return lastItem
//        }
//
//        fatalError("Workflow has no items to launch")
//    }
//
//    private static func findHeadItem(element: AnyWorkflow.Element?, item: AnyWorkflowItem?) -> AnyWorkflowItem? {
//        guard let previous = element?.previous,
//              let previousItem = (previous.value.metadata as? ExtendedFlowRepresentableMetadata)?.workflowItemFactory(item) else { return item }
//
//        return findHeadItem(element: previous, item: previousItem)
//    }
//
//    /**
//     Creates a base for proceeding with a `WorkflowItem`.
//     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
//     - Parameter content: `WorkflowBuilder` consisting of `WorkflowItem`s that define your workflow.
//     */
//    public init<WI: _WorkflowItemProtocol>(isLaunched: Binding<Bool> = .constant(true),
//                                           @WorkflowBuilder content: () -> WI) where Content == WorkflowLauncher<WI>, WI.FlowRepresentableType.WorkflowInput == Never {
//        self.init(isLaunched: isLaunched, startingArgs: .none, content: content)
//    }
//
//    /**
//     Creates a base for proceeding with a `WorkflowItem`.
//     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
//     - Parameter launchingWith: arguments passed to the first loaded `FlowRepresentable` in the underlying `Workflow`.
//     - Parameter content: `WorkflowBuilder` consisting of `WorkflowItem`s that define your workflow.
//     */
//    public init<WI: _WorkflowItemProtocol>(isLaunched: Binding<Bool> = .constant(true),
//                                           launchingWith args: WI.FlowRepresentableType.WorkflowInput,
//                                           @WorkflowBuilder content: () -> WI) where Content == WorkflowLauncher<WI> {
//        self.init(isLaunched: isLaunched, startingArgs: .args(args), content: content)
//    }
//
//    /**
//     Creates a base for proceeding with a `WorkflowItem`.
//     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
//     - Parameter launchingWith: arguments passed to the first loaded `FlowRepresentable` in the underlying `Workflow`.
//     - Parameter content: `WorkflowBuilder` consisting of `WorkflowItem`s that define your workflow.
//     */
//    public init<WI: _WorkflowItemProtocol>(isLaunched: Binding<Bool> = .constant(true),
//                                           launchingWith args: AnyWorkflow.PassedArgs,
//                                           @WorkflowBuilder content: () -> WI) where Content == WorkflowLauncher<WI>, WI.FlowRepresentableType.WorkflowInput == AnyWorkflow.PassedArgs {
//        self.init(isLaunched: isLaunched, startingArgs: args, content: content)
//    }
//
//    /**
//     Creates a base for proceeding with a `WorkflowItem`.
//     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
//     - Parameter launchingWith: arguments passed to the first loaded `FlowRepresentable` in the underlying `Workflow`.
//     - Parameter content: `WorkflowBuilder` consisting of `WorkflowItem`s that define your workflow.
//     */
//    public init<WI: _WorkflowItemProtocol>(isLaunched: Binding<Bool> = .constant(true),
//                                           launchingWith args: AnyWorkflow.PassedArgs,
//                                           @WorkflowBuilder content: () -> WI) where Content == WorkflowLauncher<WI> {
//        self.init(isLaunched: isLaunched, startingArgs: args, content: content)
//    }
//
//    /**
//     Creates a base for proceeding with a `WorkflowItem`.
//     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
//     - Parameter launchingWith: arguments passed to the first loaded `FlowRepresentable` in the underlying `Workflow`.
//     - Parameter content: `WorkflowBuilder` consisting of `WorkflowItem`s that define your workflow.
//     */
//    public init<A, WI: _WorkflowItemProtocol>(isLaunched: Binding<Bool> = .constant(true),
//                                              launchingWith args: A,
//                                              @WorkflowBuilder content: () -> WI) where Content == WorkflowLauncher<WI>, WI.FlowRepresentableType.WorkflowInput == AnyWorkflow.PassedArgs {
//        self.init(isLaunched: isLaunched, startingArgs: .args(args), content: content)
//    }
//
//    /**
//     Creates a base for proceeding with a `WorkflowItem`.
//     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
//     - Parameter launchingWith: arguments passed to the first loaded `FlowRepresentable` in the underlying `Workflow`.
//     - Parameter content: `WorkflowBuilder` consisting of `WorkflowItem`s that define your workflow.
//     */
//    public init<A, WI: _WorkflowItemProtocol>(isLaunched: Binding<Bool> = .constant(true),
//                                              launchingWith args: A,
//                                              @WorkflowBuilder content: () -> WI) where Content == WorkflowLauncher<WI>, WI.FlowRepresentableType.WorkflowInput == Never {
//        self.init(isLaunched: isLaunched, startingArgs: .args(args), content: content)
//    }
//
//    /**
//     Creates a base for proceeding with a `WorkflowItem`.
//     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
//     - Parameter content: `WorkflowBuilder` consisting of `WorkflowItem`s that define your workflow.
//     */
//    public init<WI: _WorkflowItemProtocol>(isLaunched: Binding<Bool> = .constant(true),
//                                           @WorkflowBuilder content: () -> WI) where Content == WorkflowLauncher<WI>, WI.FlowRepresentableType.WorkflowInput == AnyWorkflow.PassedArgs {
//        self.init(isLaunched: isLaunched, startingArgs: .none, content: content)
//    }
//
//    /**
//     Creates a base for proceeding with a `WorkflowItem`.
//     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
//     - Parameter startingArgs: arguments passed to the first loaded `FlowRepresentable` in the underlying `Workflow`.
//     - Parameter workflow: workflow to be launched; must contain `FlowRepresentable`s of type `View`
//     */
//    public init(isLaunched: Binding<Bool> = .constant(true),
//                launchingWith startingArgs: AnyWorkflow.PassedArgs = .none,
//                workflow: AnyWorkflow) where Content == WorkflowLauncher<WorkflowItemWrapper<AnyWorkflowItem, Never>> {
//        workflow.forEach {
//            assert($0.value.metadata is ExtendedFlowRepresentableMetadata, "It is possible the workflow was constructed incorrectly. This represents an internal error, please file a bug at https://github.com/wwt/SwiftCurrent/issues") // swiftlint:disable:this line_length
//        }
//
//        _content = State(wrappedValue: WorkflowLauncher(isLaunched: isLaunched, startingArgs: startingArgs) { Self.itemToLaunch(from: workflow) })
//    }
//
//    /**
//     Creates a base for proceeding with a `WorkflowItem`.
//     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
//     - Parameter startingArgs: arguments passed to the first loaded `FlowRepresentable` in the underlying `Workflow`.
//     - Parameter workflow: workflow to be launched; must contain `FlowRepresentable`s of type `View`
//     */
//    public init<A>(isLaunched: Binding<Bool> = .constant(true), launchingWith startingArgs: A, workflow: AnyWorkflow) where Content == WorkflowLauncher<WorkflowItemWrapper<AnyWorkflowItem, Never>> {
//        workflow.forEach {
//            assert($0.value.metadata is ExtendedFlowRepresentableMetadata, "It is possible the workflow was constructed incorrectly. This represents an internal error, please file a bug at https://github.com/wwt/SwiftCurrent/issues") // swiftlint:disable:this line_length
//        }
//
//        _content = State(wrappedValue: WorkflowLauncher(isLaunched: isLaunched, startingArgs: .args(startingArgs)) { Self.itemToLaunch(from: workflow) })
//    }
//
//    private init<WI: _WorkflowItemProtocol>(isLaunched: Binding<Bool>,
//                                            startingArgs: AnyWorkflow.PassedArgs,
//                                            @WorkflowBuilder content: () -> WI) where Content == WorkflowLauncher<WI> {
//        _content = State(wrappedValue: WorkflowLauncher(isLaunched: isLaunched, startingArgs: startingArgs, content: content))
//    }
//
//    private init<WI: _WorkflowItemProtocol>(_ other: WorkflowView<Content>,
//                                            newContent: Content) where Content == WorkflowLauncher<WI> {
//        _content = State(wrappedValue: newContent)
//    }
//
//    /// Adds an action to perform when this `Workflow` has finished.
//    public func onFinish<WI: _WorkflowItemProtocol>(_ closure: @escaping (AnyWorkflow.PassedArgs) -> Void) -> Self where Content == WorkflowLauncher<WI> {
//        Self(self, newContent: _content.wrappedValue.onFinish(closure: closure))
//    }
//
//    /// Adds an action to perform when this `Workflow` has abandoned.
//    public func onAbandon<WI: _WorkflowItemProtocol>(_ closure: @escaping () -> Void) -> Self where Content == WorkflowLauncher<WI> {
//        Self(self, newContent: _content.wrappedValue.onAbandon(closure: closure))
//    }
//
//    /// Subscribers to a combine publisher, when a value is emitted the workflow will abandon.
//    public func abandonOn<WI: _WorkflowItemProtocol, P: Publisher>(_ publisher: P) -> Self where Content == WorkflowLauncher<WI>, P.Failure == Never {
//        Self(self, newContent: _content.wrappedValue.abandonOn(publisher))
//    }
//
//    /// Wraps content in a NavigationView.
//    public func embedInNavigationView<WI: _WorkflowItemProtocol>() -> Self where Content == WorkflowLauncher<WI> {
//        Self(self, newContent: _content.wrappedValue.embedInNavigationView())
//    }
//}
