//
//  FileVisitor.swift
//  SwiftCurrent
//
//  Created by Morgan Zellers on 1/11/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//

//
// FileVisitor.swift
// Part of Sitrep, a tool for analyzing Swift projects.
//
// Copyright (c) 2020 Hacking with Swift
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See LICENSE for license information
//

import Foundation
import SwiftSyntax

/// This does the main job of parsing a file into a structure we can analyze.
/// It organizes the code into a tree of nodes, with any top-level code
/// being placed into properties.
class FileVisitor: SyntaxVisitor {
    /// The top level of our tree, the file itself
    var rootNode = Node()

    /// All global comments from this file
    var comments = [Comment]()

    /// An array of the imports this file uses
    var imports = [String]()

    /// The raw code for this file
    var body = ""

    /// The code for this file, minus comments and whitespace
    var strippedBody = ""

    /// The node that is currently active, such as a class or  function.
    lazy var current: Node? = {
        rootNode
    }()

    /// Triggered on entering a class
    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        create(.class, from: node)
        return .visitChildren
    }

    /// Triggered on exiting a class; moves back up the tree
    override func visitPost(_ node: ClassDeclSyntax) {
        current = current?.parent
    }

    /// Triggered on entering an enum
    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        create(.enum, from: node)
        return .visitChildren
    }

    /// Triggered on exiting an enum; moves back up the tree
    override func visitPost(_ node: EnumDeclSyntax) {
        current = current?.parent
    }

    /// Triggered on exiting a single enum case
    override func visitPost(_ node: EnumCaseElementSyntax) {
        current?.cases.append(node.identifier.text)
    }

    /// Triggered on entering an extension
    override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        create(.extension, from: node)
        return .visitChildren
    }

    /// Triggered on exiting an extension; moves back up the tree
    override func visitPost(_ node: ExtensionDeclSyntax) {
        current = current?.parent
    }

    /// Triggered on entering a function
    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        var throwingStatus = Function.ThrowingStatus.unknown
        var isStatic = false
        var returnType = ""

        // Examine this function's modifiers to figure out whether it's static
        if let modifiers = node.modifiers {
            for modifier in modifiers {
                let modifierText = modifier.withoutTrivia().name.text

                if modifierText == "static" || modifierText == "class" {
                    isStatic = true
                }
            }
        }

        // Copy in the throwing status
        if let throwsKeyword = node.signature.throwsOrRethrowsKeyword {
            if let throwsOrRethrows = Function.ThrowingStatus(rawValue: throwsKeyword.text) {
                throwingStatus = throwsOrRethrows
            }
        } else {
            throwingStatus = .none
        }

        let name = node.identifier.text

        // Flatten the list of parameters for easier storage
        let parameters = node.signature.input.parameterList.compactMap { $0.firstName?.text }

        // If we have a return type, copy it here
        if let nodeReturnType = node.signature.output?.returnType {
            returnType = "\(nodeReturnType)"
        }

        let newObject = Function(name: name, parameters: parameters, isStatic: isStatic, throwingStatus: throwingStatus, returnType: returnType)

        // Move one level deeper in our tree
        newObject.parent = current
        current?.functions.append(newObject)
        current = newObject

        return .visitChildren
    }

    /// Triggered on exiting a function; moves back up the tree
    override func visitPost(_ node: FunctionDeclSyntax) {
        current = current?.parent
    }

    /// Triggered on entering an identifer pattern – the part of a variable that contains its name
    override func visit(_ node: IdentifierPatternSyntax) -> SyntaxVisitorContinueKind {
        current?.variables.append(node.identifier.text)
        return .visitChildren
    }

    /// Triggered on finding an import statement
    override func visit(_ node: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
        let importName = node.path.description
        imports.append(importName)
        return .visitChildren
    }

    /// Triggered on entering a protocol
    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        create(.protocol, from: node)
        return .visitChildren
    }

    /// Triggered on exiting a protocol; moves back up the tree
    override func visitPost(_ node: ProtocolDeclSyntax) {
        current = current?.parent
    }

    /// Triggered on entering a file
    override func visit(_ node: SourceFileSyntax) -> SyntaxVisitorContinueKind {
        comments = comments(for: node._syntaxNode)
        body = "\(node)"
        strippedBody = body.removingDuplicateLineBreaks()
        return .visitChildren
    }

    /// Triggered on entering a struct
    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        create(.struct, from: node)
        return .visitChildren
    }

    /// Triggered on exiting a struct; moves back up the tree
    override func visitPost(_ node: StructDeclSyntax) {
        current = current?.parent
    }

    /// Converts trivia to comments
    func extractComments(from trivia: TriviaPiece) -> Comment? {
        switch trivia {
        case .lineComment(let text), .blockComment(let text):
            return Comment(type: .regular, text: text)
        case .docLineComment(let text), .docBlockComment(let text):
            return Comment(type: .documentation, text: text)
        default:
            return nil
        }
    }

    /// Used for creating classes, structs, extensions, protocols, and structs
    func create(_ type: Type.ObjectType, from node: CommonSyntax) {
        let nodeBody = "\(node)"

        // THIS CODE IS DISABLED RIGHT NOW.
        // It was designed to put all type code through a syntax parser
        // so that we could accurately remove all comments.
        // However, this is slow – if this is to be re-enabled we need to
        // make it optional.
//        let nodeBodyStripped: String
//        do {
//            let parsedBody = try SyntaxParser.parse(source: nodeBody)
//            let strippedBody = BodyStripper().visit(parsedBody)
//            nodeBodyStripped = "\(strippedBody)"
//        } catch {
//            nodeBodyStripped = ""
//        }
        // Just use an empty string in place of the commented out code above.
        let nodeBodyStripped = ""

        let inheritanceClause = node.inheritanceClause?.inheritedTypeCollection.map {
            "\($0.typeName)".trimmingCharacters(in: .whitespacesAndNewlines)
        } ?? []

        let name = node.name
            .trimmingCharacters(in: .whitespaces)

        let newObject = Type(type: type, name: name, inheritance: inheritanceClause, comments: comments(for: node._syntaxNode), body: nodeBody, strippedBody: nodeBodyStripped)

        newObject.parent = current
        current?.types.append(newObject)
        current = newObject
    }

    /// Reads all leading trivia for a node, discards everything that isn't a comment, then
    /// sends back an array of what's left.
    func comments(for node: Syntax) -> [Comment] {
        var comments = [Comment]()

        if let extractedComments = node.leadingTrivia?.compactMap(extractComments) {
            comments = extractedComments
        }

        return comments
    }
}

