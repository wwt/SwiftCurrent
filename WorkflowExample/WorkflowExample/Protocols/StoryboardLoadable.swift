//
//  StoryboardLoadable.swift
//  WorkflowExample
//
//  Created by Tyler Thompson on 9/24/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import UIKit

import Workflow

/// This makes the in-code assumption that you are following the convention that storyboard IDs are equivalent to UIViewController subclass names.
public protocol StoryboardLoadable where Self: FlowRepresentable, Self: UIViewController {
    init?(coder: NSCoder, with args: WorkflowInput)
}

extension StoryboardLoadable {
    static var storyboardId: String {
        return String(describing: Self.self)
    }

    public init(with args: WorkflowInput) {
        fatalError()
    }

    public static func _factory<FR: FlowRepresentable>(_ type: FR.Type, with args: WorkflowInput) -> FR {
        return Storyboard.main.instantiateViewController(identifier: storyboardId) {
            Self.init(coder: $0, with: args)
        } as! FR
    }
}

extension StoryboardLoadable where WorkflowInput == Never {

    public init?(coder: NSCoder, with args: WorkflowInput) { fatalError() }

    public static func _factory<FR: FlowRepresentable>(_ type: FR.Type) -> FR {
        return Storyboard.main.instantiateViewController(identifier: storyboardId) {
            Self.init(coder: $0)
        } as! FR
    }
}
