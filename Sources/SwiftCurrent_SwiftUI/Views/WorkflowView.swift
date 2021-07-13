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
 ```swift
 WorkflowView(isPresented: $isPresented.animation(), args: "String in")
         .thenProceed(with: WorkflowItem(FirstView.self)
                         .applyModifiers {
                             if true { // Enabling transition animation
                                 $0.background(Color.gray)
                                     .transition(.slide)
                                     .animation(.spring())
                             }
                         })
         .thenProceed(with: WorkflowItem(SecondView.self)
                         .persistence(.removedAfterProceeding)
                         .applyModifiers {
                             if true {
                                 $0.SecondViewSpecificModifier()
                                     .padding(10)
                                     .background(Color.purple)
                                     .transition(.opacity)
                                     .animation(.easeInOut)
                             }
                         })
         .onAbandon { print("presentingWorkflowView is now false") }
         .onFinish { args in print("Finished 1: \(args)") }
         .onFinish { print("Finished 2: \($0)") }
         .background(Color.green)
 ```
 */
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct WorkflowView: View {
    @Binding public var isPresented: Bool
    @StateObject private var model = WorkflowViewModel()
    @State private var workflow: AnyWorkflow?

    let inspection = Inspection<Self>() // Needed for ViewInspector

    /// Creates a `WorkflowView` that displays a `FlowRepresentable` when presented.
    public init(isPresented: Binding<Bool>) {
        _isPresented = .constant(false)
    }

    private init(isPresented: Binding<Bool>,
                 workflow: AnyWorkflow?) {
        _isPresented = isPresented
        _workflow = State(initialValue: workflow)
    }

    public var body: some View {
        VStack {
            model.body
        }.onAppear {
            workflow?.launch(withOrchestrationResponder: model,
                             passedArgs: .none,
                             launchStyle: .new,
                             onFinish: nil)
        }.onReceive(inspection.notice) { inspection.visit(self, $0) } // Needed for ViewInspector
    }

    /// Adds an action to perform when this `Workflow` has finished.
    public func onFinish(_: (AnyWorkflow.PassedArgs) -> Void) -> Self {
        self
    }

    /// Adds an action to perform when this `Workflow` has abandoned.
    public func onAbandon(_: () -> Void) -> Self {
        self
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension WorkflowView {
    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
     - Returns: a new `WorkflowView` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable & View>(with item: WorkflowItem<FR>) -> WorkflowView {
        var workflow = self.workflow
        if workflow == nil {
            workflow = AnyWorkflow(Workflow<FR>(item.metadata))
        } else {
            workflow?.append(item.metadata)
        }
        return WorkflowView(isPresented: $isPresented,
                            workflow: workflow)
    }
}
