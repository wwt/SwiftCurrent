//
//  Order.swift
//  WorkflowExample
//
//  Created by Tyler Thompson on 9/1/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
struct Order: Equatable {
    static func == (lhs: Order, rhs: Order) -> Bool {
        lhs.invisibleId == rhs.invisibleId
    }

    fileprivate let invisibleId = UUID()

    let location: Location?
    var orderType: OrderType?
    var menuType: MenuType?
    var shoppingCart: [Food] = []
    init (location: Location?) {
        self.location = location
    }
}

enum MenuType {
    case catering
    case regular
}

struct Food {
    let name: String
}
