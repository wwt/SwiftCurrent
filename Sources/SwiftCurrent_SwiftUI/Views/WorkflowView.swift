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
    let inspection = Inspection<Self>()

    /// Creates a `WorkflowView` that displays a `FlowRepresentable` when presented.
    public init(isPresented: Binding<Bool>) {
        _isPresented = .constant(false)
    }

    #warning("NOTE: The onReceive is how the tests work...do not remove it if you want tests that work. If you do not want tests that work why precisely are you at WWT or on this project?????")
    public var body: some View {
        VStack {
        }.onReceive(inspection.notice) { inspection.visit(self, $0) }
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
    public func thenProceed<FR: FlowRepresentable & View>(with _: WorkflowItem<FR>) -> WorkflowView {
        self // WRONG
    }
}
