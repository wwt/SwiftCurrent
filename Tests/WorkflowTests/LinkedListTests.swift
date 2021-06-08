//
//  LinkedListTests.swift
//  WorkflowTests
//
//  Created by Tyler Thompson on 11/10/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

@testable import Workflow

extension LinkedList {
    convenience init(_ elements: Value...) {
        self.init(elements)
    }

    convenience init(_ elements: [Value]) {
        let collection = elements.map { Element(with: $0) }
        for (i, node) in collection.enumerated() {
            node.previous = collection[safe: i - 1]
            node.next = collection[safe: i + 1]
        }

        self.init(collection.first)
    }
}

class LinkedListTests: XCTestCase {
    class Object { }
    func testLinkedListHoldsOnToACollection() {
        let obj1 = Object()
        let obj2 = Object()
        let obj3 = Object()

        let list = LinkedList([obj1, obj2, obj3])

        XCTAssert(list.first?.value === obj1)
        XCTAssert(list.first?.next?.value === obj2)
        XCTAssertNil(list.first?.previous)
        XCTAssert(list.first?.traverse(1)?.value === obj2)
        XCTAssert(list.first?.traverse(1)?.next?.value === obj3)
        XCTAssert(list.first?.traverse(1)?.previous?.value === obj1)
        XCTAssert(list.first?.traverse(2)?.value === obj3)
        XCTAssertNil(list.first?.traverse(2)?.next)
        XCTAssert(list.first?.traverse(2)?.previous?.value === obj2)
    }

    func testLinkedListCanBeInstantiatedWithMultipleElements() {
        let obj1 = Object()
        let obj2 = Object()
        let obj3 = Object()
        let list = LinkedList(obj1, obj2, obj3)

        XCTAssert(list.first?.value === obj1)
        XCTAssert(list.first?.traverse(1)?.value === obj2)
        XCTAssert(list.first?.traverse(2)?.value === obj3)
    }

    func testLinkedListCanBeInstantiatedWithElementArray() {
        let obj1 = Object()
        let obj2 = Object()
        let obj3 = Object()
        let arr = [obj1, obj2, obj3]
        let list = LinkedList(arr)

        XCTAssert(list.first?.value === obj1)
        XCTAssert(list.first?.traverse(1)?.value === obj2)
        XCTAssert(list.first?.traverse(2)?.value === obj3)

        for (i, node) in list.enumerated() {
            XCTAssert(node.value === arr[i])
            if i > 0 {
                XCTAssert(node.previous?.value === arr[i-1])
            }
            if i < arr.count-1 {
                XCTAssert(node.next?.value === arr[i+1])
            }
        }
    }

    func testLinkedListIterator() {
        let arr = [1, 2, 3]
        let list = LinkedList(arr)

        for (i, node) in list.enumerated() {
            XCTAssertEqual(node.value, arr[i])
        }
    }

    func testStoredProperties() {
        let obj1 = Object()
        let obj2 = Object()
        let obj3 = Object()
        let arr = [obj1, obj2, obj3]
        let list = LinkedList(arr)

        XCTAssertEqual(list.startIndex, 0)
        XCTAssertEqual(list.endIndex, 3)
        XCTAssertEqual(list.description, arr.description)
        XCTAssertFalse(list.isEmpty)
        XCTAssertEqual(list.count, 3)
        XCTAssert(list.first?.value === obj1)
        XCTAssert(list.last?.value === obj3)
    }

    func testContainsOnEquatable() {
        let list = LinkedList([1, 2, 3])

        XCTAssert(list.contains(1))
        XCTAssertFalse(list.contains(4))
    }

    func testSort() {
        let list = LinkedList([3, 1, 2])

        list.sort()

        XCTAssertEqual(list.first?.value, 1)
        XCTAssertEqual(list.first?.traverse(1)?.value, 2)
        XCTAssertEqual(list.first?.traverse(2)?.value, 3)
    }

    func testSortBy() {
        class Wrapper {
            var int: Int
            init(_ val: Int) {
                int = val
            }
        }
        let list = LinkedList([Wrapper(3), Wrapper(1), Wrapper(2)])

        list.sort(by: { $0.int <= $1.int })

        XCTAssertEqual(list.first?.value.int, 1)
        XCTAssertEqual(list.first?.traverse(1)?.value.int, 2)
        XCTAssertEqual(list.first?.traverse(2)?.value.int, 3)
    }

    func testSortedBy() {
        class Wrapper {
            var int: Int
            init(_ val: Int) {
                int = val
            }
        }
        let list: LinkedList = LinkedList([Wrapper(3), Wrapper(1), Wrapper(2)])
                              .sorted(by: { $0.int <= $1.int })

        XCTAssertEqual(list.first?.value.int, 1)
        XCTAssertEqual(list.first?.traverse(1)?.value.int, 2)
        XCTAssertEqual(list.first?.traverse(2)?.value.int, 3)
    }

