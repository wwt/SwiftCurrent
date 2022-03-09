//
//  ViewHostingExtensions.swift
//  SwiftCurrent_SwiftUITests
//
//  Created by Tyler Thompson on 7/12/21.
//

import Foundation
import SwiftUI
import ViewInspector
import XCTest
import SwiftCurrent

@testable import SwiftCurrent_SwiftUI

@available(iOS 15.0, macOS 10.15, tvOS 13.0, *)
extension View where Self: Inspectable {
    @discardableResult func host() async -> Self {
        await MainActor.run { ViewHosting.host(view: self ) }
        return self
    }

    @discardableResult func host<V: View>(_ transform: (Self) -> V) async -> Self {
        await MainActor.run { ViewHosting.host(view: transform(self) ) }
        return self
    }

    func hostAndInspect<E: InspectionEmissary>(with emissary: KeyPath<Self, E>) async throws -> InspectableView<ViewType.View<Self>> where E.V == Self {
        await host()
        return try await self[keyPath: emissary].inspect()
    }
}

@available(iOS 15.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension InspectableView where View: CustomViewType & SingleViewContent {
    func extractWorkflowLauncher<WI>() async throws -> InspectableView<ViewType.View<WorkflowLauncher<WI>>> where View.T == WorkflowView<WorkflowLauncher<WI>> {
        let actual = try view(WorkflowLauncher<WI>.self).actualView()

        DispatchQueue.main.async {
            ViewHosting.host(view: actual)
        }

        return try await actual.inspection.inspect()
    }

    func extractWorkflowItemWrapper<C, W>() async throws -> InspectableView<ViewType.View<WorkflowItemWrapper<C, W>>> where View.T == WorkflowLauncher<WorkflowItemWrapper<C, W>> {
        let mirror = Mirror(reflecting: try actualView())
        let model = try XCTUnwrap(mirror.descendant("_model") as? StateObject<WorkflowViewModel>)
        let launcher = try XCTUnwrap(mirror.descendant("_launcher") as? StateObject<Launcher>)
        let actual = try view(WorkflowItemWrapper<C, W>.self).actualView()

        DispatchQueue.main.async {
            ViewHosting.host(view: actual
                                .environmentObject(model.wrappedValue)
                                .environmentObject(launcher.wrappedValue))
        }
        
        return try await actual.inspection.inspect()
    }

    func extractWrappedWrapper<C, C1, W1>() async throws -> InspectableView<ViewType.View<WorkflowItemWrapper<C1, W1>>> where View.T == WorkflowItemWrapper<C, WorkflowItemWrapper<C1, W1>> {
        let wrapped = try await actualView().getWrappedView()
        let mirror = Mirror(reflecting: try actualView())
        let model = try XCTUnwrap(mirror.descendant("_model") as? EnvironmentObject<WorkflowViewModel>)
        let launcher = try XCTUnwrap(mirror.descendant("_launcher") as? EnvironmentObject<Launcher>)
        DispatchQueue.main.async {
            ViewHosting.host(view: wrapped
                                .environmentObject(model.wrappedValue)
                                .environmentObject(launcher.wrappedValue))
        }
        return try await wrapped.inspection.inspect()
    }
}

@available(iOS 15.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension InspectableView where View: CustomViewType & SingleViewContent, View.T: FlowRepresentable {
    func proceedInWorkflow() async throws where View.T.WorkflowOutput == Never {
        try await MainActor.run { try actualView().proceedInWorkflow() }
    }

    func proceedInWorkflow(_ args: View.T.WorkflowOutput) async throws where View.T.WorkflowOutput == AnyWorkflow.PassedArgs {
        try await MainActor.run { try actualView().proceedInWorkflow(args) }
    }

    func proceedInWorkflow(_ args: View.T.WorkflowOutput) async throws {
        try await MainActor.run { try actualView().proceedInWorkflow(args) }
    }

    func backUpInWorkflow() async throws {
        try await MainActor.run { try actualView().backUpInWorkflow() }
    }

    func abandonWorkflow() async throws {
        try await MainActor.run { try actualView().workflow?.abandon() }
    }
}

@available(iOS 15.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension InspectableView where View: CustomViewType & SingleViewContent, View.T: PassthroughFlowRepresentable {
   func proceedInWorkflow() async throws {
        try await MainActor.run { try actualView().proceedInWorkflow() }
    }
}

@available(iOS 15.0, macOS 10.15, tvOS 13.0, *)
public extension InspectionEmissary where V: View & Inspectable {
    func inspect(after delay: TimeInterval = 0,
                 function: String = #function,
                 file: StaticString = #file,
                 line: UInt = #line) async throws -> InspectableView<ViewType.View<V>> {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                let exp = self.inspect(after: delay, function: function, file: file, line: line) { view in
                    continuation.resume(returning: view)
                }
                DispatchQueue.global(qos: .background).async {
                    XCTWaiter().wait(for: [exp], timeout: TestConstant.timeout)
                }
            }
        }
    }
}
