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
    /// Sorts the linked list in place using a merge sort.
    public func sort() {
        guard first?.next != nil else { return }
        let sorted = LinkedList(mergeSort(first?.copy()) { $0 <= $1 })
        let copy = sorted.first?.copy()
        first = copy
    }

    /// Returns a sorted version of the linked list.
    public func sorted() -> LinkedList<Value> {
        LinkedList(mergeSort(first?.copy()) { $0 <= $1 })
    }

    /// Returns the maximum concrete value in the linked list; nil if there is none.
    public func max() -> Value? {
        guard var max = first?.value else { return nil }
        forEach { max = Swift.max(max, $0.value) }
        return max
    }

    /// Returns the minimum concrete value in the linked list; nil if there is none.
    public func min() -> Value? {
        guard var min = first?.value else { return nil }
        forEach { min = Swift.min(min, $0.value) }
        return min
    }
}
