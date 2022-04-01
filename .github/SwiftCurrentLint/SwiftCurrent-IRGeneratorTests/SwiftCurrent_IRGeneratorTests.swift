//
//  SwiftCurrent_IRGeneratorTests.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 3/3/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Foundation
import ShellOut
import Algorithms
import XCTest

class SwiftCurrent_IRGeneratorTests: XCTestCase {
    static var packageSwiftDirectory: URL = {
        // ../../../ brings you to SwiftCurrent directory
        URL(fileURLWithPath: #file).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    }()

    lazy var generatorCommand: String = {
        "\(Self.packageSwiftDirectory.path)/.build/*/debug/SwiftCurrent_CLI generate ir"
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
        let IR = try JSONDecoder().decode([IRType].self, from: XCTUnwrap(output.data(using: .utf8)))

        XCTAssertEqual(IR.count, 1)
        XCTAssertEqual(IR.first?.name, "Foo")
    }

    func testSingleDecodableClass() throws {
        let source = """
        class Foo: WorkflowDecodable { }
        """

        let output = try shellOut(to: "\(generatorCommand) \"\(source)\"")
        let IR = try JSONDecoder().decode([IRType].self, from: XCTUnwrap(output.data(using: .utf8)))

        XCTAssertEqual(IR.count, 1)
        XCTAssertEqual(IR.first?.name, "Foo")
    }

    func testMultipleMixedStructsAndClasses() throws {
        let source = """
        class Foo: WorkflowDecodable { }
        struct Bar: WorkflowDecodable { }
        """

        let output = try shellOut(to: "\(generatorCommand) \"\(source)\"")
        let IR = try JSONDecoder().decode([IRType].self, from: XCTUnwrap(output.data(using: .utf8)))
            .sorted { $0.name < $1.name }

        XCTAssertEqual(IR.count, 2)
        XCTAssertEqual(IR.first?.name, "Bar")
        XCTAssertEqual(IR.last?.name, "Foo")
    }

    func testOnlyDetectWorkflowDecodableTypes() throws {
        let source = """
        struct Foo: WorkflowDecodable { }
        struct Bar { }
        """

        let output = try shellOut(to: "\(generatorCommand) \"\(source)\"")
        let IR = try JSONDecoder().decode([IRType].self, from: XCTUnwrap(output.data(using: .utf8)))

        XCTAssertEqual(IR.count, 1)
        XCTAssertEqual(IR.first?.name, "Foo")
    }

    func testSingleLayerOfIndirection() throws {
        let source = """
        protocol Foo: WorkflowDecodable { }
        struct Bar: Foo { }
        """

        let output = try shellOut(to: "\(generatorCommand) \"\(source)\"")
        let IR = try JSONDecoder().decode([IRType].self, from: XCTUnwrap(output.data(using: .utf8)))

        XCTAssertEqual(IR.count, 1)
        XCTAssertEqual(IR.first?.name, "Bar")
    }

    func testMultipleLayersOfIndirection() throws {
        let source = """
        protocol Foo: WorkflowDecodable { }
        protocol Bar: Foo { }
        struct Baz: Bar { }
        """

        let output = try shellOut(to: "\(generatorCommand) \"\(source)\"")
        let IR = try JSONDecoder().decode([IRType].self, from: XCTUnwrap(output.data(using: .utf8)))

        XCTAssertEqual(IR.count, 1)
        XCTAssertEqual(IR.first?.name, "Baz")
    }

    func testSingleLayerOfNesting() throws {
        let source = """
        enum Foo {
            struct Bar: WorkflowDecodable { }
        }
        """

        let output = try shellOut(to: "\(generatorCommand) \"\(source)\"")
        let IR = try JSONDecoder().decode([IRType].self, from: XCTUnwrap(output.data(using: .utf8)))

        XCTAssertEqual(IR.count, 1)
        XCTAssertEqual(IR.first?.name, "Foo.Bar")
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
        let IR = try JSONDecoder().decode([IRType].self, from: XCTUnwrap(output.data(using: .utf8)))

        XCTAssertEqual(IR.count, 1)
        XCTAssertEqual(IR.first?.name, "Foo.Bar.Baz")
    }

    func testConformanceViaExtension() throws {
        let source = """
        struct Foo { }

        extension Foo: WorkflowDecodable { }
        """

        let output = try shellOut(to: "\(generatorCommand) \"\(source)\"")
        let IR = try JSONDecoder().decode([IRType].self, from: XCTUnwrap(output.data(using: .utf8)))

        XCTAssertEqual(IR.count, 1)
        XCTAssertEqual(IR.first?.name, "Foo")
    }

    func testConformanceViaExtension_WithNesting() throws {
        let source = """
        enum Foo {
            struct Bar { }
        }

        extension Foo.Bar: WorkflowDecodable { }
        """

        let output = try shellOut(to: "\(generatorCommand) \"\(source)\"")
        let IR = try JSONDecoder().decode([IRType].self, from: XCTUnwrap(output.data(using: .utf8)))

        XCTAssertEqual(IR.count, 1)
        XCTAssertEqual(IR.first?.name, "Foo.Bar")
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

struct IRType: Decodable {
    let name: String
}
