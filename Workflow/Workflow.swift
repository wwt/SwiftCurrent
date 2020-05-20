//
//  Workflow.swift
//  Workflow
//
//  Created by Tyler Thompson on 8/26/19.
//  Copyright © 2019 Tyler Tompson. All rights reserved.
//

import Foundation

/**
 Workflow: A doubly linked list of AnyFlowRepresentable types. Can be used to create a user flow.
 
 Examples:
 ```swift
 let workflow:Workflow = [ SomeFlowRepresentableClass.self, SomeOtherFlowRepresentableClass.self ]
 let workflow = Workflow(SomeFlowRepresentableClass.self, SomeOtherFlowRepresentableClass.self)
 let workflow = Workflow()
                    .thenPresent(SomeFlowRepresentableClass.self)
                    .thenPResent(SomeOtherFlowRepresentableClass.self, presentationType: .navigationStack)
 ```

 ### Discussion:
 In a sufficiently complex application it may make sense to create a structure to hold onto all the workflows in an application.
 If you're using UIKit then you can use a 'magic' method on UIViewController like so:
 ```swift
 class MainViewController: UIViewController {
     @IBAction func launchFlow() {
         launchInto([ SomeFlowRepresentableClass.self,
                      SomeOtherFlowRepresentableClass.self ])
     }
 }
 ```
 */
public class Workflow: LinkedList<FlowRepresentableMetaData> {
    public typealias ArrayLiteralElement = AnyFlowRepresentable.Type
    internal var instances = LinkedList<AnyFlowRepresentable?>()
    internal var presenter:AnyPresenter?

    public var firstLoadedInstance:LinkedList<AnyFlowRepresentable?>.Element?
    
    public init() {
        super.init(nil)
    }
    
    override init(_ node: Element?) {
        super.init(node)
    }
    
    deinit {
        removeInstances()
        presenter = nil
    }
    
