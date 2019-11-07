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

public enum ViewPersistance {
    case `default`
    case hiddenInitially
    case removedAfterProceeding
}
public class Workflow: LinkedList<FlowRepresentableMetaData>, ExpressibleByArrayLiteral {
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
    
    required public convenience init(arrayLiteral elements: ArrayLiteralElement...) {
        self.init(elements)
    }
    
    public convenience init(_ elements: AnyFlowRepresentable.Type...) {
        self.init(elements)
    }
    
    public convenience init(_ elements: [AnyFlowRepresentable.Type])  {
        let collection = elements.map {
            Element(with:
                FlowRepresentableMetaData($0,
                    staysInViewStack: { _ in .default },
                    presentationType: .default)
            )
        }
        for (i, node) in collection.enumerated() {
            node.previous = collection[safe: i-1]
            node.next = collection[safe: i+1]
        }

        self.init(collection.first)
    }
    
    deinit {
        removeInstances()
        presenter = nil
    }
    
    public func thenPresent<F>(_ type:F.Type, staysInViewStack:@escaping @autoclosure () -> ViewPersistance = .default, preferredLaunchStyle:PresentationType = .default) -> Workflow where F: FlowRepresentable {
        let wf = Workflow(first)
        wf.append(FlowRepresentableMetaData(type,
                                            staysInViewStack: { _ in staysInViewStack() },
                                            presentationType: preferredLaunchStyle))
        return wf
    }

    public func thenPresent<F>(_ type:F.Type, staysInViewStack:@escaping (F.IntakeType) -> ViewPersistance, preferredLaunchStyle:PresentationType = .default) -> Workflow where F: FlowRepresentable {
        let wf = Workflow(first)
        wf.append(FlowRepresentableMetaData(type,
                                            staysInViewStack: { data in
                                                guard let cast = data as? F.IntakeType else { return .default }
                                                return staysInViewStack(cast)
                                            },
                                            presentationType: preferredLaunchStyle))
        return wf
    }

    public func thenPresent<F>(_ type:F.Type, staysInViewStack:@escaping () -> ViewPersistance, preferredLaunchStyle:PresentationType = .default) -> Workflow where F: FlowRepresentable, F.IntakeType == Never {
        let wf = Workflow(first)
        wf.append(FlowRepresentableMetaData(type,
                                            staysInViewStack: { _ in
                                                return staysInViewStack()
                                            },
                                            presentationType: preferredLaunchStyle))
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
        _ = first?.traverse { node in
            var flowRepresentable = node.value.flowRepresentableType.instance()
            flowRepresentable.workflow = self
            let shouldLoad = flowRepresentable.erasedShouldLoad(with: args)
            defer {
                if (shouldLoad) {
                    let position = node.position
                    instances.replace(atIndex: position, withItem: flowRepresentable)
                    firstLoadedInstance = instances.first?.traverse(position)
                    if let firstLoadedInstance = firstLoadedInstance {
                        self.setupCallbacks(for: firstLoadedInstance, onFinish: onFinish)
                    }
                }
            }
            return shouldLoad
        }
        
        guard let first = firstLoadedInstance else { return nil }
        
        presenter?.launch(view: first.value, from: from, withLaunchStyle: launchStyle, animated: true)
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

    private func setupCallbacks(for node:LinkedList<AnyFlowRepresentable?>.Element, onFinish:((Any?) -> Void)?) {
        node.value?.proceedInWorkflow = { args in
            var argsToPass = args
            let nextNode = node.next?.traverse {
                let index = $0.position
                let metadata = self.first?.traverse(index)?.value
                var instance = metadata?.flowRepresentableType.instance()
                instance?.proceedInWorkflow = $0.value?.proceedInWorkflow
                instance?.workflow = self
                
                let hold = instance?.proceedInWorkflow
                defer {
                    instance?.proceedInWorkflow = hold
                    self.replaceInstance(atIndex: index, withInstance: instance)
                }
                
                instance?.proceedInWorkflow = { argsToPass = $0 }
                
                let shouldLoad = instance?.erasedShouldLoad(with: argsToPass) == true
                if (!shouldLoad && metadata?.staysInViewStack(argsToPass) == .hiddenInitially) {
                    self.presenter?.launch(view: instance,
                                           from: self.instances.first?.traverse(node.position)?.value,
                                           withLaunchStyle: instance?.preferredLaunchStyle ?? .default, animated: false)

                }
                
                return shouldLoad
            }

            guard let nodeToPresent = nextNode,
                  let instanceToPresent = self.instances.first?.traverse(nodeToPresent.position)?.value else {
                onFinish?(args)
                return
            }
            
            self.setupCallbacks(for: nodeToPresent, onFinish: onFinish)
            
            self.presenter?.launch(view: instanceToPresent,
                                   from: self.instances.first?.traverse(node.position)?.value,
                                   withLaunchStyle: instanceToPresent.preferredLaunchStyle, animated: true)

            if self.first?.traverse(node.position)?.value.staysInViewStack(argsToPass) == ViewPersistance.removedAfterProceeding {
                self.presenter?.destroy(self.instances.first?.traverse(node.position)?.value)
            }
        }
    }
}

public class FlowRepresentableMetaData {
    var flowRepresentableType:AnyFlowRepresentable.Type
    var staysInViewStack:(Any?) -> ViewPersistance
    var presentationType:PresentationType
    init(_ flowRepresentableType:AnyFlowRepresentable.Type, staysInViewStack:@escaping (Any?) -> ViewPersistance, presentationType:PresentationType) {
        self.flowRepresentableType = flowRepresentableType
        self.staysInViewStack = staysInViewStack
        self.presentationType = presentationType
    }
}
