//
//  ConformingType.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 3/3/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Foundation

struct ConformingType: Codable {
    let name: String
    let type: Type
    let parent: Type?
    let grandparent: Type?

    init(type: Type, parent: Type? = nil, grandparent: Type? = nil) {
        self.type = type
        self.parent = parent
        self.grandparent = grandparent

        if let grandparent = grandparent, let parent = parent {
            name = "\(grandparent.name).\(parent.name).\(type.name)"
        } else if let parent = parent {
            name = "\(parent.name).\(type.name)"
        } else {
            name = type.name
        }
    }

    var isStructuralType: Bool {
        switch type.type {
            case .class:
                return true
            case .enum:
                return true
            case .extension:
                return true
            case .protocol:
                return false
            case .struct:
                return true
        }
    }

    var hasSubTypes: Bool {
        !self.type.types.isEmpty
    }
}
