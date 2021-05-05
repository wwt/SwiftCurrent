//  swiftlint:disable:this file_name
//  Reason: The file name reflects the contents of the file.
//
//  LaunchStyleAdditions.swift
//  
//
//  Created by Tyler Thompson on 11/26/20.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import Workflow

extension LaunchStyle {
    static let _navigationStack = LaunchStyle.new
    static let _modal = LaunchStyle.new
    static let _modal_fullscreen = LaunchStyle.new
    static let _modal_pageSheet = LaunchStyle.new
    static let _modal_formSheet = LaunchStyle.new
    static let _modal_currentContext = LaunchStyle.new
    static let _modal_custom = LaunchStyle.new
    static let _modal_overFullScreen = LaunchStyle.new
    static let _modal_overCurrentContext = LaunchStyle.new
    static let _modal_popover = LaunchStyle.new
    static let _modal_automatic = LaunchStyle.new
}

extension LaunchStyle {
    #warning("Also needs docs, but swiftlint is not picking up on it, I think because all cases are documented")
    public enum PresentationType: RawRepresentable {
        public init?(rawValue: LaunchStyle) {
            switch rawValue {
                case .default: self = .default
                case ._navigationStack: self = .navigationStack
                case ._modal: self = .modal
                case ._modal_fullscreen: self = .modal(.fullScreen)
                case ._modal_pageSheet: self = .modal(.pageSheet)
                case ._modal_formSheet: self = .modal(.formSheet)
                case ._modal_currentContext: self = .modal(.currentContext)
                case ._modal_custom: self = .modal(.custom)
                case ._modal_overFullScreen: self = .modal(.overFullScreen)
                case ._modal_overCurrentContext: self = .modal(.overCurrentContext)
                case ._modal_popover: self = .modal(.popover)
                case ._modal_automatic: self = .modal(.automatic)
                default: return nil
            }
        }

        public var rawValue: LaunchStyle {
            switch self {
                case .navigationStack: return ._navigationStack
                case .modal(let style): return style.launchStyle
                case .default: return .default
            }
        }

        public typealias RawValue = LaunchStyle

        /**
        Indicates a `FlowRepresentable` should be launched in a navigation stack of some kind (For example with UIKit this would use a UINavigationController)
        - Note: If no current navigation stack is available, one will be created
        */
        case navigationStack
        /// modally: Indicates a `FlowRepresentable` should be launched modally
        case modal(ModalPresentationStyle)
        /**
        Indicates a `FlowRepresentable` can be launched contextually
        - Note: If there's already a navigation stack, it will be used. Otherwise views will present modally
        */
        case `default`

        public static var modal: PresentationType {
            .modal(.default)
        }
    }
}

extension LaunchStyle.PresentationType {
    /// Modal presentation styles available when presenting view controllers.
    public enum ModalPresentationStyle {
        /// The default presentation style chosen by the system.
        case `default`
        /// A presentation style in which the presented view covers the screen.
        case fullScreen
        /// A presentation style that partially covers the underlying content.
        case pageSheet
        /// A presentation style that displays the content centered in the screen.
        case formSheet
        /// A presentation style where the content is displayed over another view controller’s content.
        case currentContext
        /// A custom view presentation style that is managed by a custom presentation controller and one or more custom animator objects.
        case custom
        /// A view presentation style in which the presented view covers the screen.
        case overFullScreen
        /// A presentation style where the content is displayed over another view controller’s content.
        case overCurrentContext
        /// A presentation style where the content is displayed in a popover view.
        case popover
        /// The default presentation style chosen by the system.
        case automatic

        var launchStyle: LaunchStyle {
            switch self {
                case .default: return ._modal
                case .fullScreen: return ._modal_fullscreen
                case .pageSheet: return ._modal_pageSheet
                case .formSheet: return ._modal_formSheet
                case .currentContext: return ._modal_currentContext
                case .custom: return ._modal_custom
                case .overFullScreen: return ._modal_overFullScreen
                case .overCurrentContext: return ._modal_overCurrentContext
                case .popover: return ._modal_popover
                case .automatic: return ._modal_automatic
            }
        }
    }
}

extension LaunchStyle.PresentationType: Equatable {
    public static func == (lhs: LaunchStyle.PresentationType, rhs: LaunchStyle.PresentationType) -> Bool {
        lhs.rawValue === rhs.rawValue
    }
}
