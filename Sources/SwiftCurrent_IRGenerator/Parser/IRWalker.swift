//
//  IRWalker.swift
//  SwiftCurrent
//
//  Created by Morgan Zellers on 3/8/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Foundation
import SwiftSyntax

class IRWalker: SyntaxVisitor {
    var root = IRNode()
    var body = ""

    lazy var current: IRNode? = {
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

    override func visitPost(_ node: FunctionDeclSyntax) {
        current = current?.parent
    }

    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        create(.protocol, from: node)
        return .visitChildren
    }

    override func visitPost(_ node: ProtocolDeclSyntax) {
        current = current?.parent
    }

    override func visit(_ node: SourceFileSyntax) -> SyntaxVisitorContinueKind {
        body = "\(node)"
        return .visitChildren
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        create(.struct, from: node)
        return .visitChildren
    }

    override func visitPost(_ node: StructDeclSyntax) {
        current = current?.parent
    }

    func create(_ type: Type.ObjectType, from node: CommonSyntax) {
        let nodeBody = "\(node)"

        let inheritanceClause = node.inheritanceClause?.inheritedTypeCollection.map {
            "\($0.typeName)".trimmingCharacters(in: .whitespacesAndNewlines)
        } ?? []

        let name = node.name.trimmingCharacters(in: .whitespaces)
        let type = Type(type: type, name: name, inheritance: inheritanceClause, body: nodeBody)

        type.parent = current
        current?.types.append(type)
        current = type
    }
}
