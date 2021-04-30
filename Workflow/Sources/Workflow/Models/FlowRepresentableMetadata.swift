//
//  FlowRepresentableMetadata.swift
//  
//
//  Created by Tyler Thompson on 11/25/20.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation

/**
 Data about a `FlowRepresentable`. Used to make an `AnyOrchestrationResponder`.

 ### Discussion:
 Every time a `Workflow` is created, the defining characteristics about a `FlowRepresentable` is stored in the `FlowRepresentableMetadata` to be used later.

 Example
 ```swift
 let flow = Workflow(SomeFlowRepresentableClass.self) // We now have a FlowRepresentableMetadata representing SomeFlowRepresentableClass
     .thenPresent(SomeOtherFlowRepresentableClass.self, launchStyle: .navigationStack) // We now have a FlowRepresentableMetadata representing SomeOtherFlowRepresentableClass and its launch style of navigation stack
 ```
 */
public class FlowRepresentableMetadata {
    private(set) var flowRepresentableFactory: () -> AnyFlowRepresentable
    private var flowPersistance: (AnyWorkflow.PassedArgs) -> FlowPersistance
    public private(set) var launchStyle: LaunchStyle
    public private(set) var persistance: FlowPersistance?

    public init<FR: FlowRepresentable>(_ flowRepresentableType: FR.Type,
                                       launchStyle: LaunchStyle = .default,
                                       flowPersistance:@escaping (AnyWorkflow.PassedArgs) -> FlowPersistance) {
        self.flowRepresentableFactory = {
            var instance = FR.instance()
            return AnyFlowRepresentable(&instance)
        }
        self.flowPersistance = flowPersistance
        self.launchStyle = launchStyle
    }

    public convenience init<FR: FlowRepresentable>(with flowRepresentable: FR, launchStyle: LaunchStyle, persistance: FlowPersistance) {
        self.init(FR.self, launchStyle: launchStyle) { _ in persistance }
    }

    func calculatePersistance(_ args: AnyWorkflow.PassedArgs) -> FlowPersistance {
        let val = flowPersistance(args)
        persistance = val
        return val
    }
}
