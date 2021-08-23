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
public struct WorkflowLauncher<Args> {
    @Binding var isLaunched: Bool
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
}

// swiftlint:disable line_length
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowLauncher where Args == Never {
    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable, W, C>(with closure: @autoclosure () -> WorkflowItem<FR, W, C>) -> WorkflowLauncherView<WorkflowItem<FR, W, C>> where FR.WorkflowInput == Never {
        WorkflowLauncherView(item: closure(), workflowLauncher: self)
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowLauncher where Args == AnyWorkflow.PassedArgs {
    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable, W, C>(with closure: @autoclosure () -> WorkflowItem<FR, W, C>) -> WorkflowLauncherView<WorkflowItem<FR, W, C>> {
        WorkflowLauncherView(item: closure(), workflowLauncher: self)
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable, W, C>(with closure: @autoclosure () -> WorkflowItem<FR, W, C>) -> WorkflowLauncherView<WorkflowItem<FR, W, C>> where FR.WorkflowInput == AnyWorkflow.PassedArgs {
        WorkflowLauncherView(item: closure(), workflowLauncher: self)
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowLauncher {
    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable, W, C>(with closure: @autoclosure () -> WorkflowItem<FR, W, C>) -> WorkflowLauncherView<WorkflowItem<FR, W, C>> {
        WorkflowLauncherView(item: closure(), workflowLauncher: self)
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable, W, C>(with closure: @autoclosure () -> WorkflowItem<FR, W, C>) -> WorkflowLauncherView<WorkflowItem<FR, W, C>> where FR.WorkflowInput == AnyWorkflow.PassedArgs {
        WorkflowLauncherView(item: closure(), workflowLauncher: self)
    }
}

// swiftlint:enable line_length
