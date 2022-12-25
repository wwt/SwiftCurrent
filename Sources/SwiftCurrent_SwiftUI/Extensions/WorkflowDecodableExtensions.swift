//  swiftlint:disable:this file_name
//  FlowRepresentableMetadataDescriberExtensions.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Richard Gist on 12/15/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI
import SwiftCurrent

//@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
//extension WorkflowDecodable where Self: FlowRepresentable & View {
//    /// Creates a new instance of ``FlowRepresentableMetadata``
//    public static func metadataFactory(launchStyle: LaunchStyle,
//                                       flowPersistence: @escaping (AnyWorkflow.PassedArgs) -> FlowPersistence) -> FlowRepresentableMetadata {
//        ExtendedFlowRepresentableMetadata(flowRepresentableType: Self.self, launchStyle: launchStyle, flowPersistence: flowPersistence)
//    }
//
//    /// Decodes a ``LaunchStyle`` from a string.
//    public static func decodeLaunchStyle(named name: String) throws -> LaunchStyle {
//        switch name.lowercased() {
//            case "viewSwapping".lowercased(): return .default
//            case "modal".lowercased(): return ._swiftUI_modal
//            case "modal(.fullscreen)".lowercased(): return ._swiftUI_modal_fullscreen
//            case "navigationLink".lowercased(): return ._swiftUI_navigationLink
//            default: throw AnyWorkflow.DecodingError.invalidLaunchStyle(name)
//        }
//    }
//
//    /// Decodes a ``FlowPersistence`` from a string.
//    public static func decodeFlowPersistence(named name: String) throws -> FlowPersistence {
//        switch name.lowercased() {
//            case "removedAfterProceeding".lowercased(): return .removedAfterProceeding
//            default: throw AnyWorkflow.DecodingError.invalidFlowPersistence(name)
//        }
//    }
//}
