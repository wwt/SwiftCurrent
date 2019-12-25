//
//  BasePresenter.swift
//  Workflow
//
//  Created by Tyler Thompson on 8/29/19.
//  Copyright © 2019 Tyler Tompson. All rights reserved.
//

import Foundation
open class BasePresenter<T> {
    public typealias ViewType = T
    
    required public init() {
        //Meant to be called from subclasses, but presenters *must* contain an empty initializer
    }
}
