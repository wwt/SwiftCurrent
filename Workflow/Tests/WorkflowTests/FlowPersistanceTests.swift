//
//  FlowPersistanceTests.swift
//  
//
//  Created by Tyler Thompson on 11/26/20.
//

import Foundation
import XCTest
import Workflow
import Algorithms

class FlowPersistanceTests: XCTestCase {
    func testCreatingNewFlowPersistancesNeverHasTheSameInstance() {
        (1...10).forEach { _ in
            XCTAssertFalse(FlowPersistance.new === FlowPersistance.new)
        }
    }

    func testFlowPersistanceIsEquatableByReference() {
        let ref = FlowPersistance.new
        XCTAssertEqual(ref, ref)
        XCTAssertNotEqual(ref, FlowPersistance.new)
        XCTAssertEqual(FlowPersistance.default, FlowPersistance.default)
    }

    func testNoFlowPersistancesAreTheSame() {
        let allPersistances =
        [
            FlowPersistance.default,
            FlowPersistance.persistWhenSkipped,
            FlowPersistance.removedAfterProceeding
        ]
        allPersistances.combinations(ofCount: 2)
        .compactMap { (combination) -> (FlowPersistance, FlowPersistance)? in
            guard let first = combination.first,
                  let last = combination.last else { return nil }
            return (first, last)
        }
        .forEach {
            XCTAssertNotEqual($0.0, $0.1)
        }

        allPersistances.forEach {
            XCTAssertEqual($0, $0)
        }
    }
}
