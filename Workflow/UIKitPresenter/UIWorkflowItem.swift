//
//  UIWorkflowItem.swift
//  Workflow
//
//  Created by Tyler Thompson on 8/29/19.
//  Copyright © 2019 Tyler Tompson. All rights reserved.
//

import Foundation
import UIKit

open class UIWorkflowItem<I>: UIViewController {
    public var callback: ((Any?) -> Void)?
    
    public typealias IntakeType = I
    
    public weak var workflow: Workflow?
    
    open var preferredLaunchStyle:PresentationType {
        return .default
    }
}
