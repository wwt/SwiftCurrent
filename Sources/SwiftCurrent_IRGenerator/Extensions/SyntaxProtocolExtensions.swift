// swiftlint:disable:this file_name
//  SyntaxProtocolExtensions.swift
//  SwiftCurrent
//
//  Created by Morgan Zellers on 3/8/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Foundation
import SwiftSyntax

protocol CommonSyntax: SyntaxProtocol {
    var inheritanceClause: SwiftSyntax.TypeInheritanceClauseSyntax? { get set }
    var name: String { get }
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
