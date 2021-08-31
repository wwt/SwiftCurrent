## Overview

This guide will walk you through getting a `Workflow` up and running in a new iOS project.  If you would like to see an existing project, clone the repo and view the `UIKitExample` scheme in `SwiftCurrent.xcworkspace`.

The app in this guide is going to be very simple.  It consists of a screen that will launch the `Workflow`, a screen to enter an email address, and an optional screen for when the user enters an email with `@wwt.com` in it.  Here is a preview of what the app will look like:

![Preview image of app](https://raw.githubusercontent.com/wwt/SwiftCurrent/main/.github/wiki/programmatic.gif)

## Adding the dependency

For instructions on SPM and CocoaPods, [check out our installation page.](https://github.com/wwt/SwiftCurrent/wiki/Installation#swift-package-manager)

## IMPORTANT NOTE

SwiftCurrent is so convenient that you may miss the couple lines that are calls to the library.  To make it easier, we've marked our code snippets with `// SwiftCurrent` to highlight items that are coming from the library.

## Create your view controllers

Create two view controllers that inherit from `UIWorkflowItem` and implement `FlowRepresentable`.

```swift
import UIKit
import SwiftCurrent
import SwiftCurrent_UIKit

class FirstViewController: UIWorkflowItem<String, String>, FlowRepresentable { // SwiftCurrent
    private let name: String
    private let emailTextField = UITextField()
    private let welcomeLabel = UILabel()
    private let saveButton = UIButton()

    required init(with name: String) { // SwiftCurrent
        self.name = name
        super.init(nibName: nil, bundle: nil)
        configureViews()
    }

    required init?(coder: NSCoder) { nil }

    @objc private func savePressed() {
        proceedInWorkflow(emailTextField.text ?? "") // SwiftCurrent
    }

    private func configureViews() {
        view.backgroundColor = .systemGray5

        welcomeLabel.text = "Welcome \(name)!"

        emailTextField.backgroundColor = .systemGray3
        emailTextField.borderStyle = .roundedRect
        emailTextField.placeholder = "Enter email..."

        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.systemBlue, for: .normal)
        saveButton.addTarget(self, action: #selector(savePressed), for: .touchUpInside)

        view.addSubview(welcomeLabel)
        view.addSubview(emailTextField)
        view.addSubview(saveButton)

        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        welcomeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true

        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailTextField.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 16).isActive = true
        emailTextField.widthAnchor.constraint(equalToConstant: 300).isActive = true

        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        saveButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 24).isActive = true
    }
}

// This screen shows an employee only screen
class SecondViewController: UIWorkflowItem<String, String>, FlowRepresentable { // SwiftCurrent
    private let email: String
    private let finishButton = UIButton()

    required init(with email: String) { // SwiftCurrent
        self.email = email
        super.init(nibName: nil, bundle: nil)
        configureViews()
    }

    required init?(coder: NSCoder) { nil }

    func shouldLoad() -> Bool { // SwiftCurrent
        return email.contains("@wwt.com")
    }

    @objc private func finishPressed() {
        proceedInWorkflow(email) // SwiftCurrent
    }

    private func configureViews() {
        view.backgroundColor = .systemGray5

        finishButton.setTitle("Finish", for: .normal)
        finishButton.setTitleColor(.systemBlue, for: .normal)
        finishButton.addTarget(self, action: #selector(finishPressed), for: .touchUpInside)
        finishButton.accessibilityIdentifier = "finish"

        view.addSubview(finishButton)

        finishButton.translatesAutoresizingMaskIntoConstraints = false
        finishButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        finishButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
```

### Let's talk about what is going on with these view controllers

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
    private let launchButton = UIButton()

    override func viewDidLoad() {
        launchButton.setTitle("Launch Workflow", for: .normal)
        launchButton.setTitleColor(.systemBlue, for: .normal)
        launchButton.addTarget(self, action: #selector(didTapLaunchWorkflow), for: .touchUpInside)

        view.addSubview(launchButton)

        launchButton.translatesAutoresizingMaskIntoConstraints = false
        launchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        launchButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    @objc private func didTapLaunchWorkflow() {
        let workflow = Workflow(FirstViewController.self) // SwiftCurrent
            .thenPresent(SecondViewController.self) // SwiftCurrent

        launchInto(workflow, args: "Noble Six") { passedArgs in // SwiftCurrent
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

Calling `Workflow.abandon()` closes all the views launched as part of the workflow, leaving you back on `ViewController`.
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