//  swiftlint:disable:this file_name
//  WorkflowLauncherDeprecations.swift
//  SwiftCurrent
//
//  Created by Nick Kaczmarek on 3/18/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import SwiftCurrent
import SwiftUI

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension View {
    /// :nodoc: thenProceed deprecation
    @available(*, unavailable, renamed: "WorkflowItem(_:)")
    public func thenProceed<F: FlowRepresentable>(with: F.Type) -> Never {
        fatalError("Obsoleted")
    }

    /// :nodoc: thenProceed deprecation
    @available(*, unavailable, message: "thenProceed has been removed in favor of WorkflowItem(_:). See docs for usages. https://wwt.github.io/SwiftCurrent/Creating%20Workflows%20in%20SwiftUI.html#step-2")
    public func thenProceed<F: FlowRepresentable, V: View>(with: F.Type, _: () -> V) -> Never {
        fatalError("Obsoleted")
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension App {
    /// :nodoc: thenProceed deprecation
    @available(*, unavailable, renamed: "WorkflowItem(_:)")
    public func thenProceed<F: FlowRepresentable>(with: F.Type) -> Never {
        fatalError("Obsoleted")
    }

    /// :nodoc: thenProceed deprecation
    @available(*, unavailable, message: "thenProceed has been removed in favor of WorkflowItem(_:). See docs for usages. https://wwt.github.io/SwiftCurrent/Creating%20Workflows%20in%20SwiftUI.html#step-2")
    public func thenProceed<F: FlowRepresentable, V: View>(with: F.Type, _: () -> V) -> Never {
        fatalError("Obsoleted")
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension Scene {
    /// :nodoc: thenProceed deprecation
    @available(*, unavailable, renamed: "WorkflowItem(_:)")
    public func thenProceed<F: FlowRepresentable>(with: F.Type) -> Never {
        fatalError("Obsoleted")
    }

    /// :nodoc: thenProceed deprecation
    @available(*, unavailable, message: "thenProceed has been removed in favor of WorkflowItem(_:). See docs for usages. https://wwt.github.io/SwiftCurrent/Creating%20Workflows%20in%20SwiftUI.html#step-2")
    public func thenProceed<F: FlowRepresentable, V: View>(with: F.Type, _: () -> V) -> Never {
        fatalError("Obsoleted")
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowLauncher {
    /// :nodoc: WorkflowLauncher deprecation
    @available(*, unavailable, renamed: "WorkflowView(isLaunched:launchingWith:_:)")
    public init<T>(isLaunched: Binding<Bool>, startingArgs: T, _: () -> Content) {
        fatalError("Obsoleted")
    }
}
