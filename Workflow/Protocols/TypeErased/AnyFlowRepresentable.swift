//
//  AnyFlowRepresentable.swift
//  Workflow
//
//  Created by Tyler Thompson on 8/25/19.
//  Copyright © 2019 Tyler Tompson. All rights reserved.
//

import Foundation
public protocol AnyFlowRepresentable {
    var preferredLaunchStyle:PresentationType { get }
    var workflow:Workflow? { get set }
    var callback:((Any?) -> Void)? { get set }
    
    func erasedShouldLoad(with args:Any?) -> Bool
    static func instance() -> AnyFlowRepresentable
}
