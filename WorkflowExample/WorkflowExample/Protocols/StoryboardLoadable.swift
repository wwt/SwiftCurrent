//
//  StoryboardLoadable.swift
//  WorkflowExample
//
//  Created by Tyler Thompson on 9/24/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import Workflow

/// This makes the in-code assumption that you are following the convention that storyboard IDs are equivalent to UIViewController subclass names.
protocol StoryboardLoadable {}

extension StoryboardLoadable {
    static var storyboardId: String {
        return String(describing: Self.self)
    }

    static func instance() -> Self {
        return Storyboard.main.instantiateViewController(withIdentifier: storyboardId) as! Self
    }
}
