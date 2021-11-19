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

let SUBSTRUCTURE_KEY = "key.substructure"
let NAME_KEY = "key.name"
let INHERITEDTYPES_KEY = "key.inheritedtypes"

try main()

func main() throws {
    print("WOWEEEEE")
    let directoryPath = CommandLine.arguments[1]
    let seekingInheritedType = CommandLine.arguments[2]
    var frFiles: [String] = []
    let filepaths = getSwiftFiles(from: directoryPath)
    var astJsonArray: [String] = []

    for path in filepaths {
        //            do {
        //                astJsonArray.append(try shell("sourcekitten structure --file \(path)"))
        //            } catch { print("\(error)") }
        //            let file = CommandLine.arguments[1]
        let url = URL(fileURLWithPath: path)
        let sourceFile = try SyntaxParser.parse(url)
        let incremented = AddOneToIntegerLiterals().visit(sourceFile)
        print(incremented)
    }

    //        var counter = 0
    //        for structure in astJsonArray {
    //            guard let json = structure.data(using: .utf8) else { print("Error: Invalid JSON from SourceKitten"); continue }
    //            guard let file = try JSONSerialization.jsonObject(with: json, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] else { print("Error: Could not serialize JSON"); continue }
    //
    //            if let substructure = file[FindTypeInheritence.SUBSTRUCTURE_KEY] as? [[String: Any]],
    //                let typeName = substructure.first?[FindTypeInheritence.NAME_KEY] as? String,
    //                let inheritedTypes = substructure.first?[FindTypeInheritence.INHERITEDTYPES_KEY] as? [[String: String]],
    //                inheritedTypes.compactMap({ $0[FindTypeInheritence.NAME_KEY] }).contains(seekingInheritedType) {
    //                print("Appending \(typeName)")
    //                frFiles.append(typeName)
    //                counter += 1
    //            } else {
    //                astJsonArray.remove(at: counter)
    //            }
    //        }
    //
    //        frFiles.forEach { print($0) }
    //
    //        print("astJsonArray count: \(astJsonArray.count)")
    //        print("frFiles count: \(frFiles.count)")
}

class AddOneToIntegerLiterals: SyntaxRewriter {
  override func visit(_ token: TokenSyntax) -> Syntax {
    // Only transform integer literals.
    guard case .integerLiteral(let text) = token.tokenKind else {
      return Syntax(token)
    }

    // Remove underscores from the original text.
    let integerText = String(text.filter { ("0"..."9").contains($0) })

    // Parse out the integer.
    let int = Int(integerText)!

    // Create a new integer literal token with `int + 1` as its text.
    let newIntegerLiteralToken = token.withKind(.integerLiteral("\(int + 1)"))

    // Return the new integer literal.
    return Syntax(newIntegerLiteralToken)
  }
}

//class FindListOfFlowRepresentables: SyntaxRewriter {
//    override func visit(_ token: TokenSyntax) -> Syntax {
//
//    }
//}

//func shell(_ command: String) throws -> String {
//    let process = Process()
//    let pipe = Pipe()
//
//    process.standardOutput = pipe
//    process.standardError = pipe
//    process.arguments = ["-c", command]
//    process.executableURL = URL(fileURLWithPath: "/bin/zsh")
//
//    do {
//        try process.run()
//    } catch { throw error }
//
//    let data = pipe.fileHandleForReading.readDataToEndOfFile()
//    let output = String(data: data, encoding: .utf8) ?? ""
//
//    return output
//}

func getSwiftFiles(from directory: String) -> [String] {
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
        // FileManager().currentDirectoryPath
        return files.map {
            var str = $0.absoluteString
            str = String(str.suffix(from: str.range(of: directory)!.lowerBound))
            // print(str)
            return str
        }
    }
    return []
}
