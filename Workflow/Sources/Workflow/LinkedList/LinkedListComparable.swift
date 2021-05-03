//  swiftlint:disable:this file_name
//  Reason: The file name reflects the contents of the file.
//
//  LinkedListComparable.swift
//  Workflow
//
//  Created by Tyler Thompson on 11/11/18.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
extension LinkedList where Value: Comparable {
    /// Sorts the linked list in place using a merge sort
    public func sort() {
        guard first?.next != nil else { return }
        first = LinkedList(mergeSort(first) { $0 <= $1 }).first
    }

    /**
    A non-mutating sort method
    - Returns: A sorted version of the LinkedList
    */
    public func sorted() -> LinkedList<Value> {
        LinkedList(mergeSort(first) { $0 <= $1 })
    }

    /**
    Returns the maximum value in the comparable LinkedList
    - Returns: The maximum concrete value in the LinkedList or nil if there is none
    */
    public func max() -> Value? {
        guard var max = first?.value else { return nil }
        forEach { max = Swift.max(max, $0.value) }
        return max
    }

    /**
    Returns the minimum value in the comparable LinkedList
    - Returns: The minimum concrete value in the LinkedList or nil if there is none
    */
    public func min() -> Value? {
        guard var min = first?.value else { return nil }
        forEach { min = Swift.min(min, $0.value) }
        return min
    }
}
