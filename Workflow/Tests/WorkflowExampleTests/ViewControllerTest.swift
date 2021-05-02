//
//  ViewControllerTest.swift
//  WorkflowExampleTests
//
//  Created by Tyler Thompson on 9/25/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest
import UIUTest

@testable import WorkflowExample
@testable import Workflow

class ViewControllerTest<T: UIViewController & StoryboardLoadable & FlowRepresentable>: XCTestCase {
    typealias ControllerType = T
    var testViewController: ControllerType!
    var ref: AnyFlowRepresentable!
    override final func setUp() {
        loadFromStoryboard()
    }

    final func loadFromStoryboard(configure: ((inout ControllerType) -> Void)? = nil) {
        var instance = T.instance()
        testViewController = instance
        ref = AnyFlowRepresentable(&instance)

        configure?(&instance)

        instance.loadForTesting()
    }
}
