//
//  WorkflowItem.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Tyler Thompson on 7/12/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftCurrent

/**
 A concrete type used to modify a `FlowRepresentable` in a `WorkflowView`.

 ### Discussion
 `WorkflowItem` gives you the ability to specify changes you'd like to apply to a specific `FlowRepresentable` when it is time to present it in a `Workflow`.

 #### Example
 ```swift
 WorkflowItem(FirstView.self)
            .persistence(.removedAfterProceeding) // affects only FirstView
            .applyModifiers {
                if true { // Enabling transition animation
                    $0.background(Color.gray) // $0 is a FirstView instance
                        .transition(.slide)
                        .animation(.spring())
                }
            }
 ```
 */
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public final class WorkflowItem<F: FlowRepresentable & View> {
    var metadata: FlowRepresentableMetadata!
    private var flowPersistenceClosure: (AnyWorkflow.PassedArgs) -> FlowPersistence = { _ in .default }
    private var modifierClosure: ((AnyFlowRepresentableView) -> Void)?

    /// Creates a `WorkflowItem` with no arguments from a `FlowRepresentable` that is also a View.
    public init(_: F.Type) {
        metadata = FlowRepresentableMetadata(F.self,
                                             launchStyle: .new,
                                             flowPersistence: flowPersistenceClosure,
                                             flowRepresentableFactory: factory)
    }

    /**
     Provides a way to apply modifiers to your `FlowRepresentable` view.

     ### Important: The most recently defined (or last) use of this, is the only one that applies modifiers, unlike onAbandon or onFinish.
     */
    public func applyModifiers<V: View>(@ViewBuilder _ closure: @escaping (F) -> V) -> Self {
        modifierClosure = {
            // We are essentially casting this to itself, that cannot fail. (Famous last words)
            // swiftlint:disable:next force_cast
            let instance = $0.underlyingInstance as! F
            $0.changeUnderlyingView(to: closure(instance))
        }
        return self
    }

    private func factory(args: AnyWorkflow.PassedArgs) -> AnyFlowRepresentable {
        let afrv = AnyFlowRepresentableView(type: F.self, args: args)
        modifierClosure?(afrv)
        return afrv
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowItem {
    /// Sets persistence on the `FlowRepresentable` of the `WorkflowItem`.
    public func persistence(_ persistence: @escaping @autoclosure () -> FlowPersistence) -> Self {
        flowPersistenceClosure = { _ in persistence() }
        metadata = FlowRepresentableMetadata(F.self,
                                             launchStyle: .new,
                                             flowPersistence: flowPersistenceClosure,
                                             flowRepresentableFactory: factory)
        return self
    }

    /// Sets persistence on the `FlowRepresentable` of the `WorkflowItem`.
    public func persistence(_ persistence: @escaping (F.WorkflowInput) -> FlowPersistence) -> Self {
        flowPersistenceClosure = {
            guard case .args(let arg as F.WorkflowInput) = $0 else {
                fatalError("Could not cast \(String(describing: $0)) to expected type: \(F.WorkflowInput.self)")
            }
            return persistence(arg)
        }
        metadata = FlowRepresentableMetadata(F.self,
                                             launchStyle: .new,
                                             flowPersistence: flowPersistenceClosure,
                                             flowRepresentableFactory: factory)
        return self
    }

    /// Sets persistence on the `FlowRepresentable` of the `WorkflowItem`.
    public func persistence(_ persistence: @escaping (F.WorkflowInput) -> FlowPersistence) -> Self where F.WorkflowInput == AnyWorkflow.PassedArgs {
        flowPersistenceClosure = { persistence($0) }
        metadata = FlowRepresentableMetadata(F.self,
                                             launchStyle: .new,
                                             flowPersistence: flowPersistenceClosure,
                                             flowRepresentableFactory: factory)
        return self
    }

    /// Sets persistence on the `FlowRepresentable` of the `WorkflowItem`.
    public func persistence(_ persistence: @escaping () -> FlowPersistence) -> Self where F.WorkflowInput == Never {
        flowPersistenceClosure = { _ in persistence() }
        metadata = FlowRepresentableMetadata(F.self,
                                             launchStyle: .new,
                                             flowPersistence: flowPersistenceClosure,
                                             flowRepresentableFactory: factory)
        return self
    }
}
