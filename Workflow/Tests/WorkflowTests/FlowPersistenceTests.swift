//
//  FlowPersistenceTests.swift
//  
//
//  Created by Tyler Thompson on 11/26/20.
//

import Foundation
import XCTest
import Workflow
import Algorithms

class FlowPersistenceTests: XCTestCase {
    func testCreatingNewFlowPersistencesNeverHasTheSameInstance() {
        (1...10).forEach { _ in
            XCTAssertFalse(FlowPersistence.new === FlowPersistence.new)
        }
    }

    func testFlowPersistenceIsEquatableByReference() {
        let ref = FlowPersistence.new
        XCTAssertEqual(ref, ref)
        XCTAssertNotEqual(ref, FlowPersistence.new)
        XCTAssertEqual(FlowPersistence.default, FlowPersistence.default)
    }

    func testNoFlowPersistencesAreTheSame() {
        let allPersistences =
        [
            FlowPersistence.default,
            FlowPersistence.persistWhenSkipped,
            FlowPersistence.removedAfterProceeding
        ]
        allPersistences.combinations(ofCount: 2)
        .compactMap { (combination) -> (FlowPersistence, FlowPersistence)? in
            guard let first = combination.first,
                  let last = combination.last else { return nil }
            return (first, last)
        }
        .forEach {
            XCTAssertNotEqual($0.0, $0.1)
        }

        allPersistences.forEach {
            XCTAssertEqual($0, $0)
        }
    }
}
