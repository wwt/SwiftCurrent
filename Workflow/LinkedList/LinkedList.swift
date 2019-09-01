//
//  LinkedList.swift
//  iOSCSS
//
//  Created by Tyler Thompson on 11/10/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
public class LinkedList<Value> : Sequence, ExpressibleByArrayLiteral, CustomStringConvertible {
    public typealias Element = LinkedList.Node<Value>
    public typealias Index = Int
    public typealias SubSequence = LinkedList<Value>
    public typealias Iterator = LinkedListIterator<Element>
    
    public var startIndex  : LinkedList.Index  { return 0 }
    public var endIndex    : LinkedList.Index  { return count }
    public var description : String            { return toArray().description }
    public var isEmpty     : Bool              { return first == nil }
    public var count       : LinkedList.Index  {
        return reduce(0, { c, _ in
            c+1
        })
    }
    
    public var first       : Element? = nil
    public var last        : Element? { return first?.traverseToEnd() }
    
    required public convenience init(arrayLiteral elements: Value...) {
        self.init(elements)
    }
    
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
    
    public init(_ node:Element?) {
        first = node
    }
        
    public func makeIterator() -> LinkedList<Value>.LinkedListIterator<LinkedList<Value>.Node<Value>> {
        return LinkedListIterator(first)
    }
    
    func toArray() -> [Element.Value] {
        return map { $0.value }
    }
}
