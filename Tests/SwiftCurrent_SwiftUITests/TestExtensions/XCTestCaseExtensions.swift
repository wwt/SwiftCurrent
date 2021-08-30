//
//  XCTestCaseExtensions.swift
//  SwiftCurrent_SwiftUITests
//
//  Created by Morgan Zellers on 8/24/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftUI
import XCTest

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension XCTestCase {
    static var queuedExpectations: [XCTestExpectation] = []
    public var body: some View { EmptyView() }

    func removeQueuedExpectations() {
        while let e = Self.queuedExpectations.first {
            wait(for: [e], timeout: TestConstant.timeout)
            Self.queuedExpectations.removeFirst()
        }
    }
}
