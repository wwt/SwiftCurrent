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
var conformance = "FlowRepresentable"
try main()

func main() throws {
    let directoryPath = CommandLine.arguments[1]
    let filepaths = getSwiftFiles(from: directoryPath)
    let finder = ConformanceFinder()

    for path in filepaths {
        if path.lowercased().contains("test") { continue }
        let url = URL(fileURLWithPath: path)
        let sourceFile = try SyntaxParser.parse(url)
        print("Checking \(path)...")
        _ = finder.visit(sourceFile)
    }

    printFindings(finder)

    // Checking for conformed to members of the protocol names array...
    // EXTRACT TO FUNC
    var protocolConformance: [String: [String]] = [:]
    finder.protocolNames.forEach { protocolConformance["\($0)"] = [] }

    for name in protocolConformance.keys {
        conformance = name
        finder.classAndStructNames = []
        finder.extensionNames = []
        finder.protocolNames = []

        for path in filepaths {
            if path.lowercased().contains("test") { continue }
            let url = URL(fileURLWithPath: path)
            let sourceFile = try SyntaxParser.parse(url)
            print("Checking \(path)...")
            _ = finder.visit(sourceFile)
        }

        printFindings(finder)
        protocolConformance["\(name)"] = finder.classAndStructNames
    }
    // END EXTRACTED FUNC
}

func printFindings(_ finder: ConformanceFinder) {
    print("Found the following \(finder.classAndStructNames.count) \(conformance) conforming classes and structs...")
    finder.classAndStructNames.forEach { print($0) }
    print("Found the following \(finder.extensionNames.count) \(conformance) extensions...")
    finder.extensionNames.forEach { print($0) }
    print("Found the following \(finder.protocolNames.count) \(conformance) protocols...")
    finder.protocolNames.forEach { print($0) }
}

class ConformanceFinder: SyntaxRewriter {
    var classAndStructNames: [String] = []
    var extensionNames: [String] = []
    var protocolNames: [String] = []

    override func visit(_ token: TokenSyntax) -> Syntax {
        let tokenIsStructOrClass: Bool = token.previousToken?.tokenKind == .structKeyword || token.previousToken?.tokenKind == .classKeyword
        let tokenIsExtension: Bool = token.previousToken?.tokenKind == .extensionKeyword
        let tokenIsProtocol: Bool = token.previousToken?.tokenKind == .protocolKeyword

        if tokenIsExtension {
            if let name = scanForConformance(token) { extensionNames.append(name) }
        } else if tokenIsProtocol {
            if let name = scanForConformance(token) { protocolNames.append(name) }
        } else if tokenIsStructOrClass {
            if let name = scanForConformance(token) { classAndStructNames.append(name) }
        }

        return Syntax(token)
    }

    private func scanForConformance(_ token: TokenSyntax) -> String? {
        var fileToken: TokenSyntax? = token

        while fileToken?.text != "{" {
            guard let currentToken = fileToken, !currentToken.tokenKind.isKeyword else { break }
            if currentToken.text == conformance {
                return token.text
            }
            fileToken = currentToken.nextToken
        }
        return nil
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
