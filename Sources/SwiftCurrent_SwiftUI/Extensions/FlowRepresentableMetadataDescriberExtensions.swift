//  swiftlint:disable:this file_name
//  FlowRepresentableMetadataDescriberExtensions.swift
//  SwiftCurrent
//
//  Created by Richard Gist on 12/15/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI
import SwiftCurrent

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension View where Self: FlowRepresentable & FlowRepresentableMetadataDescriber {
    /// Creates a new instance of ``FlowRepresentableMetadata``
    public static func metadataFactory() -> FlowRepresentableMetadata {
        ExtendedFlowRepresentableMetadata(flowRepresentableType: Self.self)
    }
}
