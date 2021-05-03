//
//  StoryboardLoadable.swift
//
//  Created by Tyler Thompson on 5/3/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import UIKit

import Workflow

@available(iOS 13.0, *)
public protocol StoryboardLoadable where Self: FlowRepresentable, Self: UIViewController {
    static var storyboardId: String { get }
    static var storyboard: UIStoryboard { get }

    init?(coder: NSCoder, with args: WorkflowInput)
}

@available(iOS 13.0, *)
extension StoryboardLoadable {
    public init(with args: WorkflowInput) {
        // swiftlint:disable:next line_length
        fatalError("The StoryboardLoadable protocol provided a default implementation if this initializer so that consumers didn't have to worry about it in their UIViewController. If you encounter this error and need this initializer, simply add it to \(String(describing: Self.self))")
    }

    public static func _factory<FR: FlowRepresentable>(_: FR.Type, with args: WorkflowInput) -> FR {
        guard let viewController = storyboard.instantiateViewController(identifier: storyboardId, creator: { Self(coder: $0, with: args) }) as? FR else {
            fatalError("Unable to instantiate a view controller from storyboard: \(storyboard), with id: \(storyboardId), of type: \(String(describing: FR.self))")
        }
        return viewController
    }
}

@available(iOS 13.0, *)
extension StoryboardLoadable where WorkflowInput == Never {
    public init?(coder: NSCoder, with args: WorkflowInput) {
        self.init(coder: coder)
    }

    public static func _factory<FR: FlowRepresentable>(_: FR.Type) -> FR {
        guard let viewController = storyboard.instantiateViewController(identifier: storyboardId, creator: { Self(coder: $0) }) as? FR else {
            fatalError("Unable to instantiate a view controller from storyboard: \(storyboard), with id: \(storyboardId), of type: \(String(describing: FR.self))")
        }
        return viewController
    }
}
