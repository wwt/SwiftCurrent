//
//  SwiftCurrent_TypeRegistryGeneratorTests.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 3/29/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Foundation
import ShellOut
import SourceKittenFramework
import XCTest

final class SwiftCurrent_TypeRegistryGeneratorTests: XCTestCase {
    static var packageSwiftDirectory: URL = {
        // ../../../ brings you to SwiftCurrent directory
        URL(fileURLWithPath: #file).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    }()

    lazy var generatorCommand: String = {
        "\(Self.packageSwiftDirectory.path)/.build/*/debug/SwiftCurrent_CLI generate type-registry"
    }()

    override class func setUp() {
        XCTAssertNoThrow(try shellOut(to: "rm -rf \(Self.packageSwiftDirectory.path)/.build/*/debug"))
        XCTAssert(try shellOut(to: "cd \(Self.packageSwiftDirectory.path) && swift build --product=SwiftCurrent_CLI").contains("Build complete!"))
    }

    func testSingleDecodableStruct() throws {
        let source = """
        struct Foo: WorkflowDecodable { }
        """

        let output = try shellOut(to: "\(generatorCommand) \"\(source)\"")
        let structure = try JSONDecoder().decode(SyntaxStructure.self, from: XCTUnwrap(Structure(file: File(contents: output)).description.data(using: .utf8)))

        try assertTypeRegistryStructExists(on: structure)
        try assertTypesArrayExistsOnRegistry(in: structure)

        let actualTypes = try getTypeArrayLiteralFromRegistry(in: structure, fromCode: output)

        XCTAssertEqual(actualTypes?.count, 1)
        XCTAssertEqual(actualTypes?.first, "Foo.self")
    }

    func testSingleDecodableClass() throws {
        let source = """
        class Foo: WorkflowDecodable { }
        """

        let output = try shellOut(to: "\(generatorCommand) \"\(source)\"")
        let structure = try JSONDecoder().decode(SyntaxStructure.self, from: XCTUnwrap(Structure(file: File(contents: output)).description.data(using: .utf8)))

        try assertTypeRegistryStructExists(on: structure)
        try assertTypesArrayExistsOnRegistry(in: structure)

        let actualTypes = try getTypeArrayLiteralFromRegistry(in: structure, fromCode: output)

        XCTAssertEqual(actualTypes?.count, 1)
        XCTAssertEqual(actualTypes?.first, "Foo.self")
    }

    func testMultipleMixedStructsAndClasses() throws {
        let source = """
        class Foo: WorkflowDecodable { }
        struct Bar: WorkflowDecodable { }
        """

        let output = try shellOut(to: "\(generatorCommand) \"\(source)\"")
        let structure = try JSONDecoder().decode(SyntaxStructure.self, from: XCTUnwrap(Structure(file: File(contents: output)).description.data(using: .utf8)))

        try assertTypeRegistryStructExists(on: structure)
        try assertTypesArrayExistsOnRegistry(in: structure)

        let actualTypes = try getTypeArrayLiteralFromRegistry(in: structure, fromCode: output)?.sorted(by: <)

        XCTAssertEqual(actualTypes?.count, 2)
        XCTAssertEqual(actualTypes?.first, "Bar.self")
        XCTAssertEqual(actualTypes?.last, "Foo.self")
    }

    func testOnlyDetectWorkflowDecodableTypes() throws {
        let source = """
        struct Foo: WorkflowDecodable { }
        struct Bar { }
        """

        let output = try shellOut(to: "\(generatorCommand) \"\(source)\"")
        let structure = try JSONDecoder().decode(SyntaxStructure.self, from: XCTUnwrap(Structure(file: File(contents: output)).description.data(using: .utf8)))

        try assertTypeRegistryStructExists(on: structure)
        try assertTypesArrayExistsOnRegistry(in: structure)

        let actualTypes = try getTypeArrayLiteralFromRegistry(in: structure, fromCode: output)

        XCTAssertEqual(actualTypes?.count, 1)
        XCTAssertEqual(actualTypes?.first, "Foo.self")
    }

    func testSingleLayerOfIndirection() throws {
        let source = """
        protocol Foo: WorkflowDecodable { }
        struct Bar: Foo { }
        """

        let output = try shellOut(to: "\(generatorCommand) \"\(source)\"")
        let structure = try JSONDecoder().decode(SyntaxStructure.self, from: XCTUnwrap(Structure(file: File(contents: output)).description.data(using: .utf8)))

        try assertTypeRegistryStructExists(on: structure)
        try assertTypesArrayExistsOnRegistry(in: structure)

        let actualTypes = try getTypeArrayLiteralFromRegistry(in: structure, fromCode: output)

        XCTAssertEqual(actualTypes?.count, 1)
        XCTAssertEqual(actualTypes?.first, "Bar.self")
    }

    func testMultipleLayersOfIndirection() throws {
        let source = """
        protocol Foo: WorkflowDecodable { }
        protocol Bar: Foo { }
        struct Baz: Bar { }
        """

        let output = try shellOut(to: "\(generatorCommand) \"\(source)\"")
        let structure = try JSONDecoder().decode(SyntaxStructure.self, from: XCTUnwrap(Structure(file: File(contents: output)).description.data(using: .utf8)))

        try assertTypeRegistryStructExists(on: structure)
        try assertTypesArrayExistsOnRegistry(in: structure)

        let actualTypes = try getTypeArrayLiteralFromRegistry(in: structure, fromCode: output)

        XCTAssertEqual(actualTypes?.count, 1)
        XCTAssertEqual(actualTypes?.first, "Baz.self")
    }

    func testTonsOfLayersOfIndirection() throws {
        let source = """
        protocol Foo: WorkflowDecodable { }
        protocol Bar: Foo { }
        protocol Bat: Bar { }
        struct Baz: Bat { }
        """

        let output = try shellOut(to: "\(generatorCommand) \"\(source)\"")
        let structure = try JSONDecoder().decode(SyntaxStructure.self, from: XCTUnwrap(Structure(file: File(contents: output)).description.data(using: .utf8)))

        try assertTypeRegistryStructExists(on: structure)
        try assertTypesArrayExistsOnRegistry(in: structure)

        let actualTypes = try getTypeArrayLiteralFromRegistry(in: structure, fromCode: output)

        XCTAssertEqual(actualTypes?.count, 1)
        XCTAssertEqual(actualTypes?.first, "Baz.self")
    }

    func testSingleLayerOfNesting() throws {
        let source = """
        enum Foo {
            struct Bar: WorkflowDecodable { }
        }
        """

        let output = try shellOut(to: "\(generatorCommand) \"\(source)\"")
        let structure = try JSONDecoder().decode(SyntaxStructure.self, from: XCTUnwrap(Structure(file: File(contents: output)).description.data(using: .utf8)))

        try assertTypeRegistryStructExists(on: structure)
        try assertTypesArrayExistsOnRegistry(in: structure)

        let actualTypes = try getTypeArrayLiteralFromRegistry(in: structure, fromCode: output)

        XCTAssertEqual(actualTypes?.count, 1)
        XCTAssertEqual(actualTypes?.first, "Foo.Bar.self")
    }

    func testMultipleLayersOfNesting() throws {
        let source = """
        enum Foo {
            struct Bar {
                class Baz: WorkflowDecodable { }
            }
        }
        """

        let output = try shellOut(to: "\(generatorCommand) \"\(source)\"")
        let structure = try JSONDecoder().decode(SyntaxStructure.self, from: XCTUnwrap(Structure(file: File(contents: output)).description.data(using: .utf8)))

        try assertTypeRegistryStructExists(on: structure)
        try assertTypesArrayExistsOnRegistry(in: structure)

        let actualTypes = try getTypeArrayLiteralFromRegistry(in: structure, fromCode: output)

        XCTAssertEqual(actualTypes?.count, 1)
        XCTAssertEqual(actualTypes?.first, "Foo.Bar.Baz.self")
    }

    func testTonsOfLayersOfNesting() throws {
        let source = """
        enum Foo {
            struct Bar {
                class Baz {
                    struct Bat: WorkflowDecodable { }
                }
            }
        }
        """

        let output = try shellOut(to: "\(generatorCommand) \"\(source)\"")
        let structure = try JSONDecoder().decode(SyntaxStructure.self, from: XCTUnwrap(Structure(file: File(contents: output)).description.data(using: .utf8)))

        try assertTypeRegistryStructExists(on: structure)
        try assertTypesArrayExistsOnRegistry(in: structure)

        let actualTypes = try getTypeArrayLiteralFromRegistry(in: structure, fromCode: output)

        XCTAssertEqual(actualTypes?.count, 1)
        XCTAssertEqual(actualTypes?.first, "Foo.Bar.Baz.Bat.self")
    }

    func testConformanceViaExtension() throws {
        let source = """
        struct Foo { }

        extension Foo: WorkflowDecodable { }
        """

        let output = try shellOut(to: "\(generatorCommand) \"\(source)\"")
        let structure = try JSONDecoder().decode(SyntaxStructure.self, from: XCTUnwrap(Structure(file: File(contents: output)).description.data(using: .utf8)))

        try assertTypeRegistryStructExists(on: structure)
        try assertTypesArrayExistsOnRegistry(in: structure)

        let actualTypes = try getTypeArrayLiteralFromRegistry(in: structure, fromCode: output)

        XCTAssertEqual(actualTypes?.count, 1)
        XCTAssertEqual(actualTypes?.first, "Foo.self")
    }

    func testConformanceViaExtension_WithNesting() throws {
        let source = """
        enum Foo {
            struct Bar { }
        }

        extension Foo.Bar: WorkflowDecodable { }
        """

        let output = try shellOut(to: "\(generatorCommand) \"\(source)\"")
        let structure = try JSONDecoder().decode(SyntaxStructure.self, from: XCTUnwrap(Structure(file: File(contents: output)).description.data(using: .utf8)))

        try assertTypeRegistryStructExists(on: structure)
        try assertTypesArrayExistsOnRegistry(in: structure)

        let actualTypes = try getTypeArrayLiteralFromRegistry(in: structure, fromCode: output)

        XCTAssertEqual(actualTypes?.count, 1)
        XCTAssertEqual(actualTypes?.first, "Foo.Bar.self")
    }

    func testGeneratedCodeContainsConvenienceExtensions() throws {
        let source = """
        struct Foo: WorkflowDecodable { }
        """

        let output = try shellOut(to: "\(generatorCommand) \"\(source)\"")
        let structure = try JSONDecoder().decode(SyntaxStructure.self, from: XCTUnwrap(Structure(file: File(contents: output)).description.data(using: .utf8)))

        try assertTypeRegistryStructExists(on: structure)
        try assertTypesArrayExistsOnRegistry(in: structure)

        XCTAssertEqual(structure.subStructure?.count, 2)
        guard let substructure = structure.subStructure, substructure.count == 2 else { return }
        let extensionStructure = substructure[1]

        XCTAssertEqual(extensionStructure.kind, "source.lang.swift.decl.extension")
        let functionStructure = extensionStructure.subStructure?.first

        XCTAssertNotNil(functionStructure, "expected function structure")
        XCTAssertEqual(functionStructure?.accessibility, "source.lang.swift.accessibility.public")
        XCTAssertEqual(functionStructure?.kind, "source.lang.swift.decl.function.method.instance")
        XCTAssertEqual(functionStructure?.name, "decodeWorkflow(from:)")

        let internalFunctionStructure = functionStructure?.subStructure
        XCTAssertNotNil(internalFunctionStructure, "expected parameter structure")
        XCTAssertEqual(internalFunctionStructure?.first?.kind, "source.lang.swift.decl.var.parameter")
        XCTAssertEqual(internalFunctionStructure?.first?.typeName, "Data")
        XCTAssertEqual(internalFunctionStructure?.last?.kind, "source.lang.swift.expr.call")
        XCTAssertEqual(internalFunctionStructure?.last?.name, "decodeWorkflow")

        let decodeWorkflowParameterStructure = internalFunctionStructure?.last?.subStructure
        XCTAssertNotNil(decodeWorkflowParameterStructure, "expected internal structure to decodeWorkflow call")
        XCTAssertEqual(decodeWorkflowParameterStructure?.first?.kind, "source.lang.swift.expr.argument")
        XCTAssertEqual(decodeWorkflowParameterStructure?.first?.name, "withAggregator")
        XCTAssertEqual(decodeWorkflowParameterStructure?.first?.subStructure?.first?.kind, "source.lang.swift.expr.call")
        XCTAssertEqual(decodeWorkflowParameterStructure?.first?.subStructure?.first?.name, "SwiftCurrentTypeRegistry")
        XCTAssertEqual(decodeWorkflowParameterStructure?.last?.kind, "source.lang.swift.expr.argument")
        XCTAssertEqual(decodeWorkflowParameterStructure?.last?.name, "from")
    }

    func testPerformance_WithASingleType() throws {
        let source = """
        struct Foo: WorkflowDecodable { }
        """
        measure {
            _ = try? shellOut(to: "\(generatorCommand) \"\(source)\"")
        }
    }

    func testPerformance_WithManyTypes() throws {
        struct Structure {
            let name: String
            let type: String
        }
        func generateType() -> Structure {
            let nominalType = ["struct", "enum", "class"].randomElement()!
            let name: String = (Unicode.Scalar("A").value...Unicode.Scalar("Z").value)
                .lazy
                .compactMap(Unicode.Scalar.init)
                .map(String.init)
                .filter { _ in Bool.random() }
                .joined()
            return Structure(name: name, type: nominalType)
        }
        var typeDefs: [String] = (1...1000).lazy.map { _ -> String in
            let type = generateType()
            return "\(type.type) \(type.name): WorkflowDecodable { }"
        }
            .uniqued()
            .map { $0 }

        if typeDefs.count < 1000 {
            (1...(1000 - typeDefs.count)).forEach {
                let type = generateType()
                typeDefs.append("\(type.type)\($0) \(type.name): WorkflowDecodable { }")
            }
        }

        let source = typeDefs.joined(separator: "\n")
        measure {
            if let output = try? shellOut(to: "\(generatorCommand) \"\(source)\""),
               let data = output.data(using: .utf8) {
                let IR = try? JSONDecoder().decode([IRType].self, from: data)
                XCTAssertEqual(IR?.count, 1000)
            } else {
                XCTFail("No output from shell")
            }
        }
    }
}

extension SwiftCurrent_TypeRegistryGeneratorTests {
    func assertTypeRegistryStructExists(on structure: SyntaxStructure) throws {
        XCTAssertEqual(structure.subStructure?.first?.kind, "source.lang.swift.decl.struct")
        XCTAssertEqual(structure.subStructure?.first?.accessibility, "source.lang.swift.accessibility.public")
        XCTAssertEqual(structure.subStructure?.first?.name, "SwiftCurrentTypeRegistry")
        XCTAssertEqual(structure.subStructure?.first?.inheritedTypes?.count, 1)
        XCTAssertEqual(structure.subStructure?.first?.inheritedTypes?.first?.name, "FlowRepresentableAggregator")
    }

    func assertTypesArrayExistsOnRegistry(in structure: SyntaxStructure) throws {
        guard let memberStructure = structure.subStructure?.first?.subStructure, memberStructure.count == 2 else {
            XCTFail("Incorrect member structure found for struct")
            return
        }

        XCTAssertEqual(memberStructure[0].accessibility, "source.lang.swift.accessibility.public")
        XCTAssertEqual(memberStructure[0].kind, "source.lang.swift.decl.var.instance")
        XCTAssertEqual(memberStructure[0].name, "types")
        XCTAssertEqual(memberStructure[0].typeName, "[WorkflowDecodable.self]")
        XCTAssertEqual(memberStructure[1].kind, "source.lang.swift.expr.array")

        memberStructure[1].elements?.forEach {
            XCTAssertEqual($0.kind, "source.lang.swift.structure.elem.expr")
        }
    }

    func getTypeArrayLiteralFromRegistry(in structure: SyntaxStructure, fromCode code: String) throws -> [String]? {
        guard let memberStructure = structure.subStructure?.first?.subStructure, memberStructure.count == 2 else {
            XCTFail("Incorrect member structure found for struct")
            return nil
        }
        return try memberStructure[1].elements?.map { element -> String in
            let offset = try XCTUnwrap(element.offset)
            let length = try XCTUnwrap(element.length)
            return String(code[code.index(code.startIndex, offsetBy: offset)..<code.index(code.startIndex, offsetBy: offset + length)])
        }
    }
}

struct SyntaxStructure: Codable {
    let accessibility: String?
    let attribute: String?
    let attributes: [SyntaxStructure]?
    let bodyLength: Int?
    let bodyOffset: Int?
    let diagnosticStage: String?
    let elements: [SyntaxStructure]?
    let inheritedTypes: [SyntaxStructure]?
    let kind: String?
    let length: Int?
    let name: String?
    let nameLength: Int?
    let nameOffset: Int?
    let offset: Int?
    let runtimeName: String?
    let subStructure: [SyntaxStructure]?
    let typeName: String?

    enum CodingKeys: String, CodingKey {
        case accessibility = "key.accessibility"
        case attribute = "key.attribute"
        case attributes = "key.attributes"
        case bodyLength = "key.bodylength"
        case bodyOffset = "key.bodyoffset"
        case diagnosticStage = "key.diagnostic_stage"
        case elements = "key.elements"
        case inheritedTypes = "key.inheritedtypes"
        case kind = "key.kind"
        case length = "key.length"
        case name = "key.name"
        case nameLength = "key.namelength"
        case nameOffset = "key.nameoffset"
        case offset = "key.offset"
        case runtimeName = "key.runtime_name"
        case subStructure = "key.substructure"
        case typeName = "key.typename"
    }
}
