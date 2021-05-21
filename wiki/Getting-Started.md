So you're interested in trying this out. Start by cloning the repo and checking out the 'WorkflowExample' scheme. This should give you a decent idea of how the library works conceptually.

## Getting the project started
For this guide, we will create a new iOS application project in Xcode, using UIKit and Storyboards for the views.  We will also use Cocoapods for pulling in Workflow, so be sure to initialize your project with 
```ruby
pod init
```
and add 
```ruby
pod 'DynamicWorkflow/UIKit'
```
to your Podfile.

For more installation instructions, see the wiki on [installation](https://github.com/wwt/Workflow/wiki/Installation).

## Creating your first screen with Workflow


Let's jump into Swift by creating a convenience protocol to load the storyboard

```swift
import Workflow

extension StoryboardLoadable {
    static var storyboardId: String { String(describing: Self.self) }
}

protocol MainStoryboardLoadable: StoryboardLoadable {}
extension MainStoryboardLoadable {
    static var storyboard: UIStoryboard { UIStoryboard(name: "Main", bundle: Bundle(for: Self.self)) }
}
```

To begin a workflow, we create a couple of FlowRepresentables

```swift
import UIKit
import Workflow

class FirstViewController: UIWorkflowItem<String, String>, MainStoryboardLoadable {
    private let name: String

    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var welcomeLabel: UILabel! {
        willSet(this) {
            this.text = ["Welcome", name].compactMap { $0 }.joined(separator: " ") + "!"
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
    let email: String
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

Next, we create a Workflow object that is initialized with our FlowRepresentables

NOTE: our second FlowRepresentable must take as input the same type output by our first FlowRepresentable


```swift
import UIKit
import Workflow
class ViewController: UIViewController {
    @IBAction func launchWorkflow() {
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
