//  swiftlint:disable:this file_name
//  Reason: The file name reflects the contents of the file.
//
//  LinkedListNode.swift
//  Workflow
//
//  Created by Tyler Thompson on 11/11/18.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
extension LinkedList {
    /**
     A type to hold onto elements in a `LinkedList`.
     
     ### Discussion
     These nodes hold onto a value, the next node, and the previous node.
     */
    open class Node<T> {
        /// A typealias that is equivalent to the specialized type in the `LinkedList`.
        public typealias Value = T
        /// The concrete value the node is holding on to.
        public var value: Value
        /// An optional reference to the next node in the `LinkedList`.
        public var next: Node<Value>?
        /// An optional reference to the previous node in the `LinkedList`.
        public var previous: Node<Value>?
        /// Creates a node with a concrete value.
        init (with element: Value) {
            value = element
        }

        /// An enumeration indicating whether you'd like to traverse forwards or backwards through the `LinkedList`.
        public enum TraversalDirection {
            /// Traverse "forward" i.e. traverse by calling `next`.
            case forward
            /// Traverse "backward" i.e. traverse by calling `previous`.
            case backward
        }

        /**
         A method to move N spaces forwards or backwards through the nodes.
         - Parameter distance: an integer indicating how far to move through the nodes.
         - Important: If the distance is out of bounds nil will be returned
         - Returns: the node at the indicated distance; nil if distance is out of bounds.
         */
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

        /**
         A method to move forward through the nodes until a precondition is met.
         - Parameter direction: an enum indicating whether to traverse forward or backwards, defaults to `TraversalDirection.forward`.
         - Parameter until: a closure that takes in a node and returns a boolean to indicate whether traversal should continue. Once until returns true, it is not called again.
         - Returns: the node when traversal finishes; nil if none found.
         */
        open func traverse(direction: TraversalDirection = .forward, until: ((Node<T>) -> Bool)) -> Node<T>? {
            var element: Node<T> = self

            if direction == .forward && until(element) { return self }

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

        /// A method to move forward through the nodes until there is no `next`.
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

        /// A method to move backwards through the nodes until there is no `previous`.
        open func traverseToBeginning() -> Node<T> {
            var element: Node<T> = self
            while let next = element.previous {
                element = next
            }
            return element
        }

        /**
         A nodes position in the `LinkedList`
         - Complexity: O(n) this has a worst case of having to traverse the entire list to determine its position.
         */
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

        /// Creates an exact replica of the node, including the next and previous values, this essentially deep copies the entire `LinkedList`.
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
