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
        let irGenerator = IRGenerator()
        let files = try irGenerator.getFiles(from: pathOrSourceCode)

        let conformingTypes = irGenerator.findTypesConforming(to: "\(Self.conformance)", in: files)

        let encoded = try JSONEncoder().encode(conformingTypes.lazy.filter(\.isConcreteType))

        // this is actually preferred, if we can't encode to UTF8 something horribly unpredictably wrong happened, all we'd do is trap anyways
        // swiftlint:disable:next force_unwrapping
        let jsonString = String(data: encoded, encoding: .utf8)!
        print(jsonString)
    }
}
