//
//  MenuSelectionViewController.swift
//  WorkflowExample
//
//  Created by Tyler Thompson on 9/24/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
import DynamicWorkflow

class MenuSelectionViewController: UIWorkflowItem<Order>, StoryboardLoadable {
    var order:Order?
    
    @IBAction func cateringMenu() {
        order?.menuType = .catering
        proceedInWorkflow(order)
    }
    
    @IBAction func regularMenu() {
        order?.menuType = .regular
        proceedInWorkflow(order)
    }
}

extension MenuSelectionViewController: FlowRepresentable {
    func shouldLoad(with order: Order) -> Bool {
        self.order = order
        if (order.location?.menuTypes.count == 1) {
            var o = order
            o.menuType = order.location?.menuTypes.first
            proceedInWorkflow(o)
        }
        return false
        return (order.location?.menuTypes.count ?? 0) > 1
    }
}
