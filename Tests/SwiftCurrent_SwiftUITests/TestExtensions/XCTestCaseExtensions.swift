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
extension View where Self: XCTestCase {
    public var body: some View { EmptyView() }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension Scene where Self: XCTestCase {
    public var body: some Scene { WindowGroup { EmptyView() } }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension App where Self: XCTestCase {
    public var body: some Scene { WindowGroup { EmptyView() } }
}
