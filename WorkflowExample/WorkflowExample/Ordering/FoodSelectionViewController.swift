//
//  FoodSelectionViewController.swift
//  WorkflowExample
//
//  Created by Tyler Thompson on 9/24/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
import Workflow

class FoodSelectionViewController: UIWorkflowItem<Order, Order>, StoryboardLoadable {
    var order:Order?
    
    @IBAction func firstFoodChoice() {
        order?.shoppingCart.append(Food(name: "Combo #1"))
        guard let order = order else { return }
        proceedInWorkflow(order)
    }

    @IBAction func secondFoodChoice() {
        order?.shoppingCart.append(Food(name: "Combo #2"))
        guard let order = order else { return }
        proceedInWorkflow(order)
    }

    @IBAction func thirdFoodChoice() {
        order?.shoppingCart.append(Food(name: "Combo #3"))
        guard let order = order else { return }
        proceedInWorkflow(order)
    }
}

extension FoodSelectionViewController: FlowRepresentable {
    func shouldLoad(with order: Order) -> Bool {
        defer {
            self.order = order
        }
        return true
    }
}
