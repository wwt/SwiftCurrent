//  swiftlint:disable:this file_name
//  Reason: The file name reflects the contents of the file.
//
//  CollectionExtensions.swift
//  Workflow
//
//  Created by Tyler Thompson on 4/9/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
extension Collection {
    subscript (safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
