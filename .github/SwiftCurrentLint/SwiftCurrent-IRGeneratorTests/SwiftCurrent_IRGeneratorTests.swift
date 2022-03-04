//
//  SwiftCurrent_IRGeneratorTests.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 3/3/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Foundation
import XCTest

class SwiftCurrent_IRGeneratorTests: XCTestCase {
    static var packageSwiftDirectory: URL = {
        // ../../../ brings you to SwiftCurrent directory
        URL(fileURLWithPath: #file).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    }()

    lazy var generatorCommand: String = {
        "\(Self.packageSwiftDirectory.path)/.build/*/debug/SwiftCurrent_IRGenerator"
    }()

    override class func setUp() {
        XCTAssertNoThrow(try shell("rm -rf \(Self.packageSwiftDirectory.path)/.build/*/debug"))
        XCTAssert(try shell("cd \(Self.packageSwiftDirectory.path) && swift build --product=SwiftCurrent_IRGenerator").contains("Build complete!"))
    }

    func testSingleDecodableStruct() throws {
        let source = """
        struct Foo: WorkflowDecodable { }
        """

        let output = try shell("\(generatorCommand) \"\(source)\"")
        let IR = try JSONDecoder().decode([IRType].self, from: XCTUnwrap(output.data(using: .utf8)))

        XCTAssertEqual(IR.count, 1)
        XCTAssertEqual(IR.first?.name, "Foo")
    }

    func testSingleDecodableClass() throws {
        let source = """
        class Foo: WorkflowDecodable { }
        """

        let output = try shell("\(generatorCommand) \"\(source)\"")
        let IR = try JSONDecoder().decode([IRType].self, from: XCTUnwrap(output.data(using: .utf8)))

        XCTAssertEqual(IR.count, 1)
        XCTAssertEqual(IR.first?.name, "Foo")
    }

    func testMultipleMixedStructsAndClasses() throws {
        let source = """
        class Foo: WorkflowDecodable { }
        struct Bar: WorkflowDecodable { }
        """

        let output = try shell("\(generatorCommand) \"\(source)\"")
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

        let output = try shell("\(generatorCommand) \"\(source)\"")
        let IR = try JSONDecoder().decode([IRType].self, from: XCTUnwrap(output.data(using: .utf8)))

        XCTAssertEqual(IR.count, 1)
        XCTAssertEqual(IR.first?.name, "Foo")
    }

    func testSingleLayerOfIndirection() throws {
        let source = """
        protocol Foo: WorkflowDecodable { }
        struct Bar: Foo { }
        """

        let output = try shell("\(generatorCommand) \"\(source)\"")
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

        let output = try shell("\(generatorCommand) \"\(source)\"")
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

        let output = try shell("\(generatorCommand) \"\(source)\"")
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

        let output = try shell("\(generatorCommand) \"\(source)\"")
        let IR = try JSONDecoder().decode([IRType].self, from: XCTUnwrap(output.data(using: .utf8)))

        XCTAssertEqual(IR.count, 1)
        XCTAssertEqual(IR.first?.name, "Foo.Bar.Baz")
    }

    func testConformanceViaExtension() throws {
        let source = """
        struct Foo { }

        extension Foo: WorkflowDecodable { }
        """

        let output = try shell("\(generatorCommand) \"\(source)\"")
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

        let output = try shell("\(generatorCommand) \"\(source)\"")
        let IR = try JSONDecoder().decode([IRType].self, from: XCTUnwrap(output.data(using: .utf8)))

        XCTAssertEqual(IR.count, 1)
        XCTAssertEqual(IR.first?.name, "Foo.Bar")
    }

    func testPerformance_WithASingleType() throws {
        let source = """
        struct Foo: WorkflowDecodable { }
        """
        measure {
            _ = try? shell("\(generatorCommand) \"\(source)\"")
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
                .map(String.init(describing:))
                .filter { _ in Bool.random() }
                .joined()
            return Structure(name: name, type: nominalType)
        }
        let typeDefs = (1...1000).map { _ -> String in
            let type = generateType()
            return "\(type.type) \(type.name): WorkflowDecodable { }"
        }
        let source = typeDefs.joined()
        measure {
            _ = try? shell("\(generatorCommand) \"\(source)\"")
        }
    }
}

struct IRType: Decodable {
    let name: String
}

@discardableResult fileprivate func shell(_ command: String) throws -> String {
    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.executableURL = URL(fileURLWithPath: "/bin/zsh")

    try task.run()
    task.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!

    return output
}
