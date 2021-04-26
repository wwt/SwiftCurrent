//
//  CollectionExtensions.swift
//  Workflow
//
//  Created by Tyler Thompson on 4/9/19.
//  Copyright © 2019 Dignity Health. All rights reserved.
//

import Foundation
extension Collection {
    subscript (safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
