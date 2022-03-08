//
//  IRNode.swift
//  SwiftCurrent
//
//  Created by Morgan Zellers on 3/8/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Foundation

class IRNode: Encodable {
    private enum CodingKeys: CodingKey {
        case cases, types
    }

    weak var parent: IRNode?
    var types = [Type]()
    var cases = [String]()
}
