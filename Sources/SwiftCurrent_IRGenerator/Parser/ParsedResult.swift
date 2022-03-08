//
//  ParsedResult.swift
//  SwiftCurrent
//
//  Created by Morgan Zellers on 3/4/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Foundation
import SwiftSyntax

/// Represents a file that has been parsed by the `IRWalker`
public struct ParsedResult {
    let filepath: URL?
    var walker: IRWalker

    init(filepath: URL) throws {
        self.filepath = filepath
        walker = IRWalker()

        do {
            let file = try SyntaxParser.parse(filepath)
            walker.walk(file)
        } catch ParserError.parserCompatibilityCheckFailed {
            fatalError("Swift version mismatch. Check that you have the correct version of SwiftSyntax for this version of Swift.")
        }
    }

    init(sourceCode: String) throws {
        self.filepath = nil
        walker = IRWalker()

        let sourceFile = try SyntaxParser.parse(source: sourceCode)
        walker.walk(sourceFile)
    }
}
