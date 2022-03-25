//
//  IRNode.swift
//  SwiftCurrent
//
//  Created by Morgan Zellers on 3/8/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Foundation

class SyntaxNode {
    weak var parent: SyntaxNode?
    var declarations = [Declaration]()
}
