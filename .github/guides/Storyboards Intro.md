## Overview

This guide will walk you through getting a `Workflow` up and running in a new iOS project.  If you would like to see an existing project, clone the repo and view the `UIKitExample` scheme in `SwiftCurrent.xcworkspace`.

The app in this guide is going to be very simple.  It consists of a screen that will launch the `Workflow`, a screen to enter an email address, and an optional screen for when the user enters an email with `@wwt.com` in it.  Here is a preview of what the app will look like:

![Preview image of app](https://raw.githubusercontent.com/wwt/SwiftCurrent/main/.github/wiki/storyboard.gif)

## Adding the dependency

For instructions on SPM and CocoaPods, [check out our installation page.](https://github.com/wwt/SwiftCurrent/wiki/Installation#swift-package-manager)

## IMPORTANT NOTE

SwiftCurrent is so convenient that you may miss the couple lines that are calls to the library.  To make it easier, we've marked our code snippets with `// SwiftCurrent` to highlight items that are coming from the library.

## Create the convenience protocols for storyboard loading

It is best practice to use the `StoryboardLoadable` protocol to connect your `FlowRepresentable` to your Storyboard.  Additionally, to limit the amount of duplicate code, you can make a convenience protocol for each storyboard.

```swift
import UIKit
import SwiftCurrent_UIKit

extension StoryboardLoadable { // SwiftCurrent
    // Assumes that your storyboardId will be the same as your UIViewController class name
    static var storyboardId: String { String(describing: Self.self) }
}

protocol MainStoryboardLoadable: StoryboardLoadable { }
extension MainStoryboardLoadable {
    static var storyboard: UIStoryboard { UIStoryboard(name: "Main", bundle: Bundle(for: Self.self)) }
}
```

> NOTE: `StoryboardLoadable` is only available in iOS 13.0 and later.

## Create your view controllers

Create two view controllers that both conform to `MainStoryboardLoadable` and inherit from `UIWorkflowItem`.

```swift
import UIKit
import SwiftCurrent_UIKit

class FirstViewController: UIWorkflowItem<String, String>, MainStoryboardLoadable { // SwiftCurrent
    private let name: String

    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var welcomeLabel: UILabel! {
        willSet(this) {
            this.text = "Welcome \(name)!"
        }
    }

    required init?(coder: NSCoder, with name: String) { // SwiftCurrent
        self.name = name
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) { nil }

    @IBAction private func savePressed(_ sender: Any) {
        proceedInWorkflow(emailTextField.text ?? "") // SwiftCurrent
    }
}

// This screen shows an employee only screen
class SecondViewController: UIWorkflowItem<String, String>, MainStoryboardLoadable { // SwiftCurrent
    private let email: String
    required init?(coder: NSCoder, with email: String) { // SwiftCurrent
        self.email = email
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) { nil }

    @IBAction private func finishPressed(_ sender: Any) {
        proceedInWorkflow(email) // SwiftCurrent
    }

    func shouldLoad() -> Bool { // SwiftCurrent
        return email.contains("@wwt.com")
    }
}
```

### Let's talk about what is going on with these view controllers

#### **Where are the `FlowRepresentable`s you mentioned earlier?**

<details>

You could declare these view controllers with `class FirstViewController: UIWorkflowItem<String, String>, FlowRepresentable, MainStoryboardLoadable`, but the `FlowRepresentable` is not specifically needed, so we excluded it from our example.
</details>

#### **Why is `FlowRepresentable` not needed in the declaration?**

<details>

These view controllers adhere to `FlowRepresentable` by the combination of `UIWorkflowItem` and `StoryboardLoadable`.

1. The `UIWorkflowItem` class implements a subset of the requirements for `FlowRepresentable`.
1. `StoryboardLoadable` implements the remaining subset and requires that it is only applied to a `FlowRepresentable`.

</details>

#### **Why these initializers?**

<details>

`StoryboardLoadable` helps guide XCode to give you compiler errors with the appropriate fix-its to generate `required init?(coder: NSCoder, with args: String)`. These initializers allow you to load from a storyboard while also having compile-time safety in your properties.  You will notice that both view controllers store the argument string on a `private let` property.
</details>

#### **What's this `shouldLoad()`?**

<details>

It is part of the `FlowRepresentable` protocol. It has default implementations created for your convenience but is still implementable if you want to control when a `FlowRepresentable` should load in the work flow.  It is called after `init` but before `viewDidLoad()`.
</details>

## Launching the `Workflow`

Next, we create a `Workflow` that is initialized with our `FlowRepresentable`s and launch it from a view controller that is already loaded onto the screen (in our case, the 'ViewController' class provided by Xcode).

```swift
import UIKit
import SwiftCurrent
import SwiftCurrent_UIKit

class ViewController: UIViewController {
    @IBAction private func launchWorkflow() {
        let workflow = Workflow(FirstViewController.self) // SwiftCurrent
                            .thenPresent(SecondViewController.self) // SwiftCurrent
        
        launchInto(workflow, args: "Some Name") { passedArgs in // SwiftCurrent
            workflow.abandon()
            guard case .args(let emailAddress as String) = passedArgs else {
                print("No email address supplied")
                return
            }
            print(emailAddress)
        }
    }
}
```

### Let's discuss what's going on here

#### **Where is the type safety, I heard about?**

<details>

The `Workflow` has compile-time type safety on the Input/Output types of the supplied `FlowRepresentable`s. This means that you will get a build error if the output of `FirstViewController` does not match the input type of `SecondViewController`.
</details>

#### **What's going on with this `passedArgs`?**

<details>

The `onFinish` closure for `Workflow.launchInto(_:args:onFinish:)` provides the last passed `AnyWorkflow.PassedArgs` in the work flow. For this Workflow, that could be the output of `FirstViewController` or `SecondViewController` depending on the email signature typed in `FirstViewController`. To extract the value, we unwrap the variable within the case of `.args()` as we expect this workflow to return some argument.
</details>

#### **Why call `abandon()`?**

<details>

Calling `abandon()` closes all the views launched as part of the workflow, leaving you back on `ViewController`.
</details>

## Testing

### Installing test dependencies

For our test example, we will be using a library called [UIUTest](https://github.com/nallick/UIUTest). It is optional for testing SwiftCurrent, but in order for the example to be copyable, you will need to add the UIUTest Swift Package
to your test target.

### Creating tests

```swift
import XCTest
import UIUTest
import SwiftCurrent

// This assumes your project was called GettingStarted.
@testable import GettingStarted

class SecondViewControllerTests: XCTestCase {
    func testSecondViewControllerDoesNotLoadWhenInputIsEmpty() {
        let ref = AnyFlowRepresentable(SecondViewController.self, args: .args(""))
        let testViewController = (ref.underlyingInstance as! SecondViewController)

        XCTAssertFalse(testViewController.shouldLoad(), "SecondViewController should not load")
    }

    func testSecondViewControllerLoadsWhenInputIsContainsWWTEmail() {
        let ref = AnyFlowRepresentable(SecondViewController.self, args: .args("Awesome.Possum@wwt.com"))
        let testViewController = (ref.underlyingInstance as! SecondViewController)

        XCTAssert(testViewController.shouldLoad(), "SecondViewController should load")
    }

    func testProceedPassesThroughInput() {
        // Arrange
        var proceedInWorkflowCalled = false
        let expectedString = "Awesome.Possum@wwt.com"
        let ref = AnyFlowRepresentable(SecondViewController.self, args: .args(expectedString))
        var testViewController = (ref.underlyingInstance as! SecondViewController)
        // Mimicking the lifecycle of the view controller
        _ = testViewController.shouldLoad()
        testViewController.loadForTesting() // UIUTest helper

        testViewController.proceedInWorkflowStorage = { passedArgs in
            proceedInWorkflowCalled = true
            XCTAssertEqual(passedArgs.extractArgs(defaultValue: "defaultValue used") as? String, expectedString)
        }

        // Act
        (testViewController.view.viewWithAccessibilityIdentifier("finish") as? UIButton)?.simulateTouch() // UIUTest helper

        // Assert
        XCTAssert(proceedInWorkflowCalled, "proceedInWorkflow should be called")
    }
}
```

While this team finds that testing our view controllers with [UIUTest](https://github.com/nallick/UIUTest) allows us to decrease the visibility of our properties and provide better coverage, [UIUTest](https://github.com/nallick/UIUTest) is not needed for testing SwiftCurrent. If you do not want to take the dependency, you will have to elevate visibility or find a way to invoke the `finishPressed` method.

#### **What is going on with: `testSecondViewControllerDoesNotLoadWhenInputIsEmpty`?**

<details>
This test is super simple. We create the view controller in a way that will go through the correct init, with expected arguments. Then we call `shouldLoad` to validate if the provided Input gets us the results we want.
</details>

#### **What is going on with: `testProceedPassesThroughInput`?**

<details>
At a high level we are loading the view controller for testing (similar to before but now with an added step of triggering lifecycle events). We update the `proceedInWorkflow` closure so that we can confirm it was called. Finally we invoke the method that will call proceed. The assert is verifying that the Output is the same as the input, as this view controller is passing it through.
</details>

#### **I added UIUTest, why isn't it hitting the finish button?**

<details>
It's easy to forget to set the accessibility identifier on the button, please check that first. Second, if you don't call `loadForTesting()` your view controller doesn't make it to the window and the hit testing of `simulateTouch()` will also fail. Finally, make sure the button is visible and tappable on the simulator you are using.
</details>

## BETA Interoperability With SwiftUI
You can use your SwiftUI `View`s that are `FlowRepresentable` in your UIKit workflows. Start with your `View`

```swift
import SwiftUI
import SwiftCurrent

struct SwiftUIView: View, FlowRepresentable { // SwiftCurrent
    weak var _workflowPointer: AnyFlowRepresentable? // SwiftCurrent

    var body: some View {
        Text("FR2")
    }
}

```

Now in your UIKit workflow simply use a `HostedWorkflowItem` (While in BETA, `import SwiftCurrent_SwiftUI` is necessary)

```swift
launchInto(Workflow(HostedWorkflowItem<SwiftUIView>.self)) // SwiftCurrent
```