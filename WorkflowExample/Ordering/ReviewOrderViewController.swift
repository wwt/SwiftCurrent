//
//  ReviewOrderViewController.swift
//  WorkflowExample
//
//  Created by Tyler Thompson on 9/24/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import DynamicWorkflow

class ReviewOrderViewController: UIWorkflowItem<Order>, StoryboardLoadable {
    var order:Order?
    
    @IBOutlet weak var locationNameLabel:UILabel! {
        willSet(this) {
            this.text = order?.location?.name
        }
    }
    
    @IBOutlet weak var menuLabel:UILabel! {
        willSet(this) {
            this.text = order?.menuType == .catering ? "Catering Menu" : "Regular Menu"
        }
    }
    
    @IBOutlet weak var orderTypeLabel:UILabel! {
        willSet(this) {
            guard let order = order else { return }
            this.text = order.orderType == .pickup ? "Pickup" : "Delivery"
        }
    }
    
    @IBOutlet weak var foodChoiceLabel:UILabel! {
        willSet(this) {
            this.text = order?.shoppingCart.compactMap { $0.name }.joined(separator: ", ")
        }
    }
    
//    @IBAction func editLocation() {
//
//    }
}

extension ReviewOrderViewController: FlowRepresentable {
    func shouldLoad(with order: Order) -> Bool {
        self.order = order
        return true
    }
}
