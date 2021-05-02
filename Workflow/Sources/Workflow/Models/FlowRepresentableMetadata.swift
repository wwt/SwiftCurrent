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

 ### Discussion
 Every time a `Workflow` is created, the defining characteristics about a `FlowRepresentable` is stored in the `FlowRepresentableMetadata` to be used later.

 #### Example
 ```swift
 Workflow(SomeFlowRepresentableClass.self) // We now have a FlowRepresentableMetadata representing SomeFlowRepresentableClass
     .thenPresent(SomeOtherFlowRepresentableClass.self, launchStyle: .navigationStack) // We now have a FlowRepresentableMetadata representing SomeOtherFlowRepresentableClass and its launch style of navigation stack
 ```
 Initially we create a `FlowRepresentableMetadata` representing SomeFlowRepresentableClass.  When we call `.thenPresent` we add a `FlowRepresentableMetadata` representing SomeOtherFlowRepresentableClass and its launch style of navigation stack to the `Workflow`.
 */
public class FlowRepresentableMetadata {
    private(set) var flowRepresentableFactory: (AnyWorkflow.PassedArgs) -> AnyFlowRepresentable
    private var flowPersistence: (AnyWorkflow.PassedArgs) -> FlowPersistence
    public private(set) var launchStyle: LaunchStyle
    public private(set) var persistence: FlowPersistence?

    public init<FR: FlowRepresentable>(_ flowRepresentableType: FR.Type,
                                       launchStyle: LaunchStyle = .default,
                                       flowPersistence:@escaping (AnyWorkflow.PassedArgs) -> FlowPersistence) {
        flowRepresentableFactory = { args in
            return AnyFlowRepresentable(FR.self, args: args)
        }
        self.flowPersistence = flowPersistence
        self.launchStyle = launchStyle
    }

    public convenience init<FR: FlowRepresentable>(with flowRepresentable: FR, launchStyle: LaunchStyle, persistence: FlowPersistence) {
        self.init(FR.self, launchStyle: launchStyle) { _ in persistence }
    }

    func calculatePersistence(_ args: AnyWorkflow.PassedArgs) -> FlowPersistence {
        let val = flowPersistence(args)
        persistence = val
        return val
    }
}
