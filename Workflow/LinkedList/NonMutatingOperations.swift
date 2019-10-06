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
        var previous:Element?
        var next:Element?
        
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
    public func sorted(by comparator:(Value, Value) -> Bool) -> LinkedList<Value> {
        guard first?.next != nil else { return self }
        return LinkedList(mergeSort(first, by: comparator))
    }
    
    public func dropFirst(_ n: Int = 1) -> SubSequence {
        guard n > 0 else { return self }
        let copy = first?.copy().traverse(n)
        copy?.previous = nil
        return LinkedList(copy)
    }
    
    public func dropLast(_ n: Int = 1) -> SubSequence {
        guard n > 0 else { return self }
        let l = last?.copy().traverse(-n)
        l?.next = nil
        return LinkedList(l?.traverseToBeginning())
    }
    
    public func drop(while predicate: (Element) throws -> Bool) rethrows -> SubSequence {
        guard var l = last?.copy() else { return [] }
        while (try predicate(l)) {
            if let prev = l.previous {
                l = prev
            } else { break }
        }
        l.next = nil
        return LinkedList(l)
    }
    
    public func prefix(_ maxLength: Int) -> SubSequence {
        guard maxLength > 0 else { return [] }
        let copy = first?.copy().traverse(maxLength-1)
        copy?.next = nil
        return LinkedList(copy?.traverseToBeginning())
    }
    
    public func prefix(while predicate: (Element) throws -> Bool) rethrows -> SubSequence {
        guard var f = first?.copy() else { return [] }
        while (try predicate(f)) {
            if let next = f.next {
                f = next
            } else { break }
        }
        f.next = nil
        return LinkedList(f)
    }
    
    public func suffix(_ maxLength: Int) -> SubSequence {
        guard maxLength > 0 else { return [] }
        let copy = last?.copy().traverse(-(maxLength-1))
        copy?.previous = nil
        return LinkedList(copy)
    }
    
    public func split(maxSplits: Int, omittingEmptySubsequences: Bool, whereSeparator isSeparator: (Element) throws -> Bool) rethrows -> [SubSequence] {
        let splitNodeArr = (try? map { $0 }.split(maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences, whereSeparator: isSeparator)) ?? []
        return splitNodeArr.map { LinkedList($0.map { $0.value }) }
    }
}
