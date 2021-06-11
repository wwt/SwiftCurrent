# Interested in seeing examples of Workflow in action?
Start by cloning the repo and checking out the 'WorkflowExample' scheme. This should give you a decent idea of how the library works.  If you want to create a new project, read on.

# CocoaPods with Programmatic Views

## Adding the dependency
```ruby
pod 'DynamicWorkflow/UIKit'
```
Add the above line to your Podfile.

For more installation instructions, see the wiki on [installation](https://github.com/wwt/Workflow/wiki/Installation).

## Create your view controllers
Create two view controllers that inherit from [UIWorkflowItem<I, O>](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Classes/UIWorkflowItem.html).

```swift
import UIKit
import Workflow
import WorkflowUIKit

class FirstViewController: UIWorkflowItem<String, String>, FlowRepresentable {
    private let name: String
    private let emailTextField = UITextField()
    private let welcomeLabel = UILabel()
    private let saveButton = UIButton()

    required init(with name: String) {
        self.name = name
        super.init(nibName: nil, bundle: nil)

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

    required init?(coder: NSCoder) { nil }

    @objc private func savePressed() {
        proceedInWorkflow(emailTextField.text ?? "")
    }
}

// This screen shows an employee only screen
class SecondViewController: UIWorkflowItem<String, String>, FlowRepresentable {
    private let email: String
    private let emailLabel = UILabel()
    private let nextButton = UIButton()

    required init(with email: String) {
        self.email = email
        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = .systemGray5

        emailLabel.text = "Entered: \(email)"

        nextButton.setTitle("Next", for: .normal)
        nextButton.setTitleColor(.systemBlue, for: .normal)
        nextButton.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)

        view.addSubview(emailLabel)
        view.addSubview(nextButton)

        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nextButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 16).isActive = true
    }

    required init?(coder: NSCoder) { nil }

    func shouldLoad() -> Bool { email.contains("@wwt.com") }

    @objc private func nextPressed() {
        proceedInWorkflow(email)
    }
}
```
### Let's talk about what is going on with these view controllers.
#### **What's this `shouldLoad()`?**
<details>

It is part of the [FlowRepresentable](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/FlowRepresentable.html) protocol. It has default implementations created for your convenience but is still implementable if you want to control when a [FlowRepresentable](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/FlowRepresentable.html) should load in the work flow.  It is called after `init` but before `viewDidLoad()`.
</details>

## Launching the [Workflow](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Classes/Workflow.html)
Next, we create a [Workflow](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Classes/Workflow.html) that is initialized with our [FlowRepresentable](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/FlowRepresentable.html)s and launch it from a view controller that is already loaded onto the screen (in our case, the 'ViewController' class provided by Xcode).

```swift
import UIKit
import Workflow

class ViewController: UIViewController {
    private let launchButton = UIButton()

    init() {
        super.init(nibName: nil, bundle: nil)

        launchButton.setTitle("Launch Workflow", for: .normal)
        launchButton.addTarget(self, action: #selector(launchWorkflow), for: .touchUpInside)

        view.addSubview(launchButton)

        launchButton.translatesAutoresizingMaskIntoConstraints = false
        launchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        launchButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func launchWorkflow() {
        let workflow = Workflow(FirstViewController.self)
            .thenPresent(SecondViewController.self)

        launchInto(workflow, args: "Noble Six") { passedArgs in
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
### Let's discuss what's going on here.
#### **Where is the type safety, I heard about?**
<details>

The [Workflow](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Classes/Workflow.html) has compile-time type safety on the Input/Output types of the supplied [FlowRepresentable](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/FlowRepresentable.html)s. This means that you will get a build error if the output of `FirstViewController` does not match the input type of `SecondViewController`.
</details>

#### **What's going on with this `passedArgs`?**
<details>

The `onFinish` closure for `launchInto(_:args:onFinish:)` provides the last passed [AnyWorkflow.PassedArgs](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Classes/AnyWorkflow/PassedArgs.html) in the work flow. For this Workflow, that could be the output of `FirstViewController` or `SecondViewController` depending on the email signature typed in `FirstViewController`. To extract the value, we unwrap the variable within the case of `.args()` as we expect this workflow to return some argument.
</details>

#### **Why call `abandon()`?**
<details>

Calling `abandon()` closes all the views launched as part of the workflow, leaving you back on `ViewController`.
</details>

## Testing

### Installing test dependencies
For our test example, we will be using a library called [UIUTest](https://github.com/nallick/UIUTest). It is optional for testing Workflow, but in order for the example to be copyable, you will need to add
```ruby
pod 'UIUTest'
```
to your test target.

### Creating the tests

```swift
import XCTest
import UIUTest
import Workflow

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

        (testViewController.view.viewWithAccessibilityIdentifier("finish") as? UIButton)?.simulateTouch() // UIUTest helper

        XCTAssert(proceedInWorkflowCalled, "proceedInWorkflow should be called")
    }
}
```
While this team finds that testing our view controllers with [UIUTest](https://github.com/nallick/UIUTest) allows us to decrease the visibility of our properties and provide better coverage, [UIUTest](https://github.com/nallick/UIUTest) is not needed for testing Workflow. If you do not want to take the dependency, you will have to elevate visibility or find a way to invoke the `finishPressed` method.

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
