//
//  WorkflowView.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 2/21/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

#warning("FIXME")
// swiftlint:disable all

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
    @State var content: Content

    let inspection = Inspection<Self>()

    public var body: some View {
        content
            .onReceive(inspection.notice) { inspection.visit(self, $0) }
    }

    /**
     Creates a base for proceeding with a `WorkflowItem`.
     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
     - Parameter content: `WorkflowBuilder` consisting of `WorkflowItem`s that define your workflow.
     */
    public init<WI: _WorkflowItemProtocol>(isLaunched: Binding<Bool> = .constant(true),
                                           @WorkflowBuilder content: () -> WI) where Content == WorkflowLauncher<WI>, WI.F.WorkflowInput == Never {
        self.init(isLaunched: isLaunched, startingArgs: .none, content: content())
    }

    /**
     Creates a base for proceeding with a `WorkflowItem`.
     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
     - Parameter launchingWith: arguments passed to the first loaded `FlowRepresentable` in the underlying `Workflow`.
     - Parameter content: `WorkflowBuilder` consisting of `WorkflowItem`s that define your workflow.
     */
    public init<WI: _WorkflowItemProtocol>(isLaunched: Binding<Bool> = .constant(true),
                                           launchingWith args: WI.F.WorkflowInput,
                                           @WorkflowBuilder content: () -> WI) where Content == WorkflowLauncher<WI> {
        self.init(isLaunched: isLaunched, startingArgs: .args(args), content: content())
    }

    /**
     Creates a base for proceeding with a `WorkflowItem`.
     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
     - Parameter launchingWith: arguments passed to the first loaded `FlowRepresentable` in the underlying `Workflow`.
     - Parameter content: `WorkflowBuilder` consisting of `WorkflowItem`s that define your workflow.
     */
    public init<WI: _WorkflowItemProtocol>(isLaunched: Binding<Bool> = .constant(true),
                         launchingWith args: AnyWorkflow.PassedArgs,
                                           @WorkflowBuilder content: () -> WI) where Content == WorkflowLauncher<WI>, WI.F.WorkflowInput == AnyWorkflow.PassedArgs {
        self.init(isLaunched: isLaunched, startingArgs: args, content: content())
    }

    /**
     Creates a base for proceeding with a `WorkflowItem`.
     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
     - Parameter launchingWith: arguments passed to the first loaded `FlowRepresentable` in the underlying `Workflow`.
     - Parameter content: `WorkflowBuilder` consisting of `WorkflowItem`s that define your workflow.
     */
    public init<WI: _WorkflowItemProtocol>(isLaunched: Binding<Bool> = .constant(true),
                         launchingWith args: AnyWorkflow.PassedArgs,
                                           @WorkflowBuilder content: () -> WI) where Content == WorkflowLauncher<WI> {
        self.init(isLaunched: isLaunched, startingArgs: args, content: content())
    }

    /**
     Creates a base for proceeding with a `WorkflowItem`.
     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
     - Parameter launchingWith: arguments passed to the first loaded `FlowRepresentable` in the underlying `Workflow`.
     - Parameter content: `WorkflowBuilder` consisting of `WorkflowItem`s that define your workflow.
     */
    public init<A, WI: _WorkflowItemProtocol>(isLaunched: Binding<Bool> = .constant(true),
                            launchingWith args: A,
                                              @WorkflowBuilder content: () -> WI) where Content == WorkflowLauncher<WI>, WI.F.WorkflowInput == AnyWorkflow.PassedArgs {
        self.init(isLaunched: isLaunched, startingArgs: .args(args), content: content())
    }

    private init<WI: _WorkflowItemProtocol>(isLaunched: Binding<Bool>,
                          startingArgs: AnyWorkflow.PassedArgs,
                                            content: WI) where Content == WorkflowLauncher<WI> {
        _content = State(wrappedValue: WorkflowLauncher(isLaunched: isLaunched, startingArgs: startingArgs) { content })
    }

    private init<WI: _WorkflowItemProtocol>(_ other: WorkflowView<Content>,
                                            newContent: Content) where Content == WorkflowLauncher<WI> {
        _content = State(wrappedValue: newContent)
    }

    /// Adds an action to perform when this `Workflow` has finished.
    public func onFinish<WI: _WorkflowItemProtocol>(_ closure: @escaping (AnyWorkflow.PassedArgs) -> Void) -> Self where Content == WorkflowLauncher<WI> {
        Self(self, newContent: _content.wrappedValue.onFinish(closure: closure))
    }

    /// Adds an action to perform when this `Workflow` has abandoned.
    public func onAbandon<WI: _WorkflowItemProtocol>(_ closure: @escaping () -> Void) -> Self where Content == WorkflowLauncher<WI> {
        Self(self, newContent: _content.wrappedValue.onAbandon(closure: closure))
    }

    /// Wraps content in a NavigationView.
    public func embedInNavigationView<WI: _WorkflowItemProtocol>() -> Self where Content == WorkflowLauncher<WI> {
        Self(self, newContent: _content.wrappedValue.embedInNavigationView())
    }
}
