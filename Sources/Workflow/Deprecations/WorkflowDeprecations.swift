//  swiftlint:disable:this file_name
//  WorkflowDeprecations.swift
//  Workflow
//
//  Created by Richard Gist on 5/13/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//  swiftlint:disable all

import Foundation

// V3 Upgrades
extension Workflow {
    @available(*, unavailable, renamed: "thenPresent(_:presentationType:flowPersistence:)")
    public func thenPresent<F>(_ type:F.Type, presentationType:LaunchStyle = LaunchStyle.default, staysInViewStack:@escaping @autoclosure () -> FlowPersistence) -> Workflow where F: FlowRepresentable {
        fatalError("Obsoleted")
    }

    @available(*, unavailable, renamed: "thenPresent(_:presentationType:flowPersistence:)")
    public func thenPresent<F>(_ type:F.Type, presentationType:LaunchStyle = LaunchStyle.default, staysInViewStack:@escaping (F.WorkflowInput) -> FlowPersistence) -> Workflow where F: FlowRepresentable {
        fatalError("Obsoleted")
    }

    @available(*, unavailable, renamed: "thenPresent(_:presentationType:flowPersistence:)")
    public func thenPresent<F>(_ type:F.Type, presentationType:LaunchStyle = LaunchStyle.default, staysInViewStack:@escaping () -> FlowPersistence) -> Workflow where F: FlowRepresentable, F.WorkflowInput == Never {
        fatalError("Obsoleted")
    }
}
