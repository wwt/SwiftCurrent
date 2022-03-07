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
        let files: [ParsedFile]
        switch pathOrSourceCode {
            case .firstChoice(let url):
                let fileURLs = try getSwiftFileURLs(from: url)
                files = fileURLs.compactMap { try? ParsedFile(url: $0) }
            case .secondChoice(let source):
                files = try [ParsedFile(sourceCode: source)]
        }

        let allConformances = findTypesConforming(to: "\(Self.conformance)", in: files)
        var conformingTypes = allConformances.flatMap(\.value)
        var secondLevelConformances: [ConformingType] = []

        for conformingType in conformingTypes {
            let typesConforming = findTypesConforming(to: conformingType.type.name, in: files)
            secondLevelConformances.append(contentsOf: typesConforming.flatMap(\.value))
            conformingTypes.append(contentsOf: typesConforming.flatMap(\.value))
        }

        for conformingType in secondLevelConformances {
            let types = findTypesConforming(to: conformingType.type.name, in: files)
            conformingTypes.append(contentsOf: types.flatMap(\.value))
        }

        let encoded = try JSONEncoder().encode(conformingTypes.lazy.filter(\.isStructuralType))
        if let jsonString = String(data: encoded, encoding: .utf8) {
            print(jsonString)
        }
    }

    func findTypesConforming(to conformance: String, in files: [ParsedFile], objectType: Type.ObjectType? = nil) -> [Type.ObjectType: [ConformingType]] {
        var typesConforming: [Type.ObjectType: [ConformingType]] = [:]

        files.forEach {
            let rootNode = $0.results.root

            for firstSubtype in rootNode.types {
                checkTypeForConformance(firstSubtype, conformance: conformance, typesConforming: &typesConforming)

                for secondSubtype in firstSubtype.types {
                    checkTypeForConformance(secondSubtype, parent: firstSubtype, conformance: conformance, typesConforming: &typesConforming)

                    for third in secondSubtype.types {
                        checkTypeForConformance(third, parent: secondSubtype, grandparent: firstSubtype, conformance: conformance, typesConforming: &typesConforming)
                    }
                }
            }
        }

        return typesConforming
    }

    func checkTypeForConformance(_ type: Type, parent: Type? = nil, grandparent: Type? = nil, conformance: String, typesConforming: inout [Type.ObjectType: [ConformingType]]) {
        if type.inheritance.contains(conformance) {
            let conforming = ConformingType(type: type, parent: parent, grandparent: grandparent)
            typesConforming[type.type, default: []].append(conforming)
        }
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
