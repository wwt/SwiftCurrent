//
//  main.swift
//  SwiftCurrent
//
//  Created by Morgan Zellers on 11/18/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//
// swiftlint:disable line_length

import Foundation
import SwiftSyntax

let SUBSTRUCTURE_KEY = "key.substructure"
let NAME_KEY = "key.name"
let INHERITEDTYPES_KEY = "key.inheritedtypes"

try main()

func main() throws {
    let directoryPath = CommandLine.arguments[1]
    let filepaths = getSwiftFiles(from: directoryPath)
    let finder = FlowRepresentableFinder()

    for path in filepaths {
        if path.lowercased().contains("test") { continue }
        let url = URL(fileURLWithPath: path)
        let sourceFile = try SyntaxParser.parse(url)
        print("Checking \(path)...")
        _ = finder.visit(sourceFile)
    }
   
    print("Found the following \(finder.frStructNames.count) FlowRepresentables...")
    finder.frStructNames.forEach { print($0) }
}

class FlowRepresentableFinder: SyntaxRewriter {
    var frStructNames: [String] = []

    override func visit(_ token: TokenSyntax) -> Syntax {
        let currentTokenIsStructOrClass: Bool = token.previousToken?.tokenKind == .structKeyword || token.previousToken?.tokenKind == .classKeyword

        if currentTokenIsStructOrClass {
            var fileToken: TokenSyntax? = token
            while fileToken?.text != "{" {
                guard let currentToken = fileToken, !currentToken.tokenKind.isKeyword else { break }
                if currentToken.text == "FlowRepresentable" {
                    print("Adding \(token.text) to list of FlowRepresentables...")
                    frStructNames.append(token.text)
                    break
                }
                fileToken = currentToken.nextToken
            }
        }

        return Syntax(token)
    }
}

func getSwiftFiles(from directory: String) -> [String] {
    let url = URL(fileURLWithPath: directory)
    var files = [URL]()

    if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
        for case let fileURL as URL in enumerator {
            do {
                let fileAttributes = try fileURL.resourceValues(forKeys: [.isRegularFileKey])
                if fileAttributes.isRegularFile! && fileURL.absoluteString.contains(".swift") {
                    files.append(fileURL)
                }
            } catch { print(error, fileURL) }
        }
        return files.map { filename in
            guard let rangeOfFilePrefix = filename.relativeString.range(of: "file://") else { return filename.relativeString }
            return String(filename.relativeString.suffix(from: rangeOfFilePrefix.upperBound))
        }
    }
    return []
}
