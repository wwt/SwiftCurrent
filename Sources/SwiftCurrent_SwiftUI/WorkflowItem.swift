//
//  WorkflowItem.swift
//  SwiftCurrent
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
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public final class WorkflowItem<F: FlowRepresentable & View> {
    /// Creates a `WorkflowItem` with no arguments from a `FlowRepresentable` that is also a View.
    public init(_: F.Type) { }

    /// Sets persistence on the `FlowRepresentable` of the `WorkflowItem`.
    public func persistence(_ : FlowPersistence) -> Self {
        self
    }
}
