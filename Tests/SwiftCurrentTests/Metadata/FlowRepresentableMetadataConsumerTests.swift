//
//  FlowRepresentableMetadataConsumerTests.swift
//  SwiftCurrent
//
//  Created by Morgan Zellers on 11/2/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//  

import XCTest
import SwiftCurrent

class FlowRepresentableMetadataConsumerTests: XCTestCase {
    func testOverridingFlowRepresentableMetadata() {
        class SpecialConformanceClass { }
        class NewMetadata: FlowRepresentableMetadata {
            var wf: String? // AnyWFItem

            private override init<FR>(_ flowRepresentableType: FR.Type,
                                      launchStyle: LaunchStyle = .default,
                                      flowPersistence: @escaping (AnyWorkflow.PassedArgs) -> FlowPersistence,
                                      flowRepresentableFactory: @escaping (AnyWorkflow.PassedArgs) -> AnyFlowRepresentable) where FR : FlowRepresentable {
                super.init(flowRepresentableType, launchStyle: launchStyle, flowPersistence: flowPersistence, flowRepresentableFactory: flowRepresentableFactory)
            }

            convenience init<FR: FlowRepresentable & SpecialConformanceClass>(flowRepresentableType: FR.Type,
                                                                              launchStyle: LaunchStyle = .default,
                                                                              flowPersistence: @escaping (AnyWorkflow.PassedArgs) -> FlowPersistence,
                                                                              flowRepresentableFactory: @escaping (AnyWorkflow.PassedArgs) -> AnyFlowRepresentable) {
                self.init(flowRepresentableType, launchStyle: launchStyle, flowPersistence: flowPersistence, flowRepresentableFactory: flowRepresentableFactory)

                wf = String(describing: flowRepresentableType)
            }
        }

        final class FR1: SpecialConformanceClass, FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }

        let _ = NewMetadata(flowRepresentableType: FR1.self,
                              flowPersistence: { _ in .default }) { _ in
            AnyFlowRepresentable(FR1.self, args: .none)
        }
    }
}
