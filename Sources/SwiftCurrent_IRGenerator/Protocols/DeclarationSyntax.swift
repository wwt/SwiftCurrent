//
//  SyntaxProtocolExtensions.swift
//  SwiftCurrent
//
//  Created by Morgan Zellers on 3/8/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Foundation
import SwiftSyntax

protocol DeclarationSyntax: SyntaxProtocol {
    var inheritanceClause: SwiftSyntax.TypeInheritanceClauseSyntax? { get set }
    var name: String { get }
}

extension ClassDeclSyntax: DeclarationSyntax {
    var name: String { identifier.text }
}

extension EnumDeclSyntax: DeclarationSyntax {
    var name: String { identifier.text }
}

extension StructDeclSyntax: DeclarationSyntax {
    var name: String { identifier.text }
}

extension ProtocolDeclSyntax: DeclarationSyntax {
    var name: String { identifier.text }
}

extension ExtensionDeclSyntax: DeclarationSyntax {
    var name: String { "\(extendedType)" }
}
