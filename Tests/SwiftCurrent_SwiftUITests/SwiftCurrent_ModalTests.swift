//
//  SwiftCurrent_ModalTests.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 7/12/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest
import SwiftUI

import SwiftCurrent

@testable import ViewInspector
@testable import SwiftCurrent_SwiftUI // testable sadly needed for inspection.inspect to work

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension InspectableView where View == ViewType.Sheet {
    func isPresented() throws -> Bool {
        return (Mirror(reflecting: content.view).descendant("builder", "isPresented") as? Binding<Bool>)?.wrappedValue ?? false
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
final class SwiftCurrent_ModalTests: XCTestCase, View {
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
                    thenProceed(with: FR2.self).presentationType(.modal)
                }
            }
            .onFinish { _ in
                expectOnFinish.fulfill()
            }).inspection.inspect { fr1 in
                let model = (Mirror(reflecting: try fr1.actualView()).descendant("_model") as! EnvironmentObject<WorkflowViewModel>).wrappedValue
                let launcher = (Mirror(reflecting: try fr1.actualView()).descendant("_launcher") as! EnvironmentObject<Launcher>).wrappedValue
                XCTAssertEqual(try fr1.find(FR1.self).text().string(), "FR1 type")
                try fr1.actualView().inspect(model: model, launcher: launcher) { fr1 in
                    XCTAssertNoThrow(try fr1.find(FR1.self).actualView().proceedInWorkflow())
                    try fr1.actualView().inspect(model: model, launcher: launcher) { fr1 in
                        XCTAssertTrue(try fr1.find(ViewType.Sheet.self).isPresented())
                        try fr1.find(ViewType.Sheet.self).find(WorkflowItem<FR2, Never, FR2>.self).actualView().inspect(model: model, launcher: launcher) { fr2 in
                            XCTAssertEqual(try fr2.view(FR2.self).text().string(), "FR2 type")
                            XCTAssertNoThrow(try fr2.view(FR2.self).actualView().proceedInWorkflow())
                        }
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
                        thenProceed(with: FR1.self).presentationType(.modal)
                    }.presentationType(.modal)
                }
            }
        ).inspection.inspect { fr1 in
            let model = (Mirror(reflecting: try fr1.actualView()).descendant("_model") as! EnvironmentObject<WorkflowViewModel>).wrappedValue
            let launcher = (Mirror(reflecting: try fr1.actualView()).descendant("_launcher") as! EnvironmentObject<Launcher>).wrappedValue
            XCTAssertNoThrow(try fr1.find(FR1.self).actualView().proceedInWorkflow())
            try fr1.actualView().inspect { first in
                XCTAssert(try first.find(ViewType.Sheet.self).isPresented())
                try first.find(ViewType.Sheet.self).view(WorkflowItem<FR1, WorkflowItem<FR1, Never, FR1>, FR1>.self).actualView().inspect(model: model, launcher: launcher) { second in
                    XCTAssert(try first.find(ViewType.Sheet.self).isPresented())
                    XCTAssertNoThrow(try second.find(FR1.self).actualView().proceedInWorkflow())
                    try second.actualView().inspect { second in
                        XCTAssert(try first.find(ViewType.Sheet.self).isPresented())
                        XCTAssert(try second.find(ViewType.Sheet.self).isPresented())
                        try second.find(ViewType.Sheet.self).view(WorkflowItem<FR1, Never, FR1>.self).actualView().inspect(model: model, launcher: launcher) { third in
                            XCTAssertNoThrow(try third.find(FR1.self).actualView().proceedInWorkflow())
                            try third.actualView().inspect { third in
                                XCTAssert(try first.find(ViewType.Sheet.self).isPresented())
                                XCTAssert(try second.find(ViewType.Sheet.self).isPresented())
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
        var model: WorkflowViewModel!
        var launcher: Launcher!
        var fr1: InspectableView<ViewType.View<WorkflowItem<FR1, WorkflowItem<FR2, WorkflowItem<FR3, WorkflowItem<FR4, WorkflowItem<FR5, WorkflowItem<FR6, WorkflowItem<FR7, Never, FR7>, FR6>, FR5>, FR4>, FR3>, FR2>, FR1>>>!
        var fr2: InspectableView<ViewType.View<WorkflowItem<FR2, WorkflowItem<FR3, WorkflowItem<FR4, WorkflowItem<FR5, WorkflowItem<FR6, WorkflowItem<FR7, Never, FR7>, FR6>, FR5>, FR4>, FR3>, FR2>>>!
        var fr3: InspectableView<ViewType.View<WorkflowItem<FR3, WorkflowItem<FR4, WorkflowItem<FR5, WorkflowItem<FR6, WorkflowItem<FR7, Never, FR7>, FR6>, FR5>, FR4>, FR3>>>!
        var fr4: InspectableView<ViewType.View<WorkflowItem<FR4, WorkflowItem<FR5, WorkflowItem<FR6, WorkflowItem<FR7, Never, FR7>, FR6>, FR5>, FR4>>>!
        var fr5: InspectableView<ViewType.View<WorkflowItem<FR5, WorkflowItem<FR6, WorkflowItem<FR7, Never, FR7>, FR6>, FR5>>>!
        var fr6: InspectableView<ViewType.View<WorkflowItem<FR6, WorkflowItem<FR7, Never, FR7>, FR6>>>!

        let expectViewLoaded = ViewHosting.loadView(
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self) {
                        thenProceed(with: FR3.self) {
                            thenProceed(with: FR4.self) {
                                thenProceed(with: FR5.self) {
                                    thenProceed(with: FR6.self) {
                                        thenProceed(with: FR7.self).presentationType(.modal)
                                    }.presentationType(.modal)
                                }.presentationType(.modal)
                            }.presentationType(.modal)
                        }.presentationType(.modal)
                    }.presentationType(.modal)
                }
            }
        ).inspection.inspect { fr_1 in
            model = (Mirror(reflecting: try fr_1.actualView()).descendant("_model") as! EnvironmentObject<WorkflowViewModel>).wrappedValue
            launcher = (Mirror(reflecting: try fr_1.actualView()).descendant("_launcher") as! EnvironmentObject<Launcher>).wrappedValue
            XCTAssertNoThrow(try fr_1.find(FR1.self).actualView().proceedInWorkflow())
            try fr_1.actualView().inspect { fr_1 in
                XCTAssert(try fr_1.find(ViewType.Sheet.self).isPresented())
                fr1 = fr_1
            }
        }

        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)

        removeQueuedExpectations()

        try fr1.find(ViewType.Sheet.self).view(WorkflowItem<FR2, WorkflowItem<FR3, WorkflowItem<FR4, WorkflowItem<FR5, WorkflowItem<FR6, WorkflowItem<FR7, Never, FR7>, FR6>, FR5>, FR4>, FR3>, FR2>.self).actualView().inspect(model: model, launcher: launcher) { fr_2 in
            XCTAssert(try fr1.find(ViewType.Sheet.self).isPresented())
            XCTAssertNoThrow(try fr_2.find(FR2.self).actualView().proceedInWorkflow())
            try fr_2.actualView().inspect { fr_2 in
                XCTAssert(try fr1.find(ViewType.Sheet.self).isPresented())
                XCTAssert(try fr_2.find(ViewType.Sheet.self).isPresented())
                fr2 = fr_2
            }
        }

        removeQueuedExpectations()

        try fr2.find(ViewType.Sheet.self).view(WorkflowItem<FR3, WorkflowItem<FR4, WorkflowItem<FR5, WorkflowItem<FR6, WorkflowItem<FR7, Never, FR7>, FR6>, FR5>, FR4>, FR3>.self).actualView().inspect(model: model, launcher: launcher) { fr_3 in
            XCTAssertNoThrow(try fr_3.find(FR3.self).actualView().proceedInWorkflow())
            try fr_3.actualView().inspect { fr_3 in
                XCTAssert(try fr1.find(ViewType.Sheet.self).isPresented())
                XCTAssert(try fr2.find(ViewType.Sheet.self).isPresented())
                XCTAssert(try fr_3.find(ViewType.Sheet.self).isPresented())
                fr3 = fr_3
            }
        }

        removeQueuedExpectations()

        try fr3.find(ViewType.Sheet.self).view(WorkflowItem<FR4, WorkflowItem<FR5, WorkflowItem<FR6, WorkflowItem<FR7, Never, FR7>, FR6>, FR5>, FR4>.self).actualView().inspect(model: model, launcher: launcher) { fr_4 in
            XCTAssertNoThrow(try fr_4.find(FR4.self).actualView().proceedInWorkflow())
            try fr_4.actualView().inspect { fr_4 in
                XCTAssert(try fr1.find(ViewType.Sheet.self).isPresented())
                XCTAssert(try fr2.find(ViewType.Sheet.self).isPresented())
                XCTAssert(try fr3.find(ViewType.Sheet.self).isPresented())
                XCTAssert(try fr_4.find(ViewType.Sheet.self).isPresented())
                fr4 = fr_4
            }
        }

        removeQueuedExpectations()

        try fr4.find(ViewType.Sheet.self).view(WorkflowItem<FR5, WorkflowItem<FR6, WorkflowItem<FR7, Never, FR7>, FR6>, FR5>.self).actualView().inspect(model: model, launcher: launcher) { fr_5 in
            XCTAssertNoThrow(try fr_5.find(FR5.self).actualView().proceedInWorkflow())
            try fr_5.actualView().inspect { fr_5 in
                XCTAssert(try fr1.find(ViewType.Sheet.self).isPresented())
                XCTAssert(try fr2.find(ViewType.Sheet.self).isPresented())
                XCTAssert(try fr3.find(ViewType.Sheet.self).isPresented())
                XCTAssert(try fr4.find(ViewType.Sheet.self).isPresented())
                XCTAssert(try fr_5.find(ViewType.Sheet.self).isPresented())
                fr5 = fr_5
            }
        }

        removeQueuedExpectations()

        try fr5.find(ViewType.Sheet.self).view(WorkflowItem<FR6, WorkflowItem<FR7, Never, FR7>, FR6>.self).actualView().inspect(model: model, launcher: launcher) { fr_6 in
            XCTAssertNoThrow(try fr_6.find(FR6.self).actualView().proceedInWorkflow())
            try fr_6.actualView().inspect { fr_6 in
                XCTAssert(try fr1.find(ViewType.Sheet.self).isPresented())
                XCTAssert(try fr2.find(ViewType.Sheet.self).isPresented())
                XCTAssert(try fr3.find(ViewType.Sheet.self).isPresented())
                XCTAssert(try fr4.find(ViewType.Sheet.self).isPresented())
                XCTAssert(try fr5.find(ViewType.Sheet.self).isPresented())
                XCTAssert(try fr_6.find(ViewType.Sheet.self).isPresented())
                fr6 = fr_6
            }
        }

        removeQueuedExpectations()

        try fr6.find(ViewType.Sheet.self).view(WorkflowItem<FR7, Never, FR7>.self).actualView().inspect(model: model, launcher: launcher) { fr7 in
            XCTAssertNoThrow(try fr7.find(FR7.self).actualView().proceedInWorkflow())
            try fr7.actualView().inspect { fr7 in
                XCTAssert(try fr1.find(ViewType.Sheet.self).isPresented())
                XCTAssert(try fr2.find(ViewType.Sheet.self).isPresented())
                XCTAssert(try fr3.find(ViewType.Sheet.self).isPresented())
                XCTAssert(try fr4.find(ViewType.Sheet.self).isPresented())
                XCTAssert(try fr5.find(ViewType.Sheet.self).isPresented())
                XCTAssert(try fr6.find(ViewType.Sheet.self).isPresented())
            }
        }
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
                        thenProceed(with: FR3.self).presentationType(.modal)
                    }.presentationType(.modal)
                }
            }
        ).inspection.inspect { fr1 in
            let model = (Mirror(reflecting: try fr1.actualView()).descendant("_model") as! EnvironmentObject<WorkflowViewModel>).wrappedValue
            let launcher = (Mirror(reflecting: try fr1.actualView()).descendant("_launcher") as! EnvironmentObject<Launcher>).wrappedValue
            XCTAssertThrowsError(try fr1.find(FR1.self).actualView())
            try fr1.view(WorkflowItem<FR2, WorkflowItem<FR3, Never, FR3>, FR2>.self).actualView().inspect(model: model, launcher: launcher) { fr2 in
                XCTAssertNoThrow(try fr2.find(FR2.self).actualView().proceedInWorkflow())
                try fr2.actualView().inspect { fr2 in
                    try fr2.find(ViewType.Sheet.self).view(WorkflowItem<FR3, Never, FR3>.self).actualView().inspect(model: model, launcher: launcher) { fr3 in
                        XCTAssert(try fr2.find(ViewType.Sheet.self).isPresented())
                        XCTAssertNoThrow(try fr3.find(FR3.self).actualView())
                    }
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
                        thenProceed(with: FR3.self).presentationType(.modal)
                    }.presentationType(.modal)
                }
            }
        ).inspection.inspect { fr1 in
            let model = (Mirror(reflecting: try fr1.actualView()).descendant("_model") as! EnvironmentObject<WorkflowViewModel>).wrappedValue
            let launcher = (Mirror(reflecting: try fr1.actualView()).descendant("_launcher") as! EnvironmentObject<Launcher>).wrappedValue
            XCTAssertNoThrow(try fr1.find(FR1.self).actualView().proceedInWorkflow())
            try fr1.actualView().inspect { fr1 in
                XCTAssert(try fr1.find(ViewType.Sheet.self).isPresented())
                try fr1.find(ViewType.Sheet.self).view(WorkflowItem<FR2, WorkflowItem<FR3, Never, FR3>, FR2>.self).view(WorkflowItem<FR3, Never, FR3>.self).actualView().inspect(model: model, launcher: launcher) { fr3 in
                    XCTAssert(try fr1.find(ViewType.Sheet.self).isPresented())
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
                            thenProceed(with: FR4.self).presentationType(.modal)
                        }
                    }.presentationType(.modal)
                }
            }
        ).inspection.inspect { fr1 in
            let model = (Mirror(reflecting: try fr1.actualView()).descendant("_model") as! EnvironmentObject<WorkflowViewModel>).wrappedValue
            let launcher = (Mirror(reflecting: try fr1.actualView()).descendant("_launcher") as! EnvironmentObject<Launcher>).wrappedValue
            XCTAssertNoThrow(try fr1.find(FR1.self).actualView().proceedInWorkflow())
            try fr1.actualView().inspect { fr1 in
                XCTAssert(try fr1.find(ViewType.Sheet.self).isPresented())
                try fr1.find(ViewType.Sheet.self).view(WorkflowItem<FR2, WorkflowItem<FR3, WorkflowItem<FR4, Never, FR4>, FR3>, FR2>.self).view(WorkflowItem<FR3, WorkflowItem<FR4, Never, FR4>, FR3>.self).view(WorkflowItem<FR4, Never, FR4>.self).actualView().inspect(model: model, launcher: launcher) { fr4 in
                    XCTAssert(try fr1.find(ViewType.Sheet.self).isPresented())
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
                        thenProceed(with: FR3.self).presentationType(.modal)
                    }.presentationType(.modal)
                }
            }
            .onFinish { _ in
                expectOnFinish.fulfill()
            }).inspection.inspect { fr1 in
                let model = (Mirror(reflecting: try fr1.actualView()).descendant("_model") as! EnvironmentObject<WorkflowViewModel>).wrappedValue
                let launcher = (Mirror(reflecting: try fr1.actualView()).descendant("_launcher") as! EnvironmentObject<Launcher>).wrappedValue
                XCTAssertNoThrow(try fr1.find(FR1.self).actualView().proceedInWorkflow())
                try fr1.actualView().inspect { fr1 in
                    XCTAssert(try fr1.find(ViewType.Sheet.self).isPresented())
                    try fr1.find(ViewType.Sheet.self).view(WorkflowItem<FR2, WorkflowItem<FR3, Never, FR3>, FR2>.self).actualView().inspect(model: model, launcher: launcher) { fr2 in
                        XCTAssert(try fr1.find(ViewType.Sheet.self).isPresented())
                        XCTAssertNoThrow(try fr2.find(FR2.self).actualView().proceedInWorkflow())
                    }
                }
            }

        wait(for: [expectOnFinish, expectViewLoaded], timeout: TestConstant.timeout)
    }

}
