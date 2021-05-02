//
//  UIKitPresenterTests.swift
//  WorkflowUIKitTests
//
//  Created by Tyler Thompson on 5/1/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

@testable import Workflow
@testable import WorkflowUIKit

class UIKitPresenterTests: XCTestCase {
    func testUnknownLaunchStyleThrowsFatalError() {
        let ls = LaunchStyle.new
        class FR1: TestViewController { }
        class FR2: TestViewController { }

        let wf = Workflow(FR1.self).thenPresent(FR2.self)
        let rootController = UIViewController()
        rootController.loadForTesting()

        let presenter = UIKitPresenter(rootController, launchStyle: .modal)

        wf.applyOrchestrationResponder(presenter)
        var fr1 = FR1()
        let node = AnyWorkflow.InstanceNode(with: AnyFlowRepresentable(&fr1))
        let metadata = FlowRepresentableMetadata(FR1.self, launchStyle: ls, flowPersistence: { _ in .default })

        XCTAssertThrowsFatalError {
            presenter.proceed(to: (instance: node, metadata: metadata),
                              from: (instance: node, metadata: metadata))
        }
    }
}

extension UIKitPresenterTests {
    class TestViewController: UIWorkflowItem<AnyWorkflow.PassedArgs, Any?>, FlowRepresentable {
        var data: Any?
        static func instance() -> Self {
            let controller = Self()
            controller.view.backgroundColor = .red
            return controller
        }
        func shouldLoad(with args: AnyWorkflow.PassedArgs) -> Bool {
            self.data = args.extract(nil)
            return true
        }
        func next() {
            proceedInWorkflow(data)
        }
    }
}
