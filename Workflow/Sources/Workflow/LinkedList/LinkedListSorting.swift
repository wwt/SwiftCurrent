//  swiftlint:disable:this file_name
//  Reason: The file name reflects the contents of the file.
//
//  LinkedListSorting.swift
//  Workflow
//
//  Created by Tyler Thompson on 11/11/18.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
extension LinkedList {
    func mergeSort(_ head: Element?, by comparator: (Value, Value) -> Bool) -> Element? {
        guard head?.next != nil else { return head }
        let middle = splitHalf(head)
        let nextOfMiddle = middle?.next
        middle?.next = nil

        let left = mergeSort(head, by: comparator)
        let right = mergeSort(nextOfMiddle, by: comparator)

        let sorted = sortedMerge(upper: left, lower: right, by: comparator)
        return sorted
    }

    private func sortedMerge(upper: Element?, lower: Element?, by comparator: (Value, Value) -> Bool) -> Element? {
        var result: Element?
        guard let a = upper else { return lower }
        guard let b = lower else { return upper }

        if comparator(a.value, b.value) {
            result = a
            result?.next = sortedMerge(upper: a.next, lower: b, by: comparator)
        } else {
            result = b
            result?.next = sortedMerge(upper: a, lower: b.next, by: comparator)
        }
        return result
    }

    private func splitHalf(_ head: Element?) -> Element? {
        var fast = head?.next
        var slow = head
        while fast != nil {
            fast = fast?.next
            if fast != nil {
                slow = slow?.next
                fast = fast?.next
            }
        }
        return slow
    }
}
