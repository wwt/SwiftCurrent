//
//  FlowRepresentableMetadata.swift
//  
//
//  Created by Tyler Thompson on 11/25/20.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation

/**
 Data about a `FlowRepresentable`. Used to make an `OrchestrationResponder`.

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
    /// Preferred `LaunchStyle` of the associated `FlowRepresentable`.
    public private(set) var launchStyle: LaunchStyle
    /// Preferred `FlowPersistence` of  the associated `FlowRepresentable`.
    public private(set) var persistence: FlowPersistence?

    /**
     Creates an instance that holds onto metadata associated with the `FlowRepresentable`.

     - Parameter flowRepresentableType: specific type of the associated `FlowRepresentable`.
     - Parameter launchStyle: the style to use when launching the `FlowRepresentable`.
     - Parameter flowPersistence: a closure passing arguments to the caller and returning the preferred `FlowPersistence`.
     */
    public init<FR: FlowRepresentable>(_ flowRepresentableType: FR.Type,
                                       launchStyle: LaunchStyle = .default,
                                       flowPersistence:@escaping (AnyWorkflow.PassedArgs) -> FlowPersistence) {
        flowRepresentableFactory = { args in
            AnyFlowRepresentable(FR.self, args: args)
        }
        self.flowPersistence = flowPersistence
        self.launchStyle = launchStyle
    }

    func calculatePersistence(_ args: AnyWorkflow.PassedArgs) -> FlowPersistence {
        let val = flowPersistence(args)
        persistence = val
        return val
    }
}
