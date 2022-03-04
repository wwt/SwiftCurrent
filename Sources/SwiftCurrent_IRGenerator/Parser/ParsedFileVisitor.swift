//
//  ParsedFileVisitor.swift
//  SwiftCurrent
//
//  Created by Morgan Zellers on 3/4/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Foundation
import SwiftSyntax

class ParsedFileVisitor: SyntaxVisitor {
    var root = Node()
    var comments = [Comment]()
    var imports = [String]()
    var body = ""
    var strippedBody = ""

    lazy var current: Node? = {
        root
    }()

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        create(.class, from: node)
        return .visitChildren
    }

    override func visitPost(_ node: ClassDeclSyntax) {
        current = current?.parent
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        create(.enum, from: node)
        return .visitChildren
    }

    override func visitPost(_ node: EnumDeclSyntax) {
        current = current?.parent
    }

    override func visitPost(_ node: EnumCaseElementSyntax) {
        current?.cases.append(node.identifier.text)
    }

    override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        create(.extension, from: node)
        return .visitChildren
    }

    override func visitPost(_ node: ExtensionDeclSyntax) {
        current = current?.parent
    }

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        var throwingStatus = Function.ThrowingStatus.unknown
        var isStatic = false
        var returnType = ""

        if let modifiers = node.modifiers {
            for modifier in modifiers {
                let modifierText = modifier.withoutTrivia().name.text

                if modifierText == "static" || modifierText == "class" {
                    isStatic = true
                }
            }
        }

        if let throwsKeyword = node.signature.throwsOrRethrowsKeyword {
            if let throwsOrRethrows = Function.ThrowingStatus(rawValue: throwsKeyword.text) {
                throwingStatus = throwsOrRethrows
            }
        } else {
            throwingStatus = .none
        }

        let name = node.identifier.text
        let parameters = node.signature.input.parameterList.compactMap { $0.firstName?.text }
        if let nodeReturnType = node.signature.output?.returnType {
            returnType = "\(nodeReturnType)"
        }

        let newObject = Function(name: name, parameters: parameters, isStatic: isStatic, throwingStatus: throwingStatus, returnType: returnType)
        newObject.parent = current
        current?.functions.append(newObject)
        current = newObject

        return .visitChildren
    }

    override func visitPost(_ node: FunctionDeclSyntax) {
        current = current?.parent
    }

    override func visit(_ node: IdentifierPatternSyntax) -> SyntaxVisitorContinueKind {
        current?.variables.append(node.identifier.text)
        return .visitChildren
    }

    override func visit(_ node: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
        let importName = node.path.description
        imports.append(importName)
        return .visitChildren
    }

    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        create(.protocol, from: node)
        return .visitChildren
    }

    override func visitPost(_ node: ProtocolDeclSyntax) {
        current = current?.parent
    }

    override func visit(_ node: SourceFileSyntax) -> SyntaxVisitorContinueKind {
        comments = comments(for: node._syntaxNode)
        body = "\(node)"
        strippedBody = body.removeDuplicateLineBreaks()
        return .visitChildren
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        create(.struct, from: node)
        return .visitChildren
    }

    override func visitPost(_ node: StructDeclSyntax) {
        current = current?.parent
    }

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

    func create(_ type: Type.ObjectType, from node: CommonSyntax) {
        let nodeBody = "\(node)"
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

    func comments(for node: Syntax) -> [Comment] {
        var comments = [Comment]()

        if let extractedComments = node.leadingTrivia?.compactMap(extractComments) {
            comments = extractedComments
        }

        return comments
    }
}

class Node: Encodable {
    private enum CodingKeys: CodingKey {
        case cases, functions, types, variables
    }

    weak var parent: Node?
    var variables = [String]()
    var types = [Type]()
    var functions = [Function]()
    var cases = [String]()
}

class Type: Node, Decodable {
    private enum CodingKeys: CodingKey {
        case name, type, inheritance, comments, body, strippedBody
    }

    enum ObjectType: String, Codable {
        case `class`, `enum`, `extension`, `protocol`, `struct`
    }

    let name: String
    let type: ObjectType
    let inheritance: [String]
    let comments: [Comment]
    let body: String
    let strippedBody: String

    init(type: ObjectType, name: String, inheritance: [String], comments: [Comment], body: String, strippedBody: String) {
        self.type = type
        self.name = name
        self.inheritance = inheritance
        self.comments = comments
        self.body = body.trimmingCharacters(in: .whitespacesAndNewlines)
        self.strippedBody = body.removeDuplicateLineBreaks()
    }
}

struct Comment: Codable {
    enum CommentType: String, Codable {
        case regular, documentation
    }

    var type: CommentType
    var text: String
}

class Function: Node {
    enum ThrowingStatus: String {
        case none, `throws`, `rethrows`, unknown
    }

    private enum CodingKeys: CodingKey {
        case name, parameters, isStatic, throwingStatus, returnType
    }

    let name: String
    let parameters: [String]
    let isStatic: Bool
    let throwingStatus: ThrowingStatus
    let returnType: String

    init(name: String, parameters: [String], isStatic: Bool, throwingStatus: ThrowingStatus, returnType: String) {
        self.name = name
        self.parameters = parameters
        self.isStatic = isStatic
        self.throwingStatus = throwingStatus
        self.returnType = returnType
    }

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

protocol CommonSyntax: SyntaxProtocol {
    var inheritanceClause: SwiftSyntax.TypeInheritanceClauseSyntax? { get set }
    var name: String { get }
    var leadingTrivia: SwiftSyntax.Trivia? { get set }
    func withoutTrivia() -> Self
}

extension String {
    var lines: [String] {
        components(separatedBy: "\n")
    }

    func removeDuplicateLineBreaks() -> String {
        let strippedLines = self.lines
        let nonEmptyLines = strippedLines.filter { $0.isEmpty == false }
        return nonEmptyLines.joined(separator: "\n")
    }
}

extension ClassDeclSyntax: CommonSyntax {
    var name: String { identifier.text }
}

extension EnumDeclSyntax: CommonSyntax {
    var name: String { identifier.text }
}

extension StructDeclSyntax: CommonSyntax {
    var name: String { identifier.text }
}

extension ProtocolDeclSyntax: CommonSyntax {
    var name: String { identifier.text }
}

extension ExtensionDeclSyntax: CommonSyntax {
    var name: String { "\(extendedType)" }
}
