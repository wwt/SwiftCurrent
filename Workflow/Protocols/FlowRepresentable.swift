//
//  FlowRepresentable.swift
//  Workflow
//
//  Created by Tyler Thompson on 8/25/19.
//  Copyright © 2019 Tyler Tompson. All rights reserved.
//

import Foundation

/**
 FlowRepresentable: A typed version of 'AnyFlowRepresentable'. Use this on views that you want to add to a workflow.
 
 Examples:
 ```swift
 class SomeViewController: UIViewController, FlowRepresentable {
     typealias IntakeType = String
 
     weak var workflow: Workflow?
 
     var callback: ((Any?) -> Void)?
 
     static func instance() -> AnyFlowRepresentable {
         return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SomeViewController") as! SomeViewController
     }
 
     func shouldLoad(with args: String) -> Bool {
         return true
     }
 }
 ```
 
 ### Discussion:
 It's important to make sure your FlowRepresentable is not dependent on other views. It's okay to specify that a certain kind of data needs to be passed in, but keep your views from knowing what came before or what's likely to come after. In that way you'll end up with pieces of a workflow that can be moved, or put into multiple places with ease. Notice the 'Instance' method. This is needed for Workflow to create a new instance of your view. Make sure that this function always returns a new, unique instance of your class. Note that this is still accomplishable whether the view is created programmatically or in a storyboard.
 */

public protocol FlowRepresentable: AnyFlowRepresentable {
    ///IntakeType: The data type required to be passed to your FlowRepresentable (use `Any?` if you don't care)
    associatedtype IntakeType

    /// shouldLoad: A method indicating whether it makes sense for this view to load in a workflow
    /// - Parameter args: Note you can rename this in your implementation if 'args' doesn't make sense. If a previous item in a workflow tries to pass a type that does not match `shouldLoad` will automatically be false, and this method will not be called.
    /// - Returns: Bool
    /// - Note: This method is called *before* your view loads. Do not attempt to do any UI work in this method. This is however a good place to set up data on your view.
    mutating func shouldLoad(with args:IntakeType) -> Bool
    mutating func shouldLoad() -> Bool
}

public extension FlowRepresentable {
    mutating func shouldLoad() -> Bool {
        return true
    }
}

public extension FlowRepresentable where IntakeType == Never {
    mutating func erasedShouldLoad(with args: Any?) -> Bool {
        return shouldLoad()
    }
    
    mutating func shouldLoad(with args: Never) -> Bool { }
    
    /// shouldLoad: A method indicating whether it makes sense for this view to load in a workflow
    /// - Returns: Bool
    /// - Note: This particular version of shouldLoad is only available when your `IntakeType` is `Never`, indicating you do not care about data passed to this view
    mutating func shouldLoad() -> Bool {
        return true
    }
}

public extension FlowRepresentable {
    mutating func erasedShouldLoad(with args:Any?) -> Bool {
        guard let cast = args as? IntakeType else { return false }
        return shouldLoad(with: cast)
    }
    
    func proceedInWorkflow(_ args:Any? = nil) {
        proceedInWorkflow?(args)
    }
}
