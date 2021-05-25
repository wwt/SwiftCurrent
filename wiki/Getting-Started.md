# Interested in seeing examples of Workflow in action?
Start by cloning the repo and checking out the 'WorkflowExample' scheme. This should give you a decent idea of how the library works.  If you want to create a new project, read on.

# Cocoapods with Storyboards

## Getting a new project started
```ruby
pod 'DynamicWorkflow/UIKit'
```
Add the above line to your Podfile.

For more installation instructions, see the wiki on [installation](https://github.com/wwt/Workflow/wiki/Installation).

## Create the convenience protocols for storyboard loading
It is best practice to use the [StoryboardLoadable](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/StoryboardLoadable.html) protocol to connect your [FlowRepresentable](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/FlowRepresentable.html) to your Storyboard.  Additionally, to limit the amount of duplicate code, you can make a convenience protocol for each storyboard.
```swift
import Workflow

extension StoryboardLoadable {
    static var storyboardId: String { String(describing: Self.self) }
}

protocol MainStoryboardLoadable: StoryboardLoadable { }
extension MainStoryboardLoadable {
    static var storyboard: UIStoryboard { UIStoryboard(name: "Main", bundle: Bundle(for: Self.self)) }
}
```
NOTE: [StoryboardLoadable](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/StoryboardLoadable.html) is only available in iOS 13.0 and later.

## Create your view controllers.
First, create two view controllers that both conform to `MainStoryboardLoadable` and inherit from [UIWorkflowItem<I, O>](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Classes/UIWorkflowItem.html).

```swift
import UIKit
import Workflow

class FirstViewController: UIWorkflowItem<String, String>, MainStoryboardLoadable {
    private let name: String

    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var welcomeLabel: UILabel! {
        willSet(this) {
            this.text = "Welcome \(name)!"
        }
    }

    required init?(coder: NSCoder, with name: String) {
        self.name = name
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @IBAction private func savePressed(_ sender: Any) {
        proceedInWorkflow(emailTextField.text ?? "")
    }
}

// This screen shows an employee only screen
class SecondViewController: UIWorkflowItem<String, String>, MainStoryboardLoadable {
    private let email: String
    required init?(coder: NSCoder, with email: String) {
        self.email = email
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @IBAction private func finishPressed(_ sender: Any) {
        proceedInWorkflow(email)
    }

    func shouldLoad() -> Bool {
        return email.contains("@wwt.com")
    }
}
```
### Let's talk about what is going on with these view controllers.
#### **Where are the [FlowRepresentables](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/FlowRepresentable.html) you mentioned earlier?**
<details> 

You could declare these view controllers with `class FirstViewController: UIWorkflowItem<String, String>, FlowRepresentable, MainStoryboardLoadable`, but the [FlowRepresentable](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/FlowRepresentable.html) is not specifically needed, so we excluded it from our example.

#### **Why is [FlowRepresentable](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/FlowRepresentable.html) not needed in the declaration?**
<details>

1. Each view controller inherits from the *optional* [UIWorkflowItem<I, O>](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Classes/UIWorkflowItem.html) class.  This class removes some of the boilerplate that normally comes with a [FlowRepresentable](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/FlowRepresentable.html).
    - Your view controller will not be a [FlowRepresentable](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/FlowRepresentable.html) by inheriting [UIWorkflowItem](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Classes/UIWorkflowItem.html).
1. `MainStoryboardLoadable` inherits from [StoryboardLoadable](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/StoryboardLoadable.html) which can only be applied to a `UIViewController` that is also a [FlowRepresentable](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/FlowRepresentable.html).
1. Because [UIWorkflowItem](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Classes/UIWorkflowItem.html) partially implements the [FlowRepresentable](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/FlowRepresentable.html) protocol and [StoryboardLoadable](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/StoryboardLoadable.html) requires the remaining implementation along with its requirement to be applied to a [FlowRepresentable](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/FlowRepresentable.html), these view controllers become [FlowRepresentable](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/FlowRepresentable.html).
</details>
</details>

#### **Why these initializers?**
<details>

[StoryboardLoadable](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/StoryboardLoadable.html) helps guide XCode to give you compiler errors with the appropriate fix-its to generate `required init?(coder: NSCoder, with args: String)`. These initializers allow you to load from a storyboard while also having compile-time safety in your properties.  You will notice that both view controllers store the argument string on a `private let` property.
</details>

#### **What's this `shouldLoad()`?**
<details>

It is part of the [FlowRepresentable](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/FlowRepresentable.html) protocol. It has default implementations created for your convenience, but is still left implementable by you should you want to control when a [FlowRepresentable](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/FlowRepresentable.html) should load in the work flow.  It is called after `init` but before `viewDidLoad()`.
</details>

## Launching the [Workflow](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Classes/Workflow.html)
Next, we create a [Workflow](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Classes/Workflow.html) that is initialized with our [FlowRepresentable](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/FlowRepresentable.html)s, and launch it from a view controller that is already loaded onto the screen (here we use the default ViewController of a new iOS project).

```swift
import UIKit
import Workflow

class ViewController: UIViewController {
    @IBAction private func launchWorkflow() {
        let workflow = Workflow(FirstViewController.self)
                            .thenPresent(SecondViewController.self)
        launchInto(workflow, args: "Some Name") { passedArgs in
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
