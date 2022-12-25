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
public struct WorkflowItem<Content: View, Args>: _WorkflowItemProtocol {
    public var launchStyle: State<LaunchStyle.SwiftUI.PresentationType> = State(wrappedValue: .default)

    @Environment(\.workflowArgs) var args
    @ViewBuilder var content: (AnyWorkflow.PassedArgs) -> Content

    public init(@ViewBuilder _ content: @escaping () -> Content) where Args == Never {
        self.content = { _ in content() }
    }

    public init(@ViewBuilder _ content: @escaping (Args) -> Content) {
        self.content = {
            guard case .args(let args as Args) = $0 else {
                fatalError("View expected type: \(type(of: Args.self)), but got type: \($0) instead")
            }
            return content(args)
        }
    }

    public init(@ViewBuilder _ content: @escaping (Args) -> Content) where Args == AnyWorkflow.PassedArgs {
        self.content = { content($0) }
    }

    private init<A>(previous: WorkflowItem<Content, A>,
                    presentationType: LaunchStyle.SwiftUI.PresentationType) {
        self.launchStyle = State(wrappedValue: presentationType)
        content = previous.content
    }

    public var body: some View {
        content(args)
    }
}
//
//public struct WorkflowItem<FlowRepresentableType: FlowRepresentable & View, Content: View>: _WorkflowItemProtocol { // swiftlint:disable:this generic_type_name
//    // These need to be state variables to survive SwiftUI re-rendering. Change under penalty of torture BY the codebase you modified.
//    @State private var content: Content?
//    @State private var metadata: FlowRepresentableMetadata!
//    @State private var modifierClosure: ((AnyFlowRepresentableView) -> Void)?
//    @State private var flowPersistenceClosure: (AnyWorkflow.PassedArgs) -> FlowPersistence = { _ in .default }
//    @State private var launchStyle: LaunchStyle.SwiftUI.PresentationType = .default
//    @State private var persistence: FlowPersistence = .default
//    @EnvironmentObject private var model: WorkflowViewModel
//
//    private var elementRef: AnyWorkflow.Element?
//
//    public var body: some View {
//        ViewBuilder {
//            content ?? model.body?.extractErasedView() as? Content
//        }
//        .onReceive(model.$body) {
//            if let body = $0?.extractErasedView() as? Content, elementRef == nil || elementRef === $0 {
//                content = body
//            }
//        }
//    }
//
//    public func canDisplay(_ element: AnyWorkflow.Element?) -> Bool {
//        (element?.extractErasedView() as? Content != nil) && (elementRef == nil || elementRef === element)
//    }
//
//    public func didDisplay(_ element: AnyWorkflow.Element?) -> Bool {
//        (elementRef != nil || elementRef === element)
//    }
//
//    public mutating func setElementRef(_ element: AnyWorkflow.Element?) {
//        if canDisplay(element) {
//            elementRef = element
//        }
//    }
//
//    private init<C>(previous: WorkflowItem<FlowRepresentableType, C>,
//                    launchStyle: LaunchStyle.SwiftUI.PresentationType,
//                    modifierClosure: @escaping ((AnyFlowRepresentableView) -> Void),
//                    flowPersistenceClosure: @escaping (AnyWorkflow.PassedArgs) -> FlowPersistence) {
//        _modifierClosure = State(initialValue: modifierClosure)
//        _flowPersistenceClosure = State(initialValue: flowPersistenceClosure)
//        _launchStyle = State(initialValue: launchStyle)
//        let metadata = ExtendedFlowRepresentableMetadata(flowRepresentableType: FlowRepresentableType.self,
//                                                         launchStyle: launchStyle.rawValue,
//                                                         flowPersistence: flowPersistenceClosure,
//                                                         flowRepresentableFactory: factory)
//        _metadata = State(initialValue: metadata)
//    }
//
//    /// Creates a workflow item from a FlowRepresentable type
//    public init(_ item: FlowRepresentableType.Type) where Content == FlowRepresentableType {
//        let metadata = ExtendedFlowRepresentableMetadata(flowRepresentableType: FlowRepresentableType.self,
//                                                         launchStyle: .new,
//                                                         flowPersistence: flowPersistenceClosure,
//                                                         flowRepresentableFactory: factory)
//        _metadata = State(initialValue: metadata)
//    }
//
//#if (os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)) && canImport(UIKit)
//    /// Creates a `WorkflowItem` from a `UIViewController`.
//    @available(iOS 14.0, macOS 11, tvOS 14.0, *)
//    public init<VC: FlowRepresentable & UIViewController>(_: VC.Type) where Content == ViewControllerWrapper<VC>, FlowRepresentableType == ViewControllerWrapper<VC> {
//        let metadata = FlowRepresentableMetadata(ViewControllerWrapper<VC>.self,
//                                                 launchStyle: .new,
//                                                 flowPersistence: flowPersistenceClosure,
//                                                 flowRepresentableFactory: factory)
//        _metadata = State(initialValue: metadata)
//    }
//#endif
//
//    /**
//     Provides a way to apply modifiers to your `FlowRepresentable` view.
//     ### Important: The most recently defined (or last) use of this, is the only one that applies modifiers, unlike onAbandon or onFinish.
//     */
//    public func applyModifiers<V: View>(@ViewBuilder _ closure: @escaping (FlowRepresentableType) -> V) -> WorkflowItem<FlowRepresentableType, V> {
//        WorkflowItem<FlowRepresentableType, V>(previous: self,
//                                               launchStyle: launchStyle,
//                                               modifierClosure: {
//            // We are essentially casting this to itself, that cannot fail. (Famous last words)
//            // swiftlint:disable:next force_cast
//            let instance = $0.underlyingInstance as! FlowRepresentableType
//            $0.changeUnderlyingView(to: closure(instance))
//        },
//                                               flowPersistenceClosure: flowPersistenceClosure)
//    }
//
//    private func factory(args: AnyWorkflow.PassedArgs) -> AnyFlowRepresentable {
//        let afrv = AnyFlowRepresentableView(type: FlowRepresentableType.self, args: args)
//        modifierClosure?(afrv)
//        return afrv
//    }
//}
//
//@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
//extension WorkflowItem {
//    /// :nodoc: Protocol requirement.
//    public var workflowLaunchStyle: LaunchStyle.SwiftUI.PresentationType {
//        launchStyle
//    }
//
//    /// :nodoc: Protocol requirement.
//    public func modify(workflow: AnyWorkflow) {
//        workflow.append(metadata)
//    }
//}
//
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowItem {
    // swiftlint:disable trailing_closure
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
//    public func persistence(_ persistence: @escaping (FlowRepresentableType.WorkflowInput) -> FlowPersistence.SwiftUI.Persistence) -> Self where FlowRepresentableType.WorkflowInput == AnyWorkflow.PassedArgs { // swiftlint:disable:this line_length
//        Self(previous: self,
//             launchStyle: launchStyle,
//             modifierClosure: modifierClosure ?? { _ in },
//             flowPersistenceClosure: { persistence($0).rawValue })
//    }
//
//    /// Sets persistence on the `FlowRepresentable` of the `WorkflowItem`.
//    public func persistence(_ persistence: @escaping () -> FlowPersistence.SwiftUI.Persistence) -> Self where FlowRepresentableType.WorkflowInput == Never {
//        Self(previous: self,
//             launchStyle: launchStyle,
//             modifierClosure: modifierClosure ?? { _ in },
//             flowPersistenceClosure: { _ in persistence().rawValue })
//    }
    // swiftlint:enable trailing_closure
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowItem {
    /// Sets the presentationType on the `FlowRepresentable` of the `WorkflowItem`.
    public func presentationType(_ presentationType: @escaping @autoclosure () -> LaunchStyle.SwiftUI.PresentationType) -> Self {
        Self(previous: self, presentationType: presentationType())
    }
}
//// swiftlint:enable line_length
