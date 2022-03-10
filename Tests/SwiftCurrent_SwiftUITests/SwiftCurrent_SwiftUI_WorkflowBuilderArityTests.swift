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

@available(iOS 15.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
final class SwiftCurrent_SwiftUI_WorkflowBuilderArityTests: XCTestCase, App {
    func testArity1() async throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        let viewUnderTest = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await viewUnderTest.find(FR1.self).proceedInWorkflow()
    }

    func testArity2() async throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        struct FR2: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }
        }

        let viewUnderTest = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
                WorkflowItem(FR2.self)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await viewUnderTest.find(FR1.self).proceedInWorkflow()
        try await viewUnderTest.find(FR2.self).proceedInWorkflow()
    }

    func testArity3() async throws {
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
        let viewUnderTest = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
                WorkflowItem(FR2.self)
                WorkflowItem(FR3.self)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await viewUnderTest.find(FR1.self).proceedInWorkflow()
        try await viewUnderTest.find(FR2.self).proceedInWorkflow()
        try await viewUnderTest.find(FR3.self).proceedInWorkflow()
    }

    func testArity4() async throws {
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

        let viewUnderTest = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
                WorkflowItem(FR2.self)
                WorkflowItem(FR3.self)
                WorkflowItem(FR4.self)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await viewUnderTest.find(FR1.self).proceedInWorkflow()
        try await viewUnderTest.find(FR2.self).proceedInWorkflow()
        try await viewUnderTest.find(FR3.self).proceedInWorkflow()
        try await viewUnderTest.find(FR4.self).proceedInWorkflow()
    }

    func testArity5() async throws {
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

        let viewUnderTest = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
                WorkflowItem(FR2.self)
                WorkflowItem(FR3.self)
                WorkflowItem(FR4.self)
                WorkflowItem(FR5.self)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await viewUnderTest.find(FR1.self).proceedInWorkflow()
        try await viewUnderTest.find(FR2.self).proceedInWorkflow()
        try await viewUnderTest.find(FR3.self).proceedInWorkflow()
        try await viewUnderTest.find(FR4.self).proceedInWorkflow()
        try await viewUnderTest.find(FR5.self).proceedInWorkflow()
    }

    func testArity6() async throws {
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

        let viewUnderTest = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
                WorkflowItem(FR2.self)
                WorkflowItem(FR3.self)
                WorkflowItem(FR4.self)
                WorkflowItem(FR5.self)
                WorkflowItem(FR6.self)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await viewUnderTest.find(FR1.self).proceedInWorkflow()
        try await viewUnderTest.find(FR2.self).proceedInWorkflow()
        try await viewUnderTest.find(FR3.self).proceedInWorkflow()
        try await viewUnderTest.find(FR4.self).proceedInWorkflow()
        try await viewUnderTest.find(FR5.self).proceedInWorkflow()
        try await viewUnderTest.find(FR6.self).proceedInWorkflow()
    }

    func testArity7() async throws {
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

        let viewUnderTest = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
                WorkflowItem(FR2.self)
                WorkflowItem(FR3.self)
                WorkflowItem(FR4.self)
                WorkflowItem(FR5.self)
                WorkflowItem(FR6.self)
                WorkflowItem(FR7.self)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await viewUnderTest.find(FR1.self).proceedInWorkflow()
        try await viewUnderTest.find(FR2.self).proceedInWorkflow()
        try await viewUnderTest.find(FR3.self).proceedInWorkflow()
        try await viewUnderTest.find(FR4.self).proceedInWorkflow()
        try await viewUnderTest.find(FR5.self).proceedInWorkflow()
        try await viewUnderTest.find(FR6.self).proceedInWorkflow()
        try await viewUnderTest.find(FR7.self).proceedInWorkflow()
    }

    func testArity8() async throws {
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
        struct FR8: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR8 type") }
        }

        let viewUnderTest = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
                WorkflowItem(FR2.self)
                WorkflowItem(FR3.self)
                WorkflowItem(FR4.self)
                WorkflowItem(FR5.self)
                WorkflowItem(FR6.self)
                WorkflowItem(FR7.self)
                WorkflowItem(FR8.self)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await viewUnderTest.find(FR1.self).proceedInWorkflow()
        try await viewUnderTest.find(FR2.self).proceedInWorkflow()
        try await viewUnderTest.find(FR3.self).proceedInWorkflow()
        try await viewUnderTest.find(FR4.self).proceedInWorkflow()
        try await viewUnderTest.find(FR5.self).proceedInWorkflow()
        try await viewUnderTest.find(FR6.self).proceedInWorkflow()
        try await viewUnderTest.find(FR7.self).proceedInWorkflow()
        try await viewUnderTest.find(FR8.self).proceedInWorkflow()
    }

    func testArity9() async throws {
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
        struct FR8: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR8 type") }
        }
        struct FR9: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR9 type") }
        }

        let viewUnderTest = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
                WorkflowItem(FR2.self)
                WorkflowItem(FR3.self)
                WorkflowItem(FR4.self)
                WorkflowItem(FR5.self)
                WorkflowItem(FR6.self)
                WorkflowItem(FR7.self)
                WorkflowItem(FR8.self)
                WorkflowItem(FR9.self)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await viewUnderTest.find(FR1.self).proceedInWorkflow()
        try await viewUnderTest.find(FR2.self).proceedInWorkflow()
        try await viewUnderTest.find(FR3.self).proceedInWorkflow()
        try await viewUnderTest.find(FR4.self).proceedInWorkflow()
        try await viewUnderTest.find(FR5.self).proceedInWorkflow()
        try await viewUnderTest.find(FR6.self).proceedInWorkflow()
        try await viewUnderTest.find(FR7.self).proceedInWorkflow()
        try await viewUnderTest.find(FR8.self).proceedInWorkflow()
        try await viewUnderTest.find(FR9.self).proceedInWorkflow()
    }

    func testArity10() async throws {
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
        struct FR8: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR8 type") }
        }
        struct FR9: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR9 type") }
        }
        struct FR10: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR10 type") }
        }

        let viewUnderTest = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
                WorkflowItem(FR2.self)
                WorkflowItem(FR3.self)
                WorkflowItem(FR4.self)
                WorkflowItem(FR5.self)
                WorkflowItem(FR6.self)
                WorkflowItem(FR7.self)
                WorkflowItem(FR8.self)
                WorkflowItem(FR9.self)
                WorkflowItem(FR10.self)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await viewUnderTest.find(FR1.self).proceedInWorkflow()
        try await viewUnderTest.find(FR2.self).proceedInWorkflow()
        try await viewUnderTest.find(FR3.self).proceedInWorkflow()
        try await viewUnderTest.find(FR4.self).proceedInWorkflow()
        try await viewUnderTest.find(FR5.self).proceedInWorkflow()
        try await viewUnderTest.find(FR6.self).proceedInWorkflow()
        try await viewUnderTest.find(FR7.self).proceedInWorkflow()
        try await viewUnderTest.find(FR8.self).proceedInWorkflow()
        try await viewUnderTest.find(FR9.self).proceedInWorkflow()
        try await viewUnderTest.find(FR10.self).proceedInWorkflow()
    }

    func testArity5_WithWorkflowGroup() async throws {
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
        struct FR8: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR8 type") }
        }
        struct FR9: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR9 type") }
        }
        struct FR10: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR10 type") }
        }

        let viewUnderTest = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
                WorkflowItem(FR2.self)
                WorkflowItem(FR3.self)
                WorkflowItem(FR4.self)
                WorkflowItem(FR5.self)
                WorkflowGroup {
                    WorkflowItem(FR6.self)
                    WorkflowItem(FR7.self)
                    WorkflowItem(FR8.self)
                    WorkflowItem(FR9.self)
                    WorkflowItem(FR10.self)
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await viewUnderTest.find(FR1.self).proceedInWorkflow()
        try await viewUnderTest.find(FR2.self).proceedInWorkflow()
        try await viewUnderTest.find(FR3.self).proceedInWorkflow()
        try await viewUnderTest.find(FR4.self).proceedInWorkflow()
        try await viewUnderTest.find(FR5.self).proceedInWorkflow()
        try await viewUnderTest.find(FR6.self).proceedInWorkflow()
        try await viewUnderTest.find(FR7.self).proceedInWorkflow()
        try await viewUnderTest.find(FR8.self).proceedInWorkflow()
        try await viewUnderTest.find(FR9.self).proceedInWorkflow()
        try await viewUnderTest.find(FR10.self).proceedInWorkflow()
    }

    func testUltramassiveWorkflow() async throws {
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
        struct FR8: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR8 type") }
        }
        struct FR9: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR9 type") }
        }
        struct FR10: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR10 type") }
        }
        struct FR11: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        struct FR12: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }
        }
        struct FR13: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR3 type") }
        }
        struct FR14: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR4 type") }
        }
        struct FR15: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR5 type") }
        }
        struct FR16: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR6 type") }
        }
        struct FR17: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR7 type") }
        }
        struct FR18: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR8 type") }
        }
        struct FR19: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR9 type") }
        }
        struct FR20: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR10 type") }
        }
        struct FR21: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        struct FR22: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }
        }
        struct FR23: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR3 type") }
        }
        struct FR24: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR4 type") }
        }
        struct FR25: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR5 type") }
        }
        struct FR26: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR6 type") }
        }
        struct FR27: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR7 type") }
        }
        struct FR28: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR8 type") }
        }
        struct FR29: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR9 type") }
        }
        struct FR30: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR10 type") }
        }
        struct FR41: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        struct FR42: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }
        }
        struct FR43: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR3 type") }
        }
        struct FR44: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR4 type") }
        }
        struct FR45: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR5 type") }
        }
        struct FR46: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR6 type") }
        }
        struct FR47: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR7 type") }
        }
        struct FR48: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR8 type") }
        }
        struct FR49: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR9 type") }
        }
        struct FR50: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR10 type") }
        }
        struct FR51: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        struct FR52: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }
        }
        struct FR53: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR3 type") }
        }
        struct FR54: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR4 type") }
        }
        struct FR55: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR5 type") }
        }
        struct FR56: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR6 type") }
        }
        struct FR57: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR7 type") }
        }
        struct FR58: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR8 type") }
        }
        struct FR59: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR9 type") }
        }
        struct FR60: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR10 type") }
        }
        struct FR61: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        struct FR62: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }
        }
        struct FR63: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR3 type") }
        }
        struct FR64: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR4 type") }
        }
        struct FR65: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR5 type") }
        }
        struct FR66: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR6 type") }
        }
        struct FR67: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR7 type") }
        }
        struct FR68: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR8 type") }
        }
        struct FR69: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR9 type") }
        }
        struct FR70: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR10 type") }
        }
        struct FR71: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        struct FR72: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }
        }
        struct FR73: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR3 type") }
        }
        struct FR74: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR4 type") }
        }
        struct FR75: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR5 type") }
        }
        struct FR76: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR6 type") }
        }
        struct FR77: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR7 type") }
        }
        struct FR78: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR8 type") }
        }
        struct FR79: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR9 type") }
        }
        struct FR80: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR10 type") }
        }
        struct FR81: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        struct FR82: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }
        }
        struct FR83: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR3 type") }
        }
        struct FR84: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR4 type") }
        }
        struct FR85: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR5 type") }
        }
        struct FR86: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR6 type") }
        }
        struct FR87: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR7 type") }
        }
        struct FR88: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR8 type") }
        }
        struct FR89: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR9 type") }
        }
        struct FR90: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR10 type") }
        }
        struct FR91: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        struct FR92: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }
        }
        struct FR93: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR3 type") }
        }
        struct FR94: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR4 type") }
        }
        struct FR95: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR5 type") }
        }
        struct FR96: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR6 type") }
        }
        struct FR97: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR7 type") }
        }
        struct FR98: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR8 type") }
        }
        struct FR99: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR9 type") }
        }
        struct FR100: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR10 type") }
        }
        let viewUnderTest = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
                WorkflowItem(FR2.self)
                WorkflowItem(FR3.self)
                WorkflowItem(FR4.self)
                WorkflowItem(FR5.self)
                WorkflowItem(FR6.self)
                WorkflowItem(FR7.self)
                WorkflowItem(FR8.self)
                WorkflowItem(FR9.self)
                WorkflowGroup {
                    WorkflowItem(FR10.self)
                    WorkflowItem(FR11.self)
                    WorkflowItem(FR12.self)
                    WorkflowItem(FR13.self)
                    WorkflowItem(FR14.self)
                    WorkflowItem(FR15.self)
                    WorkflowItem(FR16.self)
                    WorkflowItem(FR17.self)
                    WorkflowItem(FR18.self)
                    WorkflowGroup {
                        WorkflowItem(FR19.self)
                        WorkflowItem(FR20.self)
                        WorkflowItem(FR21.self)
                        WorkflowItem(FR22.self)
                        WorkflowItem(FR23.self)
                        WorkflowItem(FR24.self)
                        WorkflowItem(FR25.self)
                        WorkflowItem(FR26.self)
                        WorkflowItem(FR27.self)
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await MainActor.run {
            try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow()
            try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow()
            try viewUnderTest.find(FR3.self).actualView().proceedInWorkflow()
            try viewUnderTest.find(FR4.self).actualView().proceedInWorkflow()
            try viewUnderTest.find(FR5.self).actualView().proceedInWorkflow()
            try viewUnderTest.find(FR6.self).actualView().proceedInWorkflow()
            try viewUnderTest.find(FR7.self).actualView().proceedInWorkflow()
            try viewUnderTest.find(FR8.self).actualView().proceedInWorkflow()
            try viewUnderTest.find(FR9.self).actualView().proceedInWorkflow()
            try viewUnderTest.find(FR10.self).actualView().proceedInWorkflow()
            try viewUnderTest.find(FR11.self).actualView().proceedInWorkflow()
            try viewUnderTest.find(FR12.self).actualView().proceedInWorkflow()
        }
    }
}
