//
//  Node.swift
//  iOSCSS
//
//  Created by Tyler Thompson on 11/11/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
extension LinkedList {
    /**
     LinkedList.Node: A type to hold onto elements in a LinkedList
     
     ### Discussion:
     These nodes hold onto a value, the next node, and the previous node.
     */
    open class Node<T> {
        /// Value: A typealias that is equivalent to the specialized type in the LinkedList
        public typealias Value = T
        /// value: The concrete value the node is holding onto
        public var value: Value
        /// next: An optional reference to the next node in the LinkedList
        public var next: Node<Value>?
        /// previous: An optional reference to the previous node in the LinkedList
        public var previous: Node<Value>?
        /// init(with element:Value): Nodes are initialized with the concrete value they should hold on to
        init (with element: Value) {
            value = element
        }

        public enum TraversalDirection {
            case forward
            case backward
        }

        /// traverse(distance): A method to move N spaces forwards or backwards through the nodes
        /// - Parameter distance: An integer indicating how far to move through the nodes
        /// - Note: If the distance is out of bounds nil will be returned
        /// - Returns: Node<T>? where T is the specialized type of the LinkedList
        open func traverse(_ distance: Int) -> Node<T>? {
            guard distance > 0 || distance < 0 else { return self }
            let direction: TraversalDirection = (distance >= 0) ? .forward : .backward
            var element: Node<T>? = self
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

        /// traverse(Until): A method to move forward through the nodes until a precondition is met
        /// - Parameter direction: An enum indacting whether to traverse forward or backwards, defaults to foward.
        /// - Parameter until: A function that takes in a Node<T> and returns a boolean to indicate whether traversal should continue
        /// - Note: If `true` is returned from `until` then traversal stops. e.g. `node.traverse { $0.value == 0 }` traverses until it finds a node who has a value of 0
        /// - Returns: Node<T>? where T is the specialized type of the LinkedList
        open func traverse(direction: TraversalDirection = .forward, until: ((Node<T>) -> Bool)) -> Node<T>? {
            var element: Node<T> = self

            if direction == .forward, until(element) { return self }

            switch direction {
                case .forward:
                    while let next = element.next {
                        guard !until(next) else { return next }
                        element = next
                    }
                case .backward:
                    while let prev = element.previous {
                        guard !until(prev) else { return prev }
                        element = prev
                    }
            }
            return nil
        }

        /// traverseToEnd: A method to move forward through the nodes until there is no `next`
        open func traverseToEnd() -> Node<T> {
            var element: Node<T> = self
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

        /// traverseToBeginning: A method to move backwards through the nodes until there is no `previous`
        open func traverseToBeginning() -> Node<T> {
            var element: Node<T> = self
            while let next = element.previous {
                element = next
            }
            return element
        }

        /// position: A computed property that calculates a nodes position in the LinkedList
        /// - Complexity: O(n) this has a worst case of having to traverse the entire list to determine its position
        open var position: Int {
            var counter = 0
            var element: Node<T> = self
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

        /// copy: Creates an exact replica of the node, including the next and previous values, this essentially deep copies the entire LinkedList
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
