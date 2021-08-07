## Overview

This guide will walk you through getting a [Workflow](https://wwt.github.io/SwiftCurrent/Classes/Workflow.html) up and running in a new iOS project.  If you would like to see an existing project, clone the repo and view the `SwiftUIExample` scheme in `SwiftCurrent.xcworkspace`.

The app in this guide is going to be very simple.  It consists of a view that will host the [WorkflowLauncher](https://wwt.github.io/SwiftCurrent/Structs/WorkflowLauncher.html), a view to enter an email address, and an optional view for when the user enters an email with `@wwt.com` in it.  Here is a preview of what the app will look like:

![Preview image of app](https://raw.githubusercontent.com/wwt/SwiftCurrent/main/wiki/swiftUI.gif)

## Adding the dependency

For instructions on SPM and CocoaPods, [check out our installation page.](https://github.com/wwt/SwiftCurrent/wiki/Installation#swift-package-manager)

## IMPORTANT NOTE

SwiftCurrent is so convenient that you may miss the couple lines that are calls to the library.  To make it easier, we've marked our code snippets with `// SwiftCurrent` to highlight items that are coming from the library.

## Create your views

Create two views that implement [FlowRepresentable](https://wwt.github.io/SwiftCurrent/Protocols/FlowRepresentable.html).

```swift
import SwiftUI
import SwiftCurrent

struct FirstView: View, FlowRepresentable { // SwiftCurrent
    typealias WorkflowOutput = String // SwiftCurrent
    weak var _workflowPointer: AnyFlowRepresentable? // SwiftCurrent

    @State private var email = ""
    private let name: String
    
    init(with name: String) { // SwiftCurrent
        self.name = name
    }

    var body: some View {
        VStack {
            Text("Welcome \(name)!")
            TextField("Enter email...", text: $email)
                .textContentType(.emailAddress)
            Button("Save") { proceedInWorkflow(email) }
        }
    }
}

struct FirstView_Previews: PreviewProvider {
    static var previews: some View {
        FirstView(with: "Example Name")
    }
}

struct SecondView: View, FlowRepresentable { // SwiftCurrent
    typealias WorkflowOutput = String // SwiftCurrent
    weak var _workflowPointer: AnyFlowRepresentable? // SwiftCurrent

    private let email: String

    init(with email: String) { // SwiftCurrent
        self.email = email
    }

    var body: some View {
        VStack {
            Button("Finish") { proceedInWorkflow(email) }
        }
    }

    func shouldLoad() -> Bool { // SwiftCurrent
        email.lowercased().contains("@wwt.com")
    }
}

struct SecondView_Previews: PreviewProvider {
    static var previews: some View {
        SecondView(with: "Example.Name@wwt.com")
    }
}
```

### Let's talk about what is going on with these views

#### **Why is `_workflowPointer` weak?**

<details>

The [FlowRepresentable](https://wwt.github.io/SwiftCurrent/Protocols/FlowRepresentable.html) protocol requires there to be a `_workflowPointer` on your object, but protocols cannot enforce you to use `weak`. If you do not put `weak var _workflowPointer`, the [FlowRepresentable](https://wwt.github.io/SwiftCurrent/Protocols/FlowRepresentable.html) will end up with a strong circular reference when placed in a [Workflow](https://wwt.github.io/SwiftCurrent/Classes/Workflow.html).
</details>

#### **What's this `shouldLoad()`?**

<details>

It is part of the [FlowRepresentable](https://wwt.github.io/SwiftCurrent/Protocols/FlowRepresentable.html) protocol. It has default implementations created for your convenience but is still implementable if you want to control when a [FlowRepresentable](https://wwt.github.io/SwiftCurrent/Protocols/FlowRepresentable.html) should load in the workflow.  It is called after `init` but before `body` in SwiftUI.
</details>

#### **Why is there a `WorkflowOutput` but no `WorkflowInput`?**

<details>

`WorkflowInput` is inferred from the initializer that you create. If you do not include an initializer, `WorkflowInput` will be `Never`; otherwise `WorkflowInput` will be the type supplied in the initializer.  `WorkflowOutput` cannot be inferred to be anything other than `Never`. This means you must manually provide `WorkflowOutput` a type when you want to pass data forward.
</details>

## Launching the [Workflow](https://wwt.github.io/SwiftCurrent/Classes/Workflow.html)

Next we add a [WorkflowLauncher](https://wwt.github.io/SwiftCurrent/Structs/WorkflowLauncher.html) to the body of our starting app view, in this case `ContentView`.

```swift
import SwiftUI
import SwiftCurrent_SwiftUI

struct ContentView: View {
    @State var workflowIsPresented = false
    var body: some View {
        if !workflowIsPresented {
            Button("Present") { $workflowIsPresented.wrappedValue = true }
        }
        WorkflowLauncher(isLaunched: $workflowIsPresented, startingArgs: "SwiftCurrent") // SwiftCurrent
            .thenProceed(with: WorkflowItem(FirstView.self) // SwiftCurrent
                            .applyModifiers { firstView in firstView.padding().border(Color.gray) })
            .thenProceed(with: WorkflowItem(SecondView.self) // SwiftCurrent
                            .applyModifiers { $0.padding().border(Color.gray) })
            .onFinish { passedArgs in // SwiftCurrent
                workflowIsPresented = false
                guard case .args(let emailAddress as String) = passedArgs else {
                    print("No email address supplied")
                    return
                }
                print(emailAddress)
            }
    }
}

struct Content_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
```

### Let's discuss what's going on here

#### **Wait, where is the [Workflow](https://wwt.github.io/SwiftCurrent/Classes/Workflow.html)?**

<details>

In SwiftUI, the [Workflow](https://wwt.github.io/SwiftCurrent/Classes/Workflow.html) type is handled by the library when you start with a [WorkflowLauncher](https://wwt.github.io/SwiftCurrent/Structs/WorkflowLauncher.html).
</details>

#### **Where is the type safety, I heard about?**

<details>

[WorkflowLauncher](https://wwt.github.io/SwiftCurrent/Structs/WorkflowLauncher.html) is specialized with your `startingArgs` type.  In [FlowRepresentable](https://wwt.github.io/SwiftCurrent/Protocols/FlowRepresentable.html), these types are supplied by the `WorkflowInput` and `WorkflowOutput` associated types.  These all work together to create compile-time type safety when creating your flow. This means that you will get a build error if the output of `FirstView` does not match the input type of `SecondView`.
</details>

#### **What's going on with this `startingArgs` and `passedArgs`?**

<details>

`startingArgs` are the [AnyWorkflow.PassedArgs](https://wwt.github.io/SwiftCurrent/Classes/AnyWorkflow/PassedArgs.html) handed to the first [FlowRepresentable](https://wwt.github.io/SwiftCurrent/Protocols/FlowRepresentable.html) in the workflow.  These arguments are used to pass data and determine if the view should load.

`passedArgs` are the [AnyWorkflow.PassedArgs](https://wwt.github.io/SwiftCurrent/Classes/AnyWorkflow/PassedArgs.html) coming from the last view in the workflow.  `onFinish` is only called when the user has gone through all the screens in the `Workflow` by navigation or skipping.  For this workflow, `passedArgs` is going to be the output of `FirstView` or `SecondView` depending on the email signature typed in `FirstView`.  To extract the value, we unwrap the variable within the case of `.args()` as we expect this workflow to return some argument.
</details>

## Interoperability With UIKit
You can use your `UIViewController`s that are [FlowRepresentable](https://wwt.github.io/SwiftCurrent/Protocols/FlowRepresentable.html) in your SwiftUI workflows. This is as seamless as it normally is to add to a workflow in SwiftUI. Start with your `UIViewController`

```swift
// This is programmatic but could just as easily have been StoryboardLoadable
final class FirstViewController: UIWorkflowItem<Never, Never>, FlowRepresentable { // SwiftCurrent
    typealias WorkflowOutput = String // SwiftCurrent
    let nextButton = UIButton()

    @objc private func nextPressed() {
        proceedInWorkflow("string value") // SwiftCurrent
    }

    override func viewDidLoad() {
        nextButton.setTitle("Next", for: .normal)
        nextButton.setTitleColor(.systemBlue, for: .normal)
        nextButton.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)

        view.addSubview(nextButton)

        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nextButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
```

Now in SwiftUI simply reference that controller.

```swift
WorkflowLauncher(isLaunched: $workflowIsPresented) // SwiftCurrent
    .thenProceed(with: WorkflowItem(FirstViewController.self)) // SwiftCurrent
    .thenProceed(with: WorkflowItem(SecondView.self))
```