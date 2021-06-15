//
//  LinkedListIterator.swift
//  Workflow
//
//  Created by Tyler Thompson on 11/11/18.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
extension LinkedList {
    /// :nodoc: Sequence protocol requirement.
    public struct LinkedListIterator<N: Element>: IteratorProtocol {
        /// :nodoc: IteratorProtocol requirement.
        public typealias Element = N
        var element: N?

        init(_ node: N?) {
            element = node
        }

        /// :nodoc: IteratorProtocol requirement.
        public mutating func next() -> N? {
            let elementCopy = element
            element = element?.next as? N
            return elementCopy
        }
    }
}
