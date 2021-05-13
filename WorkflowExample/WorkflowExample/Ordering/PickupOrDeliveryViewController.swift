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
    var order: Order

    required init?(coder: NSCoder, with order: Order) {
        self.order = order
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) { fatalError() }

    @IBAction private func selectPickup() {
        order.orderType = .pickup
        proceedInWorkflow(order)
    }

    @IBAction private func selectDelivery() {
        let workflow = Workflow(EnterAddressViewController.self)
        launchInto(workflow, args: order, withLaunchStyle: .modal) { [weak self] in
            workflow.abandon()
            guard case .args(let order as Order) = $0 else { return }
            self?.proceedInWorkflow(order)
        }
    }

    func shouldLoad() -> Bool {
        if let location = order.location,
            location.orderTypes.count == 1 {
            order.orderType = location.orderTypes.first
            proceedInWorkflow(order)
        }
        return (order.location?.orderTypes.count ?? 0) > 1
    }
}
