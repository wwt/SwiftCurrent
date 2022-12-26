//
//  File.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 12/25/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI
import XCTest
import UIKit
import SnapshotTesting

/// Asserts that a given value matches a reference on disk.
///
/// - Parameters:
///   - value: A value to compare against a reference.
///   - snapshotting: A strategy for serializing, deserializing, and comparing values.
///   - name: An optional description of the snapshot.
///   - recording: Whether or not to record a new reference.
///   - timeout: The amount of time a snapshot must be generated in.
///   - file: The file in which failure occurred. Defaults to the file name of the test case in which this function was called.
///   - testName: The name of the test in which failure occurred. Defaults to the function name of the test case in which this function was called.
///   - line: The line number on which failure occurred. Defaults to the line number on which this function was called.
public func assertSnapshot<V: View, Format>(matching value: @autoclosure () throws -> V,
                                            as snapshotting: Snapshotting<UIViewController, Format>,
                                            named name: String? = nil,
                                            record recording: Bool = false,
                                            timeout: TimeInterval = 5,
                                            file: StaticString = #file,
                                            testName: String = #function,
                                            line: UInt = #line) {
    assertSnapshot(matching: try UIHostingController(rootView: value()),
                   as: snapshotting,
                   named: name,
                   record: recording,
                   timeout: timeout,
                   file: file,
                   testName: testName,
                   line: line)
}
