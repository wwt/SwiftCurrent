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
