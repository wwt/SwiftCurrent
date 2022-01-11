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
    let fileURLs = getSwiftFileURLs(from: directoryPath)

    let files: [File] = fileURLs.compactMap { try? File(url: $0) }

    printFindings(files)
}

func printFindings(_ files: [File]) {
    files.forEach {
        print("\($0.results.rootNode.types.first?.name)")
    }

    let classes = files.filter { $0.results.rootNode.types.first?.type == .class }

    classes.forEach {
        guard let name = $0.results.rootNode.types.first?.name,
              let inheritence = $0.results.rootNode.types.first?.inheritance else { return }

        print("Inheritance for \(name): \(inheritence)")
    }
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

func getSwiftFileURLs(from directory: String) -> [URL] {
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
            guard let rangeOfFilePrefix = filename.relativeString.range(of: "file://") else { return URL(fileURLWithPath: filename.relativeString) }
            return URL(fileURLWithPath: String(filename.relativeString.suffix(from: rangeOfFilePrefix.upperBound)))
        }
    }
    return []
}
