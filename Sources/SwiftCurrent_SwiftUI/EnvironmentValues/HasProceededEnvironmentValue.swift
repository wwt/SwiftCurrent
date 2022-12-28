// swiftlint:disable:this file_name
//  HasProceededEnvironmentValue.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 12/28/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
struct WorkflowHasProceededKey: EnvironmentKey {
    static var defaultValue: Binding<Bool>? { nil }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension EnvironmentValues {
    var workflowHasProceeded: Binding<Bool>? {
        get { self[WorkflowHasProceededKey.self] }
        set { self[WorkflowHasProceededKey.self] = newValue }
    }
}
