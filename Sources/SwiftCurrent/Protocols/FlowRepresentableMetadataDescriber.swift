//
//  FlowRepresentableMetadataDescriber.swift
//  SwiftCurrent
//
//  Created by Richard Gist on 12/7/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//  

/// Aspects of the described ``FlowRepresentable`` needed to dynamically generate metadata from the Workflow Data Scheme.
public protocol FlowRepresentableMetadataDescriber {
    /// The name of the ``FlowRepresentable`` as used in the Workflow Data Scheme
    static var flowRepresentableName: String { get }

    /// Creates a new instance of ``FlowRepresentableMetadata``
    static func metadataFactory() -> FlowRepresentableMetadata
}

// Provides the implementation for the protocol without immediately conforming FlowRepresentable
// See FlowRepresentableMetadataDescriberConsumerTests for reasons.
extension FlowRepresentable where Self: FlowRepresentableMetadataDescriber {
    /// The name of the ``FlowRepresentable`` as used in the Workflow Data Scheme
    public static var flowRepresentableName: String { String(describing: Self.self) }

    /// Creates a new instance of ``FlowRepresentableMetadata``
    public static func metadataFactory() -> FlowRepresentableMetadata {
        FlowRepresentableMetadata(Self.self)
    }
}
