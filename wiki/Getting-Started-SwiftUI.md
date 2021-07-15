# [DRAFT] Swift Package Manager with Programmatic UIKit Views

~~This guide will walk you through getting a [Workflow](https://wwt.github.io/SwiftCurrent/Classes/Workflow.html) up and running in a new iOS project.  If you would like to see an existing project, clone the repo and view the `SwiftCurrentExample` scheme in `SwiftCurrent.xcworkspace`.~~

The app in this guide is going to be very simple.  It consists of a view that will hold the [WorkflowView](https://wwt.github.io/SwiftCurrent/Structs/WorkflowView.html), a view to enter an email address, and an optional view for if your email contains `@wwt.com`.  Here is a preview of what the app will look like:

![Preview image of app]

## Adding the dependency

For instructions on SPM and CocoaPods, [check out our installation page.](https://github.com/wwt/SwiftCurrent/wiki/Installation#swift-package-manager)

## IMPORTANT NOTE

SwiftCurrent is so convenient that you may miss the couple lines that are calls to the library.  To make it easier, we've marked our code snippets with `// SwiftCurrent` to highlight items that are coming from the library.

## Create your views

Create two views that implement [FlowRepresentable](https://wwt.github.io/SwiftCurrent/Protocols/FlowRepresentable.html).

```swift
import SwiftUI
import SwiftCurrent

struct FR1: View, FlowRepresentable { // SwiftCurrent
    typealias WorkflowOutput = String // SwiftCurrent
    weak var _workflowPointer: AnyFlowRepresentable? // SwiftCurrent

    @State private var email = ""
    private let name: String

    var body: some View {
        VStack {
            Text("Welcome \(name)!")
            TextField("Enter email...", text: $email)
                .textContentType(.emailAddress)
            Button("Save") { proceedInWorkflow(email) }
        }
    }

    init(with name: String) { // SwiftCurrent
        self.name = name
    }
}

struct FR1_Previews: PreviewProvider {
    static var previews: some View {
        FR1(with: "Example Name")
    }
}

struct FR2: View, FlowRepresentable { // SwiftCurrent
    typealias WorkflowOutput = String // SwiftCurrent
    weak var _workflowPointer: AnyFlowRepresentable? // SwiftCurrent

    private let email: String

    var body: some View {
        VStack {
            Button("Finish") { proceedInWorkflow(email) }
        }
    }

    init(with email: String) { // SwiftCurrent
        self.email = email
    }

    func shouldLoad() -> Bool { // SwiftCurrent
        email.lowercased().contains("@wwt.com")
    }
}

struct FR2_Previews: PreviewProvider {
    static var previews: some View {
        FR2(with: "Example.Name@wwt.com")
    }
}
```

### Let's talk about what is going on with these views

#### **What's this `shouldLoad()`?**

<details>

It is part of the [FlowRepresentable](https://wwt.github.io/SwiftCurrent/Protocols/FlowRepresentable.html) protocol. It has default implementations created for your convenience but is still implementable if you want to control when a [FlowRepresentable](https://wwt.github.io/SwiftCurrent/Protocols/FlowRepresentable.html) should load in the work flow.  It is called after `init` but before `body`.
</details>

## Launching the [Workflow](https://wwt.github.io/SwiftCurrent/Classes/Workflow.html)

PLACEHOLDER TEXT

```swift
import SwiftUI
import SwiftCurrent_SwiftUI

struct ContentView: View {
    @State var workflowIsPresented = false
    var body: some View {
        if workflowIsPresented {
            WorkflowView(isLaunched: .constant(true), startingArgs: "SwiftCurrent")
                .thenProceed(with: WorkflowItem(FR1.self)
                                .persistence(.removedAfterProceeding)
                                .applyModifiers { fr1 in fr1.padding().border(.gray) })
                .thenProceed(with: WorkflowItem(FR2.self)
                                .persistence(.removedAfterProceeding)
                                .applyModifiers { $0.padding().border(.gray) })
                .onFinish { passedArgs in
                    withAnimation { workflowIsPresented = false }
                    guard case .args(let emailAddress as String) = passedArgs else {
                        print("No email address supplied")
                        return
                    }
                    print(emailAddress)
                }
                .transition(.slide)
        } else {
            Button("Present") { $workflowIsPresented.wrappedValue = true }
        }
    }
}
```

### Let's discuss what's going on here

#### **Where is the type safety, I heard about?**

<details>

~~The [Workflow](https://wwt.github.io/SwiftCurrent/Classes/Workflow.html) has compile-time type safety on the Input/Output types of the supplied [FlowRepresentable](https://wwt.github.io/SwiftCurrent/Protocols/FlowRepresentable.html)s. This means that you will get a build error if the output of `FirstViewController` does not match the input type of `SecondViewController`.~~
</details>

#### **What's going on with this `startingArgs`?**

<details>

~~The `onFinish` closure for `launchInto(_:args:onFinish:)` provides the last passed [AnyWorkflow.PassedArgs](https://wwt.github.io/SwiftCurrent/Classes/AnyWorkflow/PassedArgs.html) in the work flow. For this Workflow, that could be the output of `FirstViewController` or `SecondViewController` depending on the email signature typed in `FirstViewController`. To extract the value, we unwrap the variable within the case of `.args()` as we expect this workflow to return some argument.~~
</details>