    func testSortInPlacePerformance() {
        let limit = 10_000
        let list = LinkedList((1...limit).map { _ in arc4random_uniform(UInt32(limit)) })

        measure {
            list.sort()
        }
    }

    func testSortPerformance() {
        let limit = 10_000
        let list = LinkedList((1...limit).map { _ in arc4random_uniform(UInt32(limit)) })

        measure {
            _ = list.sorted()
        }
    }

    func testAppendToExisting() {
        let list = LinkedList([1, 2, 3])
        list.append(4)

        XCTAssertEqual(list.last?.value, 4)
        XCTAssertEqual(list.last?.previous?.value, 3)
    }

    func testAppendToEmpty() {
        let list = LinkedList<Int>()
        list.append(1)

        XCTAssertEqual(list.first?.value, 1)
        XCTAssertEqual(list.last?.value, 1)
    }

    func testAppendArrToExisting() {
        let list = LinkedList([1, 2, 3])
        list.append(contentsOf: [4, 5])

        XCTAssertEqual(list.first?.traverse(3)?.value, 4)
        XCTAssertEqual(list.first?.traverse(3)?.previous?.value, 3)
        XCTAssertEqual(list.first?.traverse(3)?.next?.value, 5)
        XCTAssertEqual(list.first?.traverse(4)?.value, 5)
        XCTAssertEqual(list.first?.traverse(4)?.previous?.value, 4)
        XCTAssertEqual(list.first?.traverse(4)?.next?.value, nil)
    }

    func testAppendArrToEmpty() {
        let list = LinkedList<Int>()
        list.append(contentsOf: [1, 2])

        XCTAssertEqual(list.first?.value, 1)
        XCTAssertEqual(list.last?.value, 2)
    }

    func testInsertToExisting() {
        let list = LinkedList([1, 2, 4])

        list.insert(3, atIndex: 2)

        XCTAssertEqual(list.first?.traverse(2)?.value, 3)
        XCTAssertEqual(list.first?.traverse(2)?.previous?.value, 2)
        XCTAssertEqual(list.first?.traverse(2)?.next?.value, 4)
    }

    func testInsertCollectionToExisting() {
        let list = LinkedList([1, 2, 5])

        list.insert(contentsOf: [3, 4], at: 2)

        XCTAssertEqual(list.first?.traverse(2)?.value, 3)
        XCTAssertEqual(list.first?.traverse(2)?.previous?.value, 2)
        XCTAssertEqual(list.first?.traverse(2)?.next?.value, 4)
        XCTAssertEqual(list.first?.traverse(3)?.value, 4)
        XCTAssertEqual(list.first?.traverse(3)?.previous?.value, 3)
        XCTAssertEqual(list.first?.traverse(3)?.next?.value, 5)
    }

    func testRemoveAllCleansUpMemory() {
        let list = LinkedList([ComplexObject(1), ComplexObject(2), ComplexObject(3)])
        weak var first: LinkedList<ComplexObject>.Element? = list.first
        weak var middle: ComplexObject? = list.first?.next?.value
        weak var last: LinkedList<ComplexObject>.Element? = list.last

        list.removeAll()

        XCTAssertNil(first)
        XCTAssertNil(middle)
        XCTAssertNil(last)
    }

    func testRemoveFirst() {
        let list = LinkedList([1, 2, 3, 4, 5, 6])
        list.removeFirst()

        XCTAssertEqual(list.first?.value, 2)

        list.removeFirst(3)

        XCTAssertEqual(list.first?.value, 5)
    }

    func testRemoveFirstCleansUpMemory() {
        let list = LinkedList([ComplexObject(1), ComplexObject(2), ComplexObject(3), ComplexObject(4), ComplexObject(5), ComplexObject(6)])
        weak var first = list.first

        list.removeFirst()

        XCTAssertNil(first)
    }

    func testDropFirst() {
        let list = LinkedList([1, 2, 3, 4, 5, 6])

        XCTAssertEqual(list.dropFirst().first?.value, 2)

        XCTAssertEqual(list.dropFirst(4).first?.value, 5)

        XCTAssertEqual(list.count, 6)
    }

    func testPrefix() {
        let list = LinkedList([1, 2, 3, 4, 5, 6])

        XCTAssertEqual(list.prefix(1).last?.value, 1)

        XCTAssertEqual(list.prefix(4).last?.value, 4)

        XCTAssertEqual(list.count, 6)
    }

