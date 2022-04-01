//
//  File.swift
//  SwiftCurrent
//
//  Created by Morgan Zellers on 3/4/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Foundation
import SwiftSyntax

/// Represents a file that has been parsed by the `IRWalker`
public struct File {
    var visitor: SourceVisitor

    var declarations: [Declaration] {
        visitor.root.declarations
    }

    init(filepath: URL) throws {
        visitor = SourceVisitor()

        let file = try SyntaxParser.parse(filepath)
        visitor.walk(file)
    }

    init(sourceCode: String) throws {
        visitor = SourceVisitor()

        let sourceFile = try SyntaxParser.parse(source: sourceCode)
        visitor.walk(sourceFile)
    }
}
