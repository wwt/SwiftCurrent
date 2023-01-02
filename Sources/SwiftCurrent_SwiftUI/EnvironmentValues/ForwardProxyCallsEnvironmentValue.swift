// swiftlint:disable:this file_name
//  ForwardProxyCallsEnvironmentValue.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 1/2/23.
//  Copyright © 2023 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
struct ForwardProxyCallsKey: EnvironmentKey {
    static var defaultValue: Bool { false }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension EnvironmentValues {
    var forwardProxyCalls: Bool {
        get { self[ForwardProxyCallsKey.self] }
        set { self[ForwardProxyCallsKey.self] = newValue }
    }
}
