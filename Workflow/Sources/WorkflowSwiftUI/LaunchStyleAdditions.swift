//
//  File.swift
//  
//
//  Created by Tyler Thompson on 11/29/20.
//

import Foundation
import Workflow

public extension LaunchStyle {
    static let _navigationStack = LaunchStyle.new
    static let _modal = LaunchStyle.new
    @available(iOS 14.0, *)
    static let _modal_fullscreen = LaunchStyle.new

    enum PresentationType: RawRepresentable {
        public init?(rawValue: LaunchStyle) {
            if #available(iOS 14.0, *),
               rawValue == ._modal_fullscreen {
                self = .modal(.fullScreen)
                return
            }
            switch rawValue {
                case .default: self = .default
                case ._navigationStack: self = .navigationStack
                case ._modal: self = .modal
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
            return .modal(.default)
        }
    }
}

extension LaunchStyle.PresentationType {
    public enum ModalPresentationStyle {
        case `default`
        case fullScreen

        var launchStyle: LaunchStyle {
            switch self {
                case .default: return ._modal
                case .fullScreen: if #available(iOS 14.0, *) {
                    return ._modal_fullscreen
                }
            }
            return ._modal //should never happen
        }
    }
}

extension LaunchStyle.PresentationType: Equatable {
    public static func == (lhs: LaunchStyle.PresentationType, rhs: LaunchStyle.PresentationType) -> Bool {
        return lhs.rawValue === rhs.rawValue
    }
}
