//
//  TestView.swift
//  SwiftUIExample
//
//  Created by Richard Gist on 9/1/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftUI
import SwiftCurrent_SwiftUI
import SwiftCurrent_UIKit

struct TestView: View {
    var body: some View {
        switch Environment.viewToTest {
            case .oneItemWorkflow: oneItemWorkflow
            case .twoItemWorkflow: twoItemWorkflow
            case .threeItemWorkflow: threeItemWorkflow
            case .fourItemWorkflow: fourItemWorkflow
            default: EmptyView()
        }
    }

    @ViewBuilder var oneItemWorkflow: some View {
        if Environment.shouldEmbedInNavStack {
            WorkflowView {
                WorkflowItem(FR1.self)
                    .persistence(persistence(for: FR1.self))
                    .presentationType(presentationType(for: FR1.self))
            }.embedInNavigationView()
        } else {
            WorkflowView {
                WorkflowItem(FR1.self)
                    .persistence(persistence(for: FR1.self))
                    .presentationType(presentationType(for: FR1.self))
            }
        }
    }

    @ViewBuilder var twoItemWorkflow: some View {
        if Environment.shouldEmbedInNavStack {
            WorkflowView {
                WorkflowItem(FR1.self)
                    .persistence(persistence(for: FR1.self))
                    .presentationType(presentationType(for: FR1.self))
                WorkflowItem(FR2.self)
                    .persistence(persistence(for: FR2.self))
                    .presentationType(presentationType(for: FR2.self))
            }.embedInNavigationView()
        } else {
            WorkflowView {
                WorkflowItem(FR1.self)
                    .persistence(persistence(for: FR1.self))
                    .presentationType(presentationType(for: FR1.self))
                WorkflowItem(FR2.self)
                    .persistence(persistence(for: FR2.self))
                    .presentationType(presentationType(for: FR2.self))
            }
        }
    }

    @ViewBuilder var threeItemWorkflow: some View {
        if Environment.shouldEmbedInNavStack {
            WorkflowView {
                WorkflowItem(FR1.self)
                    .persistence(persistence(for: FR1.self))
                    .presentationType(presentationType(for: FR1.self))
                WorkflowItem(FR2.self)
                    .persistence(persistence(for: FR2.self))
                    .presentationType(presentationType(for: FR2.self))
                WorkflowItem(FR3.self)
                    .persistence(persistence(for: FR2.self))
                    .presentationType(presentationType(for: FR2.self))
            }.embedInNavigationView()
        } else {
            WorkflowView {
                WorkflowItem(FR1.self)
                    .persistence(persistence(for: FR1.self))
                    .presentationType(presentationType(for: FR1.self))
                WorkflowItem(FR2.self)
                    .persistence(persistence(for: FR2.self))
                    .presentationType(presentationType(for: FR2.self))
                WorkflowItem(FR3.self)
                    .persistence(persistence(for: FR2.self))
                    .presentationType(presentationType(for: FR2.self))
            }
        }
    }

    @ViewBuilder var fourItemWorkflow: some View {
        if Environment.shouldEmbedInNavStack {
            WorkflowView {
                WorkflowItem(FR1.self)
                    .persistence(persistence(for: FR1.self))
                    .presentationType(presentationType(for: FR1.self))
                WorkflowItem(FR2.self)
                    .persistence(persistence(for: FR2.self))
                    .presentationType(presentationType(for: FR2.self))
                WorkflowItem(FR3.self)
                    .persistence(persistence(for: FR3.self))
                    .presentationType(presentationType(for: FR3.self))
                WorkflowItem(FR4.self)
                    .persistence(persistence(for: FR4.self))
                    .presentationType(presentationType(for: FR4.self))
            }.embedInNavigationView()
        } else {
            WorkflowView {
                WorkflowItem(FR1.self)
                    .persistence(persistence(for: FR1.self))
                    .presentationType(presentationType(for: FR1.self))
                WorkflowItem(FR2.self)
                    .persistence(persistence(for: FR2.self))
                    .presentationType(presentationType(for: FR2.self))
                WorkflowItem(FR3.self)
                    .persistence(persistence(for: FR3.self))
                    .presentationType(presentationType(for: FR3.self))
                WorkflowItem(FR4.self)
                    .persistence(persistence(for: FR4.self))
                    .presentationType(presentationType(for: FR4.self))
            }
        }
    }

    func persistence<F>(for type: F.Type) -> FlowPersistence.SwiftUI.Persistence {
        if case .persistence(_, let persistence) = Environment.persistence(for: type),
           let enumValue = FlowPersistence.SwiftUI.Persistence(rawValue: persistence) {
            return enumValue
        }
        return .default
    }

    func presentationType<F>(for type: F.Type) -> LaunchStyle.SwiftUI.PresentationType {
        if case .presentationType(_, let presentationType) = Environment.presentationType(for: type) {
            return presentationType
        }
        return .default
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}

import SwiftCurrent
struct FR1: View, FlowRepresentable {
    weak var _workflowPointer: AnyFlowRepresentable?
    var body: some View {
        VStack {
            Text("This is \(String(describing: Self.self))")
            Button("Navigate forward") { proceedInWorkflow() }
            Button("Navigate backward") { try? backUpInWorkflow() }
        }
    }

    func shouldLoad() -> Bool {
        guard case .shouldLoad(_, let shouldLoad) = Environment.shouldLoad(for: Self.self) else { return true }
        return shouldLoad
    }
}

struct FR2: View, FlowRepresentable {
    weak var _workflowPointer: AnyFlowRepresentable?
    var body: some View {
        VStack {
            Text("This is \(String(describing: Self.self))")
            Button("Navigate forward") { proceedInWorkflow() }
            Button("Navigate backward") { try? backUpInWorkflow() }
        }
    }

