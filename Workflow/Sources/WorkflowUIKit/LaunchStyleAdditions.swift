//
//  LaunchStyleAdditions.swift
//  
//
//  Created by Tyler Thompson on 11/26/20.
//

import Foundation
import Workflow

extension LaunchStyle {
    public static let _navigationStack = LaunchStyle.new
    public static let _modal = LaunchStyle.new
    public static let _modal_fullscreen = LaunchStyle.new
    public static let _modal_pageSheet = LaunchStyle.new
    public static let _modal_formSheet = LaunchStyle.new
    public static let _modal_currentContext = LaunchStyle.new
    public static let _modal_custom = LaunchStyle.new
    public static let _modal_overFullScreen = LaunchStyle.new
    public static let _modal_overCurrentContext = LaunchStyle.new
    public static let _modal_popover = LaunchStyle.new
    public static let _modal_automatic = LaunchStyle.new
}

extension LaunchStyle {
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

        /// navigationStack: Indicates a `FlowRepresentable` should be launched in a navigation stack of some kind (For example with UIKit this would use a UINavigationController)
        /// - Note: If no current navigation stack is available, one will be created
        case navigationStack
        /// modally: Indicates a `FlowRepresentable` should be launched modally
        case modal(ModalPresentationStyle)
        /// default: Indicates a `FlowRepresentable` can be launched contextually
        /// - Note: If there's already a navigation stack, it will be used. Otherwise views will present modally
        case `default`

        public static var modal: PresentationType {
            .modal(.default)
        }
    }
}

extension LaunchStyle.PresentationType {
    public enum ModalPresentationStyle {
        case `default`
        case fullScreen
        case pageSheet
        case formSheet
        case currentContext
        case custom
        case overFullScreen
        case overCurrentContext
        case popover
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
