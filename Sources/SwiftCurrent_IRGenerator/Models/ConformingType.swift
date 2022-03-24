//
//  ConformingType.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 3/3/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Foundation

struct ConformingType: Encodable {
    let type: Type
    let parents: [Type]

    var name: String {
        parents.map(\.name).appending(type.name).joined(separator: ".")
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

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }
}

extension ConformingType {
    enum CodingKeys: String, CodingKey {
        case name
    }
}
