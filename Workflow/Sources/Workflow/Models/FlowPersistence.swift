//
//  FlowPersistence.swift
//  
//
//  Created by Tyler Thompson on 11/26/20.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
/**
 An extendable class that indicates how a `FlowRepresentable` should be persisted.

 ### Discussion
 Used when you are creating a `Workflow`.
 */
public final class FlowPersistence {
    /// Indicates a `FlowRepresentable` in a `Workflow` should persist based on its `shouldLoad` function.
    public static let `default` = FlowPersistence()
    /// Indicates a `FlowRepresentable` in a `Workflow` who's `shouldLoad` function returns false should still be persisted in the workflow.
    public static let persistWhenSkipped = FlowPersistence()
    /// Indicates a `FlowRepresentable` in a `Workflow` who's `shouldLoad` function returns true should be removed from the workflow after proceeding forward.
    public static let removedAfterProceeding = FlowPersistence()

    /// A new instance of `FlowPersistence`; only use for extending cases of `FlowPersistence`.
    public static var new: FlowPersistence { FlowPersistence() }

    private init() {
        // FlowPersistence is designed to behave like an enum but be extensible. Enums cannot be initialized.
    }
}

extension FlowPersistence: Equatable {
    public static func == (lhs: FlowPersistence, rhs: FlowPersistence) -> Bool {
        lhs === rhs
    }
}
