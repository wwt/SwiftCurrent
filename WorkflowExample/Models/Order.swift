//
//  Order.swift
//  WorkflowExample
//
//  Created by Tyler Thompson on 9/1/19.
//  Copyright © 2019 Tyler Tompson. All rights reserved.
//

import Foundation
struct Order {
    let location:Location?
    var orderType:OrderType?
    var menuType:MenuType?
    init (location:Location?) {
        self.location = location
    }
}

enum MenuType {
    case catering
    case regular
}
