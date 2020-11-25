//
//  Iterator.swift
//  iOSCSS
//
//  Created by Tyler Thompson on 11/11/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
extension LinkedList {
    public struct LinkedListIterator<N: Element>: IteratorProtocol {
        public typealias Element = N
        var element:N?
        
        init(_ node:N?) {
            element = node
        }
        
        mutating public func next() -> N? {
            let elementCopy = element
            element = element?.next as? N
            return elementCopy
        }
    }
}
