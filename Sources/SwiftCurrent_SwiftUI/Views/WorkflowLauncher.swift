//
//  WorkflowLauncher.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 7/12/21.
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
///         if true { // Enabling transition animation
///             $0.background(Color.gray)
///                 .transition(.slide)
///                 .animation(.spring())
///         }
///     })
///     .thenProceed(with: WorkflowItem(SecondView.self)
///                     .persistence(.removedAfterProceeding)
///                     .applyModifiers {
///         if true {
///             $0.SecondViewSpecificModifier()
///                 .padding(10)
///                 .background(Color.purple)
///                 .transition(.opacity)
///                 .animation(.easeInOut)
///         }
///     })
///     .onAbandon { print("isLaunched is now false") }
///     .onFinish { args in print("Finished 1: \(args)") }
///     .onFinish { print("Finished 2: \($0)") }
///     .background(Color.green)
///  ```
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct WorkflowLauncher<Args> {
    @Binding private var isLaunched: Bool
    var passedArgs = AnyWorkflow.PassedArgs.none
    var onFinish = [(AnyWorkflow.PassedArgs) -> Void]()
    var onAbandon = [() -> Void]()

    /**
     Creates a base for proceeding with a `WorkflowItem`.
     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
     */
    public init(isLaunched: Binding<Bool>) where Args == Never {
        _isLaunched = isLaunched
    }

    /**
     Creates a base for proceeding with a `WorkflowItem`.
     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
     - Parameter startingArgs: arguments passed to the first `FlowRepresentable` in the underlying `Workflow`.
     */
    public init(isLaunched: Binding<Bool>, startingArgs args: Args) {
        _isLaunched = isLaunched
        if let args = args as? AnyWorkflow.PassedArgs {
            passedArgs = args
        } else {
            passedArgs = .args(args)
        }
    }

    private init(isLaunched: Binding<Bool>,
                 startingArgs: AnyWorkflow.PassedArgs,
                 onFinish: [(AnyWorkflow.PassedArgs) -> Void],
                 onAbandon: [() -> Void]) {
        _isLaunched = isLaunched
        passedArgs = startingArgs
        self.onFinish = onFinish
        self.onAbandon = onAbandon
    }

    /// Adds an action to perform when this `Workflow` has finished.
    public func onFinish(closure: @escaping (AnyWorkflow.PassedArgs) -> Void) -> Self {
        var onFinish = self.onFinish
        onFinish.append(closure)
        return Self(isLaunched: _isLaunched,
                    startingArgs: passedArgs,
                    onFinish: onFinish,
                    onAbandon: onAbandon)
    }

    /// Adds an action to perform when this `Workflow` has abandoned.
    public func onAbandon(closure: @escaping () -> Void) -> Self {
        var onAbandon = self.onAbandon
        onAbandon.append(closure)
        return Self(isLaunched: _isLaunched,
                    startingArgs: passedArgs,
                    onFinish: onFinish,
                    onAbandon: onAbandon)
    }

    public func thenProceed<A, W, C>(with closure: @autoclosure () -> WorkflowItem<A, W, C>) -> WorkflowItem<Args, W, C> {
        WorkflowItem(self, isLaunched: _isLaunched, wrap: closure())
    }
}

//@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
//extension WorkflowLauncher where Args == Never {
//    /**
//     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
//     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
//     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
//     */
//    public func thenProceed<FR: FlowRepresentable & View, T>(with item: WorkflowItem<FR, T>) -> ModifiedWorkflowView<FR.WorkflowOutput, Never, T> where FR.WorkflowInput == Never {
//        ModifiedWorkflowView(self, isLaunched: _isLaunched, item: item)
//    }
//}
//
//@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
//extension WorkflowLauncher where Args == AnyWorkflow.PassedArgs {
//    /**
//     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
//     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
//     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
//     */
//    public func thenProceed<FR: FlowRepresentable & View, T>(with item: WorkflowItem<FR, T>) -> ModifiedWorkflowView<FR.WorkflowOutput, Never, T> where FR.WorkflowInput == AnyWorkflow.PassedArgs {
//        ModifiedWorkflowView(self, isLaunched: _isLaunched, item: item)
//    }
//
//    /**
//     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
//     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
//     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
//     */
//    public func thenProceed<FR: FlowRepresentable & View, T>(with item: WorkflowItem<FR, T>) -> ModifiedWorkflowView<FR.WorkflowOutput, Never, T> {
//        ModifiedWorkflowView(self, isLaunched: _isLaunched, item: item)
//    }
//}
//
//@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
//extension WorkflowLauncher {
//    /**
//     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
//     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
//     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
//     */
//    public func thenProceed<FR: FlowRepresentable & View, T>(with item: WorkflowItem<FR, T>) -> ModifiedWorkflowView<FR.WorkflowOutput, Never, T> where Args == FR.WorkflowInput {
//        ModifiedWorkflowView(self, isLaunched: _isLaunched, item: item)
//    }
//
//    /**
//     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
//     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
//     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
//     */
//    public func thenProceed<FR: FlowRepresentable & View, T>(with item: WorkflowItem<FR, T>) -> ModifiedWorkflowView<FR.WorkflowOutput, Never, T> where FR.WorkflowInput == AnyWorkflow.PassedArgs {
//        ModifiedWorkflowView(self, isLaunched: _isLaunched, item: item)
//    }
//}
