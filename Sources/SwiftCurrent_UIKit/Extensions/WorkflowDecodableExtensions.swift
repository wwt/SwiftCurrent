//  swiftlint:disable:this file_name
//  WorkflowDecodableExtensions.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 1/18/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftCurrent
import UIKit

extension WorkflowDecodable where Self: UIViewController & FlowRepresentable {
    public static func decodeLaunchStyle(named name: String) throws -> LaunchStyle {
        switch name.lowercased() {
            case "automatic": return .default
            case "navigationstack": return ._navigationStack
            case "modal": return ._modal
            case "modal(.automatic)": return ._modal_automatic
            case "modal(.currentcontext)": return ._modal_currentContext
            case "modal(.custom)": return ._modal_custom
            case "modal(.formsheet)": return ._modal_formSheet
            case "modal(.fullscreen)": return ._modal_fullscreen
            case "modal(.overcurrentcontext)": return ._modal_overCurrentContext
            case "modal(.overfullscreen)": return ._modal_overFullScreen
            case "modal(.popover)": return ._modal_popover
            case "modal(.pagesheet)": return ._modal_pageSheet
            default: throw AnyWorkflow.DecodingError.invalidLaunchStyle(name)
        }
    }
}
