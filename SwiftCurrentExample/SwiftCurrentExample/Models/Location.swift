//
//  Location.swift
//  SwiftCurrentExample
//
//  Created by Tyler Thompson on 9/1/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
struct Address {
    let line1: String
    let line2: String
    let city: String
    let state: String
    let zip: String
}

struct Location {
    let name: String
    let address: Address
    let orderTypes: [OrderType]
    let menuTypes: [MenuType]
}

enum OrderType {
    case pickup
    case delivery(Address)
}

extension OrderType: Equatable {
    static func == (lhs: OrderType, rhs: OrderType) -> Bool {
        switch (lhs, rhs) {
        case (.pickup, .pickup): return true
        case (.delivery, .delivery): return true
        default: return false
        }
    }
}
