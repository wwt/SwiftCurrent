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

    printFindings(files)
}

func printFindings(_ files: [File]) {
    var protocolsConforming: [Type] = []

    files.forEach {
        let root = $0.results.rootNode

        for type in root.types {

            if type.inheritance.contains(conformance) {
                print("Inheritance for \(type.type.rawValue) \(type.name): \(type.inheritance)")
            }

            if type.type == .protocol && (type.inheritance.contains(conformance) == true) {
                _ = findFlowRepresentableName(type.name, files: files)
                protocolsConforming.append(type)
                print("Appending \(type.type.rawValue) \(type.name) to list of protocols conforming to \(conformance)")
            }
        }
    }

    files.forEach {
        let root = $0.results.rootNode

        protocolsConforming.forEach { proto in

            for type in root.types {
                if type.inheritance.contains(proto.name) {
                    print("Inheritance for \(type.type.rawValue) \(type.name): \(type.inheritance)")
                }
            }
        }
    }
}

func findFlowRepresentableName(_ filename: String, files: [File]) -> Type? {
    var x: Type?
    files.forEach { file in
        file.results.rootNode.types.forEach { type in
            if type.variables.contains("flowRepresentableName") {
                x = type
            }
        }
    }
    return x
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
