//
//  ViewControllerTest.swift
//  WorkflowExampleTests
//
//  Created by Tyler Thompson on 9/25/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

@testable import WorkflowExample

class ViewControllerTest<T: UIViewController & StoryboardLoadable>: XCTestCase {
    typealias ControllerType = T
    var testViewController:ControllerType!
    override final func setUp() {
        loadFromStoryboard()
    }
    
    final func loadFromStoryboard(configure: ((ControllerType) -> Void)? = nil) {
        testViewController = UIViewController.loadFromStoryboard(identifier: ControllerType.storyboardId, configure:configure)
        afterLoadFromStoryboard()
    }
    
    func afterLoadFromStoryboard() { }

}
