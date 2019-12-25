//
//  LinkedList.swift
//  iOSCSS
//
//  Created by Tyler Thompson on 11/10/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
/**
 LinkedList: A sequence type used to create a doubly linked list
 
 ### Discussion:
 A workflow is ultimately a doubly linked list. This is the underlying sequence type used.
 */

public class LinkedList<Value> : Sequence, CustomStringConvertible {
    public typealias Element = LinkedList.Node<Value>
    public typealias Index = Int
    public typealias SubSequence = LinkedList<Value>
    public typealias Iterator = LinkedListIterator<Element>
    
    /// startIndex: The beginning index of the linked list (0 indexed)
    /// - Complexity: O(1)
    public var startIndex  : LinkedList.Index  { return 0 }
    /// endIndex: The last index in the list
    /// - Complexity: O(n). The LinkedList must traverse to the end to determine the count
    public var endIndex    : LinkedList.Index  { return count }
    /// description: A property indicating what to show when the LinkedList is printed.
    public var description : String            { return toArray().description }
    /// isEmpty: A boolean to indicate whether the linked list contains any values
    /// - Complexity: O(1)
    public var isEmpty     : Bool              { return first == nil }
    /// endIndex: The last index in the list
    /// - Complexity: O(n). The linked list must traverse to the end to determine the count
    public var count       : LinkedList.Index  {
        return reduce(0, { c, _ in
            c+1
        })
    }
    
    /// first: The first node in the list
    public var first       : Element? = nil
    /// last: The last node in the list
    /// - Complexity: O(n). The LinkedList must traverse to the end to determine the count
    public var last        : Element? { return first?.traverseToEnd() }
    
    public convenience init(_ elements: Value...) {
        self.init(elements)
    }

    public convenience init(_ elements: [Value])  {
        let collection = elements.map { Element(with: $0) }
        for (i, node) in collection.enumerated() {
            node.previous = collection[safe: i-1]
            node.next = collection[safe: i+1]
        }

        self.init(collection.first)
    }
    
    /// init(elements): A LinkedList can be instantiated simply by providing the first node in the list
    public init(_ node:Element?) {
        first = node
    }
    
    public func makeIterator() -> Iterator {
        return LinkedListIterator(first)
    }
    
    func toArray() -> [Element.Value] {
        return map { $0.value }
    }
}
