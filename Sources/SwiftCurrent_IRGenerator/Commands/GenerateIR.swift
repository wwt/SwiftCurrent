//
//  GenerateIR.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 3/3/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//

import Foundation

import ArgumentParser
import SwiftSyntax

struct GenerateIR: ParsableCommand {
    fileprivate static let conformance: StaticString = "WorkflowDecodable"

    @Argument(help: "The path to a directory containing swift source files with types conforming to \(Self.conformance)")
    var pathOrSourceCode: Either<URL, String>

    mutating func run() throws {
        let files: [ParsedResult]
        switch pathOrSourceCode {
            case .firstChoice(let url):
                let fileURLs = try getSwiftFileURLs(from: url)
                files = fileURLs.compactMap { try? ParsedResult(filepath: $0) }
            case .secondChoice(let source):
                files = try [ParsedResult(sourceCode: source)]
        }

        let conformingTypes = findTypesConforming(to: "\(Self.conformance)", in: files)
            .flatMap(\.value)

        let encoded = try JSONEncoder().encode(conformingTypes.lazy.filter(\.isStructuralType))
        if let jsonString = String(data: encoded, encoding: .utf8) {
            print(jsonString)
        }
    }

    func findTypesConforming(to conformance: String, in files: [ParsedResult], objectType: Type.ObjectType? = nil) -> [Type.ObjectType: [ConformingType]] {
        var typesConforming: [Type.ObjectType: [ConformingType]] = [:]

        files.forEach {
            let rootNode = $0.walker.root

            for firstSubtype in rootNode.types {
                checkTypeForConformance(firstSubtype, conformance: conformance).forEach {
                    typesConforming[$0.type.type, default: []].append($0)
                }
            }
        }

        typesConforming[.protocol]?.forEach {
            // Find arbitrarily deep protocol chains
            typesConforming.merge(findTypesConforming(to: $0.type.name, in: files)) { $0 + $1 }
        }
        return typesConforming
    }

    func checkTypeForConformance(_ type: Type, parents: [Type] = [], conformance: String) -> [ConformingType] {
        var conformingTypes = [ConformingType]()
        if type.inheritance.contains(conformance) {
            conformingTypes.append(ConformingType(type: type, parents: parents))
        }

        // Find arbitrarily nested types
        return type.types
            .flatMap { checkTypeForConformance($0, parents: parents.appending(type), conformance: conformance) }
            .appending(contentsOf: conformingTypes)
    }

    func getSwiftFileURLs(from directory: URL) throws -> [URL] {
        var files = [URL]()

        if let enumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator where fileURL.pathExtension == "swift" {
                let fileAttributes = try fileURL.resourceValues(forKeys: [.isRegularFileKey])
                if fileAttributes.isRegularFile == true {
                    files.append(fileURL)
                }
            }
        }

        return files.filter(\.isFileURL)
    }
}

extension Array where Self.Element: Type {
    func containsSubTypes() -> Bool {
        !self.allSatisfy { $0.types.isEmpty }
    }
}
