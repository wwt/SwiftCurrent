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
        
    }

    @IBAction func secondFoodChoice() {
        
    }

    @IBAction func thirdFoodChoice() {
        
    }
}

extension FoodSelectionViewController: FlowRepresentable {
    func shouldLoad(with order: Order) -> Bool {
        self.order = order
        return true
    }
}