    /// thenPresent: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter staysInViewStack: An `ViewPersistance`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    public func thenPresent<F>(_ type:F.Type, presentationType:PresentationType = .default, staysInViewStack:@escaping @autoclosure () -> ViewPersistance = .default) -> Workflow where F: FlowRepresentable {
        let wf = Workflow(first)
        wf.append(FlowRepresentableMetaData(type,
                                            presentationType: presentationType,
                                            staysInViewStack: { _ in staysInViewStack() }))
        return wf
    }

    /// thenPresent: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter staysInViewStack: A closure taking in the generic type from the `FlowRepresentable` and returning a `ViewPersistance`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    public func thenPresent<F>(_ type:F.Type, presentationType:PresentationType = .default, staysInViewStack:@escaping (F.IntakeType) -> ViewPersistance) -> Workflow where F: FlowRepresentable {
        let wf = Workflow(first)
        wf.append(FlowRepresentableMetaData(type,
                                            presentationType: presentationType,
                                            staysInViewStack: { data in
                                                guard let cast = data as? F.IntakeType else { return .default }
                                                return staysInViewStack(cast)
        }))
        return wf
    }

    /// thenPresent: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter staysInViewStack: A closure returning a `ViewPersistance`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    public func thenPresent<F>(_ type:F.Type, presentationType:PresentationType = .default, staysInViewStack:@escaping () -> ViewPersistance) -> Workflow where F: FlowRepresentable, F.IntakeType == Never {
        let wf = Workflow(first)
        wf.append(FlowRepresentableMetaData(type,
                                            presentationType: presentationType,
                                            staysInViewStack: { _ in
                                                return staysInViewStack()
        }))
        return wf
    }

    public func applyPresenter(_ presenter:AnyPresenter) {
        self.presenter = presenter
    }

    public func launch(from: Any?, with args:Any?, withLaunchStyle launchStyle:PresentationType = .default, onFinish:((Any?) -> Void)? = nil) -> LinkedList<AnyFlowRepresentable?>.Element? {
        #if DEBUG
        if (NSClassFromString("XCTest") != nil) {
            NotificationCenter.default.post(name: .workflowLaunched, object: [
                "workflow" : self,
                "launchFrom": from,
                "args": args,
                "style": launchStyle,
                "onFinish": onFinish
            ])
        }
        #endif
        removeInstances()
        instances.append(contentsOf: map { _ in nil })
        var rootView:Any?
        var metadata:FlowRepresentableMetaData?
        _ = first?.traverse { node in
            metadata = node.value
            let metadata = node.value
            var flowRepresentable = metadata.flowRepresentableType.instance()
            flowRepresentable.workflow = self
            let shouldLoad = flowRepresentable.erasedShouldLoad(with: args)
            defer {
                let position = node.position
                if (shouldLoad) {
                    instances.replace(atIndex: position, withItem: flowRepresentable)
                    firstLoadedInstance = instances.first?.traverse(position)
                    if let firstLoadedInstance = firstLoadedInstance {
                        self.setupCallbacks(for: firstLoadedInstance,
                                            shouldDestroy: metadata.staysInViewStack(args) == ViewPersistance.removedAfterProceeding,
                                            onFinish: onFinish)
                    }
                } else if (!shouldLoad && metadata.staysInViewStack(args) == .hiddenInitially) {
                    var reference:((Any?) -> Void)?
                    self.handleCallbackWhenHiddenInitially(viewToPresent: &rootView,
                                                           hold: &reference,
                                                           instance: flowRepresentable,
                                                           instancePosition: position,
                                                           from: from,
                                                           metadata: metadata,
                                                           onFinish: onFinish)
                }

            }
            return shouldLoad
        }
        
        guard let first = firstLoadedInstance,
              let m = metadata else { return nil }
        
        presenter?.launch(view: first.value, from: rootView ?? from, withLaunchStyle: launchStyle, metadata: m, animated: true, completion: nil)
        return firstLoadedInstance
    }
    
    /// abandon: Called when the workflow should be terminated, and the app should return to the point before the workflow was launched
    /// - Parameter animated: A boolean indicating whether abandoning the workflow should be animated
    /// - Parameter onFinish: A callback after the workflow has been abandoned.
    /// - Returns: Void
    /// - Note: In order for this to function the workflow must have a presenter, presenters must call back to the workflow to inform when the abandon process has finished for the onFinish callback to be called.
    public func abandon(animated:Bool = true, onFinish:(() -> Void)? = nil) {
        presenter?.abandon(self, animated:animated) {
            self.removeInstances()
            self.firstLoadedInstance = nil
            self.presenter = nil
            onFinish?()
        }
    }
    
    private func removeInstances() {
        instances.forEach { $0.value?.proceedInWorkflow = nil }
        instances.removeAll()
        firstLoadedInstance = nil
    }
    
    private func replaceInstance(atIndex index:Int, withInstance instance:AnyFlowRepresentable?) {
        instances.replace(atIndex: index, withItem: instance)
    }

    private func setupCallbacks(for node:LinkedList<AnyFlowRepresentable?>.Element, shouldDestroy:Bool = false, onFinish:((Any?) -> Void)?) {
        node.value?.proceedInWorkflow = { args in
            var argsToPass = args
            var viewToPresent:Any?
            let nextNode = node.next?.traverse {
                let index = $0.position
                guard let metadata = self.first?.traverse(index)?.value else { return false }
                var instance = metadata.flowRepresentableType.instance()
                instance.proceedInWorkflow = $0.value?.proceedInWorkflow
                instance.workflow = self
                
                var hold = instance.proceedInWorkflow
                defer {
                    instance.proceedInWorkflow = hold
                    self.replaceInstance(atIndex: index, withInstance: instance)
                }
                
                instance.proceedInWorkflow = { argsToPass = $0 }
                
                let shouldLoad = instance.erasedShouldLoad(with: argsToPass) == true
                if (!shouldLoad && metadata.staysInViewStack(argsToPass) == .hiddenInitially) {
                    self.handleCallbackWhenHiddenInitially(viewToPresent: &viewToPresent,
                                                           hold: &hold,
                                                           instance: instance,
                                                           instancePosition: index,
                                                           from: self.instances.first?.traverse(node.position)?.value,
                                                           metadata: metadata,
                                                           onFinish: onFinish)
                }
                
                return shouldLoad
            }

            guard let nodeToPresent = nextNode,
                  let metadata = self.first?.traverse(nodeToPresent.position)?.value,
                  let instanceToPresent = self.instances.first?.traverse(nodeToPresent.position)?.value else {
                onFinish?(args)
                return
            }
            
            self.setupCallbacks(for: nodeToPresent,
                                shouldDestroy: metadata.staysInViewStack(argsToPass) == ViewPersistance.removedAfterProceeding,
                                onFinish: onFinish)
            
            viewToPresent = viewToPresent ?? self.instances.first?.traverse(node.position)?.value
            
            self.presenter?.launch(view: instanceToPresent,
                                   from: viewToPresent,
                                   withLaunchStyle: metadata.presentationType, metadata: metadata, animated: true) {
                if shouldDestroy {
                    self.presenter?.destroy(self.instances.first?.traverse(node.position)?.value)
                }
            }
        }
    }
    
    private func handleCallbackWhenHiddenInitially(viewToPresent:inout Any?, hold:inout ((Any?) -> Void)?, instance:AnyFlowRepresentable, instancePosition:Int, from:Any?, metadata: FlowRepresentableMetaData, onFinish:((Any?) -> Void)?) {
        viewToPresent = instance
        self.replaceInstance(atIndex: instancePosition, withInstance: instance)
        if let instanceNode = self.instances.first?.traverse(instancePosition) {
            self.setupCallbacks(for: instanceNode, onFinish: onFinish)
            hold = instanceNode.value?.proceedInWorkflow
        }
        self.presenter?.launch(view: instance,
                               from: from,
                               withLaunchStyle: metadata.presentationType, metadata: metadata, animated: false, completion: nil)

    }
}

public class FlowRepresentableMetaData {
    private(set) var flowRepresentableType:AnyFlowRepresentable.Type
    private(set) var staysInViewStack:(Any?) -> ViewPersistance
    private(set) var presentationType:PresentationType
    internal init(_ flowRepresentableType:AnyFlowRepresentable.Type, presentationType:PresentationType = .default, staysInViewStack:@escaping (Any?) -> ViewPersistance) {
        self.flowRepresentableType = flowRepresentableType
        self.staysInViewStack = staysInViewStack
        self.presentationType = presentationType
    }
}
