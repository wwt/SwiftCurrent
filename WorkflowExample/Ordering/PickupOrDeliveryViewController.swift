//
//  PickupOrDeliveryViewController.swift
//  WorkflowExample
//
//  Created by Tyler Thompson on 9/24/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
import DynamicWorkflow

class PickupOrDeliveryViewController: UIWorkflowItem<Order>, StoryboardLoadable {
    var order:Order?
    
    @IBAction func selectPickup() {
        order?.orderType = .pickup
        proceedInWorkflow(order)
    }
    
    @IBAction func selectDelivery() {
        let workflow:Workflow = [
            EnterAddressViewController.self
        ]
        launchInto(workflow, args: order, withLaunchStyle: .modally) { [weak self] (order) in
            workflow.abandon()
            self?.proceedInWorkflow(order)
        }
    }
}

extension PickupOrDeliveryViewController: FlowRepresentable {
    func shouldLoad(with order: Order) -> Bool {
        self.order = order
        return (order.location?.orderTypes.count ?? 0) > 1
    }
}
