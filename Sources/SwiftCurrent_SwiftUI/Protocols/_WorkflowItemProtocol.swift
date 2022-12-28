//
//  _WorkflowItemProtocol.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 2/23/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI
import SwiftCurrent

/// :nodoc: Protocol is forced to be public, but it is an internal protocol.
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public protocol _WorkflowItemProtocol: View { // swiftlint:disable:this type_name
    var launchStyle: State<LaunchStyle.SwiftUI.PresentationType> { get }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension Never: _WorkflowItemProtocol {
    public var launchStyle: State<LaunchStyle.SwiftUI.PresentationType> { State(wrappedValue: .default) }
}
