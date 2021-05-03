//  swiftlint:disable:this file_name
//  Reason: The file name reflects the contents of the file.
//
//  LinkedListMutatingOperations.swift
//  Workflow
//
//  Created by Tyler Thompson on 11/11/18.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
extension LinkedList {
    /**
     Appends a new node to the end of the LinkedList
     - Parameter element: The concrete value that should be appended
     - Note: This operation mutates the original LinkedList
     */
    public func append(_ element: Value) {
        let node = Element(with: element)

        guard first != nil else {
            first = node
            return
        }

        node.previous = last
        last?.next = node
    }
    /**
    Appends a collection of nodes to the end of the LinkedList
    - Parameter newElements: An sequence of concrete elements that should be appended
    - Note: This operation mutates the original LinkedList
     */
    public func append<S>(contentsOf newElements: S) where S: Sequence, Value == S.Element {
        let collection = newElements.map { Element(with: $0) }
        for (i, node) in collection.enumerated() {
            node.previous = collection[safe: i - 1]
            node.next = collection[safe: i + 1]
        }
        guard first != nil else {
            first = collection.first
            return
        }
        let l = last
        collection.first?.previous = l
        l?.next = collection.first
    }

    /**
    Inserts a new node at a specified location
    - Parameter element: The concrete value that should be inserted
    - Parameter i: The index the value should be inserted at
    - Note: This operation mutates the original LinkedList
     */
    public func insert(_ element: Value, atIndex i: Index) {
        let existingNode: Element? = first?.traverse(i)
        let newNode = Element(with: element)

        newNode.previous = existingNode?.previous
        newNode.next = existingNode

        existingNode?.previous?.next = newNode

        existingNode?.previous = newNode
    }

    /**
     Inserts a sequences of new nodes at a specified location
     - Parameter newElements: A sequences of concrete values that should be inserted
     - Parameter i: The index the value should be inserted at
     - Note: This operation mutates the original LinkedList
     */
    public func insert<C>(contentsOf newElements: C, at i: Index) where C: Collection, Value == C.Element {
        let existingNode: Element? = first?.traverse(i)
        let collection = newElements.map { Element(with: $0) }
        for (i, node) in collection.enumerated() {
            node.previous = collection[safe: i - 1]
            node.next = collection[safe: i + 1]
        }

        let newNode = collection.first

        newNode?.previous = existingNode?.previous
        collection.last?.next = existingNode

        existingNode?.previous?.next = collection.first

        existingNode?.previous = collection.last
    }

    /**
    Removes a node at the specified index
    - Parameter i: The index the value should be removed from
    - Note: This operation mutates the original LinkedList
    - Note: If you pass an index greater than the count of the LinkedList this will be a NO-OP
     */
    public func remove(at i: Index) {
        let node: Element? = first?.traverse(i)
        node?.previous?.next = node?.next
        node?.next?.previous = node?.previous
    }

    /**
    Removes a node at the specified index
    - Parameter predicate: A closure indicating whether that node should be removed
    - Note: This operation mutates the original LinkedList
     */
    public func remove(where predicate: (Element) -> Bool) {
        _ = first?.traverse {
            if predicate($0) {
                $0.previous?.next = $0.next
                $0.next?.previous = $0.previous
            }
            return false
        }
    }

    /**
    Removes the first n nodes from the LinkedList
    - Parameter n: The number of nodes that should be removed
    - Note: This operation mutates the original LinkedList
    - Note: If you pass a value greater than the count of the LinkedList you will remove all items
     */
    public func removeFirst(_ n: Int = 1) {
        guard n > 0 else { return }
        let f = first
        first = first?.traverse(n)
        first?.previous?.next = nil
        first?.previous = nil

        f?.removeTillEnd()
    }

    /// removeLast: Removes the last n nodes from the LinkedList
    /// - Parameter n: The number of nodes that should be removed
    /// - Note: This operation mutates the original LinkedList
    /// - Note: If you pass a value greater than the count of the LinkedList you will remove all items
    public func removeLast(_ n: Int = 1) {
        guard n > 0 else { return }
        guard !(last === first) else {
            first = nil
            return
        }
        let l = last?.traverse(-n)
        l?.next?.removeTillEnd()
        l?.next = nil
    }

    /// popLast: Removes the last n nodes from the LinkedList and returns the removed concrete type
    /// - Note: This operation mutates the original LinkedList
    /// - Returns: The concrete type the node encapsulated that was removed
    public func popLast() -> Value? {
        let l = last
        guard !(l === first) else {
            first = nil
            return l?.value
        }
        let v = l?.value
        l?.previous?.next = nil
        l?.previous = nil
        return v
    }

    /// removeAll: Removes all nodes from the LinkedList
    /// - Note: This operation mutates the original LinkedList
    public func removeAll() {
        first?.next?.removeTillEnd()
        first = nil
    }

    /// swapAt: Swaps the concrete values of 2 nodes
    /// - Parameter i: The index of one of the items to be swapped
    /// - Parameter j: The index of the second item to be swapped
    /// - Note: This operation mutates the original LinkedList
    /// - Note: If you call this with an invalid index you will cause a `fatalError` and stop execution of the process
    public func swapAt(_ i: Int, _ j: Int) {
        var firstElement: Element?
        var secondElement: Element?
        enumerated().forEach {
            if $0.offset == i {
                firstElement = $0.element
            }
            if $0.offset == j {
                secondElement = $0.element
            }
        }
        guard let f = firstElement else {
            fatalError("Index: \(i) beyond bounds of linked list")
        }
        guard let s = secondElement else {
            fatalError("Index: \(j) beyond bounds of linked list")
        }
        swap(&f.value, &s.value)
    }

    /// replace: Replaces the concrete value of the node at the specified index
    /// - Parameter index: The index of the node with the value to be replaced
    /// - Parameter newItem: The concrete value that should replace the old value
    /// - Note: This operation mutates the original LinkedList
    /// - Note: If you call this with an invalid index this will be a NO-OP
    public func replace(atIndex index: Int, withItem newItem: Value) {
        first?.traverse(index)?.value = newItem
    }

    /// reverse: Reverse the LinkedList
    /// - Note: This operation mutates the original LinkedList
    public func reverse() {
        first = reversed().first
    }

    /// sort: Sorts the linkedList
    /// - Parameter comparator: A function that takes in 2 concrete types and indicates how they should be sorted
    /// - Note: This operation mutates the original LinkedList
    /// - Complexity: O(nLogn) This uses Merge Sort under the covers and is more performant than the built in alternative
    public func sort(by comparator: (Value, Value) -> Bool) {
        guard first?.next != nil else { return }
        first = LinkedList(mergeSort(first, by: comparator)).first
    }
}