    func shouldLoad() -> Bool {
        guard case .shouldLoad(_, let shouldLoad) = Environment.shouldLoad(for: Self.self) else { return true }
        return shouldLoad
    }
}

struct FR3: View, FlowRepresentable {
    weak var _workflowPointer: AnyFlowRepresentable?
    var body: some View {
        VStack {
            Text("This is \(String(describing: Self.self))")
            Button("Navigate forward") { proceedInWorkflow() }
            Button("Navigate backward") { try? backUpInWorkflow() }
        }
    }

    func shouldLoad() -> Bool {
        guard case .shouldLoad(_, let shouldLoad) = Environment.shouldLoad(for: Self.self) else { return true }
        return shouldLoad
    }
}

struct FR4: View, FlowRepresentable {
    weak var _workflowPointer: AnyFlowRepresentable?
    var body: some View {
        VStack {
            Text("This is \(String(describing: Self.self))")
            Button("Navigate forward") { proceedInWorkflow() }
            Button("Navigate backward") { try? backUpInWorkflow() }
        }
    }

    func shouldLoad() -> Bool {
        guard case .shouldLoad(_, let shouldLoad) = Environment.shouldLoad(for: Self.self) else { return true }
        return shouldLoad
    }
}

final class FRUI1: UIWorkflowItem<Never, Never>, FlowRepresentable {
    private lazy var text: UITextField = {
        let textField = UITextField()
        textField.text = "This is: \(String(describing: Self.self))"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var navigateForwardButton: UIButton = {
        let button = UIButton(primaryAction: UIAction(title: "Navigate foward", handler: { [self] _ in
            proceedInWorkflow()
        }))
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var navigateBackwardButton: UIButton = {
        let button = UIButton(primaryAction: UIAction(title: "Navigate backward", handler: { [self] _ in
            try? backUpInWorkflow()
        }))
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        view.addSubview(text)
        view.addSubview(navigateForwardButton)
        view.addSubview(navigateBackwardButton)

        NSLayoutConstraint.activate([
            text.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            text.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            text.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            text.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            navigateForwardButton.topAnchor.constraint(equalTo: text.bottomAnchor, constant: 10),
            navigateForwardButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            navigateForwardButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            navigateBackwardButton.topAnchor.constraint(equalTo: navigateForwardButton.bottomAnchor, constant: 10),
            navigateBackwardButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            navigateBackwardButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
}

final class FRUI2: UIWorkflowItem<Never, Never>, FlowRepresentable {
    private lazy var text: UITextField = {
        let textField = UITextField()
        textField.text = "This is: \(String(describing: Self.self))"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var navigateForwardButton: UIButton = {
        let button = UIButton(primaryAction: UIAction(title: "Navigate foward", handler: { [self] _ in
            proceedInWorkflow()
        }))
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var navigateBackwardButton: UIButton = {
        let button = UIButton(primaryAction: UIAction(title: "Navigate backward", handler: { [self] _ in
            try? backUpInWorkflow()
        }))
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        view.addSubview(text)
        view.addSubview(navigateForwardButton)
        view.addSubview(navigateBackwardButton)

        NSLayoutConstraint.activate([
            text.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            text.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            text.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            text.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            navigateForwardButton.topAnchor.constraint(equalTo: text.bottomAnchor, constant: 10),
            navigateForwardButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            navigateForwardButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            navigateBackwardButton.topAnchor.constraint(equalTo: navigateForwardButton.bottomAnchor, constant: 10),
            navigateBackwardButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            navigateBackwardButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
}

final class FRUI3: UIWorkflowItem<Never, Never>, FlowRepresentable {
    private lazy var text: UITextField = {
        let textField = UITextField()
        textField.text = "This is: \(String(describing: Self.self))"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var navigateForwardButton: UIButton = {
        let button = UIButton(primaryAction: UIAction(title: "Navigate foward", handler: { [self] _ in
            proceedInWorkflow()
        }))
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var navigateBackwardButton: UIButton = {
        let button = UIButton(primaryAction: UIAction(title: "Navigate backward", handler: { [self] _ in
            try? backUpInWorkflow()
        }))
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        view.addSubview(text)
        view.addSubview(navigateForwardButton)
        view.addSubview(navigateBackwardButton)

        NSLayoutConstraint.activate([
            text.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            text.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            text.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            text.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            navigateForwardButton.topAnchor.constraint(equalTo: text.bottomAnchor, constant: 10),
            navigateForwardButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            navigateForwardButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            navigateBackwardButton.topAnchor.constraint(equalTo: navigateForwardButton.bottomAnchor, constant: 10),
            navigateBackwardButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            navigateBackwardButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
}

final class FRUI4: UIWorkflowItem<Never, Never>, FlowRepresentable {
    private lazy var text: UITextField = {
        let textField = UITextField()
        textField.text = "This is: \(String(describing: Self.self))"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var navigateForwardButton: UIButton = {
        let button = UIButton(primaryAction: UIAction(title: "Navigate foward", handler: { [self] _ in
            proceedInWorkflow()
        }))
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var navigateBackwardButton: UIButton = {
        let button = UIButton(primaryAction: UIAction(title: "Navigate backward", handler: { [self] _ in
            try? backUpInWorkflow()
        }))
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        view.addSubview(text)
        view.addSubview(navigateForwardButton)
        view.addSubview(navigateBackwardButton)

        NSLayoutConstraint.activate([
            text.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            text.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            text.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            text.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            navigateForwardButton.topAnchor.constraint(equalTo: text.bottomAnchor, constant: 10),
            navigateForwardButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            navigateForwardButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            navigateBackwardButton.topAnchor.constraint(equalTo: navigateForwardButton.bottomAnchor, constant: 10),
            navigateBackwardButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            navigateBackwardButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
}
