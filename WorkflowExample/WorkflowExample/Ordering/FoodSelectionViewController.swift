//
//  FoodSelectionViewController.swift
//  WorkflowExample
//
//  Created by Tyler Thompson on 9/24/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import WorkflowUIKit

class FoodSelectionViewController: UIWorkflowItem<Order, Order>, StoryboardLoadable {
    var order: Order

    required init?(coder: NSCoder, with order: Order) {
        self.order = order
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) { fatalError() }

    @IBAction private func firstFoodChoice() {
        order.shoppingCart.append(Food(name: "Combo #1"))
        proceedInWorkflow(order)
    }

    @IBAction private func secondFoodChoice() {
        order.shoppingCart.append(Food(name: "Combo #2"))
        proceedInWorkflow(order)
    }

    @IBAction private func thirdFoodChoice() {
        order.shoppingCart.append(Food(name: "Combo #3"))
        proceedInWorkflow(order)
    }
}
