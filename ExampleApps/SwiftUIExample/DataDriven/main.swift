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

var conformance = "FlowRepresentable"
try main()

func main() throws {
    let directoryPath = CommandLine.arguments[1]
    let fileURLs = getSwiftFileURLs(from: directoryPath)
    let files: [File] = fileURLs.compactMap { try? File(url: $0) }

    printFindings(files)
}

func printFindings(_ files: [File]) {
    var protocolsConforming: [String] = []

    files.forEach {
        let root = $0.results.rootNode

        for type in root.types {

            if type.inheritance.contains(conformance) {
                print("Inheritance for \(type.type.rawValue) \(type.name): \(type.inheritance)")
            }

            if type.type == .protocol && (type.inheritance.contains(conformance) == true) {
                protocolsConforming.append(type.name)
                print("Appending \(type.type.rawValue) \(type.name) to list of protocols conforming to \(conformance)")
            }
        }
    }

    files.forEach {
        let root = $0.results.rootNode

        protocolsConforming.forEach { proto in

            for type in root.types {

                if type.inheritance.contains(proto) {
                    print("Inheritance for \(type.type.rawValue) \(type.name): \(type.inheritance)")
                }
            }
        }
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