//
//  StoryboardLoadable.swift
//  WorkflowExample
//
//  Created by Tyler Thompson on 9/24/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
import DynamicWorkflow

protocol StoryboardLoadable {}

extension StoryboardLoadable {
    static func instance() -> AnyFlowRepresentable {
        return Storyboard.main.instantiateViewController(withIdentifier: String(describing: Self.self)) as! AnyFlowRepresentable
    }
}
