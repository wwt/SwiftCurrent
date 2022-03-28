//
//  IR.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 3/28/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Foundation
import ArgumentParser
import SwiftSyntax

struct IR: ParsableCommand {
    fileprivate static let conformance: StaticString = "WorkflowDecodable"

    @Argument(help: "The path to a directory containing swift source files with types conforming to \(Self.conformance)")
    var pathOrSourceCode: Either<URL, String>

    mutating func run() throws {
        let files = try getFiles()

        let conformingTypes = findTypesConforming(to: "\(Self.conformance)", in: files)

        let encoded = try JSONEncoder().encode(conformingTypes.lazy.filter(\.isConcreteType))

        // this is actually preferred, if we can't encode to UTF8 something horribly unpredictably wrong happened, all we'd do is trap anyways
        // swiftlint:disable:next force_unwrapping
        let jsonString = String(data: encoded, encoding: .utf8)!
        print(jsonString)
    }

    private func getFiles() throws -> [File] {
        switch pathOrSourceCode {
            case .firstChoice(let url):
                let fileURLs = try getSwiftFileURLs(from: url)
                return fileURLs.compactMap { try? File(filepath: $0) }
            case .secondChoice(let source):
                return try [File(sourceCode: source)]
        }
    }

    private func findTypesConforming(to conformance: String, in files: [File], objectType: Declaration.NominalType? = nil) -> [ConformingType] {
        files
            .flatMap(\.declarations)
            .flatMap { checkTypeForConformance($0, conformance: conformance) }
            .reduce(into: [ConformingType]()) {
                $0.append($1)
                // Find arbitrarily chained protocols (P1 inherits from WorkflowDecodable and P2 inherits from P1 and P3 inherits from P2...)
                if $1.declaration.nominalType == .protocol {
                    $0.append(contentsOf: findTypesConforming(to: $1.declaration.name, in: files))
                }
            }
    }

    private func checkTypeForConformance(_ type: Declaration, parents: [Declaration] = [], conformance: String) -> [ConformingType] {
        // Find arbitrarily nested types
        type.declarations
            .flatMap { checkTypeForConformance($0, parents: parents.appending(type), conformance: conformance) }
            .appending(contentsOf: type.inheritance.contains(conformance) ? [ConformingType(declaration: type, parents: parents)] : [])
    }

    private func getSwiftFileURLs(from directory: URL) throws -> [URL] {
        var files = [URL]()

        if let enumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
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
