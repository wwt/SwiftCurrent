//
//  PickupOrDeliveryViewController.swift
//  WorkflowExample
//
//  Created by Tyler Thompson on 9/24/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
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
        let workflow = Workflow()
            .thenPresent(EnterAddressViewController.self)
        launchInto(workflow, args: order, withLaunchStyle: .modal) { [weak self] (order) in
            workflow.abandon()
            self?.proceedInWorkflow(order)
        }
    }
}

extension PickupOrDeliveryViewController: FlowRepresentable {
    func shouldLoad(with order: Order) -> Bool {
        self.order = order
        if let location = order.location,
            location.orderTypes.count == 1 {
            self.order?.orderType = location.orderTypes.first
            proceedInWorkflow(self.order)
        }
        return (order.location?.orderTypes.count ?? 0) > 1
    }
}
