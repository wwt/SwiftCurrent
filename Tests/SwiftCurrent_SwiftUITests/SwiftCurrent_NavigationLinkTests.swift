//
//  SwiftCurrent_NavigationLinkTests.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 7/12/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest
import SwiftUI
import ViewInspector

import SwiftCurrent
@testable import SwiftCurrent_SwiftUI // testable sadly needed for inspection.inspect to work

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
final class SwiftCurrent_NavigationLinkTests: XCTestCase, View {
    override func tearDownWithError() throws {
        removeQueuedExpectations()
    }
    
    func testWorkflowCanBeFollowed() throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        struct FR2: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }
        }
        let expectOnFinish = expectation(description: "OnFinish called")
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }.presentationType(.navigationLink)
            }
            .onFinish { _ in
                expectOnFinish.fulfill()
            }).inspection.inspect { fr1 in
                let model = (Mirror(reflecting: try fr1.actualView()).descendant("_model") as! EnvironmentObject<WorkflowViewModel>).wrappedValue
                let launcher = (Mirror(reflecting: try fr1.actualView()).descendant("_launcher") as! EnvironmentObject<Launcher>).wrappedValue
                XCTAssertEqual(try fr1.find(FR1.self).text().string(), "FR1 type")
                XCTAssertFalse(try fr1.find(ViewType.NavigationLink.self).isActive())
                XCTAssertNoThrow(try fr1.find(FR1.self).actualView().proceedInWorkflow())
                try fr1.actualView().inspect { fr1 in
                    XCTAssertTrue(try fr1.find(ViewType.NavigationLink.self).isActive())
                    try fr1.find(ViewType.NavigationLink.self).find(WorkflowItem<FR2, Never, FR2>.self).actualView().inspect(model: model, launcher: launcher) { fr2 in
                        XCTAssertEqual(try fr2.find(FR2.self).text().string(), "FR2 type")
                        XCTAssertNoThrow(try fr2.find(FR2.self).actualView().proceedInWorkflow())
                    }
                }
            }

        wait(for: [expectOnFinish, expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testWorkflowItemsOfTheSameTypeCanBeFollowed() throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }

        let expectViewLoaded = ViewHosting.loadView(
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR1.self)
                    }.presentationType(.navigationLink)
                }.presentationType(.navigationLink)
            }
        ).inspection.inspect { fr1 in
            let model = (Mirror(reflecting: try fr1.actualView()).descendant("_model") as! EnvironmentObject<WorkflowViewModel>).wrappedValue
            let launcher = (Mirror(reflecting: try fr1.actualView()).descendant("_launcher") as! EnvironmentObject<Launcher>).wrappedValue
            XCTAssertFalse(try fr1.find(ViewType.NavigationLink.self).isActive())
            XCTAssertNoThrow(try fr1.find(FR1.self).actualView().proceedInWorkflow())
            try fr1.actualView().inspect { first in
                XCTAssert(try first.find(ViewType.NavigationLink.self).isActive())
                try first.find(ViewType.NavigationLink.self).view(WorkflowItem<FR1, WorkflowItem<FR1, Never, FR1>, FR1>.self).actualView().inspect(model: model, launcher: launcher) { second in
                    XCTAssert(try first.find(ViewType.NavigationLink.self).isActive())
                    XCTAssertFalse(try second.find(ViewType.NavigationLink.self).isActive())
                    XCTAssertNoThrow(try second.find(FR1.self).actualView().proceedInWorkflow())
                    try second.actualView().inspect { second in
                        XCTAssert(try first.find(ViewType.NavigationLink.self).isActive())
                        XCTAssert(try second.find(ViewType.NavigationLink.self).isActive())
                        try second.find(ViewType.NavigationLink.self).view(WorkflowItem<FR1, Never, FR1>.self).actualView().inspect(model: model, launcher: launcher) { third in
                            XCTAssertNoThrow(try third.find(FR1.self).actualView().proceedInWorkflow())
                            try third.actualView().inspect { third in
                                XCTAssert(try first.find(ViewType.NavigationLink.self).isActive())
                                XCTAssert(try second.find(ViewType.NavigationLink.self).isActive())
                            }
                        }
                    }
                }
            }
        }

        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testLargeWorkflowCanBeFollowed() throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        struct FR2: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }
        }
        struct FR3: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR3 type") }
        }
        struct FR4: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR4 type") }
        }
        struct FR5: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR5 type") }
        }
        struct FR6: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR6 type") }
        }
        struct FR7: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR7 type") }
        }
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self) {
                        thenProceed(with: FR3.self) {
                            thenProceed(with: FR4.self) {
                                thenProceed(with: FR5.self) {
                                    thenProceed(with: FR6.self) {
                                        thenProceed(with: FR7.self)
                                    }.presentationType(.navigationLink)
                                }.presentationType(.navigationLink)
                            }.presentationType(.navigationLink)
                        }.presentationType(.navigationLink)
                    }.presentationType(.navigationLink)
                }.presentationType(.navigationLink)
            }
        ).inspection.inspect { fr1 in
            let model = (Mirror(reflecting: try fr1.actualView()).descendant("_model") as! EnvironmentObject<WorkflowViewModel>).wrappedValue
            let launcher = (Mirror(reflecting: try fr1.actualView()).descendant("_launcher") as! EnvironmentObject<Launcher>).wrappedValue
            XCTAssertFalse(try fr1.find(ViewType.NavigationLink.self).isActive())
            XCTAssertNoThrow(try fr1.find(FR1.self).actualView().proceedInWorkflow())
            try fr1.actualView().inspect { fr1 in
                XCTAssert(try fr1.find(ViewType.NavigationLink.self).isActive())
                try fr1.find(ViewType.NavigationLink.self).view(WorkflowItem<FR2, WorkflowItem<FR3, WorkflowItem<FR4, WorkflowItem<FR5, WorkflowItem<FR6, WorkflowItem<FR7, Never, FR7>, FR6>, FR5>, FR4>, FR3>, FR2>.self).actualView().inspect(model: model, launcher: launcher) { fr2 in
                    XCTAssert(try fr1.find(ViewType.NavigationLink.self).isActive())
                    XCTAssertFalse(try fr2.find(ViewType.NavigationLink.self).isActive())
                    XCTAssertNoThrow(try fr2.find(FR2.self).actualView().proceedInWorkflow())
                    try fr2.actualView().inspect { fr2 in
                        XCTAssert(try fr1.find(ViewType.NavigationLink.self).isActive())
                        XCTAssert(try fr2.find(ViewType.NavigationLink.self).isActive())
                        try fr2.find(ViewType.NavigationLink.self).view(WorkflowItem<FR3, WorkflowItem<FR4, WorkflowItem<FR5, WorkflowItem<FR6, WorkflowItem<FR7, Never, FR7>, FR6>, FR5>, FR4>, FR3>.self).actualView().inspect(model: model, launcher: launcher) { fr3 in
                            XCTAssertFalse(try fr3.find(ViewType.NavigationLink.self).isActive())
                            XCTAssertNoThrow(try fr3.find(FR3.self).actualView().proceedInWorkflow())
                            try fr3.actualView().inspect { fr3 in
                                XCTAssert(try fr1.find(ViewType.NavigationLink.self).isActive())
                                XCTAssert(try fr2.find(ViewType.NavigationLink.self).isActive())
                                XCTAssert(try fr3.find(ViewType.NavigationLink.self).isActive())
                                try fr3.find(ViewType.NavigationLink.self).view(WorkflowItem<FR4, WorkflowItem<FR5, WorkflowItem<FR6, WorkflowItem<FR7, Never, FR7>, FR6>, FR5>, FR4>.self).actualView().inspect(model: model, launcher: launcher) { fr4 in
                                    XCTAssertFalse(try fr4.find(ViewType.NavigationLink.self).isActive())
                                    XCTAssertNoThrow(try fr4.find(FR4.self).actualView().proceedInWorkflow())
                                    try fr4.actualView().inspect { fr4 in
                                        XCTAssert(try fr1.find(ViewType.NavigationLink.self).isActive())
                                        XCTAssert(try fr2.find(ViewType.NavigationLink.self).isActive())
                                        XCTAssert(try fr3.find(ViewType.NavigationLink.self).isActive())
                                        XCTAssert(try fr4.find(ViewType.NavigationLink.self).isActive())
                                        try fr4.find(ViewType.NavigationLink.self).view(WorkflowItem<FR5, WorkflowItem<FR6, WorkflowItem<FR7, Never, FR7>, FR6>, FR5>.self).actualView().inspect(model: model, launcher: launcher) { fr5 in
                                            XCTAssertFalse(try fr5.find(ViewType.NavigationLink.self).isActive())
                                            XCTAssertNoThrow(try fr5.find(FR5.self).actualView().proceedInWorkflow())
                                            try fr5.actualView().inspect { fr5 in
                                                XCTAssert(try fr1.find(ViewType.NavigationLink.self).isActive())
                                                XCTAssert(try fr2.find(ViewType.NavigationLink.self).isActive())
                                                XCTAssert(try fr3.find(ViewType.NavigationLink.self).isActive())
                                                XCTAssert(try fr4.find(ViewType.NavigationLink.self).isActive())
                                                XCTAssert(try fr5.find(ViewType.NavigationLink.self).isActive())
                                                try fr5.find(ViewType.NavigationLink.self).view(WorkflowItem<FR6, WorkflowItem<FR7, Never, FR7>, FR6>.self).actualView().inspect(model: model, launcher: launcher) { fr6 in
                                                    XCTAssertFalse(try fr6.find(ViewType.NavigationLink.self).isActive())
                                                    XCTAssertNoThrow(try fr6.find(FR6.self).actualView().proceedInWorkflow())
                                                    try fr6.actualView().inspect { fr6 in
                                                        XCTAssert(try fr1.find(ViewType.NavigationLink.self).isActive())
                                                        XCTAssert(try fr2.find(ViewType.NavigationLink.self).isActive())
                                                        XCTAssert(try fr3.find(ViewType.NavigationLink.self).isActive())
                                                        XCTAssert(try fr4.find(ViewType.NavigationLink.self).isActive())
                                                        XCTAssert(try fr5.find(ViewType.NavigationLink.self).isActive())
                                                        XCTAssert(try fr6.find(ViewType.NavigationLink.self).isActive())
                                                        try fr6.find(ViewType.NavigationLink.self).view(WorkflowItem<FR7, Never, FR7>.self).actualView().inspect(model: model, launcher: launcher) { fr7 in
                                                            XCTAssertNoThrow(try fr7.find(FR7.self).actualView().proceedInWorkflow())
                                                            try fr7.actualView().inspect { fr7 in
                                                                XCTAssert(try fr1.find(ViewType.NavigationLink.self).isActive())
                                                                XCTAssert(try fr2.find(ViewType.NavigationLink.self).isActive())
                                                                XCTAssert(try fr3.find(ViewType.NavigationLink.self).isActive())
                                                                XCTAssert(try fr4.find(ViewType.NavigationLink.self).isActive())
                                                                XCTAssert(try fr5.find(ViewType.NavigationLink.self).isActive())
                                                                XCTAssert(try fr6.find(ViewType.NavigationLink.self).isActive())
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testNavLinkWorkflowsCanSkipTheFirstItem() throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
            func shouldLoad() -> Bool { false }
        }
        struct FR2: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }
        }
        struct FR3: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR3 type") }
        }
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self) {
                        thenProceed(with: FR3.self)
                    }.presentationType(.navigationLink)
                }.presentationType(.navigationLink)
            }
        ).inspection.inspect { fr1 in
            let model = (Mirror(reflecting: try fr1.actualView()).descendant("_model") as! EnvironmentObject<WorkflowViewModel>).wrappedValue
            let launcher = (Mirror(reflecting: try fr1.actualView()).descendant("_launcher") as! EnvironmentObject<Launcher>).wrappedValue
            XCTAssertThrowsError(try fr1.find(FR1.self).actualView())
            try fr1.view(WorkflowItem<FR2, WorkflowItem<FR3, Never, FR3>, FR2>.self).actualView().inspect(model: model, launcher: launcher) { fr2 in
                XCTAssertFalse(try fr2.find(ViewType.NavigationLink.self).isActive())
                XCTAssertNoThrow(try fr2.find(FR2.self).actualView().proceedInWorkflow())
                try fr2.find(ViewType.NavigationLink.self).view(WorkflowItem<FR3, Never, FR3>.self).actualView().inspect(model: model, launcher: launcher) { fr3 in
                    XCTAssert(try fr2.find(ViewType.NavigationLink.self).isActive())
                    XCTAssertNoThrow(try fr3.find(FR3.self).actualView())
                }
            }
        }

        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testNavLinkWorkflowsCanSkipOneItemInTheMiddle() throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        struct FR2: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }
            func shouldLoad() -> Bool { false }
        }
        struct FR3: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR3 type") }
        }
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self) {
                        thenProceed(with: FR3.self)
                    }.presentationType(.navigationLink)
                }.presentationType(.navigationLink)
            }
        ).inspection.inspect { fr1 in
            let model = (Mirror(reflecting: try fr1.actualView()).descendant("_model") as! EnvironmentObject<WorkflowViewModel>).wrappedValue
            let launcher = (Mirror(reflecting: try fr1.actualView()).descendant("_launcher") as! EnvironmentObject<Launcher>).wrappedValue
            XCTAssertFalse(try fr1.find(ViewType.NavigationLink.self).isActive())
            XCTAssertNoThrow(try fr1.find(FR1.self).actualView().proceedInWorkflow())
            try fr1.actualView().inspect { fr1 in
                XCTAssert(try fr1.find(ViewType.NavigationLink.self).isActive())
                try fr1.find(ViewType.NavigationLink.self).view(WorkflowItem<FR2, WorkflowItem<FR3, Never, FR3>, FR2>.self).view(WorkflowItem<FR3, Never, FR3>.self).actualView().inspect(model: model, launcher: launcher) { fr3 in
                    XCTAssert(try fr1.find(ViewType.NavigationLink.self).isActive())
                    XCTAssertThrowsError(try fr1.find(FR2.self).actualView())
                    XCTAssertNoThrow(try fr3.find(FR3.self).actualView())
                }
            }
        }

        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testNavLinkWorkflowsCanSkipTwoItemsInTheMiddle() throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        struct FR2: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }
            func shouldLoad() -> Bool { false }
        }
        struct FR3: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR3 type") }
            func shouldLoad() -> Bool { false }
        }
        struct FR4: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR3 type") }
        }
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self) {
                        thenProceed(with: FR3.self) {
                            thenProceed(with: FR4.self)
                        }
                    }.presentationType(.navigationLink)
                }.presentationType(.navigationLink)
            }
        ).inspection.inspect { fr1 in
            let model = (Mirror(reflecting: try fr1.actualView()).descendant("_model") as! EnvironmentObject<WorkflowViewModel>).wrappedValue
            let launcher = (Mirror(reflecting: try fr1.actualView()).descendant("_launcher") as! EnvironmentObject<Launcher>).wrappedValue
            XCTAssertFalse(try fr1.find(ViewType.NavigationLink.self).isActive())
            XCTAssertNoThrow(try fr1.find(FR1.self).actualView().proceedInWorkflow())
            try fr1.actualView().inspect { fr1 in
                XCTAssert(try fr1.find(ViewType.NavigationLink.self).isActive())
                try fr1.find(ViewType.NavigationLink.self).view(WorkflowItem<FR2, WorkflowItem<FR3, WorkflowItem<FR4, Never, FR4>, FR3>, FR2>.self).view(WorkflowItem<FR3, WorkflowItem<FR4, Never, FR4>, FR3>.self).view(WorkflowItem<FR4, Never, FR4>.self).actualView().inspect(model: model, launcher: launcher) { fr4 in
                    XCTAssert(try fr1.find(ViewType.NavigationLink.self).isActive())
                    XCTAssertThrowsError(try fr1.find(FR2.self).actualView())
                    XCTAssertThrowsError(try fr1.find(FR3.self).actualView())
                    XCTAssertNoThrow(try fr4.find(FR4.self).actualView())
                }
            }
        }

        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testNavLinkWorkflowsCanSkipLastItem() throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        struct FR2: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }
        }
        struct FR3: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR3 type") }
            func shouldLoad() -> Bool { false }
        }

        let expectOnFinish = expectation(description: "onFinish called")
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self) {
                        thenProceed(with: FR3.self)
                    }.presentationType(.navigationLink)
                }.presentationType(.navigationLink)
            }
            .onFinish { _ in
                expectOnFinish.fulfill()
            }).inspection.inspect { fr1 in
                let model = (Mirror(reflecting: try fr1.actualView()).descendant("_model") as! EnvironmentObject<WorkflowViewModel>).wrappedValue
                let launcher = (Mirror(reflecting: try fr1.actualView()).descendant("_launcher") as! EnvironmentObject<Launcher>).wrappedValue
                XCTAssertFalse(try fr1.find(ViewType.NavigationLink.self).isActive())
                XCTAssertNoThrow(try fr1.find(FR1.self).actualView().proceedInWorkflow())
                try fr1.actualView().inspect { fr1 in
                    XCTAssert(try fr1.find(ViewType.NavigationLink.self).isActive())
                    try fr1.find(ViewType.NavigationLink.self).view(WorkflowItem<FR2, WorkflowItem<FR3, Never, FR3>, FR2>.self).actualView().inspect(model: model, launcher: launcher) { fr2 in
                        XCTAssert(try fr1.find(ViewType.NavigationLink.self).isActive())
                        XCTAssertFalse(try fr2.find(ViewType.NavigationLink.self).isActive())
                        XCTAssertNoThrow(try fr2.find(FR2.self).actualView().proceedInWorkflow())
                    }
                }
            }

        wait(for: [expectOnFinish, expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testConvenienceEmbedInNavViewFunction() throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }

        let launcherView = WorkflowLauncher(isLaunched: .constant(true)) {
            thenProceed(with: FR1.self).presentationType(.navigationLink)
        }.embedInNavigationView()

        let expectViewLoaded = launcherView.inspection.inspect { launcher in
            let navView = try launcher.navigationView()
            XCTAssert(try navView.navigationViewStyle() is StackNavigationViewStyle)
            XCTAssertNoThrow(try navView.view(WorkflowItem<FR1, Never, FR1>.self, 0))
        }
        ViewHosting.host(view: launcherView)
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
    }
}
