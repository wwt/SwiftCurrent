//
//  SwiftCurrent_SwiftUI_WorkflowBuilderArityTests.swift
//  SwiftCurrent
//
//  Created by Matt Freiburg on 2/21/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import XCTest
import SwiftUI
import ViewInspector

import SwiftCurrent
@testable import SwiftCurrent_SwiftUI // testable sadly needed for inspection.inspect to work

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
final class SwiftCurrent_SwiftUI_WorkflowBuilderArityTests: XCTestCase, App {
    override func tearDownWithError() throws {
        removeQueuedExpectations()
    }

    func testArity1() throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowView {
                WorkflowItem(FR1.self)
            }
        ).inspection.inspect { viewUnderTest in
            XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
        }

        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
    }

//    func testArity2() throws {
//        struct FR1: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR1 type") }
//        }
//        struct FR2: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR2 type") }
//        }
//        let expectViewLoaded = ViewHosting.loadView(
//            WorkflowView {
//                WorkflowItem(FR1.self)
//                WorkflowItem(FR2.self)
//            }
//        ).inspection.inspect { viewUnderTest in
//            XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
//            try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow())
//            }
//        }
//
//        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
//    }
//
//    func testArity3() throws {
//        struct FR1: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR1 type") }
//        }
//        struct FR2: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR2 type") }
//        }
//        struct FR3: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR3 type") }
//        }
//        let expectViewLoaded = ViewHosting.loadView(
//            WorkflowView {
//                WorkflowItem(FR1.self)
//                WorkflowItem(FR2.self)
//                WorkflowItem(FR3.self)
//            }
//        ).inspection.inspect { viewUnderTest in
//            XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
//            try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow())
//                try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                    XCTAssertNoThrow(try viewUnderTest.find(FR3.self).actualView().proceedInWorkflow())
//                }
//            }
//        }
//
//        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
//    }
//
//    func testArity4() throws {
//        struct FR1: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR1 type") }
//        }
//        struct FR2: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR2 type") }
//        }
//        struct FR3: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR3 type") }
//        }
//        struct FR4: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR4 type") }
//        }
//        let expectViewLoaded = ViewHosting.loadView(
//            WorkflowView {
//                WorkflowItem(FR1.self)
//                WorkflowItem(FR2.self)
//                WorkflowItem(FR3.self)
//                WorkflowItem(FR4.self)
//            }
//        ).inspection.inspect { viewUnderTest in
//            XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
//            try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow())
//                try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                    XCTAssertNoThrow(try viewUnderTest.find(FR3.self).actualView().proceedInWorkflow())
//                    try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                        XCTAssertNoThrow(try viewUnderTest.find(FR4.self).actualView().proceedInWorkflow())
//                    }
//                }
//            }
//        }
//
//        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
//    }
//
//    func testArity5() throws {
//        struct FR1: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR1 type") }
//        }
//        struct FR2: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR2 type") }
//        }
//        struct FR3: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR3 type") }
//        }
//        struct FR4: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR4 type") }
//        }
//        struct FR5: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR5 type") }
//        }
//        let expectViewLoaded = ViewHosting.loadView(
//            WorkflowView {
//                WorkflowItem(FR1.self)
//                WorkflowItem(FR2.self)
//                WorkflowItem(FR3.self)
//                WorkflowItem(FR4.self)
//                WorkflowItem(FR5.self)
//            }
//        ).inspection.inspect { viewUnderTest in
//            XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
//            try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow())
//                try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                    XCTAssertNoThrow(try viewUnderTest.find(FR3.self).actualView().proceedInWorkflow())
//                    try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                        XCTAssertNoThrow(try viewUnderTest.find(FR4.self).actualView().proceedInWorkflow())
//                        try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                            XCTAssertNoThrow(try viewUnderTest.find(FR5.self).actualView().proceedInWorkflow())
//                        }
//                    }
//                }
//            }
//        }
//
//        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
//    }
//
//    func testArity6() throws {
//        struct FR1: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR1 type") }
//        }
//        struct FR2: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR2 type") }
//        }
//        struct FR3: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR3 type") }
//        }
//        struct FR4: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR4 type") }
//        }
//        struct FR5: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR5 type") }
//        }
//        struct FR6: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR6 type") }
//        }
//        let expectViewLoaded = ViewHosting.loadView(
//            WorkflowView {
//                WorkflowItem(FR1.self)
//                WorkflowItem(FR2.self)
//                WorkflowItem(FR3.self)
//                WorkflowItem(FR4.self)
//                WorkflowItem(FR5.self)
//                WorkflowItem(FR6.self)
//            }
//        ).inspection.inspect { viewUnderTest in
//            XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
//            try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow())
//                try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                    XCTAssertNoThrow(try viewUnderTest.find(FR3.self).actualView().proceedInWorkflow())
//                    try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                        XCTAssertNoThrow(try viewUnderTest.find(FR4.self).actualView().proceedInWorkflow())
//                        try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                            XCTAssertNoThrow(try viewUnderTest.find(FR5.self).actualView().proceedInWorkflow())
//                            try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                                XCTAssertNoThrow(try viewUnderTest.find(FR6.self).actualView().proceedInWorkflow())
//                            }
//                        }
//                    }
//                }
//            }
//        }
//
//        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
//    }
//
//    func testArity7() throws {
//        struct FR1: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR1 type") }
//        }
//        struct FR2: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR2 type") }
//        }
//        struct FR3: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR3 type") }
//        }
//        struct FR4: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR4 type") }
//        }
//        struct FR5: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR5 type") }
//        }
//        struct FR6: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR6 type") }
//        }
//        struct FR7: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR7 type") }
//        }
//        let expectViewLoaded = ViewHosting.loadView(
//            WorkflowView {
//                WorkflowItem(FR1.self)
//                WorkflowItem(FR2.self)
//                WorkflowItem(FR3.self)
//                WorkflowItem(FR4.self)
//                WorkflowItem(FR5.self)
//                WorkflowItem(FR6.self)
//                WorkflowItem(FR7.self)
//            }
//        ).inspection.inspect { viewUnderTest in
//            XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
//            try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow())
//                try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                    XCTAssertNoThrow(try viewUnderTest.find(FR3.self).actualView().proceedInWorkflow())
//                    try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                        XCTAssertNoThrow(try viewUnderTest.find(FR4.self).actualView().proceedInWorkflow())
//                        try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                            XCTAssertNoThrow(try viewUnderTest.find(FR5.self).actualView().proceedInWorkflow())
//                            try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                                XCTAssertNoThrow(try viewUnderTest.find(FR6.self).actualView().proceedInWorkflow())
//                                try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                                    XCTAssertNoThrow(try viewUnderTest.find(FR7.self).actualView().proceedInWorkflow())
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//
//        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
//    }
//
//    func testArity8() throws {
//        struct FR1: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR1 type") }
//        }
//        struct FR2: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR2 type") }
//        }
//        struct FR3: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR3 type") }
//        }
//        struct FR4: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR4 type") }
//        }
//        struct FR5: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR5 type") }
//        }
//        struct FR6: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR6 type") }
//        }
//        struct FR7: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR7 type") }
//        }
//        struct FR8: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR8 type") }
//        }
//        let expectViewLoaded = ViewHosting.loadView(
//            WorkflowView {
//                WorkflowItem(FR1.self)
//                WorkflowItem(FR2.self)
//                WorkflowItem(FR3.self)
//                WorkflowItem(FR4.self)
//                WorkflowItem(FR5.self)
//                WorkflowItem(FR6.self)
//                WorkflowItem(FR7.self)
//                WorkflowItem(FR8.self)
//            }
//        ).inspection.inspect { viewUnderTest in
//            XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
//            try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow())
//                try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                    XCTAssertNoThrow(try viewUnderTest.find(FR3.self).actualView().proceedInWorkflow())
//                    try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                        XCTAssertNoThrow(try viewUnderTest.find(FR4.self).actualView().proceedInWorkflow())
//                        try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                            XCTAssertNoThrow(try viewUnderTest.find(FR5.self).actualView().proceedInWorkflow())
//                            try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                                XCTAssertNoThrow(try viewUnderTest.find(FR6.self).actualView().proceedInWorkflow())
//                                try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                                    XCTAssertNoThrow(try viewUnderTest.find(FR7.self).actualView().proceedInWorkflow())
//                                    try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                                        XCTAssertNoThrow(try viewUnderTest.find(FR8.self).actualView().proceedInWorkflow())
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//
//        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
//    }
//
//    func testArity9() throws {
//        struct FR1: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR1 type") }
//        }
//        struct FR2: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR2 type") }
//        }
//        struct FR3: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR3 type") }
//        }
//        struct FR4: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR4 type") }
//        }
//        struct FR5: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR5 type") }
//        }
//        struct FR6: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR6 type") }
//        }
//        struct FR7: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR7 type") }
//        }
//        struct FR8: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR8 type") }
//        }
//        struct FR9: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR9 type") }
//        }
//        let expectViewLoaded = ViewHosting.loadView(
//            WorkflowView {
//                WorkflowItem(FR1.self)
//                WorkflowItem(FR2.self)
//                WorkflowItem(FR3.self)
//                WorkflowItem(FR4.self)
//                WorkflowItem(FR5.self)
//                WorkflowItem(FR6.self)
//                WorkflowItem(FR7.self)
//                WorkflowItem(FR8.self)
//                WorkflowItem(FR9.self)
//            }
//        ).inspection.inspect { viewUnderTest in
//            XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
//            try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow())
//                try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                    XCTAssertNoThrow(try viewUnderTest.find(FR3.self).actualView().proceedInWorkflow())
//                    try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                        XCTAssertNoThrow(try viewUnderTest.find(FR4.self).actualView().proceedInWorkflow())
//                        try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                            XCTAssertNoThrow(try viewUnderTest.find(FR5.self).actualView().proceedInWorkflow())
//                            try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                                XCTAssertNoThrow(try viewUnderTest.find(FR6.self).actualView().proceedInWorkflow())
//                                try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                                    XCTAssertNoThrow(try viewUnderTest.find(FR7.self).actualView().proceedInWorkflow())
//                                    try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                                        XCTAssertNoThrow(try viewUnderTest.find(FR8.self).actualView().proceedInWorkflow())
//                                        try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                                            XCTAssertNoThrow(try viewUnderTest.find(FR9.self).actualView().proceedInWorkflow())
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//
//        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
//    }
//
//    func testArity10() throws {
//        struct FR1: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR1 type") }
//        }
//        struct FR2: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR2 type") }
//        }
//        struct FR3: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR3 type") }
//        }
//        struct FR4: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR4 type") }
//        }
//        struct FR5: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR5 type") }
//        }
//        struct FR6: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR6 type") }
//        }
//        struct FR7: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR7 type") }
//        }
//        struct FR8: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR8 type") }
//        }
//        struct FR9: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR9 type") }
//        }
//        struct FR10: View, FlowRepresentable, Inspectable {
//            var _workflowPointer: AnyFlowRepresentable?
//            var body: some View { Text("FR10 type") }
//        }
//        let expectViewLoaded = ViewHosting.loadView(
//            WorkflowView {
//                WorkflowItem(FR1.self)
//                WorkflowItem(FR2.self)
//                WorkflowItem(FR3.self)
//                WorkflowItem(FR4.self)
//                WorkflowItem(FR5.self)
//                WorkflowItem(FR6.self)
//                WorkflowItem(FR7.self)
//                WorkflowItem(FR8.self)
//                WorkflowItem(FR9.self)
//                WorkflowItem(FR10.self)
//            }
//        ).inspection.inspect { viewUnderTest in
//            XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
//            try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow())
//                try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                    XCTAssertNoThrow(try viewUnderTest.find(FR3.self).actualView().proceedInWorkflow())
//                    try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                        XCTAssertNoThrow(try viewUnderTest.find(FR4.self).actualView().proceedInWorkflow())
//                        try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                            XCTAssertNoThrow(try viewUnderTest.find(FR5.self).actualView().proceedInWorkflow())
//                            try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                                XCTAssertNoThrow(try viewUnderTest.find(FR6.self).actualView().proceedInWorkflow())
//                                try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                                    XCTAssertNoThrow(try viewUnderTest.find(FR7.self).actualView().proceedInWorkflow())
//                                    try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                                        XCTAssertNoThrow(try viewUnderTest.find(FR8.self).actualView().proceedInWorkflow())
//                                        try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                                            XCTAssertNoThrow(try viewUnderTest.find(FR9.self).actualView().proceedInWorkflow())
//                                            try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
//                                                XCTAssertNoThrow(try viewUnderTest.find(FR10.self).actualView().proceedInWorkflow())
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//
//        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
//    }
}
