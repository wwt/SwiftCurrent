//  swiftlint:disable:this file_name
//  SwiftUIFlowPersistenceAdditions.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Morgan Zellers on 9/13/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//
import SwiftCurrent

extension FlowPersistence {
    /// A namespace for the SwiftUI persistence types.
    public enum SwiftUI {
        /// A type indicating how a `FlowRepresentable` should be persisted.
        public enum Persistence: RawRepresentable, CaseIterable {
            /// Indicates a `FlowRepresentable` in a `Workflow` should persist based on its `shouldLoad` function.
            case `default`
            /// Indicates a `FlowRepresentable` in a `Workflow` whose `shouldLoad` function returns true, should be removed from the workflow after proceeding forward.
            case removedAfterProceeding

            /// Creates a `Persistence` from a `FlowPersistence`, or returns nil if no mapping exists.
            public init?(rawValue: FlowPersistence) {
                switch rawValue {
                    case .default: self = .default
                    case .removedAfterProceeding: self = .removedAfterProceeding
                    case .persistWhenSkipped: return nil
                    default: return nil
                }
            }

            /// The corresponding `FlowPersistence` for this `Persistence`
            public var rawValue: FlowPersistence {
                switch self {
                    case .default: return .default
                    case .removedAfterProceeding: return .removedAfterProceeding
                }
            }
        }
    }
}

extension FlowPersistence.SwiftUI.Persistence: Equatable {
    /// :nodoc: Equatable protocol requirement.
    public static func == (lhs: FlowPersistence.SwiftUI.Persistence, rhs: FlowPersistence.SwiftUI.Persistence) -> Bool {
        lhs.rawValue === rhs.rawValue
    }
}
