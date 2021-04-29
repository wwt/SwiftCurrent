//
//  PickupOrDeliveryViewController.swift
//  WorkflowExample
//
//  Created by Tyler Thompson on 9/24/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import Workflow
import WorkflowUIKit

class PickupOrDeliveryViewController: UIWorkflowItem<Order, Order>, StoryboardLoadable {
    var order: Order?

    @IBAction func selectPickup() {
        order?.orderType = .pickup
        guard let order = order else { return }
        proceedInWorkflow(order)
    }

    @IBAction func selectDelivery() {
        let workflow = Workflow(EnterAddressViewController.self)
        launchInto(workflow, args: order, withLaunchStyle: .modal) { [weak self] (order) in
            workflow.abandon()
            guard let order = order as? Order else { return }
            self?.proceedInWorkflow(order)
        }
    }
}

extension PickupOrDeliveryViewController: FlowRepresentable {
    func shouldLoad(with order: Order) -> Bool {
        defer {
            self.order = order
        }
        var order = order
        if let location = order.location,
            location.orderTypes.count == 1 {
            order.orderType = location.orderTypes.first
            proceedInWorkflow(order)
        }
        return (order.location?.orderTypes.count ?? 0) > 1
    }
}
