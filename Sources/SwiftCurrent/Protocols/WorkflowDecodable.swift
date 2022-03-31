//
//  FlowRepresentableMetadataDescriber.swift
//  SwiftCurrent
//
//  Created by Richard Gist on 12/7/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//  

/// Aspects of the described ``FlowRepresentable`` needed to dynamically generate metadata from the Workflow Data Scheme.
/// Only types conforming to `WorkflowDecodable` will be able to be decoded from data.
public protocol WorkflowDecodable {
    /// The name of the ``FlowRepresentable`` as used in the Workflow Data Scheme.
    static var flowRepresentableName: String { get }

    /// Creates a new instance of ``FlowRepresentableMetadata``.
    static func metadataFactory(launchStyle: LaunchStyle,
                                flowPersistence: @escaping (AnyWorkflow.PassedArgs) -> FlowPersistence) -> FlowRepresentableMetadata

    /// Decodes a ``LaunchStyle`` from a string.
    static func decodeLaunchStyle(named name: String) throws -> LaunchStyle

    /// Decodes a ``FlowPersistence`` from a string.
    static func decodeFlowPersistence(named name: String) throws -> FlowPersistence
}

extension WorkflowDecodable {
    /// Decodes a ``LaunchStyle`` from a string.
    public static func decodeLaunchStyle(named name: String) throws -> LaunchStyle {
        throw AnyWorkflow.DecodingError.invalidLaunchStyle(name)
    }

    /// Decodes a ``FlowPersistence`` from a string.
    public static func decodeFlowPersistence(named name: String) throws -> FlowPersistence {
        switch name.lowercased() {
            case "persistWhenSkipped".lowercased(): return .persistWhenSkipped
            case "removedAfterProceeding".lowercased(): return .removedAfterProceeding
            default: throw AnyWorkflow.DecodingError.invalidFlowPersistence(name)
        }
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
        FlowRepresentableMetadata(Self.self, launchStyle: launchStyle, flowPersistence: flowPersistence)
    }
}
