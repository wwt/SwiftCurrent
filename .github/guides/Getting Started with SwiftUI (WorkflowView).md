## Overview

This guide will walk you through getting a `Workflow` up and running in a new iOS project.  If you would like to see an existing project, clone the repo and view the `SwiftUIExample` scheme in `SwiftCurrent.xcworkspace`.

The app in this guide is going to be very simple.  It consists of a view that will host the `WorkflowView`, a view to enter an email address, and an optional view for when the user enters an email with `@wwt.com` in it.  Here is a preview of what the app will look like:

![Preview image of app](https://user-images.githubusercontent.com/79471462/131556533-f2ad1e6c-9acd-4d62-94ac-9140c9718f95.gif)

## Adding the Dependency

For instructions using Swift Package Manager (SPM) and CocoaPods, [check out our installation page.](installation.html#swift-package-manager) This guide assumes you use SPM.

## IMPORTANT NOTE

SwiftCurrent is so convenient that you may miss the couple of lines that are calls to the library. To make it easier, we've marked our code snippets with `// SwiftCurrent` to highlight items that are coming from the library.

## Create Your Views

Create two views that implement `FlowRepresentable`.

First view:

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
            Button("Save") { proceedInWorkflow(email) } // SwiftCurrent
        }
    }
}

struct FirstView_Previews: PreviewProvider {
    static var previews: some View {
        FirstView(with: "Example Name")
    }
}
```

Second view:

```swift
import SwiftUI
import SwiftCurrent

struct SecondView: View, FlowRepresentable { // SwiftCurrent
    typealias WorkflowOutput = String // SwiftCurrent
    weak var _workflowPointer: AnyFlowRepresentable? // SwiftCurrent

    private let email: String

    init(with email: String) { // SwiftCurrent
        self.email = email
    }

    var body: some View {
        VStack {
            Button("Finish") { proceedInWorkflow(email) } // SwiftCurrent
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

### What Is Going on With These Views?

#### **Why is `_workflowPointer` weak?**

<details>

<code>FlowRepresentable._workflowPointer</code> is required to conform to the <code>FlowRepresentable</code> protocol, but protocols cannot enforce you to use <code>weak</code>. If you do not put <code>weak var _workflowPointer</code>, the <code>FlowRepresentable</code> will end up with a strong circular reference when placed in a <code>Workflow</code>.
</details>

#### **What's this `shouldLoad()`?**

<details>

<code>FlowRepresentable.shouldLoad()</code> is part of the <code>FlowRepresentable</code> protocol. It has default implementations created for your convenience but is still implementable if you want to control when a <code>FlowRepresentable</code> should load in the workflow. It is called after <code>init</code> but before <code>body</code> in SwiftUI.
</details>

#### **Why is there a `WorkflowOutput` but no `WorkflowInput`?**

<details>

<code>FlowRepresentable.WorkflowInput</code> is inferred from the initializer that you create. If you do not include an initializer, <code>WorkflowInput</code> will be <code>Never</code>; otherwise <code>WorkflowInput</code> will be the type supplied in the initializer. <code>FlowRepresentable.WorkflowOutput</code> cannot be inferred to be anything other than `Never`. This means you must manually provide <code>WorkflowOutput</code> a type when you want to pass data forward.
</details>

## Launching the `Workflow`

Next we add a `WorkflowView` to the body of our starting app view, in this case `ContentView`.

```swift
import SwiftUI
import SwiftCurrent_SwiftUI

struct ContentView: View {
    @State var workflowIsPresented = false
    var body: some View {
        if !workflowIsPresented {
            Button("Present") { workflowIsPresented = true }
        } else {
            WorkflowView(isLaunched: $workflowIsPresented, launchingWith: "SwiftCurrent") { // SwiftCurrent
                WorkflowItem(FirstView.self) { // SwiftCurrent
                    .applyModifiers { firstView in firstView.padding().border(Color.gray) } // SwiftCurrent
                WorkflowItem(SecondView.self) // SwiftCurrent
                    .applyModifiers { $0.padding().border(Color.gray) } // SwiftCurrent
            }.onFinish { passedArgs in // SwiftCurrent
                workflowIsPresented = false
                guard case .args(let emailAddress as String) = passedArgs else {
                    print("No email address supplied")
                    return
                }
                print(emailAddress)
            }
        }
    }
}

struct Content_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
```

### What's Going on Here?

#### **Wait, where is the `Workflow`?**

<details>

In SwiftUI, the <code>Workflow</code> type is handled by the library when you start with a <code>WorkflowView</code>.
</details>

#### **Where is the type safety I heard about?**

<details>

<code>WorkflowView</code> is specialized with your <code>launchingWith</code> type. <code>FlowRepresentable</code> is specialized with the <code>FlowRepresentable.WorkflowInput</code> and <code>FlowRepresentable.WorkflowOutput</code> associated types. These all work together when creating your flow at run-time to ensure the validity of your <code>Workflow</code>. If the output of <code>FirstView</code> does not match the input of <code>SecondView</code>, the library will send an error when creating the <code>Workflow</code>.
</details>

#### **What's going on with this `launchingWith` and `passedArgs`?**

<details>

<code>launchingWith</code> are the <code>AnyWorkflow.PassedArgs</code> handed to the first <code>FlowRepresentable</code> in the workflow. These arguments are used to pass data and determine if the view should load.

<code>passedArgs</code> are the <code>AnyWorkflow.PassedArgs</code> coming from the last view in the workflow. <code>onFinish</code> is only called when the user has gone through all the screens in the <code>Workflow</code> by navigation or skipping. For this workflow, <code>passedArgs</code> is going to be the output of <code>FirstView</code> or <code>SecondView</code>, depending on the email signature typed in <code>FirstView</code>. To extract the value, we unwrap the variable within the case of <code>.args()</code> as we expect this workflow to return some argument.
</details>

## Interoperability With UIKit
You can use your `UIViewController`s that are `FlowRepresentable` in your SwiftUI workflows. This is as seamless as it normally is to add to a workflow in SwiftUI. Start with your `UIViewController`.

```swift
import UIKit
import SwiftCurrent
import SwiftCurrent_UIKit

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
WorkflowView(isLaunched: $workflowIsPresented) { // SwiftCurrent
    WorkflowItem(FirstViewController.self) // SwiftCurrent
    WorkflowItem(SecondView.self) // SwiftCurrent
}
```