    func testPrefixWhile() {
        let list = LinkedList([1, 2, 3, 4, 5, 6])

        XCTAssertEqual(list.prefix(while: { $0 != 2 }).last?.value, 2)

        XCTAssertEqual(list.prefix(while: { $0 != 4 }).last?.value, 4)

        XCTAssertEqual(list.count, 6)
    }

    func testRemoveLast() {
        let list = LinkedList([1, 2, 3, 4, 5, 6])

        list.removeLast()

        XCTAssertEqual(list.last?.value, 5)

        list.removeLast(3)

        XCTAssertEqual(list.last?.value, 2)
    }

    func testRemoveLastWhenOnlyOneItem() {
        let list = LinkedList([1])

        list.removeLast()

        XCTAssertNil(list.last)
        XCTAssertNil(list.first)
    }

    func testRemoveLastCleansUpMemory() {
        let list = LinkedList([ComplexObject(1), ComplexObject(2), ComplexObject(3), ComplexObject(4), ComplexObject(5), ComplexObject(6)])

        weak var last = list.last?.previous

        list.removeLast(2)

        XCTAssertNil(last)
    }

    func testDropLast() {
        let list = LinkedList([1, 2, 3, 4, 5, 6])

        XCTAssertEqual(list.dropLast().last?.value, 5)

        XCTAssertEqual(list.dropLast(4).last?.value, 2)

        XCTAssertEqual(list.count, 6)
    }

    func testSuffix() {
        let list = LinkedList([1, 2, 3, 4, 5, 6])

        XCTAssertEqual(list.suffix(1).first?.value, 6)

        XCTAssertEqual(list.suffix(3).first?.value, 4)

        XCTAssertEqual(list.count, 6)
    }

    func testDropWhile() {
        let list = LinkedList([1, 2, 3, 4, 5, 6])

        XCTAssertEqual(list.drop(while: { $0 != 3}).last?.value, 3)

        XCTAssertEqual(list.count, 6)
    }

    func testPopLast() {
        let list = LinkedList([1, 2])

        let last = list.popLast()

        XCTAssertEqual(list.last?.value, 1)
        XCTAssertEqual(last, 2)
        XCTAssertEqual(list.popLast(), 1)
        XCTAssertNil(list.first)
    }

    func testPopLastCleansUpMemory() {
        let list = LinkedList([ComplexObject(1), ComplexObject(2), ComplexObject(3)])

        weak var last = list.popLast()
        weak var middle = list.popLast()
        weak var first = list.popLast()

        XCTAssertNil(last)
        XCTAssertNil(middle)
        XCTAssertNil(first)
        XCTAssert(list.isEmpty)
    }

    func testRemoveAtIndex() {
        let list = LinkedList([1, 2, 3])

        list.remove(at: 1)

        XCTAssertEqual(list.count, 2)
        XCTAssertEqual(list.first?.value, 1)
        XCTAssertEqual(list.first?.next?.value, 3)
        XCTAssertEqual(list.last?.value, 3)
        XCTAssertEqual(list.last?.previous?.value, 1)
    }

    func testRemoveAll() {
        let list = LinkedList([1, 2, 3])

        list.removeAll()

        XCTAssertEqual(list.count, 0)
        XCTAssertNil(list.first)
        XCTAssertNil(list.last)
    }

    func testRemoveWhere() {
        let list = LinkedList([1, 2, 3, 2, 4, 2])

        list.remove { $0.value == 2 }

        XCTAssertEqual(list.count, 3)
        XCTAssertEqual(list.first?.value, 1)
        XCTAssertEqual(list.first?.next?.value, 3)
        XCTAssertEqual(list.last?.value, 4)
    }

    func testLastWhere() {
        class Obj {
            let num: Int
            init(_ num: Int) { self.num = num }
        }
        let list = LinkedList([Obj(1), Obj(4), Obj(4), Obj(3)])
        let expectedValue = list.first?.traverse(2)?.value

        let last = list.last { $0.value.num == 4 }

        XCTAssertEqual(last?.value.num, 4)
        XCTAssert(last?.value === expectedValue)

        let notFound = list.last { $0.value.num == 10 }

        XCTAssertNil(notFound)
    }

    func testLastWhereAllowsThrowingClosure() {
        class Obj { func throwing() throws -> Bool { true } }
        let list = LinkedList([Obj(), Obj(), Obj()])

        let foundObj = try? list.last { try $0.value.throwing() }

        XCTAssert(foundObj?.value === list.last?.value)
    }
    
    func testEquatability() {
        let list = LinkedList([1, 2, 3])
        let list2 = LinkedList([1, 2, 3])

        XCTAssertEqual(list, list2)

        let list3 = LinkedList([1, 2, 3, 4])

        XCTAssertNotEqual(list, list3)
    }

