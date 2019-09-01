//
//  Workflow.swift
//  Workflow
//
//  Created by Tyler Thompson on 8/26/19.
//  Copyright © 2019 TT. All rights reserved.
//

import Foundation

public class Workflow: LinkedList<AnyFlowRepresentable.Type> {
    
    internal var instances:LinkedList<AnyFlowRepresentable> = []
    internal var presenter:AnyPresenter?

    public var firstLoadedInstance:LinkedList<AnyFlowRepresentable>.Node<AnyFlowRepresentable>?
    
    override init(_ node: Element?) {
        super.init(node)
    }
    
    public func applyPresenter(_ presenter:AnyPresenter) {
        self.presenter = presenter
    }
    
    public func launch(from: Any?, with args:Any?, withLaunchStyle launchStyle:PresentationType = .default, onFinish:((Any?) -> Void)? = nil) -> LinkedList<AnyFlowRepresentable>.Node<AnyFlowRepresentable>? {
        removeInstances()
        instances.append(contentsOf: map {
            var flowRepresentable = $0.value.instance()
            flowRepresentable.workflow = self
            return flowRepresentable
        })
        instances.forEach { setupCallbacks(for: $0, onFinish: onFinish) }
        firstLoadedInstance = instances.first?.traverse {
            $0.value.erasedShouldLoad(with: args)
        }
        guard let first = firstLoadedInstance else {
            return nil
        }
        presenter?.launch(view: first.value, from: from, withLaunchStyle: launchStyle)
        return firstLoadedInstance
    }
    
    public func abandon(animated:Bool = true, onFinish:(() -> Void)? = nil) {
        presenter?.abandon(self, animated:animated, onFinish:onFinish)
    }
    
    private func removeInstances() {
        instances.forEach { $0.value.callback = nil }
        instances.removeAll()
    }
    
    private func replaceInstance(atIndex index:Int, withInstance instance:AnyFlowRepresentable?) {
        guard let instance = instance else { return }
        instances.replace(atIndex: index, withItem: instance)
    }

    private func setupCallbacks(for node:LinkedList<AnyFlowRepresentable>.Node<AnyFlowRepresentable>, onFinish:((Any?) -> Void)?) {
        node.value.callback = { args in
            var argsToPass = args
            let nextNode = node.next?.traverse {
                let index = $0.position
                var instance = self.first?.traverse(index)?.value.instance()
                instance?.callback = $0.value.callback
                
                let hold = instance?.callback
                defer {
                    instance?.callback = hold
                    self.replaceInstance(atIndex: index, withInstance: instance)
                }
                
                instance?.callback = { argsToPass = $0 }
                
                return instance?.erasedShouldLoad(with: argsToPass) == true
            }

            guard let nodeToPresent = nextNode else {
                onFinish?(args)
                return
            }
            
            let instanceToPresent = self.instances.first?.traverse(nodeToPresent.position)?.value
            
            self.presenter?.launch(view: instanceToPresent,
                                   from: self.instances.first?.traverse(node.position)?.value,
                                   withLaunchStyle: instanceToPresent?.preferredLaunchStyle ?? .default)
        }
    }
}
