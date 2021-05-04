//
//  EnterAddressViewController.swift
//  WorkflowExample
//
//  Created by Tyler Thompson on 9/24/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import Workflow
import WorkflowUIKit

class EnterAddressViewController: UIWorkflowItem<Order, Order>, StoryboardLoadable {
    var order: Order

    required init?(coder: NSCoder, with order: Order) {
        self.order = order
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) { nil }

    @IBAction private func saveAddress() {
        order.orderType = .delivery(Address(line1: "MyAddress", line2: "", city: "", state: "", zip: ""))
        proceedInWorkflow(order)
    }
}
