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
    public var launchStyle: State<SwiftCurrent.LaunchStyle.SwiftUI.PresentationType> { storage.presentationType }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
fileprivate class AnyWorkflowItemStorageBase {
    // swiftlint:disable:next unavailable_function
    var presentationType: State<SwiftCurrent.LaunchStyle.SwiftUI.PresentationType> {
        fatalError("AnyWorkflowItemStorageBase called directly, only available internally so something has gone VERY wrong.")
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
fileprivate final class AnyWorkflowItemStorage<Wrapped: _WorkflowItemProtocol>: AnyWorkflowItemStorageBase {
    var holder: Wrapped
    init(_ wrapped: inout Wrapped) {
        holder = wrapped
    }

    override var presentationType: State<SwiftCurrent.LaunchStyle.SwiftUI.PresentationType> {
        holder.launchStyle
    }
}
