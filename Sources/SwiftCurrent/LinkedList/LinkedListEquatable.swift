//  swiftlint:disable:this file_name
//  Reason: The file name reflects the contents of the file.
//
//  LinkedListEquatable.swift
//  Workflow
//
//  Created by Tyler Thompson on 11/11/18.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
extension LinkedList: Equatable where Value: Equatable {
    /// :nodoc: Equatable protocol requirement.
    public static func == (lhs: LinkedList<Value>, rhs: LinkedList<Value>) -> Bool {
        lhs.toArray() == rhs.toArray()
    }

    /**
     Returns a boolean indicating whether the given value is present in the linked list.
     - Parameter element: the value to check against the linked list.
     */
    public func contains(_ element: Element.Value) -> Bool {
        contains { $0.value == element }
    }
}
