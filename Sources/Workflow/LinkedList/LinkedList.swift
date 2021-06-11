//
//  LinkedList.swift
//  Workflow
//
//  Created by Tyler Thompson on 11/10/18.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
/**
 A doubly linked list.
 
 ### Discussion
 A workflow is ultimately a doubly linked list. This is the underlying sequence type used.
 */

public class LinkedList<Value>: Sequence, CustomStringConvertible {
    public typealias Element = LinkedList.Node<Value>
    public typealias Index = Int
    public typealias SubSequence = LinkedList<Value>
    public typealias Iterator = LinkedListIterator<Element>

    /**
     The beginning index of the linked list (0 indexed).
     - Complexity: O(1)
     */
    public var startIndex: LinkedList.Index { 0 }
    /**
     The last index in the list.
     - Complexity: O(n). The linked list must traverse to the end.
     */
    public var endIndex: LinkedList.Index { count }
    /// A textual representation of the linked list and its elements.
    public var description: String { toArray().description }
    /**
     A boolean to indicate whether the linked list contains any values.
     - Complexity: O(1)
     */
    public var isEmpty: Bool { first == nil }
    /**
     The number of elements in the linked list.
     - Complexity: O(n). The linked list must traverse to the end to determine the count.
     */
    public var count: LinkedList.Index {
        reduce(0) { c, _ in c + 1 }
    }

    /// The first node in the linked list.
    public var first: Element?

    /** The last node in the linked list.
     - Complexity: O(n). The linked list must traverse to the end.
     */
    public var last: Element? { first?.traverseToEnd() }

    /// Creates a copy of a `LinkedList` by providing the first node, and copying it.
    public required init(_ node: Element? = nil) {
        first = node?.copy()
    }

    /** Creates a `LinkedList` by providing the first node in the list.
    - Important: This can potentially cause memory retention issues, you are passing a reference, be aware.
     */
    public required init(withoutCopying node: Element?) {
        first = node
    }

    deinit {
        removeAll()
    }

    /// Returns an iterator over the elements of this sequence.
    public func makeIterator() -> Iterator {
        LinkedListIterator(first)
    }

    func toArray() -> [Element.Value] {
        map { $0.value }
    }

    /**
     Returns the last element of the sequence that satisfies the given
     predicate.

     - Parameter predicate: A closure that takes an element of the sequence as
     its argument and returns a Boolean value indicating whether the
     element is a match.
     - Returns: The last element of the sequence that satisfies `predicate`,
     or `nil` if there is no element that satisfies `predicate`.
     - Complexity: O(n). The linked list must traverse to the end.

     #### Example
     This example uses the `last(where:)` method to find the last
     negative number in an array of integers:
     ```swift
     let numbers = LinkedList([3, 7, 4, -2, 9, -6, 10, 1])
     if let lastNegative = numbers.last(where: { $0.value < 0 }) {
        print("The last negative number is \(lastNegative).")
     }
     // Prints "The last negative number is -6."
     ```
     */
    public func last(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        var lastElement: Element?

        for element in self where try predicate(element) {
            lastElement = element
        }

        return lastElement
    }
}
