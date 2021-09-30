//
//  PassedArgs.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 9/29/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//  

extension AnyWorkflow {
    /// A type that represents either a type erased value or no value.
    public enum PassedArgs {
        /// No arguments are passed forward.
        case none
        /// The type erased value passed forward.
        case args(Any?)

        /**
         Performs a coalescing operation, returning the type erased value of a `PassedArgs` instance or a default value.

         - Parameter defaultValue: the default value to use if there are no args.
         - Returns: type erased value of a `PassedArgs` instance or a default value.
         */
        public func extractArgs(defaultValue: Any?) -> Any? {
            if case .args(let value) = self {
                return value
            }
            return defaultValue
        }
    }
}
