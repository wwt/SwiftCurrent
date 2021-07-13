//
//  WorkflowView.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 7/12/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftUI
import SwiftCurrent

/**
 A view used to build a `Workflow` in SwiftUI.

 ### Discussion
 The preferred method for creating a `Workflow` with SwiftUI is a combination of `WorkflowView` and `WorkflowItem`. Initialize with arguments if your first `FlowRepresentable` has an input type.

 #### Example
 */
/// ```swift
/// WorkflowView(isPresented: $isPresented.animation(), args: "String in")
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
///     .onAbandon { print("presentingWorkflowView is now false") }
///     .onFinish { args in print("Finished 1: \(args)") }
///     .onFinish { print("Finished 2: \($0)") }
///     .background(Color.green)
///  ```
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct WorkflowView<Args>: View {
    @Binding public var isPresented: Bool
    @StateObject private var model = WorkflowViewModel()

    let inspection = Inspection<Self>() // Needed for ViewInspector
    private var workflow: AnyWorkflow?
    private var onFinish = [(AnyWorkflow.PassedArgs) -> Void]()
    private var onAbandon = [() -> Void]()
    private var passedArgs = AnyWorkflow.PassedArgs.none

    /// Creates a `WorkflowView` that displays a `FlowRepresentable` when presented.
    public init(isPresented: Binding<Bool>) where Args == Never {
        _isPresented = isPresented
    }

    /// Creates a `WorkflowView` that displays a `FlowRepresentable` when presented.
    public init(isPresented: Binding<Bool>, args: Args) {
        _isPresented = isPresented
        if let args = args as? AnyWorkflow.PassedArgs {
            passedArgs = args
        } else {
            passedArgs = .args(args)
        }
    }

    private init(isPresented: Binding<Bool>,
                 workflow: AnyWorkflow?,
                 onFinish: [(AnyWorkflow.PassedArgs) -> Void],
                 onAbandon: [() -> Void],
                 passedArgs: AnyWorkflow.PassedArgs) {
        _isPresented = isPresented
        self.workflow = workflow
        self.onFinish = onFinish
        self.onAbandon = onAbandon
        self.passedArgs = passedArgs
    }

    #warning("Need to add a test that says only launch once")
    public var body: some View {
        if isPresented {
            VStack {
                model.body
            }
            .onAppear {
                model.isPresented = $isPresented
                model.onAbandon = onAbandon
                workflow?.launch(withOrchestrationResponder: model,
                                 passedArgs: passedArgs,
                                 launchStyle: .new) { passedArgs in
                    onFinish.forEach { $0(passedArgs) }
                }
            }
            .onDisappear {
                model.body = AnyView(EmptyView())
            }
            .onReceive(inspection.notice) { inspection.visit(self, $0) } // Needed for ViewInspector
        }
    }

    /// Adds an action to perform when this `Workflow` has finished.
    public func onFinish(closure: @escaping (AnyWorkflow.PassedArgs) -> Void) -> Self {
        var onFinish = self.onFinish
        onFinish.append(closure)
        return WorkflowView(isPresented: $isPresented,
                            workflow: workflow,
                            onFinish: onFinish,
                            onAbandon: onAbandon,
                            passedArgs: passedArgs)
    }

    /// Adds an action to perform when this `Workflow` has abandoned.
    public func onAbandon(closure: @escaping () -> Void) -> Self {
        var onAbandon = self.onAbandon
        onAbandon.append(closure)
        return WorkflowView(isPresented: $isPresented,
                            workflow: workflow,
                            onFinish: onFinish,
                            onAbandon: onAbandon,
                            passedArgs: passedArgs)
    }
}

// MARK: thenProceeds
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowView where Args == Never {
    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
     - Returns: a new `WorkflowView` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable & View>(with item: WorkflowItem<FR>) -> WorkflowView<FR.WorkflowOutput> where FR.WorkflowInput == Never {
        var workflow = self.workflow
        if workflow == nil {
            workflow = AnyWorkflow(Workflow<FR>(item.metadata))
        } else {
            workflow?.append(item.metadata)
        }
        return WorkflowView<FR.WorkflowOutput>(isPresented: $isPresented,
                                               workflow: workflow,
                                               onFinish: onFinish,
                                               onAbandon: onAbandon,
                                               passedArgs: passedArgs)
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowView where Args == AnyWorkflow.PassedArgs {
    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
     - Returns: a new `WorkflowView` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable & View>(with item: WorkflowItem<FR>) -> WorkflowView<FR.WorkflowOutput> where FR.WorkflowInput == AnyWorkflow.PassedArgs {
        var workflow = self.workflow
        if workflow == nil {
            workflow = AnyWorkflow(Workflow<FR>(item.metadata))
        } else {
            workflow?.append(item.metadata)
        }
        return WorkflowView<FR.WorkflowOutput>(isPresented: $isPresented,
                                               workflow: workflow,
                                               onFinish: onFinish,
                                               onAbandon: onAbandon,
                                               passedArgs: passedArgs)
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowView {
    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
     - Returns: a new `WorkflowView` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable & View>(with item: WorkflowItem<FR>) -> WorkflowView<FR.WorkflowOutput> where Args == FR.WorkflowInput {
        var workflow = self.workflow
        if workflow == nil {
            workflow = AnyWorkflow(Workflow<FR>(item.metadata))
        } else {
            workflow?.append(item.metadata)
        }
        return WorkflowView<FR.WorkflowOutput>(isPresented: $isPresented,
                                               workflow: workflow,
                                               onFinish: onFinish,
                                               onAbandon: onAbandon,
                                               passedArgs: passedArgs)
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
     - Returns: a new `WorkflowView` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable & View>(with item: WorkflowItem<FR>) -> WorkflowView<FR.WorkflowOutput> where FR.WorkflowInput == AnyWorkflow.PassedArgs {
        var workflow = self.workflow
        if workflow == nil {
            workflow = AnyWorkflow(Workflow<FR>(item.metadata))
        } else {
            workflow?.append(item.metadata)
        }
        return WorkflowView<FR.WorkflowOutput>(isPresented: $isPresented,
                                               workflow: workflow,
                                               onFinish: onFinish,
                                               onAbandon: onAbandon,
                                               passedArgs: passedArgs)
    }
}
