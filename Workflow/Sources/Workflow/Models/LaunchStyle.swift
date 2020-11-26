//
//  LaunchStyle.swift
//  Workflow
//
//  Created by Tyler Thompson on 8/29/19.
//  Copyright © 2019 Tyler Tompson. All rights reserved.
//

import Foundation
/**
 LaunchStyle: An extendable class that indicates how FlowRepresentables should be launched
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
