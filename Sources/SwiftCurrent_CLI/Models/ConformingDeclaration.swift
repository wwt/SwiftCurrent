//
//  ConformingType.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 3/3/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Foundation

struct ConformingDeclaration {
    let declaration: Declaration
    let parents: [Declaration]

    var name: String {
        parents.map(\.name).appending(declaration.name).joined(separator: ".")
    }

    var isConcreteType: Bool {
        switch declaration.nominalType {
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
}

extension ConformingDeclaration: Encodable {
    enum CodingKeys: String, CodingKey {
        case name
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }
}
