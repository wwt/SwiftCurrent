//
//  ParsedFile.swift
//  SwiftCurrent
//
//  Created by Morgan Zellers on 3/4/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Foundation
import SwiftSyntax

public struct ParsedFile {
    let url: URL?
    var results: ParsedFileVisitor

    init(url: URL) throws {
        self.url = url
        results = ParsedFileVisitor()

        do {
            let file = try SyntaxParser.parse(url)
            results.walk(file)
        } catch ParserError.parserCompatibilityCheckFailed {
            fatalError("""
            Swift version mismatch. Check that you have the correct version of SwiftSyntax for this version of Swift.
            """)
        }
    }

    init(sourceCode: String) throws {
        self.url = nil
        results = ParsedFileVisitor()

        let sourceFile = try SyntaxParser.parse(source: sourceCode)
        results.walk(sourceFile)
    }
}
