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
 let workflow = Workflow()
                    .thenPresent(SomeFlowRepresentableClass.self)
                    .thenPResent(SomeOtherFlowRepresentableClass.self, presentationType: .navigationStack)
 ```

 ### Discussion:
 In a sufficiently complex application it may make sense to create a structure to hold onto all the workflows in an application.
 Example
 ```swift
 struct Workflows {
    static let schedulingFlow = Workflow()
                                 .thenPresent(SomeFlowRepresentableClass.self)
                                 .thenPResent(SomeOtherFlowRepresentableClass.self, presentationType: .navigationStack)
 }
 ```
 */

public class AnyWorkflow: LinkedList<FlowRepresentableMetaData> {
    public typealias ArrayLiteralElement = AnyFlowRepresentable.Type
    internal var instances = LinkedList<AnyFlowRepresentable?>()
    internal var presenter: AnyPresenter?
    internal var orchestrationResponder: AnyOrchestrationResponder?

    public var firstLoadedInstance: LinkedList<AnyFlowRepresentable?>.Element?

    public init() {
        super.init(nil)
    }

    required init(_ node: Element?) {
        super.init(node)
    }

    deinit {
        removeInstances()
        presenter = nil
        orchestrationResponder = nil
    }

    public func applyPresenter(_ presenter: AnyPresenter) {
        self.presenter = presenter
    }

    public func applyOrchestrationResponder(_ orchestrationResponder: AnyOrchestrationResponder) {
        self.orchestrationResponder = orchestrationResponder
    }

    private enum PassedArgs {
        case none
        case args(Any?)
    }

    private func postDataForTestListeners(from: Any?,
                                          with args: Any?,
                                          withLaunchStyle launchStyle: PresentationType = .default,
                                          onFinish: ((Any?) -> Void)? = nil) {
        #if DEBUG
        if NSClassFromString("XCTest") != nil {
            NotificationCenter.default.post(name: .workflowLaunched, object: [
                "workflow": self,
                "launchFrom": from,
                "args": args,
                "style": launchStyle,
                "onFinish": onFinish
            ])
        }
        #endif
    }

    public func launch(from: Any?,
                       with args: Any?,
                       withLaunchStyle launchStyle: PresentationType = .default,
                       onFinish: ((Any?) -> Void)? = nil) -> LinkedList<AnyFlowRepresentable?>.Element? {
        postDataForTestListeners(from: from,
                                 with: args,
                                 withLaunchStyle: launchStyle,
                                 onFinish: onFinish)
        removeInstances()
        instances.append(contentsOf: map { _ in nil })
        var root: Any?
        var metadata: FlowRepresentableMetaData?
        var passedArgs: PassedArgs = .none
        _ = first?.traverse { node in
            metadata = node.value
            let metadata = node.value
            var flowRepresentable = metadata.flowRepresentableType.instance()
            flowRepresentable.workflow = self

            flowRepresentable.proceedInWorkflowStorage = { passedArgs = .args($0) }

            let argsToPass: Any? = {
                if case .args(let value) = passedArgs {
                    return value
                }
                return args
            }()

            let shouldLoad = flowRepresentable.erasedShouldLoad(with: argsToPass)

            defer {
                let position = node.position
                if shouldLoad {
                    instances.replace(atIndex: position, withItem: flowRepresentable)
                    firstLoadedInstance = instances.first?.traverse(position)
                    if let firstLoadedInstance = firstLoadedInstance {
                        self.setupCallbacks(for: firstLoadedInstance,
                                            shouldDestroy: metadata.persistance(args) == FlowPersistance.removedAfterProceeding,
                                            onFinish: onFinish)
                    }
                } else if !shouldLoad && metadata.persistance(args) == .persistWhenSkipped {
                    var reference: ((Any?) -> Void)?
                    self.handleCallbackWhenHiddenInitially(viewToPresent: &root,
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
              let m = metadata else {
                if case .args(let value) = passedArgs {
                    onFinish?(value)
                } else if args != nil {
                    onFinish?(args)
                }
                return nil
        }

        presenter?.launch(view: first.value, from: root ?? from, withLaunchStyle: launchStyle, metadata: m, animated: true, completion: nil)
        orchestrationResponder?.proceed(to: first.value, from: nil, metadata: m)
        return firstLoadedInstance
    }

    /// abandon: Called when the workflow should be terminated, and the app should return to the point before the workflow was launched
    /// - Parameter animated: A boolean indicating whether abandoning the workflow should be animated
    /// - Parameter onFinish: A callback after the workflow has been abandoned.
    /// - Returns: Void
    /// - Note: In order for this to function the workflow must have a presenter, presenters must call back to the workflow to inform when the abandon process has finished for the onFinish callback to be called.
    public func abandon(animated: Bool = true, onFinish:(() -> Void)? = nil) {
        presenter?.abandon(self, animated: animated) {
            self.removeInstances()
            self.firstLoadedInstance = nil
            self.presenter = nil
            onFinish?()
        }
    }

    private func removeInstances() {
        instances.forEach { $0.value?.proceedInWorkflowStorage = nil }
        instances.removeAll()
        firstLoadedInstance = nil
    }

    private func replaceInstance(atIndex index: Int, withInstance instance: AnyFlowRepresentable?) {
        instances.replace(atIndex: index, withItem: instance)
    }

    private func setupCallbacks(for node: LinkedList<AnyFlowRepresentable?>.Element, shouldDestroy: Bool = false, onFinish: ((Any?) -> Void)?) {
        node.value?.proceedInWorkflowStorage = { [self] args in
            var argsToPass = args
            var viewToPresent: Any?
            let nextNode = node.next?.traverse {
                let index = $0.position
                guard let metadata = first?.traverse(index)?.value else { return false }
                var instance = metadata.flowRepresentableType.instance()
                instance.proceedInWorkflowStorage = $0.value?.proceedInWorkflowStorage
                instance.workflow = self

                var hold = instance.proceedInWorkflowStorage
                defer {
                    instance.proceedInWorkflowStorage = hold
                    replaceInstance(atIndex: index, withInstance: instance)
                }

                instance.proceedInWorkflowStorage = { argsToPass = $0 }

                let shouldLoad = instance.erasedShouldLoad(with: argsToPass) == true
                if !shouldLoad && metadata.persistance(argsToPass) == .persistWhenSkipped {
                    handleCallbackWhenHiddenInitially(viewToPresent: &viewToPresent,
                                                           hold: &hold,
                                                           instance: instance,
                                                           instancePosition: index,
                                                           from: instances.first?.traverse(node.position)?.value,
                                                           metadata: metadata,
                                                           onFinish: onFinish)
                }

                return shouldLoad
            }

            guard let nodeToPresent = nextNode,
                  let metadata = first?.traverse(nodeToPresent.position)?.value,
                  let instanceToPresent = instances.first?.traverse(nodeToPresent.position)?.value else {
                onFinish?(argsToPass)
                return
            }

            self.setupCallbacks(for: nodeToPresent,
                                shouldDestroy: metadata.persistance(argsToPass) == FlowPersistance.removedAfterProceeding,
                                onFinish: onFinish)

            viewToPresent = viewToPresent ?? instances.first?.traverse(node.position)?.value

            presenter?.launch(view: instanceToPresent,
                                   from: viewToPresent,
                                   withLaunchStyle: metadata.presentationType, metadata: metadata, animated: true) {
                if shouldDestroy {
                    presenter?.destroy(instances.first?.traverse(node.position)?.value)
                }
            }

            orchestrationResponder?.proceed(to: instanceToPresent, from: viewToPresent, metadata: metadata)
        }
    }

    private func handleCallbackWhenHiddenInitially(viewToPresent:inout Any?,
                                                   hold:inout ((Any?) -> Void)?,
                                                   instance: AnyFlowRepresentable,
                                                   instancePosition: Int,
                                                   from: Any?,
                                                   metadata: FlowRepresentableMetaData,
                                                   onFinish: ((Any?) -> Void)?) {
        viewToPresent = instance
        self.replaceInstance(atIndex: instancePosition, withInstance: instance)
        if let instanceNode = self.instances.first?.traverse(instancePosition) {
            self.setupCallbacks(for: instanceNode, onFinish: onFinish)
            hold = instanceNode.value?.proceedInWorkflowStorage
        }
        self.presenter?.launch(view: instance,
                               from: from,
                               withLaunchStyle: metadata.presentationType, metadata: metadata, animated: false, completion: nil)

    }
}

public final class Workflow<F: FlowRepresentable>: AnyWorkflow {
    public required init(_ node: AnyWorkflow.Element?) {
        super.init(node)
    }

    internal override init() { super.init() }

    /// init: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter staysInViewStack: An `FlowPersistance`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    public convenience init(_ type: F.Type, presentationType: PresentationType = .default, staysInViewStack:@escaping @autoclosure () -> FlowPersistance = .default) {
        self.init(FlowRepresentableMetaData(type,
                                             presentationType: presentationType,
                                             staysInViewStack: { _ in staysInViewStack() }))
    }
    /// init: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter staysInViewStack: A closure taking in the generic type from the `FlowRepresentable` and returning a `FlowPersistance`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    public convenience init(_ type: F.Type, presentationType: PresentationType = .default, staysInViewStack:@escaping (F.WorkflowInput) -> FlowPersistance) {
        self.init(FlowRepresentableMetaData(type,
                                            presentationType: presentationType,
                                            staysInViewStack: { data in
                                                guard let cast = data as? F.WorkflowInput else { return .default }
                                                return staysInViewStack(cast)
        }))
    }

    /// init: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter staysInViewStack: A closure returning a `FlowPersistance`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    public convenience init(_ type: F.Type, presentationType: PresentationType = .default, staysInViewStack:@escaping () -> FlowPersistance) where F.WorkflowInput == Never {
        self.init(FlowRepresentableMetaData(type,
                                            presentationType: presentationType,
                                            staysInViewStack: { _ in
                                                return staysInViewStack()
        }))
    }
}

public extension Workflow where F.WorkflowOutput == Never {
    /// thenPresent: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter staysInViewStack: An `FlowPersistance`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                            presentationType: PresentationType = .default,
                                            staysInViewStack:@escaping @autoclosure () -> FlowPersistance = .default) -> Workflow<FR> where FR.WorkflowInput == Never {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetaData(type,
                                            presentationType: presentationType,
                                            staysInViewStack: { _ in
                                                return staysInViewStack()
        }))
        return wf
    }
}

public extension Workflow {
    /// thenPresent: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter staysInViewStack: An `FlowPersistance`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                            presentationType: PresentationType = .default,
                                            staysInViewStack:@escaping @autoclosure () -> FlowPersistance = .default) -> Workflow<FR> where F.WorkflowOutput == FR.WorkflowInput {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetaData(type,
                                            presentationType: presentationType,
                                            staysInViewStack: { _ in staysInViewStack() }))
        return wf
    }

    /// thenPresent: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter staysInViewStack: A closure taking in the generic type from the `FlowRepresentable` and returning a `FlowPersistance`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                            presentationType: PresentationType = .default,
                                            staysInViewStack:@escaping (FR.WorkflowInput) -> FlowPersistance) -> Workflow<FR> where F.WorkflowOutput == FR.WorkflowInput {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetaData(type,
                                            presentationType: presentationType,
                                            staysInViewStack: { data in
                                                guard let cast = data as? FR.WorkflowInput else { return .default }
                                                return staysInViewStack(cast)
        }))
        return wf
    }

    /// thenPresent: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter staysInViewStack: A closure returning a `FlowPersistance`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                            presentationType: PresentationType = .default,
                                            staysInViewStack:@escaping @autoclosure () -> FlowPersistance = .default) -> Workflow<FR> where FR.WorkflowInput == Never {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetaData(type,
                                            presentationType: presentationType,
                                            staysInViewStack: { _ in
                                                return staysInViewStack()
        }))
        return wf
    }
}

public class FlowRepresentableMetaData {
    private(set) public var flowRepresentableType: AnyFlowRepresentable.Type
    private(set) public var persistance: (Any?) -> FlowPersistance
    private(set) public var presentationType: PresentationType
    public init(_ flowRepresentableType: AnyFlowRepresentable.Type, presentationType: PresentationType = .default, staysInViewStack:@escaping (Any?) -> FlowPersistance) {
        self.flowRepresentableType = flowRepresentableType
        self.persistance = staysInViewStack
        self.presentationType = presentationType
    }
}
