//
//  Equatable.swift
//  iOSCSS
//
//  Created by Tyler Thompson on 11/11/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
extension LinkedList : Equatable where Value : Equatable {
    public static func == (lhs:LinkedList<Value>, rhs: LinkedList<Value>) -> Bool {
        return lhs.toArray() == rhs.toArray()
    }
    public func contains(_ element:Element.Value) -> Bool {
        return contains(where: { $0.value == element })
    }
}

