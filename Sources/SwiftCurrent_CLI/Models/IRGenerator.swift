//
//  IRGenerator.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 3/29/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Foundation
import ArgumentParser
import SwiftSyntax

struct IRGenerator {
    func getFiles(from pathOrSourceCode: Either<URL, String>) throws -> [File] {
        switch pathOrSourceCode {
            case .firstChoice(let url):
                let fileURLs = try getSwiftFileURLs(from: url)
                return fileURLs.compactMap { try? File(filepath: $0) }
            case .secondChoice(let source):
                return try [File(sourceCode: source)]
        }
    }

    func findDeclarationsConforming(to conformance: String, in files: [File], objectType: Declaration.NominalType? = nil) -> [ConformingDeclaration] {
        files
            .flatMap(\.declarations)
            .flatMap { checkDeclarationForConformance($0, conformance: conformance) }
            .reduce(into: [ConformingDeclaration]()) {
                $0.append($1)
                // Find arbitrarily chained protocols (P1 inherits from WorkflowDecodable and P2 inherits from P1 and P3 inherits from P2...)
                if $1.declaration.nominalType == .protocol {
                    $0.append(contentsOf: findDeclarationsConforming(to: $1.declaration.name, in: files))
                }
            }
    }

    private func checkDeclarationForConformance(_ type: Declaration, parents: [Declaration] = [], conformance: String) -> [ConformingDeclaration] {
        // Find arbitrarily nested types
        type.declarations
            .flatMap { checkDeclarationForConformance($0, parents: parents.appending(type), conformance: conformance) }
            .appending(contentsOf: type.inheritance.contains(conformance) ? [ConformingDeclaration(declaration: type, parents: parents)] : [])
    }

    private func getSwiftFileURLs(from url: URL) throws -> [URL] {
        guard url.pathExtension.isEmpty else {
            if FileManager.default.fileExists(atPath: url.path) && url.pathExtension == "swift" {
                return [URL(fileURLWithPath: url.path)]
            } else {
                return []
            }
        }

        var files = [URL]()

        if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator where try fileURL.isSwiftFile {
                files.append(fileURL)
            }
        }

        return files.filter(\.isFileURL)
    }
}

extension URL {
    fileprivate var isSwiftFile: Bool {
        get throws {
            try pathExtension == "swift" && resourceValues(forKeys: [.isRegularFileKey]).isRegularFile == true
        }
    }
}
