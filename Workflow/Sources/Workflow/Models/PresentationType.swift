//
//  PresentationType.swift
//  Workflow
//
//  Created by Tyler Thompson on 8/29/19.
//  Copyright © 2019 Tyler Tompson. All rights reserved.
//

import Foundation
/**
 PresentationType: An enum that indicates how FlowRepresentables should be presented
 
 ### Discussion:
 Mostly used when you tell a workflow to launch, or on the `FlowRepresentable` protocol if you have a view that preferrs to be launched with a certain style
 */

public final class LaunchStyle {
    private init() { }

    public static let `default` = LaunchStyle()
    public static var new: LaunchStyle { LaunchStyle() }
}

extension LaunchStyle: Equatable {
    public static func == (lhs: LaunchStyle, rhs: LaunchStyle) -> Bool {
        return lhs === rhs
    }
}

/**
 FlowPersistance: An enum that indicates how FlowRepresentables should be persist when in the view stack

### Discussion:
Used when you are creating a workflow
*/
public final class FlowPersistance {
    private init() { }
    /// default: Indicates a `FlowRepresentable` in a `Workflow` should persist in the viewstack based on it's `shouldLoad` function
    public static let `default` = FlowPersistance()
    /// default: Indicates a `FlowRepresentable` in a `Workflow` who's `shouldLoad` function returns false should still be in the viewstack so if a user navigates backwards it'll appear
    public static let persistWhenSkipped = FlowPersistance()
    /// default: Indicates a `FlowRepresentable` in a `Workflow` who's `shouldLoad` function returns true should be removed from the viewstack after the user progresses past it
    public static let removedAfterProceeding = FlowPersistance()
}

extension FlowPersistance: Equatable {
    public static func == (lhs: FlowPersistance, rhs: FlowPersistance) -> Bool {
        return lhs === rhs
    }
}
