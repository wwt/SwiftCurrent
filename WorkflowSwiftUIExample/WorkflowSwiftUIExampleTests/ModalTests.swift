//
//  ModalTests.swift
//  WorkflowSwiftUIExampleTests
//
//  Created by Tyler Thompson on 12/5/20.
//

import Foundation
import SwiftUI
import Workflow
import ViewInspector
import XCTest

@testable import WorkflowSwiftUI

class ModalTests: XCTestCase {
    func testProceedingForwardWithWorkflow_WithDefaultLaunchStyle_AndModalDefaultPresentationOnSecondaryAndFartherViews_CallsThroughToOnFinish() throws {
        let expectation = self.expectation(description: "OnFinish called")
        let view = WorkflowView(Workflow(FR1.self)
                                    .thenPresent(FR2.self, presentationType: .modal)
                                    .thenPresent(FR3.self, presentationType: .modal)
                                    .thenPresent(FR4.self, presentationType: .modal)) { _ in expectation.fulfill() }

        let fr1 = try view.workflowModel.view.inspect().anyView().view(FR1.self).actualView()
        fr1.proceedInWorkflow()
        //NOTE: The best we can really do here is assert the wrapper has the correct views set, we cannot really assert that it was presented modally per se
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView().current.inspect().anyView().view(FR1.self)
        let fr2 = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView().next.inspect().anyView().view(FR2.self).actualView()
        fr2.proceedInWorkflow()

        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR1.self)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR2.self)
        let fr3 = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(FR3.self).actualView()
        fr3.proceedInWorkflow()

        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR1.self)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR2.self)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR3.self)
        let fr4 = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(FR4.self).actualView()
        fr4.proceedInWorkflow()

        wait(for: [expectation], timeout: 3)
    }

    func testProceedingForwardWithWorkflow_WithModalModalLaunchStyle_AndModalDefaultPresentationOnSecondaryAndFartherViews_CallsThroughToOnFinish() throws {
        let expectation = self.expectation(description: "OnFinish called")
        let view = WorkflowView(Workflow(FR1.self)
                                    .thenPresent(FR2.self, presentationType: .modal)
                                    .thenPresent(FR3.self, presentationType: .modal)
                                    .thenPresent(FR4.self, presentationType: .modal), withLaunchStyle: .modal) { _ in expectation.fulfill() }

        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView().current.inspect().anyView().emptyView()
        let fr1 = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView().next.inspect().anyView().view(FR1.self).actualView()
        fr1.proceedInWorkflow()

        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().emptyView()
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR1.self)
        let fr2 = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(FR2.self).actualView()
        fr2.proceedInWorkflow()

        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().emptyView()
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR1.self)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR2.self)
        let fr3 = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(FR3.self).actualView()
        fr3.proceedInWorkflow()

        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().emptyView()
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR1.self)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR2.self)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR3.self)
        let fr4 = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(FR4.self).actualView()
        fr4.proceedInWorkflow()

        wait(for: [expectation], timeout: 3)
    }

    func testProceedingForwardWithWorkflow_WithModalModalLaunchStyle_AndModalDefaultPresentationAllViews_CallsThroughToOnFinish() throws {
        let expectation = self.expectation(description: "OnFinish called")
        let view = WorkflowView(Workflow(FR1.self, presentationType: .modal)
                                    .thenPresent(FR2.self, presentationType: .modal)
                                    .thenPresent(FR3.self, presentationType: .modal)
                                    .thenPresent(FR4.self, presentationType: .modal), withLaunchStyle: .modal) { _ in expectation.fulfill() }

        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView().current.inspect().anyView().emptyView()
        let fr1 = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(FR1.self).actualView()
        fr1.proceedInWorkflow()

        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().emptyView()
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR1.self)
        let fr2 = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(FR2.self).actualView()
        fr2.proceedInWorkflow()

        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().emptyView()
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR1.self)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR2.self)
        let fr3 = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(FR3.self).actualView()
        fr3.proceedInWorkflow()

        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().emptyView()
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR1.self)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR2.self)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR3.self)
        let fr4 = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(FR4.self).actualView()
        fr4.proceedInWorkflow()

        wait(for: [expectation], timeout: 3)
    }

    func testProceedingForwardWithWorkflow_WithDefaultLaunchStyle_AndModalDefaultPresentationAllViews_CallsThroughToOnFinish() throws {
        let expectation = self.expectation(description: "OnFinish called")
        let view = WorkflowView(Workflow(FR1.self, presentationType: .modal)
                                    .thenPresent(FR2.self, presentationType: .modal)
                                    .thenPresent(FR3.self, presentationType: .modal)
                                    .thenPresent(FR4.self, presentationType: .modal)) { _ in expectation.fulfill() }

        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView().current.inspect().anyView().emptyView()
        let fr1 = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(FR1.self).actualView()
        fr1.proceedInWorkflow()

        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR1.self)
        let fr2 = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(FR2.self).actualView()
        fr2.proceedInWorkflow()

        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR1.self)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR2.self)
        let fr3 = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(FR3.self).actualView()
        fr3.proceedInWorkflow()

        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR1.self)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR2.self)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR3.self)
        let fr4 = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(FR4.self).actualView()
        fr4.proceedInWorkflow()

        wait(for: [expectation], timeout: 3)
    }

    func testProceedingForwardWithWorkflow_WithDefaultLaunchStyle_AndModalFullScreenPresentationOnSecondaryAndFartherViews_CallsThroughToOnFinish() throws {
        let expectation = self.expectation(description: "OnFinish called")
        let view = WorkflowView(Workflow(FR1.self)
                                    .thenPresent(FR2.self, presentationType: .modal(.fullScreen))
                                    .thenPresent(FR3.self, presentationType: .modal(.fullScreen))
                                    .thenPresent(FR4.self, presentationType: .modal(.fullScreen))) { _ in expectation.fulfill() }

        let fr1 = try view.workflowModel.view.inspect().anyView().view(FR1.self).actualView()
        fr1.proceedInWorkflow()
        //NOTE: The best we can really do here is assert the wrapper has the correct views set, we cannot really assert that it was presented modally per se
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView().current.inspect().anyView().view(FR1.self)
        let fr2 = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView().next.inspect().anyView().view(FR2.self).actualView()
        fr2.proceedInWorkflow()

        XCTAssertEqual(try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView().style, .fullScreen)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR1.self)
        XCTAssertEqual(try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
                        .next.inspect().anyView().view(ModalWrapper.self).actualView().style, .fullScreen)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR2.self)
        let fr3 = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(FR3.self).actualView()
        fr3.proceedInWorkflow()

        XCTAssertEqual(try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView().style, .fullScreen)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR1.self)
        XCTAssertEqual(try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
                        .next.inspect().anyView().view(ModalWrapper.self).actualView().style, .fullScreen)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR2.self)
        XCTAssertEqual(try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
                        .next.inspect().anyView().view(ModalWrapper.self).actualView()
                        .next.inspect().anyView().view(ModalWrapper.self).actualView().style, .fullScreen)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR3.self)
        let fr4 = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(FR4.self).actualView()
        fr4.proceedInWorkflow()

        wait(for: [expectation], timeout: 3)
    }

    func testProceedingForwardWithWorkflow_WithModalModalLaunchStyle_AndModalFullScreenPresentationOnSecondaryAndFartherViews_CallsThroughToOnFinish() throws {
        let expectation = self.expectation(description: "OnFinish called")
        let view = WorkflowView(Workflow(FR1.self)
                                    .thenPresent(FR2.self, presentationType: .modal(.fullScreen))
                                    .thenPresent(FR3.self, presentationType: .modal(.fullScreen))
                                    .thenPresent(FR4.self, presentationType: .modal(.fullScreen)), withLaunchStyle: .modal(.fullScreen)) { _ in expectation.fulfill() }

        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView().current.inspect().anyView().emptyView()
        let fr1 = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView().next.inspect().anyView().view(FR1.self).actualView()
        fr1.proceedInWorkflow()

        XCTAssertEqual(try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView().style, .fullScreen)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().emptyView()
        XCTAssertEqual(try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
                        .next.inspect().anyView().view(ModalWrapper.self).actualView().style, .fullScreen)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR1.self)
        let fr2 = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(FR2.self).actualView()
        fr2.proceedInWorkflow()

        XCTAssertEqual(try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView().style, .fullScreen)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().emptyView()
        XCTAssertEqual(try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
                        .next.inspect().anyView().view(ModalWrapper.self).actualView().style, .fullScreen)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR1.self)
        XCTAssertEqual(try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
                        .next.inspect().anyView().view(ModalWrapper.self).actualView()
                        .next.inspect().anyView().view(ModalWrapper.self).actualView().style, .fullScreen)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR2.self)
        let fr3 = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(FR3.self).actualView()
        fr3.proceedInWorkflow()

        XCTAssertEqual(try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView().style, .fullScreen)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().emptyView()
        XCTAssertEqual(try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
                        .next.inspect().anyView().view(ModalWrapper.self).actualView().style, .fullScreen)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR1.self)
        XCTAssertEqual(try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
                        .next.inspect().anyView().view(ModalWrapper.self).actualView()
                        .next.inspect().anyView().view(ModalWrapper.self).actualView().style, .fullScreen)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR2.self)
        XCTAssertEqual(try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
                        .next.inspect().anyView().view(ModalWrapper.self).actualView()
                        .next.inspect().anyView().view(ModalWrapper.self).actualView()
                        .next.inspect().anyView().view(ModalWrapper.self).actualView().style, .fullScreen)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR3.self)
        let fr4 = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(FR4.self).actualView()
        fr4.proceedInWorkflow()

        wait(for: [expectation], timeout: 3)
    }

    func testProceedingForwardWithWorkflow_WithModalModalLaunchStyle_AndModalFullScreenPresentationAllViews_CallsThroughToOnFinish() throws {
        let expectation = self.expectation(description: "OnFinish called")
        let view = WorkflowView(Workflow(FR1.self, presentationType: .modal(.fullScreen))
                                    .thenPresent(FR2.self, presentationType: .modal(.fullScreen))
                                    .thenPresent(FR3.self, presentationType: .modal(.fullScreen))
                                    .thenPresent(FR4.self, presentationType: .modal(.fullScreen)), withLaunchStyle: .modal(.fullScreen)) { _ in expectation.fulfill() }

        XCTAssertEqual(try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView().style, .fullScreen)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView().current.inspect().anyView().emptyView()
        let fr1 = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(FR1.self).actualView()
        fr1.proceedInWorkflow()

        XCTAssertEqual(try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView().style, .fullScreen)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().emptyView()
        XCTAssertEqual(try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
                        .next.inspect().anyView().view(ModalWrapper.self).actualView().style, .fullScreen)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR1.self)
        let fr2 = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(FR2.self).actualView()
        fr2.proceedInWorkflow()

        XCTAssertEqual(try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView().style, .fullScreen)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().emptyView()
        XCTAssertEqual(try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
                        .next.inspect().anyView().view(ModalWrapper.self).actualView().style, .fullScreen)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR1.self)
        XCTAssertEqual(try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
                        .next.inspect().anyView().view(ModalWrapper.self).actualView()
                        .next.inspect().anyView().view(ModalWrapper.self).actualView().style, .fullScreen)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR2.self)
        let fr3 = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(FR3.self).actualView()
        fr3.proceedInWorkflow()

        XCTAssertEqual(try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView().style, .fullScreen)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().emptyView()
        XCTAssertEqual(try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
                        .next.inspect().anyView().view(ModalWrapper.self).actualView().style, .fullScreen)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR1.self)
        XCTAssertEqual(try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
                        .next.inspect().anyView().view(ModalWrapper.self).actualView()
                        .next.inspect().anyView().view(ModalWrapper.self).actualView().style, .fullScreen)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR2.self)
        XCTAssertEqual(try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
                        .next.inspect().anyView().view(ModalWrapper.self).actualView()
                        .next.inspect().anyView().view(ModalWrapper.self).actualView()
                        .next.inspect().anyView().view(ModalWrapper.self).actualView().style, .fullScreen)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR3.self)
        let fr4 = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(FR4.self).actualView()
        fr4.proceedInWorkflow()

        wait(for: [expectation], timeout: 3)
    }

    func testProceedingForwardWithWorkflow_WithDefaultLaunchStyle_AndModalFullScreenPresentationAllViews_CallsThroughToOnFinish() throws {
        let expectation = self.expectation(description: "OnFinish called")
        let view = WorkflowView(Workflow(FR1.self, presentationType: .modal(.fullScreen))
                                    .thenPresent(FR2.self, presentationType: .modal(.fullScreen))
                                    .thenPresent(FR3.self, presentationType: .modal(.fullScreen))
                                    .thenPresent(FR4.self, presentationType: .modal(.fullScreen))) { _ in expectation.fulfill() }

        XCTAssertEqual(try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView().style, .fullScreen)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView().current.inspect().anyView().emptyView()
        let fr1 = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(FR1.self).actualView()
        fr1.proceedInWorkflow()

        XCTAssertEqual(try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView().style, .fullScreen)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR1.self)
        let fr2 = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(FR2.self).actualView()
        fr2.proceedInWorkflow()

        XCTAssertEqual(try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView().style, .fullScreen)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR1.self)
        XCTAssertEqual(try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
                        .next.inspect().anyView().view(ModalWrapper.self).actualView().style, .fullScreen)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR2.self)
        let fr3 = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(FR3.self).actualView()
        fr3.proceedInWorkflow()

        XCTAssertEqual(try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView().style, .fullScreen)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR1.self)
        XCTAssertEqual(try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
                        .next.inspect().anyView().view(ModalWrapper.self).actualView().style, .fullScreen)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR2.self)
        XCTAssertEqual(try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
                        .next.inspect().anyView().view(ModalWrapper.self).actualView()
                        .next.inspect().anyView().view(ModalWrapper.self).actualView().style, .fullScreen)
        _ = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .current.inspect().anyView().view(FR3.self)
        let fr4 = try view.workflowModel.view.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(ModalWrapper.self).actualView()
            .next.inspect().anyView().view(FR4.self).actualView()
        fr4.proceedInWorkflow()

        wait(for: [expectation], timeout: 3)
    }
}

