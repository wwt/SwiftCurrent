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

class ViewControllerTest<T: StoryboardLoadable>: XCTestCase {
    typealias ControllerType = T
    var testViewController: ControllerType!
    var ref: AnyFlowRepresentable!

    final func loadFromStoryboard(args: AnyWorkflow.PassedArgs, configure: ((inout ControllerType) -> Void)? = nil) {
        ref = AnyFlowRepresentable(T.self, args: args)
        testViewController = (ref.underlyingInstance as! ControllerType)

        configure?(&testViewController)

        _ = ref.shouldLoad(with: args)

        testViewController.loadForTesting()
    }
}
