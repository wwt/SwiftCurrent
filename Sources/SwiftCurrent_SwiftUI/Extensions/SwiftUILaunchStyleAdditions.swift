//  swiftlint:disable:this file_name
//  SwiftUILaunchStyleAdditions.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Tyler Thompson on 8/22/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftCurrent

extension LaunchStyle {
    static let _swiftUI_navigationLink = LaunchStyle.new
    static let _swiftUI_modal = LaunchStyle.new
    static let _swiftUI_modal_fullscreen = LaunchStyle.new
}

extension LaunchStyle {
    /// A namespace for the SwiftUI launch styles.
    public enum SwiftUI {
        /// A type indicating how a `FlowRepresentable` should be presented.
        public enum PresentationType: RawRepresentable, CaseIterable {
            public static let allCases: [LaunchStyle.SwiftUI.PresentationType] = [.default, .navigationLink, .modal(.sheet), .modal(.fullScreenCover)]

            /**
             Indicates a `FlowRepresentable` can be launched contextually.
             - Important: This swaps out SwiftUI Views and does not animate by default; you can supply your own animations.
             */
            case `default`

            /**
             Indicates a `FlowRepresentable` should be wrapped in a NavigationLink.
             - Important: You are responsible for supplying a NavigationView.
             */
            case navigationLink

            /**
             Indicates a `FlowRepresentable` should be presented modally.
             - Important: Will not effect the first item in a Workflow.
             */
            case modal(ModalPresentationStyle = .sheet)

            /// Creates a `PresentationType` from a `LaunchStyle`, or returns nil if no mapping exists.
            public init?(rawValue: LaunchStyle) {
                switch rawValue {
                    case .default: self = .default
                    case ._swiftUI_navigationLink: self = .navigationLink
                    case ._swiftUI_modal: self = .modal()
                    case ._swiftUI_modal_fullscreen: self = .modal(.fullScreenCover)
                    default: return nil
                }
            }

            /**
             Indicates a `FlowRepresentable` should be presented modally.
             - Important: Will not effect the first item in a Workflow.
             */
            public static let modal = Self.modal()

            /// The corresponding `LaunchStyle` for this `PresentationType`
            public var rawValue: LaunchStyle {
                switch self {
                    case .navigationLink: return ._swiftUI_navigationLink
                    case .modal(.fullScreenCover): return ._swiftUI_modal_fullscreen
                    case .modal: return ._swiftUI_modal
                    case .default: return .default
                }
            }
        }
    }
}

extension LaunchStyle.SwiftUI.PresentationType: Equatable {
    /// :nodoc: Equatable protocol requirement.
    public static func == (lhs: LaunchStyle.SwiftUI.PresentationType, rhs: LaunchStyle.SwiftUI.PresentationType) -> Bool {
        lhs.rawValue === rhs.rawValue
    }
}

extension LaunchStyle.SwiftUI {
    /// Modal presentation styles available when presenting sheets
    public enum ModalPresentationStyle {
        /// Presents a sheet
        case sheet
        /// Presents a modal view that covers as much of the screen as possible
        case fullScreenCover
    }
}
