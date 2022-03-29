//
//  TypeRegistry.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 3/29/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Foundation
import ArgumentParser
import SwiftSyntax

struct TypeRegistry: ParsableCommand {
    fileprivate static let conformance: StaticString = "WorkflowDecodable"

    @Argument(help: "The path to a directory containing swift source files with types conforming to \(Self.conformance)")
    var pathOrSourceCode: Either<URL, String>

    mutating func run() throws {
        let irGenerator = IRGenerator()
        let files = try irGenerator.getFiles(from: pathOrSourceCode)

        let conformingTypes = irGenerator.findTypesConforming(to: "\(Self.conformance)", in: files).filter(\.isConcreteType)

        let types = conformingTypes.map { "\($0.name).self" }

        print(
            """
            import SwiftCurrent

            public struct SwiftCurrentTypeRegistry: FlowRepresentableAggregator {
                public var types: [WorkflowDecodable.self] = [\(types.joined(separator: ","))]
            }

            extension JSONDecoder {

            }

            extension DecodeWorkflow {

            }
            """
        )
    }
}
