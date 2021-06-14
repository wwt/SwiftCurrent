//
//  MenuSelectionViewController.swift
//  WorkflowExample
//
//  Created by Tyler Thompson on 9/24/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import SwiftCurrent_UIKit

class MenuSelectionViewController: UIWorkflowItem<Order, Order>, StoryboardLoadable {
    var order: Order

    required init?(coder: NSCoder, with order: Order) {
        self.order = order
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) { fatalError() }

    @IBAction private func cateringMenu() {
        order.menuType = .catering
        proceedInWorkflow(order)
    }

    @IBAction private func regularMenu() {
        order.menuType = .regular
        proceedInWorkflow(order)
    }

    func shouldLoad() -> Bool {
        if order.location?.menuTypes.count == 1 {
            order.menuType = order.location?.menuTypes.first
            proceedInWorkflow(order)
        }
        return (order.location?.menuTypes.count ?? 0) > 1
    }
}
