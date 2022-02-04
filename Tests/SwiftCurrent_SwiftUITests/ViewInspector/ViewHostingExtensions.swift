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

@testable import SwiftCurrent_SwiftUI

@available(iOS 15.0, macOS 10.15, tvOS 13.0, *)
extension View where Self: Inspectable {
    func hostAndInspect<E: InspectionEmissary>(with emmisary: KeyPath<Self, E>) async throws -> InspectableView<ViewType.View<Self>> where E.V == Self {
        DispatchQueue.main.async { ViewHosting.host(view: self) }
        return try await self[keyPath: emmisary].inspect()
    }
}

@available(iOS 15.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension InspectableView where View: CustomViewType & SingleViewContent {
    func extractWorkflowItem<F, W, C>() async throws -> InspectableView<ViewType.View<WorkflowItem<F, W, C>>> where View.T == WorkflowLauncher<WorkflowItem<F, W, C>> {
        let mirror = Mirror(reflecting: try actualView())
        let model = try XCTUnwrap(mirror.descendant("_model") as? StateObject<WorkflowViewModel>)
        let launcher = try XCTUnwrap(mirror.descendant("_launcher") as? StateObject<Launcher>)
        let actual = try view(WorkflowItem<F, W, C>.self).actualView()

        DispatchQueue.main.async {
            ViewHosting.host(view: actual
                                .environmentObject(model.wrappedValue)
                                .environmentObject(launcher.wrappedValue))
        }
        
        return try await actual.inspection.inspect()
    }

    func extractWrappedWorkflowItem<F, W, C, PF, PC>() async throws -> InspectableView<ViewType.View<WorkflowItem<F, W, C>>> where View.T == WorkflowItem<PF, WorkflowItem<F, W, C>, PC> {
        let wrapped = try await actualView().getWrappedView()
        return try find(type(of: wrapped))
    }
}

@available(iOS 15.0, macOS 10.15, tvOS 13.0, *)
public extension InspectionEmissary where V: View & Inspectable {
    func inspect(after delay: TimeInterval = 0,
                 function: String = #function,
                 file: StaticString = #file,
                 line: UInt = #line) async throws -> InspectableView<ViewType.View<V>> {
        try await withCheckedThrowingContinuation { continuation in
            do {
                var v: InspectableView<ViewType.View<V>>?
                let exp = self.inspect(after: delay, function: function, file: file, line: line) { view in
                    v = view
                }
                XCTWaiter().wait(for: [exp], timeout: TestConstant.timeout)
                continuation.resume(returning: try XCTUnwrap(v, "view type \(String(describing: V.self)) not inspected"))
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension ViewHosting {
    static func loadView<V: View>(_ view: V) -> V {
        defer {
            Self.host(view: view)
        }
        return view
    }

    static func loadView<F, W, C>(_ view: WorkflowLauncher<WorkflowItem<F, W, C>>) -> WorkflowItem<F, W, C> {
        var workflowItem: WorkflowItem<F, W, C>!
        let exp = view.inspection.inspect {
            do {
                workflowItem = try $0.view(WorkflowItem<F, W, C>.self).actualView()
            } catch {
                XCTFail(error.localizedDescription)
            }
        }

        Self.host(view: view)

        XCTWaiter().wait(for: [exp], timeout: TestConstant.timeout)
        XCTAssertNotNil(workflowItem)
        let model = Mirror(reflecting: view).descendant("_model") as? StateObject<WorkflowViewModel>
        let launcher = Mirror(reflecting: view).descendant("_launcher") as? StateObject<Launcher>
        XCTAssertNotNil(model)
        XCTAssertNotNil(launcher)
        defer {
            Self.host(view: workflowItem.environmentObject(model!.wrappedValue).environmentObject(launcher!.wrappedValue))
        }
        return workflowItem
    }

    static func loadView<F, W, C>(_ view: WorkflowItem<F, W, C>, model: WorkflowViewModel, launcher: Launcher) -> WorkflowItem<F, W, C> {
        defer {
            Self.host(view: view.environmentObject(model).environmentObject(launcher))
        }
        return view
    }
}
