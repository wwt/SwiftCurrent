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

var conformance = "WorkflowDecodable"
try main()

func main() throws {
    let directoryPath = CommandLine.arguments[1]
    let fileURLs = getSwiftFileURLs(from: directoryPath)
    let files: [File] = fileURLs.compactMap { try? File(url: $0) }

    print("Checking \(conformance)...")
    let conformingTypes = findTypesConforming(to: conformance, in: files)
    print(conformingTypes, for: conformance)

    for conformingProtocol in conformingTypes[.protocol]! {
        print("Checking \(conformingProtocol.name)...")
        let typesConformingToProtocol = findTypesConforming(to: conformingProtocol.name, in: files)
        print(typesConformingToProtocol, for: conformingProtocol.name)
    }
}

func findTypesConforming(to conformance: String, in files: [File], objectType: Type.ObjectType? = nil) -> [Type.ObjectType: [Type]] {
    var typesConforming: [Type.ObjectType: [Type]] = [:]

    files.forEach {
        let root = $0.results.rootNode
        for type in root.types {
            let conformanceCheck = objectType == nil ? // THIS IS ANTI-STYLE GUIDE
                type.inheritance.contains(conformance) :
                type.inheritance.contains(conformance) && type.type == objectType
            
            if conformanceCheck {
                if typesConforming[type.type] == nil { typesConforming[type.type] = [] }
                typesConforming[type.type]?.append(type)
            }
        }
    }

    return typesConforming
}

//func findParent(for node: Node, in files: [File]) -> Type? {
//    files.forEach {
//        let root = $0.results.rootNode
//
//        for type in root.types {
//            if node == Node(type) { return type }
//        }
//    }
//    return nil
//}

func print(_ types: [Type.ObjectType: [Type]], for conformance: String) {
    for key in types.keys {
        print("\(key.rawValue)s conforming to \(conformance):")
        types[key]?.forEach { print("- \($0.name)") }
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
