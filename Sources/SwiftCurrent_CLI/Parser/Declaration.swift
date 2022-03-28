//
//  Type.swift
//  SwiftCurrent
//
//  Created by Morgan Zellers on 3/8/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Foundation

class Declaration: SyntaxNode {
    enum NominalType {
        case `class`, `enum`, `extension`, `protocol`, `struct`
    }

    let name: String
    let nominalType: NominalType
    let inheritance: [String]

    init(nominalType: NominalType, name: String, inheritance: [String]) {
        self.nominalType = nominalType
        self.name = name
        self.inheritance = inheritance
    }
}
