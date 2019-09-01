//
//  MutatingOperations.swift
//  iOSCSS
//
//  Created by Tyler Thompson on 11/11/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
extension LinkedList {
    public func append(_ element:Value) {
        let node = Element(with: element)
        
        guard first != nil else {
            first = node
            return
        }

        node.previous = last
        last?.next = node
    }
    
    public func append<S>(contentsOf newElements: S) where S : Sequence, Value == S.Element {
        let collection = newElements.map { Element(with: $0) }
        for (i, node) in collection.enumerated() {
            node.previous = collection[safe: i-1]
            node.next = collection[safe: i+1]
        }
        guard first != nil else {
            first = collection.first
            return
        }
        let l = last
        collection.first?.previous = l
        l?.next = collection.first
    }
    
    public func insert(_ element:Value, atIndex i:Index) {
        let existingNode:Element? = first?.traverse(i)
        let newNode = Element(with: element)
        
        newNode.previous = existingNode?.previous
        newNode.next = existingNode
        
        existingNode?.previous?.next = newNode
        
        existingNode?.previous = newNode
    }
    
    public func insert<C>(contentsOf newElements: C, at i: Int) where C : Collection, Value == C.Element {
        let existingNode:Element? = first?.traverse(i)
        let collection = newElements.map { Element(with: $0) }
        for (i, node) in collection.enumerated() {
            node.previous = collection[safe: i-1]
            node.next = collection[safe: i+1]
        }

        let newNode = collection.first
        
        newNode?.previous = existingNode?.previous
        collection.last?.next = existingNode
        
        existingNode?.previous?.next = collection.first
        
        existingNode?.previous = collection.last
    }
    
    public func remove(at i:Index) {
        let node:Element? = first?.traverse(i)
        node?.previous?.next = node?.next
        node?.next?.previous = node?.previous
    }
    
    public func removeFirst(_ n:Int = 1) {
        guard n > 0 else { return }
        let f = first
        first = first?.traverse(n)
        first?.previous?.next = nil
        first?.previous = nil
        
        f?.removeTillEnd()
    }
    
    public func removeLast(_ n:Int = 1) {
        guard n > 0 else { return }
        guard !(last === first) else {
            first = nil
            return
        }
        let l = last?.traverse(-n)
        l?.next?.removeTillEnd()
        l?.next = nil
    }
    
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
    
    public func removeAll() {
        first?.next?.removeTillEnd()
        first = nil
    }
    
    public func swapAt(_ i:Int, _ j:Int) {
        var firstElement:Element?
        var secondElement:Element?
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
    
    public func replace(atIndex index: Int, withItem newItem: Value) {
        first?.traverse(index)?.value = newItem
    }
    
    public func reverse() {
        first = reversed().first
    }
    
    public func sort(by comparator:(Value, Value) -> Bool) {
        guard first?.next != nil else { return }
        first = LinkedList(mergeSort(first, by: comparator)).first
    }
}
