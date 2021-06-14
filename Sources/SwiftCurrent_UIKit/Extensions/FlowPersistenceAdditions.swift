//  swiftlint:disable:this file_name
//  Reason: The file name reflects the contents of the file.
//
//  FlowPersistenceAdditions.swift
//  
//
//  Created by Tyler Thompson on 11/26/20.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import SwiftCurrent

extension FlowPersistence {
    /// Indicates a `FlowRepresentable` in a `Workflow` whose `shouldLoad` function returns false, should be persisted in the workflow for backwards navigation.
    public static let hiddenInitially = FlowPersistence.persistWhenSkipped
}
