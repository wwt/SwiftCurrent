//
//  FlowRepresentable.swift
//  Workflow
//
//  Created by Tyler Thompson on 8/25/19.
//  Copyright © 2019 Tyler Tompson. All rights reserved.
//

import Foundation

public protocol FlowRepresentable: AnyFlowRepresentable {
    associatedtype IntakeType
    
    func shouldLoad(with args:IntakeType) -> Bool
}

public extension FlowRepresentable {
    func erasedShouldLoad(with args:Any?) -> Bool {
        guard let cast = args as? IntakeType else { return false }
        return shouldLoad(with: cast)
    }
    
    func proceedInWorkflow(_ args:Any? = nil) {
        callback?(args)
    }
}
