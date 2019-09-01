//
//  Node.swift
//  iOSCSS
//
//  Created by Tyler Thompson on 11/11/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
extension LinkedList {
    open class Node<T> {
        public typealias Value = T
        public var value:Value
        public var next:Node<Value>?
        public var previous:Node<Value>?
        init (with element: Value) {
            value = element
        }
        
        enum TraversalDirection {
            case forward
            case backward
        }
        
        open func traverse(_ distance: Int) -> Node<T>? {
            guard distance > 0 || distance < 0 else { return self }
            let direction:TraversalDirection = (distance >= 0) ? .forward : .backward
            var element:Node<T>? = self
            switch direction {
            case .forward:
                for _ in 1...distance {
                    element = element?.next
                }
            case .backward:
                for _ in 1...(distance * -1) {
                    element = element?.previous
                }
            }
            return element
        }
        
        open func traverse(_ until:((Node<T>) -> Bool)) -> Node<T>? {
            guard !until(self) else { return self }
            var element:Node<T> = self
            while let next = element.next {
                guard !until(next) else { return next }
                element = next
            }
            return nil
        }
        
        open func traverseToEnd() -> Node<T> {
            var element:Node<T> = self
            while let next = element.next {
                element = next
            }
            return element
        }
        
        func removeTillEnd() {
            previous = nil
            while let next = next {
                next.previous?.next = nil
                next.previous = nil
            }
        }
        
        open func traverseToBeginning() -> Node<T> {
            var element:Node<T> = self
            while let next = element.previous {
                element = next
            }
            return element
        }
        
        open var position:Int {
            var counter = 0
            var element:Node<T> = self
            while let prev = element.previous {
                element = prev
                counter += 1
            }
            return counter
        }
        
        private func copyLeft() {
            if let prev = previous {
                let new = Node<T>(with: prev.value)
                new.previous = prev.previous
                new.next = self
                previous = new
            }
            previous?.copyLeft()
        }
        
        private func copyRight() {
            if let n = next {
                let new = Node<T>(with: n.value)
                new.previous = self
                new.next = n.next
                next = new
            }
            next?.copyRight()
        }
        
        open func copy() -> Node<T> {
            let node = Node<T>(with: value)
            node.previous = previous
            node.next = next
            node.copyLeft()
            node.copyRight()
            return node
        }

    }
}
