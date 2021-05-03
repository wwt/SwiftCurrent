//
//  StoryboardLoadable.swift
//
//  Created by Tyler Thompson on 5/3/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import UIKit

import Workflow

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
    /// the identifier that should be used to retrieve the UIViewController from the storyboard.
    static var storyboardId: String { get }
    /// the storyboard to retrieve the UIViewController from
    static var storyboard: UIStoryboard { get }

    /// this UIKit initializer you can use to pass arguments to the `FlowRepresentable`
    init?(coder: NSCoder, with args: WorkflowInput)
}

@available(iOS 13.0, *)
extension StoryboardLoadable {
    /// WARNING: Just a default implementation of the required `FlowRepresentable` initializer. **This will throw a fatal error on its own**, it's just meant to satisfy the protocol requirements
    public init(with args: WorkflowInput) { // swiftlint:disable:this unavailable_function
        // swiftlint:disable:next line_length
        fatalError("The StoryboardLoadable protocol provided a default implementation if this initializer so that consumers didn't have to worry about it in their UIViewController. If you encounter this error and need this initializer, simply add it to \(String(describing: Self.self))")
    }

    // No public docs necessary, as this should not be used by consumers
    // swiftlint:disable:next missing_docs
    public static func _factory<FR: FlowRepresentable>(_: FR.Type, with args: WorkflowInput) -> FR {
        guard let viewController = storyboard.instantiateViewController(identifier: storyboardId, creator: { Self(coder: $0, with: args) }) as? FR else {
            fatalError("Unable to instantiate a view controller from storyboard: \(storyboard), with id: \(storyboardId), of type: \(String(describing: FR.self))")
        }
        return viewController
    }
}

@available(iOS 13.0, *)
extension StoryboardLoadable where WorkflowInput == Never {
    // No public docs necessary, as this should not be used by consumers
    // swiftlint:disable:next missing_docs
    public init?(coder: NSCoder, with args: WorkflowInput) {
        self.init(coder: coder)
    }

    // No public docs necessary, as this should not be used by consumers
    // swiftlint:disable:next missing_docs
    public static func _factory<FR: FlowRepresentable>(_: FR.Type) -> FR {
        guard let viewController = storyboard.instantiateViewController(identifier: storyboardId, creator: { Self(coder: $0) }) as? FR else {
            fatalError("Unable to instantiate a view controller from storyboard: \(storyboard), with id: \(storyboardId), of type: \(String(describing: FR.self))")
        }
        return viewController
    }
}
