//
//  WorkflowItemWrapperTests.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 1/16/23.
//  Copyright © 2023 WWT and Tyler Thompson. All rights reserved.
//  

import XCTest
import SwiftUI
import Combine

import ViewInspector

@testable import SwiftCurrent_SwiftUI

@available(iOS 15.0, *)
@MainActor final class WorkflowItemWrapperTests: XCTestCase {
    var subscribers = Set<AnyCancellable>()

    override func setUp() {
        subscribers.removeAll()
    }

    func testWrapperForwardsOnFinishCalls() async throws {
        let parentProxy = WorkflowProxy()
        let expectedData = UUID()
        let exp = expectation(description: "Proxy onFinish called")

        parentProxy.onFinishPublisher
            .compactMap { $0 }
            .sink { args in
                if case .args(let data as UUID) = args {
                    XCTAssertEqual(data, expectedData)
                } else {
                    XCTFail("Args not passed to parent")
                }
                exp.fulfill()
            }
            .store(in: &subscribers)

        let wi = try await MainActor.run {
            WorkflowItemWrapper(content: WorkflowItem { Text("") })
        }
            .host { $0.environment(\.workflowProxy, parentProxy) }
            .inspection
            .inspect()

        let proxy = try wi.group().environment(\.workflowProxy)
        proxy.onFinishPublisher.send(.args(expectedData))

        wait(for: [exp], timeout: 0.1)
    }
}
