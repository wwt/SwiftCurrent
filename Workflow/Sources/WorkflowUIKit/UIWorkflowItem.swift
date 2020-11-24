//
//  UIWorkflowItem.swift
//  Workflow
//
//  Created by Tyler Thompson on 8/29/19.
//  Copyright © 2019 Tyler Tompson. All rights reserved.
//

import Foundation
import UIKit
import Workflow

/**
 UIWorkflowItem: A subclass of UIViewController designed for convenience. This does **NOT** have to be used, it simply removes some of the overhead that normally comes with a FlowRepresentable.
 
 ### Examples:
 ```swift
 class SomeFlowRepresentable: UIWorkflowItem<String> { //must take in a string, or will not load
     var name:String?
 }
 extension SomeFlowRepresentable: FlowRepresentable {
     func shouldLoad(with name:String) {
         self.name = name
         return true
     }
     static func instance() -> AnyFlowRepresentable {
         return SomeFlowRepresentable()
     }
 }
 ```
 
 ### Discussion:
 If you would like the same convenience for other UIKit types this class is very straightforward to create:
 ```
 open class UITableViewWorkflowItem<I>: UITableViewController {
     public var callback: ((Any?) -> Void)?
 
     public typealias WorkflowInput = I
 
     public weak var workflow: Workflow?
 }
 ```
 */

open class UIWorkflowItem<I, O>: UIViewController {
    public var proceedInWorkflowStorage: ((Any?) -> Void)?
    
    public typealias WorkflowInput = I
    public typealias WorkflowOutput = O
    
    public weak var workflow: AnyWorkflow?
}
