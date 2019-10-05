//
//  PickupOrDeliveryViewControllerTests.swift
//  WorkflowExampleTests
//
//  Created by Tyler Thompson on 9/25/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

@testable import WorkflowExample
@testable import DynamicWorkflow

class PickupOrDeliveryViewConrollerTests:ViewControllerTest<PickupOrDeliveryViewController> {
    func testShouldLoadOnlyIfThereAreMultipleOrderTypes() {
        let locationWithOne = Location(name: "", address: Address(), orderTypes: [.pickup], menuTypes: [])
        let locationWithMultiple = Location(name: "", address: Address(), orderTypes: [.pickup, .delivery(Address())], menuTypes: [])
        XCTAssertFalse(testViewController.shouldLoad(with: Order(location: locationWithOne)))
        XCTAssert(testViewController.shouldLoad(with: Order(location: locationWithMultiple)))
    }
    
    func testShouldLoadWithOnlyOneOrderTypeCallsBackImmediately() {
        var callbackCalled = false
        let locationWithOne = Location(name: "", address: Address(), orderTypes: [.delivery(Address())], menuTypes: [])
        loadFromStoryboard { viewController in
            viewController.callback = { data in
                callbackCalled = true
                XCTAssert(data is Order)
                XCTAssertEqual((data as? Order)?.orderType, .delivery(Address()))
            }
            _ = viewController.shouldLoad(with: Order(location: locationWithOne))
        }
        
        XCTAssert(callbackCalled)
    }
    
    func testSelectingPickupSetsItOnOrder() {
        var callbackCalled = false
        let location = Location(name: "", address: Address(), orderTypes: [.pickup, .delivery(Address())], menuTypes: [])
        loadFromStoryboard { viewController in
            viewController.callback = { data in
                callbackCalled = true
                XCTAssert(data is Order)
                XCTAssertEqual((data as? Order)?.orderType, .pickup)
            }
            _ = viewController.shouldLoad(with: Order(location: location))
        }
        
        testViewController.selectPickup()
        
        XCTAssert(callbackCalled)
    }
    
    func testSelectingDeliveryLaunchesWorkflowAndSetsSelectionOnOrder() {
        loadFromStoryboard()
        let unique = UUID().uuidString
        testViewController.order = Order(location: Location(name: unique, address: Address(), orderTypes: [], menuTypes: []))
        let listener = WorkflowListener()
            
        testViewController.selectDelivery()
        
        XCTAssertWorkflowLaunched(listener: listener, expectedFlowRepresentables: [
            EnterAddressViewController.self
        ])
        
        let mock = MockPresenter()
        listener.workflow?.applyPresenter(mock)
        
        var proceedInWorkflowCalled = false
        testViewController.callback = { data in
            proceedInWorkflowCalled = true
            XCTAssertEqual(data as? Int, 2)
        }

        listener.onFinish?(2)
        
        XCTAssertEqual(mock.abandonCalled, 1)
        
        XCTAssert(proceedInWorkflowCalled)
    }
}

func XCTAssertWorkflowLaunched(listener: WorkflowListener, expectedFlowRepresentables:[AnyFlowRepresentable.Type]) {
    XCTAssertNotNil(listener.workflow, "No workflow found")
    guard let workflow = listener.workflow, expectedFlowRepresentables.count == workflow.count else {
        XCTFail("workflow does not contain correct representables: \(String(describing: listener.workflow?.compactMap { String(describing: $0.value) }) )")
        return
    }
    XCTAssertEqual(workflow.compactMap { String(describing: $0.value) },
                   expectedFlowRepresentables.map { String(describing: $0) })
}

class MockPresenter: Presenter {
    var abandonCalled = 0
    var lastWorkflow:Workflow?
    var lastAnimated:Bool?
    func abandon(_ workflow: Workflow, animated: Bool, onFinish: (() -> Void)?) {
        abandonCalled += 1
        lastWorkflow = workflow
        lastAnimated = animated
        onFinish?()
    }
    required init() { }
}

class WorkflowListener {
    var workflow:Workflow?
    var launchStyle:PresentationType?
    var args:Any?
    var launchedFrom:AnyFlowRepresentable?
    var onFinish:((Any?) -> Void)?
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(workflowLaunched(notification:)), name: .workflowLaunched, object: nil)
    }
    
    @objc func workflowLaunched(notification: Notification) {
        let dict = notification.object as? [String:Any?]
        workflow = dict?["workflow"] as? Workflow
        launchStyle = dict?["style"] as? PresentationType
        onFinish = dict?["onFinish"] as? ((Any?) -> Void)
        launchedFrom = dict?["launchFrom"] as? AnyFlowRepresentable
        args = dict?["args"] as Any?
    }
}