extension ModalTests {
    struct FR1: View, FlowRepresentable, Inspectable {
        var _workflowPointer: AnyFlowRepresentable?

        static func instance() -> Self { Self() }

        var body: some View {
            Text("\(String(describing: Self.self))")
                .padding()
            Button("Proceed", action: proceedInWorkflow)
        }
    }

    struct FR2: View, FlowRepresentable, Inspectable {
        var _workflowPointer: AnyFlowRepresentable?

        static func instance() -> Self { Self() }

        var body: some View {
            Text("\(String(describing: Self.self))")
                .padding()
            Button("Proceed", action: proceedInWorkflow)
            Button("Back", action: proceedBackwardInWorkflow)
        }
    }

    struct FR3: View, FlowRepresentable, Inspectable {
        var _workflowPointer: AnyFlowRepresentable?

        static func instance() -> Self { Self() }

        var body: some View {
            Text("\(String(describing: Self.self))")
                .padding()
            Button("Proceed", action: proceedInWorkflow)
            Button("Back", action: proceedBackwardInWorkflow)
        }
    }

    struct FR4: View, FlowRepresentable, Inspectable {
        var _workflowPointer: AnyFlowRepresentable?

        static func instance() -> Self { Self() }

        var body: some View {
            Text("\(String(describing: Self.self))")
                .padding()
            Button("Back", action: proceedBackwardInWorkflow)
            Button("Abandon") {
                workflow?.abandon()
            }
        }
    }
}
