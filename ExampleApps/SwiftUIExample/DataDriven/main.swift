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
    let start = CFAbsoluteTimeGetCurrent()

    let directoryPath = CommandLine.arguments[1]
    let fileURLs = getSwiftFileURLs(from: directoryPath)
    let files: [File] = fileURLs.compactMap { try? File(url: $0) }

    print("Checking \(conformance)...")
    let conformingTypes = findTypesConforming(to: conformance, in: files)
    print(conformingTypes, for: conformance)

    for conformingProtocol in conformingTypes[.protocol]! {
        print("Checking \(conformingProtocol.type.name)...")
        let typesConformingToProtocol = findTypesConforming(to: conformingProtocol.type.name, in: files)
        print(typesConformingToProtocol, for: conformingProtocol.type.name)
    }

    let diff = CFAbsoluteTimeGetCurrent() - start
    print("Took \(diff) seconds")
}

func findTypesConforming(to conformance: String, in files: [File], objectType: Type.ObjectType? = nil) -> [Type.ObjectType: [ConformingType]] {
    var typesConforming: [Type.ObjectType: [ConformingType]] = [:]

    files.forEach {
        let rootNode = $0.results.rootNode

        for firstSubtype in rootNode.types {
            checkTypeForConformance(firstSubtype, parentType: nil, conformance: conformance, objectType: objectType, typesConforming: &typesConforming)

            for secondSubtype in firstSubtype.types {
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
        if typesConforming[type.type] == nil { typesConforming[type.type] = [] }
        let conforming = ConformingType(type: type, parent: parentType)
        typesConforming[type.type]?.append(conforming)
    }
}

class ConformingType {
    let type: Type
    let parent: Type?

    init(type: Type, parent: Type?) {
        self.type = type
        self.parent = parent
    }


//    enum Namespace {
//        struct MyType: FlowRepresentable, WorkflowDecodable { /* ... */ }
//    }
//
//    Should generate into:
//    Registry([ Namespace.MyType.self ])
    var registryDescription: String {
        parent == nil ? // THIS IS ANTI-STYLE GUIDE
            "- [\(type.name)]" :
            "- [\(parent?.name ?? "").\(type.name)]"
    }
}

func print(_ types: [Type.ObjectType: [ConformingType]], for conformance: String) {
    for key in types.keys {
        print("\(key.rawValue)s conforming to \(conformance):")
        types[key]?.forEach { print("\($0.registryDescription)") }
    }
}

func writeToDocuments(contents: String, filename: String) {
    var filePath = ""
    let directories:[String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
    let directory = directories[0] 
    filePath = directory.appending("/" + fileName)
    print("Local path = \(filePath)")
    
    do {
        try contents.write(toFile: filePath, atomically: false, encoding: String.Encoding.utf8)
    } catch let error as NSError {
        print("An error took place: \(error)")
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
