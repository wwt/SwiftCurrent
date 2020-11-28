//
//  StoryboardLoadable.swift
//  WorkflowExample
//
//  Created by Tyler Thompson on 9/24/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
import Workflow

protocol StoryboardLoadable {}

extension StoryboardLoadable {
    static var storyboardId:String {
        return String(describing: Self.self)
    }
    
    static func instance() -> Self {
        return Storyboard.main.instantiateViewController(withIdentifier: storyboardId) as! Self
    }
}
