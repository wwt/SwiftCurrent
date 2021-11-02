//
//  FlowRepresentableMetadata.swift
//  
//
//  Created by Tyler Thompson on 11/25/20.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation

/**
 Data about a `FlowRepresentable`.

 ### Discussion
 Every time a `Workflow` is created, the defining characteristics about a `FlowRepresentable` are stored in the `FlowRepresentableMetadata` to be used later.
 */
open class FlowRepresentableMetadata {
    /// Preferred `LaunchStyle` of the associated `FlowRepresentable`.
    public private(set) var launchStyle: LaunchStyle
    /// Preferred `FlowPersistence` of  the associated `FlowRepresentable`; set when `FlowRepresentableMetadata` instantiates an instance.
    public private(set) var persistence: FlowPersistence?
    private(set) var flowRepresentableFactory: (AnyWorkflow.PassedArgs) -> AnyFlowRepresentable
    private var flowPersistence: (AnyWorkflow.PassedArgs) -> FlowPersistence

    /**
     Creates an instance that holds onto metadata associated with the `FlowRepresentable`.

     - Parameter flowRepresentableType: specific type of the associated `FlowRepresentable`.
     - Parameter launchStyle: the style to use when launching the `FlowRepresentable`.
     - Parameter flowPersistence: a closure passing arguments to the caller and returning the preferred `FlowPersistence`.
     */
    public convenience init<FR: FlowRepresentable>(_ flowRepresentableType: FR.Type,
                                                   launchStyle: LaunchStyle = .default,
                                                   flowPersistence: @escaping (AnyWorkflow.PassedArgs) -> FlowPersistence) {
        self.init(flowRepresentableType,
                  launchStyle: launchStyle,
                  flowPersistence: flowPersistence) { args in
            AnyFlowRepresentable(FR.self, args: args)
        }
    }

    /**
     Creates an instance that holds onto metadata associated with the `FlowRepresentable`.

     - Parameter flowRepresentableType: specific type of the associated `FlowRepresentable`.
     - Parameter launchStyle: the style to use when launching the `FlowRepresentable`.
     - Parameter flowPersistence: a closure passing arguments to the caller and returning the preferred `FlowPersistence`.
     - Parameter flowRepresentableFactory: a closure used to generate an `AnyFlowRepresentable` from the `FlowRepresentable` type.
     */
    public init<FR: FlowRepresentable>(_ flowRepresentableType: FR.Type,
                                       launchStyle: LaunchStyle = .default,
                                       flowPersistence: @escaping (AnyWorkflow.PassedArgs) -> FlowPersistence,
                                       flowRepresentableFactory: @escaping (AnyWorkflow.PassedArgs) -> AnyFlowRepresentable) {
        self.launchStyle = launchStyle
        self.flowPersistence = flowPersistence
        self.flowRepresentableFactory = flowRepresentableFactory
        EventReceiver.flowRepresentableMetadataCreated(metadata: self, type: FR.self)
    }

    func setPersistence(_ args: AnyWorkflow.PassedArgs) -> FlowPersistence {
        let val = flowPersistence(args)
        persistence = val
        return val
    }
}
