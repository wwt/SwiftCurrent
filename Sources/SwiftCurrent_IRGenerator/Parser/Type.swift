//
//  Type.swift
//  SwiftCurrent
//
//  Created by Morgan Zellers on 3/8/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Foundation

class Type: IRNode, Decodable {
    private enum CodingKeys: CodingKey {
        case name, type, inheritance, body
    }

    enum ObjectType: String, Codable {
        case `class`, `enum`, `extension`, `protocol`, `struct`
    }

    let name: String
    let type: ObjectType
    let inheritance: [String]
    let body: String

    init(type: ObjectType, name: String, inheritance: [String], body: String) {
        self.type = type
        self.name = name
        self.inheritance = inheritance
        self.body = body.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
