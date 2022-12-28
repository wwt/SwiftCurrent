// swiftlint:disable:this file_name
//  ShouldLoadEnvironmentValue.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 12/24/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct WorkflowShouldLoadKey: EnvironmentKey {
    public static var defaultValue: Bool { true }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension EnvironmentValues {
    public internal(set) var shouldLoad: Bool {
        get { self[WorkflowShouldLoadKey.self] }
        set { self[WorkflowShouldLoadKey.self] = newValue }
    }
}
