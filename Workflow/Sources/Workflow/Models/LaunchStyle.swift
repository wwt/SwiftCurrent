//
//  LaunchStyle.swift
//  Workflow
//
//  Created by Tyler Thompson on 8/29/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation

/**
 An extendable class that indicates how a `FlowRepresentable` should be launched.

 ### Discussion
 Used when you are creating a `Workflow`.
 */
public final class LaunchStyle {
    /// default: The launch style that is used if you do not specify one. This behavior is very dependent on the responder (for example: SwiftUI and UIKit presenters will think "default" means something contextual to themselves, but it won't necessarily be the same between them)
    public static let `default` = LaunchStyle()

    /// A new instance of `LaunchStyle`; only use for extending cases of `LaunchStyle`.
    public static var new: LaunchStyle { LaunchStyle() }

    private init() {
        // LaunchStyle is designed to behave like an enum but be extensible. Enums cannot be initialized.
    }
}

extension LaunchStyle: Equatable {
    public static func == (lhs: LaunchStyle, rhs: LaunchStyle) -> Bool {
        lhs === rhs
    }
}
