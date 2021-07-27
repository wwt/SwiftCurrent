//
//  StoryboardLoadable.swift
//
//  Created by Tyler Thompson on 5/3/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import UIKit

import SwiftCurrent

/**
 A protocol indicating this a `FlowRepresentable` that should be loaded from a storyboard.

 ### Discussion
 If you use storyboards in your app and are on iOS 13 or greater `StoryboardLoadable` provides the best consumer experience for creating your `FlowRepresentable`.

 If you use the convention where the storyboard identifiers are the same name as the UIViewController class you can write an extension so your code makes that assumption.

 It may also be a good idea to make your own protocols for each of your storyboards, for the sake of clarity in your code.
 #### Example
 ```swift
 extension StoryboardLoadable {
    static var storyboardId: String { String(describing: Self.self) }
 }

 protocol MainStoryboardLoadable: StoryboardLoadable { }
 extension MainStoryboardLoadable {
    static var storyboard: UIStoryboard { UIStoryboard(name: "main", bundle: Bundle.main) }
 }
 ```
 */

@available(iOS 13.0, *)
public protocol StoryboardLoadable where Self: FlowRepresentable, Self: UIViewController {
    /// Identifier used to retrieve the UIViewController from `storyboard`.
    static var storyboardId: String { get }
    /// Storyboard used to retrieve the UIViewController.
    static var storyboard: UIStoryboard { get }

    /**
     Creates the specified view controller from the storyboard and initializes it using your custom initialization code.

     ### Discussion
     This UIKit initializer can be used to pass arguments to the `FlowRepresentable`.
     If you return `nil`, this creates the view controller using the default `init(coder:)` method.

     - Parameter coder: An unarchiver object.
     - Parameter with: `WorkflowInput` data provided by encompassing `Workflow`; parameter can be renamed.
     */
    init?(coder: NSCoder, with args: WorkflowInput)
}

@available(iOS 13.0, *)
extension StoryboardLoadable {
    /// :nodoc: **WARNING: This will throw a fatal error.** Just a default implementation of the required `FlowRepresentable` initializer meant to satisfy the protocol requirements.
    public init(with args: WorkflowInput) { // swiftlint:disable:this unavailable_function
        // swiftlint:disable:next line_length
        fatalError("The StoryboardLoadable protocol provided a default implementation of this initializer so that consumers didn't have to worry about it in their UIViewController. If you encounter this error and need this initializer, simply add it to \(String(describing: Self.self))")
    }

    // No public docs necessary, as this should not be used by consumers.
    // swiftlint:disable:next missing_docs
    public static func _factory<FR: FlowRepresentable>(_: FR.Type, with args: WorkflowInput) -> FR {
        guard let viewController = storyboard.instantiateViewController(identifier: storyboardId, creator: { (FR.self as? Self.Type)?.init(coder: $0, with: args) }) as? FR else {
            fatalError("Unable to instantiate a view controller from storyboard: \(storyboard), with id: \(storyboardId), of type: \(String(describing: FR.self))")
        }
        return viewController
    }
}

@available(iOS 13.0, *)
extension PassthroughFlowRepresentable where Self: StoryboardLoadable {
    /// :nodoc: **WARNING: This will throw a fatal error.** Just a default implementation of the required `FlowRepresentable` initializer meant to satisfy the protocol requirements.
    public init(with args: WorkflowInput) { self.init() }

    // swiftlint:disable:next missing_docs
    public init?(coder: NSCoder, with args: WorkflowInput) { self.init(coder: coder) }
}

@available(iOS 13.0, *)
extension StoryboardLoadable where WorkflowInput == Never {
    // No public docs necessary, this cannot be called.
    // swiftlint:disable:next missing_docs
    public init?(coder: NSCoder, with args: WorkflowInput) { self.init(coder: coder) }

    // No public docs necessary, as this should not be used by consumers.
    // swiftlint:disable:next missing_docs
    public static func _factory<FR: FlowRepresentable>(_: FR.Type) -> FR {
        guard let viewController = storyboard.instantiateViewController(identifier: storyboardId, creator: { (FR.self as? Self.Type)?.init(coder: $0) }) as? FR else {
            fatalError("Unable to instantiate a view controller from storyboard: \(storyboard), with id: \(storyboardId), of type: \(String(describing: FR.self))")
        }
        return viewController
    }
}
