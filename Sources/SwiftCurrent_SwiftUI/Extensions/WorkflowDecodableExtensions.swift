//  swiftlint:disable:this file_name
//  FlowRepresentableMetadataDescriberExtensions.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Richard Gist on 12/15/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI
import SwiftCurrent

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension View where Self: FlowRepresentable & WorkflowDecodable {
    #warning("Come back and test correct params are passed")
    /// Creates a new instance of ``FlowRepresentableMetadata``
    public static func metadataFactory(launchStyle: LaunchStyle,
                                       flowPersistence: @escaping (AnyWorkflow.PassedArgs) -> FlowPersistence) -> FlowRepresentableMetadata {
        ExtendedFlowRepresentableMetadata(flowRepresentableType: Self.self, launchStyle: .default) { _ in .default }
    }
}
