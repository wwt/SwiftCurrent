//
//  UIKitPresenterTests.swift
//  WorkflowUIKitTests
//
//  Created by Tyler Thompson on 5/1/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

@testable import SwiftCurrent
@testable import SwiftCurrent_UIKit

class UIKitPresenterTests: XCTestCase {
    func testUnknownLaunchStyleThrowsFatalError() {
        let ls = LaunchStyle.new
        class FR1: TestViewController { }
        class FR2: TestViewController { }

        let wf = Workflow(FR1.self).thenProceed(with: FR2.self)
        let rootController = UIViewController()
        rootController.loadForTesting()

        let presenter = UIKitPresenter(rootController, launchStyle: .modal)

        wf.orchestrationResponder = presenter
        let afr = AnyFlowRepresentable(FR1.self, args: .none)
        let metadata = FlowRepresentableMetadata(FR1.self, launchStyle: ls, flowPersistence: { _ in .default })
        let node = AnyWorkflow.Element(with: _WorkflowItem(metadata: metadata, instance: afr))

        XCTAssertThrowsFatalError {
            presenter.proceed(to: node, from: node)
        }
    }

    func testEvenWithoutAResponder_WorkflowStillAbandons() {
        class FR1: TestViewController { }
        let wf = Workflow(FR1.self)
        wf.launch(withOrchestrationResponder: UIKitPresenter(UIViewController(), launchStyle: .modal))
        wf.orchestrationResponder = nil
        wf.abandon()

        XCTAssertNil(wf.first?.value.instance?.proceedInWorkflowStorage)
        XCTAssertNil(wf.first?.value.instance)
    }
}

extension UIKitPresenterTests {
    class TestViewController: UIWorkflowItem<AnyWorkflow.PassedArgs, Any?>, FlowRepresentable {
        var data: Any?

        required init(with args: AnyWorkflow.PassedArgs) {
            super.init(nibName: nil, bundle: nil)
            view.backgroundColor = .red
            data = args.extractArgs(defaultValue: nil)
        }

        required init?(coder: NSCoder) { nil }

        func next() {
            proceedInWorkflow(data)
        }
    }
}
