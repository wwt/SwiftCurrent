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

        allConformances[.protocol]?.forEach { conformingProtocol in
            let typesConformingToProtocol = findTypesConforming(to: conformingProtocol.type.name, in: files)
            conformingTypes.append(contentsOf: typesConformingToProtocol.flatMap(\.value))
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
                checkTypeForConformance(firstSubtype, parentType: nil, conformance: conformance, objectType: objectType, typesConforming: &typesConforming)

                for secondSubtype in firstSubtype.types where firstSubtype.types.containsSubTypes() {
                    checkTypeForConformance(secondSubtype, parentType: firstSubtype, conformance: conformance, objectType: objectType, typesConforming: &typesConforming)
                }
            }
        }

        return typesConforming
    }

    func checkTypeForConformance(_ type: Type, parentType: Type?, conformance: String, objectType: Type.ObjectType?, typesConforming: inout [Type.ObjectType: [ConformingType]]) {
        let conformanceCheck = objectType == nil ? // THIS IS ANTI-STYLE GUIDE
            type.inheritance.contains(conformance) :
            type.inheritance.contains(conformance) && type.type == objectType

        if conformanceCheck {
            let conforming = ConformingType(type: type, parent: parentType)
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
