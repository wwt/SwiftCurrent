//  swiftlint:disable:this file_name
//  WorkflowDecodableExtensions_UIKit.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 1/18/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftCurrent
import UIKit

extension WorkflowDecodable where Self: UIViewController & FlowRepresentable {
    /// Decodes a ``LaunchStyle`` from a string.
    public static func decodeLaunchStyle(named name: String) throws -> LaunchStyle {
        switch name.lowercased() {
            case "automatic".lowercased(): return .default
            case "navigationStack".lowercased(): return ._navigationStack
            case "modal".lowercased(): return ._modal
            case "modal(.automatic)".lowercased(): return ._modal_automatic
            case "modal(.currentContext)".lowercased(): return ._modal_currentContext
            case "modal(.custom)".lowercased(): return ._modal_custom
            case "modal(.formSheet)".lowercased(): return ._modal_formSheet
            case "modal(.fullscreen)".lowercased(): return ._modal_fullscreen
            case "modal(.overCurrentContext)".lowercased(): return ._modal_overCurrentContext
            case "modal(.overFullScreen)".lowercased(): return ._modal_overFullScreen
            case "modal(.popover)".lowercased(): return ._modal_popover
            case "modal(.pageSheet)".lowercased(): return ._modal_pageSheet
            default: throw AnyWorkflow.DecodingError.invalidLaunchStyle(name)
        }
    }
}
