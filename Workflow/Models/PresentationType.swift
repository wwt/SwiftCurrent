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
public enum PresentationType:Int {
    /// navigationStack: Indicates a `FlowRepresentable` should be launched in a navigation stack of some kind (For example with UIKit this would use a UINavigationController)
    /// - Note: If no current navigation stack is available, one will be created
    case navigationStack
    /// modally: Indicates a `FlowRepresentable` should be launched modally
    case modally
    /// default: Indicates a `FlowRepresentable` can be launched contextually
    /// - Note: If there's already a navigation stack, it will be used. Otherwise views will present modally
    case `default`
}
