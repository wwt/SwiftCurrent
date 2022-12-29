//
//  WorkflowItem.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Tyler Thompson on 7/20/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//
import SwiftUI
import SwiftCurrent

#if (os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)) && canImport(UIKit)
import UIKit
#endif

/**
 A concrete type used to modify a `FlowRepresentable` in a workflow.

 ### Discussion
 `WorkflowItem` gives you the ability to specify changes you'd like to apply to a specific `FlowRepresentable` when it is time to present it in a `Workflow`. `WorkflowItem`s are most often created inside a `WorkflowView` or `WorkflowGroup`.

 #### Example
 ```swift
 WorkflowItem(FirstView.self)
    .persistence(.removedAfterProceeding) // affects only FirstView
    .applyModifiers {
        $0.background(Color.gray) // $0 is a FirstView instance
            .transition(.slide)
            .animation(.spring())
    }
  ```
 */
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct WorkflowItem<Content: View>: _WorkflowItemProtocol {
    public var launchStyle: State<LaunchStyle.SwiftUI.PresentationType> = State(wrappedValue: .default)
    let persistence: FlowPersistence.SwiftUI.Persistence = .default

    @Environment(\.workflowArgs) var args
    @ViewBuilder var content: (AnyWorkflow.PassedArgs) -> Content

    @State private var shouldLoad: (AnyWorkflow.PassedArgs) -> Bool = { _ in true }

    public init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = { _ in content() }
    }

    public init<A>(@ViewBuilder _ content: @escaping (A) -> Content) {
        self.content = {
            guard case .args(let args as A) = $0 else {
                fatalError("View expected type: \(type(of: A.self)), but got type: \($0) instead")
            }
            return content(args)
        }
    }

    public init(@ViewBuilder _ content: @escaping (AnyWorkflow.PassedArgs) -> Content) {
        self.content = { content($0) }
    }

    private init(previous: WorkflowItem<Content>,
                 presentationType: LaunchStyle.SwiftUI.PresentationType,
                 shouldLoad: @escaping (AnyWorkflow.PassedArgs) -> Bool) {
        launchStyle = State(wrappedValue: presentationType)
        content = previous.content
        _shouldLoad = State(wrappedValue: shouldLoad)
    }

    public var body: some View {
        content(args)
    }

    public func shouldLoad(_ closure: @escaping () -> Bool) -> Self {
        Self(previous: self, presentationType: launchStyle.wrappedValue, shouldLoad: { _ in closure() }) // swiftlint:disable:this all
    }

    public func shouldLoad(_ closure: @autoclosure @escaping () -> Bool) -> Self {
        Self(previous: self, presentationType: launchStyle.wrappedValue, shouldLoad: { _ in closure() }) // swiftlint:disable:this all
    }

    public func shouldLoad<A>(_ closure: @escaping (A) -> Bool) -> Self {
        Self(previous: self, presentationType: launchStyle.wrappedValue, shouldLoad: { // swiftlint:disable:this trailing_closure
            guard case .args(let args as A) = $0 else { return false }
            return closure(args)
        }) // swiftlint:disable:this all
    }

    /// :nodoc: Protocol requirement.
    public func _shouldLoad(args: AnyWorkflow.PassedArgs) -> Bool {
        shouldLoad(args)
    }
}

// #if (os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)) && canImport(UIKit)
//    /// Creates a `WorkflowItem` from a `UIViewController`.
//    @available(iOS 14.0, macOS 11, tvOS 14.0, *)
//    public init<VC: FlowRepresentable & UIViewController>(_: VC.Type) where Content == ViewControllerWrapper<VC>, FlowRepresentableType == ViewControllerWrapper<VC> {
//        let metadata = FlowRepresentableMetadata(ViewControllerWrapper<VC>.self,
//                                                 launchStyle: .new,
//                                                 flowPersistence: flowPersistenceClosure,
//                                                 flowRepresentableFactory: factory)
//        _metadata = State(initialValue: metadata)
//    }
// #endif

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowItem {
    /// Sets persistence on the `FlowRepresentable` of the `WorkflowItem`.
    public func persistence(_ persistence: @escaping @autoclosure () -> FlowPersistence.SwiftUI.Persistence) -> Self {
        self
//        Self(previous: self,
//             launchStyle: launchStyle,
//             modifierClosure: modifierClosure ?? { _ in },
//             flowPersistenceClosure: { _ in persistence().rawValue })
    }

//    /// Sets persistence on the `FlowRepresentable` of the `WorkflowItem`.
//    public func persistence(_ persistence: @escaping (FlowRepresentableType.WorkflowInput) -> FlowPersistence.SwiftUI.Persistence) -> Self {
//        Self(previous: self,
//             launchStyle: launchStyle,
//             modifierClosure: modifierClosure ?? { _ in },
//             flowPersistenceClosure: {
//            guard case .args(let arg as FlowRepresentableType.WorkflowInput) = $0 else {
//                fatalError("Could not cast \(String(describing: $0)) to expected type: \(FlowRepresentableType.WorkflowInput.self)")
//            }
//            return persistence(arg).rawValue
//        })
//    }
//
//    func settingPersistence(_ persistence: @escaping (AnyWorkflow.PassedArgs) -> FlowPersistence) -> Self {
//        Self(previous: self,
//             launchStyle: launchStyle,
//             modifierClosure: modifierClosure ?? { _ in },
//             flowPersistenceClosure: persistence)
//    }
//
//    /// Sets persistence on the `FlowRepresentable` of the `WorkflowItem`.
//    public func persistence(_ persistence: @escaping (FlowRepresentableType.WorkflowInput) -> FlowPersistence.SwiftUI.Persistence) -> Self where FlowRepresentableType.WorkflowInput == AnyWorkflow.PassedArgs {
//        Self(previous: self,
//             launchStyle: launchStyle,
//             modifierClosure: modifierClosure ?? { _ in },
//             flowPersistenceClosure: { persistence($0).rawValue })
//    }

    /// Sets persistence on the `FlowRepresentable` of the `WorkflowItem`.
    public func persistence(_ persistence: @escaping () -> FlowPersistence.SwiftUI.Persistence) -> Self {
        self
//        Self(previous: self,
//             launchStyle: launchStyle,
//             modifierClosure: modifierClosure ?? { _ in },
//             flowPersistenceClosure: { _ in persistence().rawValue })
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowItem {
    /// Sets the presentationType on the `FlowRepresentable` of the `WorkflowItem`.
    public func presentationType(_ presentationType: @escaping @autoclosure () -> LaunchStyle.SwiftUI.PresentationType) -> Self {
        Self(previous: self, presentationType: presentationType(), shouldLoad: shouldLoad)
    }
}
