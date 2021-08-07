//
//  SwiftUIInteropTests.swift
//  SwiftCurrent_UIKitTests
//
//  Created by Tyler Thompson on 8/7/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest
import SwiftUI
import SwiftCurrent
import SwiftCurrent_SwiftUI
import SwiftCurrent_UIKit

final class SwiftUIInteropTests: XCTestCase {
    func testLaunchingIntoAWorkflowMixedWithSwiftUIViews() {
        class FR1: TestViewController { }
        struct FR2: View, FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?

            var body: some View {
                Text("FR2")
            }
        }
        class FR3: TestViewController { }

        let root = UIViewController()
        let nav = UINavigationController(rootViewController: root)
        nav.loadForTesting()
        root.launchInto(Workflow(FR1.self)
                            .thenProceed(with: HostedWorkflowItem<FR2>.self)
                            .thenProceed(with: FR3.self))

        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: HostedWorkflowItem<FR2>.self)
        (UIApplication.topViewController() as? HostedWorkflowItem<FR2>)?.proceedInWorkflow()
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
    }
}

extension SwiftUIInteropTests {
    class TestViewController: UIWorkflowItem<AnyWorkflow.PassedArgs, Any?>, FlowRepresentable {
        var data: Any?
        required init(with args: AnyWorkflow.PassedArgs) {
            super.init(nibName: nil, bundle: nil)
            view.backgroundColor = .blue
            data = args.extractArgs(defaultValue: nil)
        }

        required init?(coder: NSCoder) { nil }

        // See important documentation on FlowRepresentable
        func shouldLoad() -> Bool { true }

        func next() {
            proceedInWorkflow(data)
        }
    }
}
