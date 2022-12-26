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
extension View {
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
extension InspectableView {
    func extractWorkflowLauncher() async throws -> Self {
        self
    }

    func extractWorkflowItemWrapper() async throws -> Self {
        self
    }

    func extractWrappedWrapper() async throws -> Self {
        self
    }

//    func findModalModifier<C, W: Inspectable>() throws -> InspectableView<ViewType.View<ModalModifier<W>>> where View.T == WorkflowItemWrapper<C, W> {
//        try find(ModalModifier<W>.self)
//    }
}

@available(iOS 15.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension InspectableView where View: CustomViewType & SingleViewContent {
    func proceedInWorkflow() async throws {
        try await MainActor.run {
            XCTFail("Proceed for tests not implemented.")
//            try actualView().proceedInWorkflow()
        }
    }

    func proceedInWorkflow<T>(_ args: T) async throws {
        try await MainActor.run {
            XCTFail("Proceed for tests not implemented.")
//            try actualView().proceedInWorkflow(args)
        }
    }

    func backUpInWorkflow() async throws {
        try await MainActor.run {
            XCTFail("Proceed for tests not implemented.")
//            try actualView().backUpInWorkflow()
        }
    }

    func abandonWorkflow() async throws {
        try await MainActor.run {
            XCTFail("Proceed for tests not implemented.")
//            try actualView().workflow?.abandon()
        }
    }
}

@available(iOS 15.0, macOS 10.15, tvOS 13.0, *)
public extension InspectionEmissary where V: View {
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
