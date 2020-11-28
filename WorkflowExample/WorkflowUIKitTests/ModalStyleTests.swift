//
//  ModalStyleTests.swift
//  WorkflowTests
//
//  Created by Tyler Thompson on 3/8/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest
import UIUTest

@testable import Workflow
import WorkflowUIKit

class ModalStyleTests: XCTestCase {
    override func setUp() {
        UIViewController.initializeTestable()
    }
    
    override func tearDown() {
        UIViewController.flushPendingTestArtifacts()
    }
    
    func testShowModalFullScreen() {
        loadView(controller: RootViewController.standard)
        
        UIApplication.topViewController()?
            .launchInto(Workflow(TestViewController.self,
                             presentationType: .modal(.fullScreen)))
        
        waitUntil(UIApplication.topViewController() is TestViewController)
        XCTAssertEqual(UIApplication.topViewController()?.modalPresentationStyle, .fullScreen)
    }
    
    func testShowModalAsPageSheet() {
        let vc = RootViewController()
        loadView(controller: vc)

        UIApplication.topViewController()?
            .launchInto(Workflow(TestViewController.self,
                             presentationType: .modal(.pageSheet)))
        
        waitUntil(UIApplication.topViewController() is TestViewController)
        
        XCTAssertEqual(UIApplication.topViewController()?.modalPresentationStyle, .pageSheet)
    }
    
    func testShowModalAsFormSheet() {
        loadView(controller: RootViewController.standard)
        
        UIApplication.topViewController()?
            .launchInto(Workflow(TestViewController.self,
                             presentationType: .modal(.formSheet)))
        
        waitUntil(UIApplication.topViewController() is TestViewController)
        XCTAssertEqual(UIApplication.topViewController()?.modalPresentationStyle, .formSheet)
    }

    func testShowModalWithCurrentContext() {
        loadView(controller: RootViewController.standard)
        
        UIApplication.topViewController()?
            .launchInto(Workflow(TestViewController.self,
                             presentationType: .modal(.currentContext)))
        
        waitUntil(UIApplication.topViewController() is TestViewController)
        XCTAssertEqual(UIApplication.topViewController()?.modalPresentationStyle, .currentContext)
    }

    func testShowModalAsCustom() {
        loadView(controller: RootViewController.standard)
        
        UIApplication.topViewController()?
            .launchInto(Workflow(TestViewController.self,
                             presentationType: .modal(.custom)))
        
        waitUntil(UIApplication.topViewController() is TestViewController)
        XCTAssertEqual(UIApplication.topViewController()?.modalPresentationStyle, .custom)
    }

    func testShowModalOverFullScreen() {
        loadView(controller: RootViewController.standard)
        
        UIApplication.topViewController()?
            .launchInto(Workflow(TestViewController.self,
                             presentationType: .modal(.overFullScreen)))
        
        waitUntil(UIApplication.topViewController() is TestViewController)
        XCTAssertEqual(UIApplication.topViewController()?.modalPresentationStyle, .overFullScreen)
    }

    func testShowModalOverCurrentContext() {
        loadView(controller: RootViewController.standard)
        
        UIApplication.topViewController()?
            .launchInto(Workflow(TestViewController.self,
                             presentationType: .modal(.overCurrentContext)))
        
        waitUntil(UIApplication.topViewController() is TestViewController)
        XCTAssertEqual(UIApplication.topViewController()?.modalPresentationStyle, .overCurrentContext)
    }

    func testShowModalAsPopover() {
        loadView(controller: RootViewController.standard)
        
        UIApplication.topViewController()?
            .launchInto(Workflow(TestViewController.self,
                             presentationType: .modal(.popover)))
        
        waitUntil(UIApplication.topViewController() is TestViewController)
        XCTAssertEqual(UIApplication.topViewController()?.modalPresentationStyle, .popover)
    }
    
    @available(iOS 13.0, *)
    func testShowModalWithAutomaticStyle() {
        loadView(controller: RootViewController.standard)
        
        UIApplication.topViewController()?
            .launchInto(Workflow(TestViewController.self,
                             presentationType: .modal(.automatic)))
        
        waitUntil(UIApplication.topViewController() is TestViewController)
        XCTAssertEqual(UIApplication.topViewController()?.modalPresentationStyle, UIViewController().modalPresentationStyle)
    }
    
    func testShowModalFullScreen_FromLaunch() {
        loadView(controller: RootViewController.standard)
        
        UIApplication.topViewController()?
            .launchInto(Workflow(TestViewController.self),
                             withLaunchStyle: .modal(.fullScreen))
        
        waitUntil(UIApplication.topViewController() is TestViewController)
        XCTAssertEqual(UIApplication.topViewController()?.modalPresentationStyle, .fullScreen)
    }
    
