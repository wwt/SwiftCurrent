//
//  WorkflowError.swift
//  Workflow
//
//  Created by Richard Gist on 5/5/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

/// Describes errors in a `Workflow`.
public enum WorkflowError: Error {
    /// An error indicating workflow could not back up.
    case failedToBackUp
}
