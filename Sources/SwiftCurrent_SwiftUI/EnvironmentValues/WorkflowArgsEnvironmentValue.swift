// swiftlint:disable:this file_name
//  WorkflowArgsEnvironmentValue.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 12/24/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftCurrent
import SwiftUI

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct WorkflowArgsKey: EnvironmentKey {
    public static var defaultValue: AnyWorkflow.PassedArgs { .none }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension EnvironmentValues {
    /// The ``AnyArgs`` used to create the ``WorkflowItem``.
    public internal(set) var workflowArgs: AnyWorkflow.PassedArgs {
        get { self[WorkflowArgsKey.self] }
        set { self[WorkflowArgsKey.self] = newValue }
    }
}
