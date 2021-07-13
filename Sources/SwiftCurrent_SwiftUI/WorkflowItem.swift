//
//  WorkflowItem.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Tyler Thompson on 7/12/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftCurrent

/**
 A concrete type used to modify a `FlowRepresentable` in a `WorkflowView`.

 ### Discussion
 `WorkflowItem` gives you the ability to specify changes you'd like to apply to a specific `FlowRepresentable` when it is time to present it in a `Workflow`.

 #### Example
 ```swift
 WorkflowItem(FirstView.self)
            .persistence(.removedAfterProceeding) // affects only FirstView
            .applyModifiers {
                if true { // Enabling transition animation
                    $0.background(Color.gray) // $0 is a FirstView instance
                        .transition(.slide)
                        .animation(.spring())
                }
            }
 ```
 */
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public final class WorkflowItem<F: FlowRepresentable & View> {
    var metadata: FlowRepresentableMetadata!
    private var flowPersistenceClosureIGuess: (AnyWorkflow.PassedArgs) -> FlowPersistence = { _ in .default }
    /// Creates a `WorkflowItem` with no arguments from a `FlowRepresentable` that is also a View.
    public init(_: F.Type) {
        metadata = FlowRepresentableMetadata(F.self,
                                             launchStyle: .new,
                                             flowPersistence: flowPersistenceClosureIGuess,
                                             flowRepresentableFactory: factory)
    }

    /// Sets persistence on the `FlowRepresentable` of the `WorkflowItem`.
    public func persistence(_ persistence: FlowPersistence) -> Self {
        flowPersistenceClosureIGuess = { _ in persistence }
        metadata = FlowRepresentableMetadata(F.self,
                                             launchStyle: .new,
                                             flowPersistence: flowPersistenceClosureIGuess,
                                             flowRepresentableFactory: factory)
        return self
    }

    func factory(args: AnyWorkflow.PassedArgs) -> AnyFlowRepresentable {
        AnyFlowRepresentableView(type: F.self, args: args)
    }
}
