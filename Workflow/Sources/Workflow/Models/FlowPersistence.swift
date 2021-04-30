//
//  FlowPersistence.swift
//  
//
//  Created by Tyler Thompson on 11/26/20.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
/**
 FlowPersistence: An extendable class that indicates how FlowRepresentables should be persisted

### Discussion:
Used when you are creating a workflow
*/
public final class FlowPersistence {
    /// default: Indicates a `FlowRepresentable` in a `Workflow` should persist in based on it's `shouldLoad` function
    public static let `default` = FlowPersistence()
    /// persistWhenSkipped: Indicates a `FlowRepresentable` in a `Workflow` who's `shouldLoad` function returns false should still be persisted so if the workflow is navigated backwards it'll be there
    public static let persistWhenSkipped = FlowPersistence()
    /// removedAfterProceeding: Indicates a `FlowRepresentable` in a `Workflow` who's `shouldLoad` function returns true should be removed from the viewstack after the workflow progresses past it
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
