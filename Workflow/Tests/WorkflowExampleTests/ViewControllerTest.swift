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
@testable import Workflow

class ViewControllerTest<T: UIViewController & StoryboardLoadable & FlowRepresentable>: XCTestCase {
    typealias ControllerType = T
    var testViewController:ControllerType!
    var ref:AnyFlowRepresentable!
    override final func setUp() {
        loadFromStoryboard()
    }
    
    final func loadFromStoryboard(configure: ((inout ControllerType) -> Void)? = nil) {
        var instance = T.instance()
        testViewController = instance
        ref = AnyFlowRepresentable(&instance)
        
        let window = UIApplication.shared.windows.first

        window?.removeViewsFromRootViewController()

        configure?(&instance)
        window?.rootViewController = instance
        instance.loadViewIfNeeded()
        instance.view.layoutIfNeeded()

        CATransaction.flush()

        afterLoadFromStoryboard()
    }
    
    func afterLoadFromStoryboard() { }
}
