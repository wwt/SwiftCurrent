//  swiftlint:disable:this file_name
//  Reason: The file name reflects the contents of the file.
//
//  LinkedListNonMutatingOperations.swift
//  Workflow
//
//  Created by Tyler Thompson on 11/11/18.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
extension LinkedList {
    /// Returns a new version of the LinkedList with all elements reversed.
    public func reversed() -> LinkedList<Value> {
        var current = first
        var previous: Element?
        var next: Element?

        while let c = current {
            next = c.next
            c.next = previous
            c.previous = next
            previous = c
            current = next
        }
        return LinkedList<Value>(previous)
    }

    /**
     Returns a new version of the linked list with a specific element replaced.
     - Parameter index: the index of the node whose concrete value should be replaced.
     - Parameter newItem: the concrete value to replace.
     */
    public func replacing(atIndex index: Int, withItem newItem: Value) -> LinkedList<Value> {
        guard let first = first else { return self }
        let copy = LinkedList(first.copy())
        copy.replace(atIndex: index, withItem: newItem)
        return copy
    }

    /**
     Returns a new, sorted version of the linked list.
     - Parameter comparator: a closure that takes in 2 concrete types and indicates how they should be sorted.
     - Complexity: O(n log(n)) This uses Merge Sort under the covers and is more performant than the built in alternative.
     */
    public func sorted(by comparator: (Value, Value) -> Bool) -> LinkedList<Value> {
        guard first?.next != nil else { return self }
        return LinkedList(mergeSort(first, by: comparator))
    }

    /**
     Returns a new version of the linked list without the first n items.
     - Parameter n: the number of items to drop from the start of the list.
     - Important: If you pass in an index that is out of the range of the linked list an empty `LinkedList` will be returned.
     */
    public func dropFirst(_ n: Int = 1) -> SubSequence {
        guard n > 0 else { return self }
        let copy = first?.copy().traverse(n)
        copy?.previous = nil
        return LinkedList(copy)
    }

    /**
     Returns a new version of the linked list without the last n items.
     - Parameter n: the number of items to drop from the end of the list.
     - Important: If you pass in an index that is out of the range of the linked list an empty `LinkedList` will be returned.
     */
    public func dropLast(_ n: Int = 1) -> SubSequence {
        guard n > 0 else { return self }
        let l = last?.copy().traverse(-n)
        l?.next = nil
        return LinkedList(l?.traverseToBeginning())
    }

    /**
     Returns a linked list by skipping elements while predicate returns true and returning the remaining elements.
     - Parameter predicate: a closure that takes a concrete type of the node as its argument and returns true if the element should be skipped or false if it should be included. Once the predicate returns false it will not be called again.
     */
    public func drop(while predicate: (Value) throws -> Bool) rethrows -> SubSequence {
        guard var l = last?.copy() else { return SubSequence() }
        while try predicate(l.value) {
            if let prev = l.previous {
                l = prev
            } else { break }
        }
        l.next = nil
        return SubSequence(l)
    }

    /**
     Returns a new version of the linked list with just the first n items.
     - Parameter maxLength: the number of items to return.
     - Important: If you pass in an index that is greater than the size of the linked list you'll get the full list. If you send in an index of 0 or smaller, you'll get an empty list back.
     */
    public func prefix(_ maxLength: Int) -> SubSequence {
        guard maxLength > 0 else { return SubSequence() }
        let copy = first?.copy().traverse(maxLength - 1)
        copy?.next = nil
        return SubSequence(copy?.traverseToBeginning())
    }

    /**
     Returns a linked list containing the initial elements until predicate returns false and skipping the remaining elements.
     - Parameter predicate: a closure that takes a concrete type of the node as its argument and returns true if the element should be included or false if it should be excluded. Once the predicate returns false it will not be called again.
     */
    public func prefix(while predicate: (Value) throws -> Bool) rethrows -> SubSequence {
        guard var f = first?.copy() else { return SubSequence() }
        while try predicate(f.value) {
            if let next = f.next {
                f = next
            } else { break }
        }
        f.next = nil
        return SubSequence(f)
    }

    /**
     Returns a new version of the linked list with just the last n items.
     - Parameter maxLength: the number of items to return.
     */
    public func suffix(_ maxLength: Int) -> SubSequence {
        guard maxLength > 0 else { return SubSequence() }
        let copy = last?.copy().traverse(-(maxLength - 1))
        copy?.previous = nil
        return LinkedList(copy)
    }
}
