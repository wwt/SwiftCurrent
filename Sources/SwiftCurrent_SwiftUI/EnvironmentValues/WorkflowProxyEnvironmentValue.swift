// swiftlint:disable:this file_name
//  WorkflowProxyEnvironmentValue.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 12/24/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct WorkflowProxyKey: EnvironmentKey {
    public static var defaultValue: WorkflowProxy { WorkflowProxy() }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension EnvironmentValues {
    /// The proxy used to perform workflow actions, like proceed, abandon, etc...
    public internal(set) var workflowProxy: WorkflowProxy {
        get { self[WorkflowProxyKey.self] }
        set { self[WorkflowProxyKey.self] = newValue }
    }
}
