//
//  FlowRepresentableMetadataDescriber.swift
//  SwiftCurrent
//
//  Created by Richard Gist on 12/7/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//  

/// Aspects of the described ``FlowRepresentable`` needed to dynamically generate metadata from the Workflow Data Scheme.
public protocol WorkflowDecodable {
    /// The name of the ``FlowRepresentable`` as used in the Workflow Data Scheme
    static var flowRepresentableName: String { get }

    /// Creates a new instance of ``FlowRepresentableMetadata``
    static func metadataFactory(launchStyle: LaunchStyle,
                                flowPersistence: @escaping (AnyWorkflow.PassedArgs) -> FlowPersistence) -> FlowRepresentableMetadata

    #warning("Worry about docs...not for public use really???")
    static func decodeLaunchStyle(named name: String) throws -> LaunchStyle

    #warning("Worry about docs...not for public use really???")
    static func decodeFlowPersistence(named name: String) throws -> FlowPersistence
}

extension WorkflowDecodable {
    #warning("You must remember when we add new ones, to make them available here...YUCK!")
    public static func decodeLaunchStyle(named name: String) throws -> LaunchStyle {
        fatalError("ObVIOUSLY BAD")
    }

    #warning("You must remember when we add new ones, to make them available here...YUCK!")
    public static func decodeFlowPersistence(named name: String) throws -> FlowPersistence {
        fatalError("ObVIOUSLY BAD")
    }
}

// Provides the implementation for the protocol without immediately conforming FlowRepresentable
// See WorkflowDecodableConsumerTests for reasons.
extension FlowRepresentable where Self: WorkflowDecodable {
    /// The name of the ``FlowRepresentable`` as used in the Workflow Data Scheme
    public static var flowRepresentableName: String { String(describing: Self.self) }

    /// Creates a new instance of ``FlowRepresentableMetadata``
    public static func metadataFactory(launchStyle: LaunchStyle,
                                       flowPersistence: @escaping (AnyWorkflow.PassedArgs) -> FlowPersistence) -> FlowRepresentableMetadata {
        FlowRepresentableMetadata(Self.self, launchStyle: launchStyle) { _ in .default }
    }
}