/// The handful of common things we use across types
protocol CommonSyntax: SyntaxProtocol {
    var inheritanceClause: SwiftSyntax.TypeInheritanceClauseSyntax? { get set }
    var name: String { get }
    var leadingTrivia: SwiftSyntax.Trivia? { get set }
    func withoutTrivia() -> Self
}

/// Returns the class's identifier text as its name
extension ClassDeclSyntax: CommonSyntax {
    var name: String { identifier.text }
}

/// Returns the enum's identifier text as its name
extension EnumDeclSyntax: CommonSyntax {
    var name: String { identifier.text }
}

/// Returns the struct's identifier text as its name
extension StructDeclSyntax: CommonSyntax {
    var name: String { identifier.text }
}

/// Returns the protocol's identifier text as its name
extension ProtocolDeclSyntax: CommonSyntax {
    var name: String { identifier.text }
}

/// Returns the extension's identifier text as its name
extension ExtensionDeclSyntax: CommonSyntax {
    var name: String { "\(extendedType)" }
}

/// The root class for the types we can scan in code
class Node: Encodable {
    /// The keys we need to write for debug output
    private enum CodingKeys: CodingKey {
        case cases, functions, types, variables
    }

    /// The parent of this node, so we can navigate back up the tree
    weak var parent: Node?

    /// All the variables defined by this node
    var variables = [String]()

    /// All the types defined inside this node
    var types = [Type]()

    /// All the methods defined inside this node
    var functions = [Function]()

    /// All the enum cases defined inside this node
    var cases = [String]()
}

/// One data type from our code, with a very loose definition of "type"
class Type: Node, Decodable {
    /// All the data we want to be able to write out for debugging purposes
    private enum CodingKeys: CodingKey {
        case name, type, inheritance, comments, body, strippedBody
    }

    /// The list of "types" we support
    enum ObjectType: String, Codable {
        case `class`, `enum`, `extension`, `protocol`, `struct`
    }

    /// The name of the type, eg `ViewController`
    let name: String

    /// The underlying type, e.g. class or struct
    let type: ObjectType

    /// The inheritance clauses attached to this type, including protocol conformances
    let inheritance: [String]

    /// An array of comments that describe this type
    let comments: [Comment]

    /// The raw source code for this type
    let body: String

    /// The source code for this type, minus empty lines and comments
    let strippedBody: String

    /// Creates an instance of Type
    init(type: ObjectType, name: String, inheritance: [String], comments: [Comment], body: String, strippedBody: String) {
        self.type = type
        self.name = name
        self.inheritance = inheritance
        self.comments = comments
        self.body = body.trimmingCharacters(in: .whitespacesAndNewlines)
        self.strippedBody = body.removingDuplicateLineBreaks()
    }
}

/// One comment, regular or documentation, from the code
struct Comment: Codable {
    enum CommentType: String, Codable {
        case regular, documentation
    }

    var type: CommentType
    var text: String
}


/// Represents one function or method in our parsed code.
class Function: Node {
    /// Stores whether the function is throwing or not
    enum ThrowingStatus: String {
        case none, `throws`, `rethrows`, unknown
    }

    /// The keys we need to write for debug output
    private enum CodingKeys: CodingKey {
        case name, parameters, isStatic, throwingStatus, returnType
    }

    /// The function name
    let name: String

    /// The parameter names received by the function
    let parameters: [String]

    /// Whether the function is static or not
    let isStatic: Bool

    /// Whether the function throws errors or not
    let throwingStatus: ThrowingStatus

    /// The data type returned by the function
    let returnType: String

    /// Creates an instance of Function using all its parameters
    init(name: String, parameters: [String], isStatic: Bool, throwingStatus: ThrowingStatus, returnType: String) {
        self.name = name
        self.parameters = parameters
        self.isStatic = isStatic
        self.throwingStatus = throwingStatus
        self.returnType = returnType
    }

    /// Encodes the function, so we can produce debug output
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(parameters, forKey: .parameters)
        try container.encode(isStatic, forKey: .isStatic)
        try container.encode(throwingStatus.rawValue, forKey: .throwingStatus)
        try container.encode(returnType, forKey: .returnType)
    }
}


extension String {
    /// An array of lines in this string, created by splitting on line breaks
    var lines: [String] {
        components(separatedBy: "\n")
    }

    /// BodyStripper removes all comments and most whitespace, but it doesn't collapse multiple
    /// repeating instances do line breaks. This method does that clean up work.
    func removingDuplicateLineBreaks() -> String {
        let strippedLines = self.lines
        let nonEmptyLines = strippedLines.filter { $0.isEmpty == false }
        return nonEmptyLines.joined(separator: "\n")
    }
}
