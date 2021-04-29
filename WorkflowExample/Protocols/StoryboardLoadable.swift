//
//  StoryboardLoadable.swift
//  WorkflowExample
//
//  Created by Tyler Thompson on 9/24/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import DynamicWorkflow

protocol StoryboardLoadable {}

extension StoryboardLoadable {
    static var storyboardId:String {
        return String(describing: Self.self)
    }
    
    static func instance() -> AnyFlowRepresentable {
        return Storyboard.main.instantiateViewController(withIdentifier: storyboardId) as! AnyFlowRepresentable
    }
}
