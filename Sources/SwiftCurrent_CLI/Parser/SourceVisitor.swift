//
//  SourceVisitor.swift
//  SwiftCurrent
//
//  Created by Morgan Zellers on 3/8/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Foundation
import SwiftSyntax

class SourceVisitor: SyntaxVisitor {
    var root = SyntaxNode()

    var current: SyntaxNode?

    override init() {
        current = root
    }

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

    override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        create(.extension, from: node)
        return .visitChildren
    }

    override func visitPost(_ node: ExtensionDeclSyntax) {
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
        .visitChildren
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        create(.struct, from: node)
        return .visitChildren
    }

    override func visitPost(_ node: StructDeclSyntax) {
        current = current?.parent
    }

    func create(_ nominalType: Declaration.NominalType, from node: DeclarationSyntax) {
        let inheritanceClause = node.inheritanceClause?.inheritedTypeCollection.map {
            "\($0.typeName)".trimmingCharacters(in: .whitespacesAndNewlines)
        } ?? []

        let name = node.name.trimmingCharacters(in: .whitespaces)
        let declaration = Declaration(nominalType: nominalType, name: name, inheritance: inheritanceClause)

        declaration.parent = current
        current?.declarations.append(declaration)
        current = declaration
    }
}