    func testShowModalAsPageSheet_FromLaunch() {
        let vc = RootViewController()
        loadView(controller: vc)
        
        UIApplication.topViewController()?
            .launchInto(Workflow(TestViewController.self),
                             withLaunchStyle: .modal(.pageSheet))
        
        waitUntil(UIApplication.topViewController() is TestViewController)
        XCTAssertEqual(UIApplication.topViewController()?.modalPresentationStyle, .pageSheet)
    }
    
    func testShowModalAsFormSheet_FromLaunch() {
        loadView(controller: RootViewController.standard)
        
        UIApplication.topViewController()?
            .launchInto(Workflow(TestViewController.self),
                             withLaunchStyle: .modal(.formSheet))
        
        waitUntil(UIApplication.topViewController() is TestViewController)
        XCTAssertEqual(UIApplication.topViewController()?.modalPresentationStyle, .formSheet)
    }

    func testShowModalWithCurrentContext_FromLaunch() {
        loadView(controller: RootViewController.standard)
        
        UIApplication.topViewController()?
            .launchInto(Workflow(TestViewController.self),
                             withLaunchStyle: .modal(.currentContext))
        
        waitUntil(UIApplication.topViewController() is TestViewController)
        XCTAssertEqual(UIApplication.topViewController()?.modalPresentationStyle, .currentContext)
    }

    func testShowModalAsCustom_FromLaunch() {
        loadView(controller: RootViewController.standard)
        
        UIApplication.topViewController()?
            .launchInto(Workflow(TestViewController.self),
                             withLaunchStyle: .modal(.custom))
        
        waitUntil(UIApplication.topViewController() is TestViewController)
        XCTAssertEqual(UIApplication.topViewController()?.modalPresentationStyle, .custom)
    }

    func testShowModalOverFullScreen_FromLaunch() {
        loadView(controller: RootViewController.standard)
        
        UIApplication.topViewController()?
            .launchInto(Workflow(TestViewController.self),
                             withLaunchStyle: .modal(.overFullScreen))
        
        waitUntil(UIApplication.topViewController() is TestViewController)
        XCTAssertEqual(UIApplication.topViewController()?.modalPresentationStyle, .overFullScreen)
    }

    func testShowModalOverCurrentContext_FromLaunch() {
        loadView(controller: RootViewController.standard)
        
        UIApplication.topViewController()?
            .launchInto(Workflow(TestViewController.self),
                             withLaunchStyle: .modal(.overCurrentContext))
        
        waitUntil(UIApplication.topViewController() is TestViewController)
        XCTAssertEqual(UIApplication.topViewController()?.modalPresentationStyle, .overCurrentContext)
    }

    func testShowModalAsPopover_FromLaunch() {
        loadView(controller: RootViewController.standard)
        
        UIApplication.topViewController()?
            .launchInto(Workflow(TestViewController.self),
                             withLaunchStyle: .modal(.popover))
        
        waitUntil(UIApplication.topViewController() is TestViewController)
        XCTAssertEqual(UIApplication.topViewController()?.modalPresentationStyle, .popover)
    }
    
    @available(iOS 13.0, *)
    func testShowModalWithAutomaticStyle_FromLaunch() {
        loadView(controller: RootViewController.standard)
        
        UIApplication.topViewController()?
            .launchInto(Workflow(TestViewController.self),
                             withLaunchStyle: .modal(.automatic))
        
        waitUntil(UIApplication.topViewController() is TestViewController)
        XCTAssertEqual(UIApplication.topViewController()?.modalPresentationStyle, UIViewController().modalPresentationStyle)
    }
    
    func testShowModalFullScreen_FromLaunch_WithFirstScreenOnANavController() {
        loadView(controller: RootViewController.standard)
        
        UIApplication.topViewController()?
            .launchInto(Workflow(TestViewController.self, presentationType: .navigationStack),
                             withLaunchStyle: .modal(.fullScreen))
        
        waitUntil(UIApplication.topViewController() is TestViewController)
        XCTAssertEqual(UIApplication.topViewController()?.navigationController?.modalPresentationStyle, .fullScreen)
    }
    
    func testShowModalAsPageSheet_FromLaunch_WithFirstScreenOnANavController() {
        let vc = RootViewController()
        loadView(controller: vc)
        
        UIApplication.topViewController()?
            .launchInto(Workflow(TestViewController.self, presentationType: .navigationStack),
                             withLaunchStyle: .modal(.pageSheet))
        
        waitUntil(UIApplication.topViewController() is TestViewController)
        XCTAssertEqual(UIApplication.topViewController()?.modalPresentationStyle, .pageSheet)
    }
    
