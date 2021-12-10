//
//  FlowRepresentableMetadataDescriber.swift
//  SwiftCurrent
//
//  Created by Richard Gist on 12/7/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//  

/// Describes aspects of the FlowRepresentable needed to map to Workflow Data Scheme and to dynamically generate metadata.
public protocol FlowRepresentableMetadataDescriber {
    /// The name of the FlowRepresentable as used in the Workflow Data Scheme
    static var flowRepresentableName: String { get }

    /// Creates a new instance of ``FlowRepresentableMetadata``
    static func metadataFactory() -> FlowRepresentableMetadata
}

// Provides the implementation for the protocol without immediately conforming FlowRepresentable
// See FlowRepresentableMetadataDescriberConsumerTests for reasons.
extension FlowRepresentable {
    /// The name of the FlowRepresentable as used in the Workflow Data Scheme
    public static var flowRepresentableName: String { String(describing: Self.self) }

    /// Creates a new instance of ``FlowRepresentableMetadata``
    public static func metadataFactory() -> FlowRepresentableMetadata {
        FlowRepresentableMetadata(Self.self) { _ in .default }
    }
}
