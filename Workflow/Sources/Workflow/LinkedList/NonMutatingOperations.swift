//
//  NonMutatingOperations.swift
//  iOSCSS
//
//  Created by Tyler Thompson on 11/11/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
extension LinkedList {
    /// reversed: Return a new version of the LinkedList with all elements reversed
    /// - Returns: A new reversed version of the LinkedList
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

    /// replacing: Return a new version of the LinkedList with a specific element replaced
    /// - Parameter index: The index of the node who's concrete value should be replaced
    /// - Parameter newItem: The concrete value to replace
    /// - Returns: A new version of the LinkedList with a specific element replaced
    public func replacing(atIndex index: Int, withItem newItem: Value) -> LinkedList<Value> {
        guard let first = first else { return self }
        let copy = LinkedList<Value>(first.copy())
        copy.replace(atIndex: index, withItem: newItem)
        return copy
    }

    /// sorted: Return a new sorted version of the LinkedList
    /// - Parameter comparator: A function that takes in 2 concrete types and indicates how they should be sorted
    /// - Complexity: O(nLogn) This uses Merge Sort under the covers and is more performant than the built in alternative
    /// - Returns: A new sorted version of the LinkedList
    public func sorted(by comparator: (Value, Value) -> Bool) -> LinkedList<Value> {
        guard first?.next != nil else { return self }
        return LinkedList(mergeSort(first, by: comparator))
    }

    /// dropFirst: Return a new version of the LinkedList without the first n items
    /// - Parameter n: The number of items to drop from the start of the list
    /// - Returns: A new version of the LinkedList without the first n items
    /// - Note: If you pass in an index that is out of the range of the LinkedList an empty LinkedList will be returned
    public func dropFirst(_ n: Int = 1) -> SubSequence {
        guard n > 0 else { return self }
        let copy = first?.copy().traverse(n)
        copy?.previous = nil
        return LinkedList(copy)
    }

    /// dropFirst: Return a new version of the LinkedList without the last n items
    /// - Parameter n: The number of items to drop from the end of the list
    /// - Returns: A new version of the LinkedList without the last n items
    /// - Note: If you pass in an index that is out of the range of the LinkedList an empty LinkedList will be returned
    public func dropLast(_ n: Int = 1) -> SubSequence {
        guard n > 0 else { return self }
        let l = last?.copy().traverse(-n)
        l?.next = nil
        return LinkedList(l?.traverseToBeginning())
    }

    /// drop(while): Return a new version of the LinkedList without the last n items
    /// - Parameter predicate: A closure that takes in the concrete type the node wraps and returns a boolean indicating whether it should drop from the list
    /// - Returns: A new version of the LinkedList without the last n items
    /// - Note: If you pass in an index that is out of the range of the LinkedList an empty LinkedList will be returned
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

    /// prefix(maxLength): Return a new version of the LinkedList with just the first n items
    /// - Parameter maxLength: The number of items to return
    /// - Returns: A new version of the LinkedList with just the first n items
    /// - Note: If you pass in an index that is greater than the size of the LinkedList you'll get the full list. If you send in an index smaller than the size of the LinkedList you'll get an empty list back.
    public func prefix(_ maxLength: Int) -> SubSequence {
        guard maxLength > 0 else { return SubSequence() }
        let copy = first?.copy().traverse(maxLength-1)
        copy?.next = nil
        return SubSequence(copy?.traverseToBeginning())
    }

    /// prefix(while): Return a new version of the LinkedList with just the first n items
    /// - Parameter predicate: A closure that takes in the concrete type the node wraps and returns a boolean indicating whether it should be included in the new list
    /// - Returns: A a new version of the LinkedList with just the first n items
    /// - Note: If you pass in an index that is greater than the size of the LinkedList you'll get the full list. If you send in an index smaller than the size of the LinkedList you'll get an empty list back.
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

    /// suffix(maxLength): Return a new version of the LinkedList with just the last n items
    /// - Parameter maxLength: The number of items to return
    /// - Returns: A new version of the LinkedList with just the last n items
    public func suffix(_ maxLength: Int) -> SubSequence {
        guard maxLength > 0 else { return SubSequence() }
        let copy = last?.copy().traverse(-(maxLength-1))
        copy?.previous = nil
        return LinkedList(copy)
    }
}