    func testShowModalAsFormSheet_FromLaunch_WithFirstScreenOnANavController() {
        loadView(controller: RootViewController.standard)
        
        UIApplication.topViewController()?
            .launchInto(Workflow(TestViewController.self, presentationType: .navigationStack),
                             withLaunchStyle: .modal(.formSheet))
        
        waitUntil(UIApplication.topViewController() is TestViewController)
        XCTAssertEqual(UIApplication.topViewController()?.navigationController?.modalPresentationStyle, .formSheet)
    }

    func testShowModalWithCurrentContext_FromLaunch_WithFirstScreenOnANavController() {
        loadView(controller: RootViewController.standard)
        
        UIApplication.topViewController()?
            .launchInto(Workflow(TestViewController.self, presentationType: .navigationStack),
                             withLaunchStyle: .modal(.currentContext))
        
        waitUntil(UIApplication.topViewController() is TestViewController)
        XCTAssertEqual(UIApplication.topViewController()?.navigationController?.modalPresentationStyle, .currentContext)
    }

    func testShowModalAsCustom_FromLaunch_WithFirstScreenOnANavController() {
        loadView(controller: RootViewController.standard)
        
        UIApplication.topViewController()?
            .launchInto(Workflow(TestViewController.self, presentationType: .navigationStack),
                             withLaunchStyle: .modal(.custom))
        
        waitUntil(UIApplication.topViewController() is TestViewController)
        XCTAssertEqual(UIApplication.topViewController()?.navigationController?.modalPresentationStyle, .custom)
    }

    func testShowModalOverFullScreen_FromLaunch_WithFirstScreenOnANavController() {
        loadView(controller: RootViewController.standard)
        
        UIApplication.topViewController()?
            .launchInto(Workflow(TestViewController.self, presentationType: .navigationStack),
                             withLaunchStyle: .modal(.overFullScreen))
        
        waitUntil(UIApplication.topViewController() is TestViewController)
        XCTAssertEqual(UIApplication.topViewController()?.navigationController?.modalPresentationStyle, .overFullScreen)
    }

    func testShowModalOverCurrentContext_FromLaunch_WithFirstScreenOnANavController() {
        loadView(controller: RootViewController.standard)
        
        UIApplication.topViewController()?
            .launchInto(Workflow(TestViewController.self, presentationType: .navigationStack),
                             withLaunchStyle: .modal(.overCurrentContext))
        
        waitUntil(UIApplication.topViewController() is TestViewController)
        XCTAssertEqual(UIApplication.topViewController()?.navigationController?.modalPresentationStyle, .overCurrentContext)
    }

    func testShowModalAsPopover_FromLaunch_WithFirstScreenOnANavController() {
        loadView(controller: RootViewController.standard)
        
        UIApplication.topViewController()?
            .launchInto(Workflow(TestViewController.self, presentationType: .navigationStack),
                             withLaunchStyle: .modal(.popover))
        
        waitUntil(UIApplication.topViewController() is TestViewController)
        XCTAssertEqual(UIApplication.topViewController()?.navigationController?.modalPresentationStyle, .popover)
    }
    
    @available(iOS 13.0, *)
    func testShowModalWithAutomaticStyle_FromLaunch_WithFirstScreenOnANavController() {
        loadView(controller: RootViewController.standard)
        
        UIApplication.topViewController()?
            .launchInto(Workflow(TestViewController.self, presentationType: .navigationStack),
                             withLaunchStyle: .modal(.automatic))
        
        waitUntil(UIApplication.topViewController() is TestViewController)
        XCTAssertEqual(UIApplication.topViewController()?.navigationController?.modalPresentationStyle, UIViewController().modalPresentationStyle)
    }
    
    private func loadView(controller: UIViewController) {
        let window = UIApplication.shared.windows.first
        window?.removeViewsFromRootViewController()
        
        window?.rootViewController = controller
        controller.loadViewIfNeeded()
        controller.view.layoutIfNeeded()
        
        controller.viewWillAppear(false)
        controller.viewDidAppear(false)
        
        CATransaction.flush()
    }
}

extension ModalStyleTests {
    class RootViewController: UIWorkflowItem<Never, Never>, FlowRepresentable {
        static func instance() -> Self {
            standard as! Self
        }
        
        static var standard: ModalStyleTests.RootViewController {
            let controller = Self()
            controller.view.backgroundColor = .blue
            return controller
        }
    }
    
    class TestViewController: UIWorkflowItem<Any?, Any?>, FlowRepresentable {
        var data:Any?
        static func instance() -> Self {
            let controller = Self()
            controller.view.backgroundColor = .red
            return controller
        }
        func shouldLoad(with args: Any?) -> Bool {
            self.data = args
            return true
        }
        func next() {
            proceedInWorkflow(data)
        }
    }
}