    func testSwap() {
        let list = LinkedList([1, 3, 2])

        list.swapAt(1, 2)

        XCTAssertEqual(list.first?.traverse(1)?.value, 2)
        XCTAssertEqual(list.first?.traverse(1)?.previous?.value, 1)
        XCTAssertEqual(list.first?.traverse(1)?.next?.value, 3)
        XCTAssertEqual(list.first?.traverse(2)?.value, 3)
    }

    func testSwapWithInvalidStart() {
        let list = LinkedList([1, 3, 2])
        XCTAssertThrowsFatalError {
            list.swapAt(20, 2)
        }
    }

    func testSwapWithInvalidEnd() {
        let list = LinkedList([1, 3, 2])
        XCTAssertThrowsFatalError {
            list.swapAt(1, 12)
        }
    }

    func testMutableReplace() {
        let list = LinkedList([ 2, 5, 6 ])

        list.replace(atIndex: 1, withItem: 4)

        XCTAssertEqual(list.first?.traverse(1)?.value, 4)
        XCTAssertEqual(list.first?.traverse(1)?.previous?.value, 2)
        XCTAssertEqual(list.first?.traverse(1)?.next?.value, 6)
    }

    func testImmutableReplace() {
        let list = LinkedList([ 2, 5, 6 ])

        XCTAssertEqual(list.replacing(atIndex: 1, withItem: 4).first?.traverse(1)?.value, 4)
        XCTAssertEqual(list.first?.traverse(1)?.value, 5)
    }

    func testReverse() {
        let list = LinkedList([1, 2, 3])

        list.reverse()

        XCTAssertEqual(list.first?.value, 3)
        XCTAssertEqual(list.first?.previous?.value, nil)
        XCTAssertEqual(list.first?.next?.value, 2)
        XCTAssertEqual(list.first?.traverse(1)?.value, 2)
        XCTAssertEqual(list.first?.traverse(1)?.previous?.value, 3)
        XCTAssertEqual(list.first?.traverse(1)?.next?.value, 1)
        XCTAssertEqual(list.first?.traverse(2)?.value, 1)
        XCTAssertEqual(list.first?.traverse(2)?.previous?.value, 2)
        XCTAssertEqual(list.first?.traverse(2)?.next?.value, nil)
    }

    func testReversed() {
        let list = LinkedList([1, 2, 3]).reversed()

        XCTAssertEqual(list.first?.value, 3)
        XCTAssertEqual(list.first?.previous?.value, nil)
        XCTAssertEqual(list.first?.next?.value, 2)
        XCTAssertEqual(list.first?.traverse(1)?.value, 2)
        XCTAssertEqual(list.first?.traverse(1)?.previous?.value, 3)
        XCTAssertEqual(list.first?.traverse(1)?.next?.value, 1)
        XCTAssertEqual(list.first?.traverse(2)?.value, 1)
        XCTAssertEqual(list.first?.traverse(2)?.previous?.value, 2)
        XCTAssertEqual(list.first?.traverse(2)?.next?.value, nil)
    }

    func testPositionOfNode() {
        let list: LinkedList<Int> = LinkedList([1, 2, 3, 1])
        XCTAssertEqual(list.first?.traverse(3)?.position, 3)
    }

    func testMax() {
        XCTAssertEqual(LinkedList([1, 2, 3]).max(), 3)
    }

    func testMin() {
        XCTAssertEqual(LinkedList([2, 1, 3]).min(), 1)
    }

    func testTraversingUntilPreconditionIsMet() {
        let list = LinkedList([1, 2, 3, 4, 5, 6, 7, 8])
        XCTAssertEqual(list.first?.traverse { $0.value == 4 }?.value, 4)
        XCTAssertNil(list.first?.traverse { $0.value == 9 })
        XCTAssertEqual(list.first?.traverse { $0.value == 1 }?.value, 1)
    }

    func testTraversingBackwardsUntilPreconditionIsMet() {
        let list = LinkedList([1, 2, 3, 4, 5, 6, 7, 8])
        XCTAssertEqual(list.last?.traverse(direction: .backward) { $0.value == 4 }?.value, 4)
        XCTAssertNil(list.last?.traverse(direction: .backward) { $0.value == 9 })
        XCTAssertEqual(list.last?.traverse(direction: .backward) { $0.value == 1 }?.value, 1)
    }

    func testTraversingBackwardsUntilPreconditionIsMet_SkipsTheFirstValue() {
        let list = LinkedList([1, 2, 3, 4, 5, 6, 7, 8])
        let node = list.last?.traverse(direction: .backward) { $0.value == 8 }
        XCTAssertNil(node)
    }

    class ComplexObject {
        var i: Int
        init(_ i: Int) {
            self.i = i
        }
    }

}
