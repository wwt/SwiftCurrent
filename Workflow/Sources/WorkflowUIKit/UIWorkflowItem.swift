//
//  UIWorkflowItem.swift
//  Workflow
//
//  Created by Tyler Thompson on 8/29/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import UIKit
import Workflow

/**
 UIWorkflowItem: A subclass of UIViewController designed for convenience. This does **NOT** have to be used, it simply removes some of the overhead that normally comes with a FlowRepresentable.
 
 ### Examples:
 ```swift
 class SomeFlowRepresentable: UIWorkflowItem<String>, FlowRepresentable { //must take in a string, or will not load
    var name:String
    init(with name: String) {
        self.name = name
    }
 }
 ```
 
 ### Discussion
 If you would like the same convenience for other UIKit types this class is very straightforward to create:
 ```
 open class UITableViewWorkflowItem<I, O>: UITableViewController {
     public typealias WorkflowInput = I
     public typealias WorkflowOutput = O

     public weak var _workflowPointer: AnyFlowRepresentable?
 }
 ```
 */

open class UIWorkflowItem<I, O>: UIViewController {
    public typealias WorkflowInput = I
    public typealias WorkflowOutput = O

    public weak var _workflowPointer: AnyFlowRepresentable?
}
