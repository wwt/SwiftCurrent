//
//  FoodSelectionViewController.swift
//  WorkflowExample
//
//  Created by Tyler Thompson on 9/24/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
import DynamicWorkflow

class FoodSelectionViewController: UIWorkflowItem<Order>, StoryboardLoadable {
    var order:Order?
    
    @IBAction func firstFoodChoice() {
        order?.shoppingCart.append(Food(name: "Combo #1"))
        proceedInWorkflow(order)
    }

    @IBAction func secondFoodChoice() {
        order?.shoppingCart.append(Food(name: "Combo #2"))
        proceedInWorkflow(order)
    }

    @IBAction func thirdFoodChoice() {
        order?.shoppingCart.append(Food(name: "Combo #3"))
        proceedInWorkflow(order)
    }
}

extension FoodSelectionViewController: FlowRepresentable {
    func shouldLoad(with order: Order) -> Bool {
        self.order = order
        return true
    }
}
