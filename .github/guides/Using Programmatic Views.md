## Overview

This guide will walk you through getting a `Workflow` up and running in a new iOS project. If you would like to see an existing project, clone the repo and view the `UIKitExample` scheme in `SwiftCurrent.xcworkspace`.

The app in this guide is going to be very simple. It consists of a screen that will launch the `Workflow`, a screen to enter an email address, and an optional screen for when the user enters an email with `@wwt.com` in it.  Here is a preview of what the app will look like:

![Preview image of app](https://user-images.githubusercontent.com/79471462/131556322-56757c1d-e4ec-4581-a47c-969f536e3893.gif)

## Adding the Dependency

For instructions on SPM and CocoaPods, [check out our installation page.](installation.html#swift-package-manager)

## IMPORTANT NOTE

SwiftCurrent is so convenient that you may miss the couple lines that are calls to the library.  To make it easier, we've marked our code snippets with `// SwiftCurrent` to highlight items that are coming from the library.

## Create Your View Controllers

Create two view controllers that inherit from `UIWorkflowItem` and implement `FlowRepresentable`.

First view controller:

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
```

Second view controller:

```swift
import UIKit
import SwiftCurrent
import SwiftCurrent_UIKit

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

### What Is Going on With These View Controllers?

#### **What's this `shouldLoad()`?**

<details>

<code>FlowRepresentable.shouldLoad()</code> is part of the <code>FlowRepresentable</code> protocol. It has default implementations created for your convenience but is still implementable if you want to control when a <code>FlowRepresentable</code> should load in the workflow. It is called after <code>init</code> but before <code>viewDidLoad()</code>.
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
            .thenProceed(with: SecondViewController.self) // SwiftCurrent

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

### What Is Going on Here?

#### **Where is the type safety I heard about?**

<details>

The </code>Workflow</code> has compile-time type safety on the Input/Output types of the supplied <code>FlowRepresentable</code>s. This means that you will get a build error if the output of <code>FirstViewController</code> does not match the input type of <code>SecondViewController</code>.
</details>

#### **What's going on with this `passedArgs`?**

<details>

The <code>onFinish</code> closure for <code>UIViewController.launchInto(_:args:withLaunchStyle:onFinish:)</code> provides the last passed <code>AnyWorkflow.PassedArgs</code> in the workflow. For this <code>Workflow</code>, that could be the output of <code>FirstViewController</code> or <code>SecondViewController</code> depending on the email signature typed in <code>FirstViewController</code>. To extract the value, we unwrap the variable within the case of <code>.args()</code> as we expect this workflow to return some argument.
</details>

#### **Why call `abandon()`?**

<details>

Calling <code>Workflow.abandon()</code> closes all the views launched as part of the workflow, leaving you back on <code>ViewController</code>.
</details>

## Testing

### Installing Test Dependencies

For our test example, we are using a library called [UIUTest](https://github.com/nallick/UIUTest). It is optional for testing SwiftCurrent, but in order for the example to be copyable, you will need to add the UIUTest Swift Package to your test target.

### Creating Tests

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

#### **What is going on with `testSecondViewControllerDoesNotLoadWhenInputIsEmpty`?**

<details>
This test is super simple. We create the view controller in a way that will go through the correct init, with expected arguments. Then we call <code>shouldLoad</code> to validate if the provided input gets us the results we want.
</details>

#### **What is going on with `testProceedPassesThroughInput`?**

<details>
At a high level, we are loading the view controller for testing (similar to before but now with an added step of triggering lifecycle events). We update the <code>proceedInWorkflow</code> closure so that we can confirm it was called. Finally, we invoke the method that will call proceed. The assert is verifying that the output is the same as the input, as this view controller is passing it through.
</details>

#### **I added UIUTest, why isn't it hitting the finish button?**

<details>
It's easy to forget to set the accessibility identifier on the button, please check that first. Second, if you don't call <code>loadForTesting()</code>, your view controller doesn't make it to the window and the hit testing of <code>simulateTouch()</code> will also fail. Finally, make sure the button is visible and tappable on the simulator you are using.
</details>

## Interoperability With SwiftUI
You can use your SwiftUI `View`s that are `FlowRepresentable` in your UIKit workflows. Start with your `View`.

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

Now in your UIKit workflow, simply use a `HostedWorkflowItem`.

```swift
launchInto(Workflow(HostedWorkflowItem<SwiftUIView>.self)) // SwiftCurrent
```
