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

extension URL: ExpressibleByArgument {
    public init?(argument: String) {
        self.init(string: argument)
    }

    public var defaultValueDescription: String {
        "A valid URL"
    }
}

struct GenerateIR: ParsableCommand {
    fileprivate static let conformance: StaticString = "WorkflowDecodable"

    @Argument(help: "The path to a directory containing swift source files with types conforming to \(Self.conformance)")
    var directoryPath: URL

    mutating func run() throws {
        let fileURLs = getSwiftFileURLs(from: directoryPath)
        let files: [File] = fileURLs.compactMap { try? File(url: $0) }

        let conformingTypes = findTypesConforming(to: "\(Self.conformance)", in: files)

        try conformingTypes[.protocol]?.forEach { conformingProtocol in
            let typesConformingToProtocol = findTypesConforming(to: conformingProtocol.type.name, in: files)
            let encodedDictionary = try JSONEncoder().encode(typesConformingToProtocol)
            if let jsonString = String(data: encodedDictionary, encoding: .utf8) {
                print(jsonString)
            }
        }
    }

    func findTypesConforming(to conformance: String, in files: [File], objectType: Type.ObjectType? = nil) -> [Type.ObjectType: [ConformingType]] {
        var typesConforming: [Type.ObjectType: [ConformingType]] = [:]

        files.forEach {
            let rootNode = $0.results.rootNode

            for firstSubtype in rootNode.types {
                checkTypeForConformance(firstSubtype, parentType: nil, conformance: conformance, objectType: objectType, typesConforming: &typesConforming)

                if firstSubtype.types.containsSubTypes() {
                    for secondSubtype in firstSubtype.types {
                        checkTypeForConformance(secondSubtype, parentType: firstSubtype, conformance: conformance, objectType: objectType, typesConforming: &typesConforming)
                    }
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
            if typesConforming[type.type] == nil { typesConforming[type.type] = [] }
            let conforming = ConformingType(type: type, parent: parentType)
            typesConforming[type.type]?.append(conforming)
        }
    }

    func getSwiftFileURLs(from directory: URL) -> [URL] {
        var files = [URL]()

        if let enumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
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
}

struct ConformingType: Codable {
    let type: Type
    let parent: Type?

    init(type: Type, parent: Type?) {
        self.type = type
        self.parent = parent
    }

    var hasSubTypes: Bool {
        !self.type.types.isEmpty
    }

    var registryDescription: String {
        parent == nil ? // THIS IS ANTI-STYLE GUIDE
            "- [\(type.name)]" :
            "- [\(parent?.name ?? "").\(type.name)]"
    }
}

extension Array where Self.Element: Type {
    func containsSubTypes() -> Bool {
        !self.allSatisfy { $0.types.isEmpty }
    }
}
