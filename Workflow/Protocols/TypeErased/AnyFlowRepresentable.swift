//
//  AnyFlowRepresentable.swift
//  Workflow
//
//  Created by Tyler Thompson on 8/25/19.
//  Copyright © 2019 Tyler Tompson. All rights reserved.
//

import Foundation

/**
 AnyFlowRepresentable: A type erased version of 'FlowRepresentable'. Generally speaking don't use this directly, use FlowRepresentable instead.
 */
public protocol AnyFlowRepresentable {
    /// preferredLaunchStyle: Gives the ability for a `FlowRepresentable` to describe how it best shows up. For example a view can claim it preferrs to be launched in a navigationStack
    var preferredLaunchStyle:PresentationType { get }
    /// workflow: Access to the `Workflow` controlling the `FlowRepresentable`. A common use case may be a `FlowRepresentable` that wants to abandon the `Workflow` it's in.
    /// - Note: While not strictly necessary it would be wise to declare this property as `weak`
    var workflow:Workflow? { get set }
    var proceedInWorkflow:((Any?) -> Void)? { get set }
    
    mutating func erasedShouldLoad(with args:Any?) -> Bool
    
    /// instance: A method to return an instance of the `FlowRepresentable`
    /// - Returns: `AnyFlowRepresentable`. Specifically a new instance from the static class passed to a `Workflow`
    /// - Note: This needs to return a unique instance of your view. Whether programmatic or from the storyboard is irrelevant
    static func instance() -> AnyFlowRepresentable
}
