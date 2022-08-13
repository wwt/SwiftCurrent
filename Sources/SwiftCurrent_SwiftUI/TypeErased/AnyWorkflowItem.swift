//
//  AnyWorkflowItem.swift
//  SwiftCurrent
//
//  Created by Morgan Zellers on 11/2/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//
//  swiftlint:disable private_over_fileprivate file_types_order

import SwiftUI
import SwiftCurrent

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct AnyWorkflowItem: View, _WorkflowItemProtocol {
    public typealias FlowRepresentableType = Never

    let inspection = Inspection<Self>()
    private let _body: AnyView
    private var storage: AnyWorkflowItemStorageBase

    public var body: some View {
        _body.onReceive(inspection.notice) { inspection.visit(self, $0) }
    }

    init<W: _WorkflowItemProtocol>(view: W) {
        var copy = view
        storage = AnyWorkflowItemStorage(&copy)
        _body = AnyView(copy)
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension AnyWorkflowItem {
    /// :nodoc: Protocol requirement.
    public var workflowLaunchStyle: LaunchStyle.SwiftUI.PresentationType {
        storage.workflowLaunchStyle
    }

    /// :nodoc: Protocol requirement.
    public func canDisplay(_ element: AnyWorkflow.Element?) -> Bool {
        storage.canDisplay(element)
    }

    /// :nodoc: Protocol requirement.
    public func modify(workflow: AnyWorkflow) {
        storage.modify(workflow: workflow)
    }

    /// :nodoc: Protocol requirement.
    public func didDisplay(_ element: AnyWorkflow.Element?) -> Bool {
        storage.didDisplay(element)
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
fileprivate class AnyWorkflowItemStorageBase {
    // swiftlint:disable:next unavailable_function
    func canDisplay(_ element: AnyWorkflow.Element?) -> Bool {
        fatalError("AnyWorkflowItemStorageBase called directly, only available internally so something has gone VERY wrong.")
    }

    // swiftlint:disable:next unavailable_function
    func modify(workflow: AnyWorkflow) {
        fatalError("AnyWorkflowItemStorageBase called directly, only available internally so something has gone VERY wrong.")
    }

    // swiftlint:disable:next unavailable_function
    func didDisplay(_ element: AnyWorkflow.Element?) -> Bool {
        fatalError("AnyWorkflowItemStorageBase called directly, only available internally so something has gone VERY wrong.")
    }

    var workflowLaunchStyle: LaunchStyle.SwiftUI.PresentationType {
        fatalError("AnyWorkflowItemStorageBase called directly, only available internally so something has gone VERY wrong.")
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
fileprivate final class AnyWorkflowItemStorage<Wrapped: _WorkflowItemProtocol>: AnyWorkflowItemStorageBase {
    var holder: Wrapped
    init(_ wrapped: inout Wrapped) {
        holder = wrapped
    }

    override func canDisplay(_ element: AnyWorkflow.Element?) -> Bool {
        holder.canDisplay(element)
    }

    override func modify(workflow: AnyWorkflow) {
        holder.modify(workflow: workflow)
    }

    override func didDisplay(_ element: AnyWorkflow.Element?) -> Bool {
        holder.didDisplay(element)
    }

    override var workflowLaunchStyle: LaunchStyle.SwiftUI.PresentationType {
        holder.workflowLaunchStyle
    }
}
