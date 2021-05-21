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
Start with your views. With your new iOS project there's 1 view controller named "ViewController" with no logic in it. Let's keep that there, because we need a starting point.

For views you want to display from now on we're going to create them as [FlowRepresentable](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/FlowRepresentable.html). So create a new view.
```swift
import Workflow

class FirstViewController: UIWorkflowItem<String, Never>, StoryboardLoadable {
    static var storyboardId: String { String(describing: Self.self) }
    static var storyboard: UIStoryboard { UIStoryboard(name: "Main", bundle: Bundle(for: Self.self)) }

    var name: String

    required init?(coder: NSCoder, with name: String) {
        self.name = name
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
```

Okay a couple things to notice. 
- We're using the *optional* convenience class [UIWorkflowItem](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Classes/UIWorkflowItem.html) to describe this view takes in a `String` and outputs `Never`, ~~if no `String` is passed to it, the view will not load.~~
- We're using the protocol [StoryboardLoadable](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/StoryboardLoadable.html) to integrate our [FlowRepresentable](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/FlowRepresentable.html) with our storyboard.
- We've slightly modified the method signature of `init` to use `name` instead of `args`. 
- We're pointing to a storyboard that has a view controller with an identifier the same as our class name.

Now from `ViewController` we can import Workflow and create a new action
```swift
import UIKit
import Workflow

class ViewController: UIViewController {
    @IBAction func launchWorkflow() {
        launchInto(Workflow(FirstViewController.self), args: "Some Name")
    }
}
```

Don't forget to hook everything up in storyboards.  And congratulations! You've created your first [FlowRepresentable](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/FlowRepresentable.html) and launched your first [Workflow](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Classes/Workflow.html)! Pretty simple.

## Enhancing the first screen

On `FirstViewController` let's add a `UITextField` so the user can enter their email address, a `UILabel` to welcome them and a `UIButton` for them to save. When saving we'll want to pass the textfield data forward, so we will also update our [UIWorkflowItem](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Classes/UIWorkflowItem.html) to specify `String?` as our output type.

```swift
class FirstViewController: UIWorkflowItem<String, String?>, StoryboardLoadable {
   // ...

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var welcomeLabel: UILabel! {
        willSet(this) {
            this.text = ["Welcome", name].compactMap { $0 }.joined(separator: " ") + "!"
        }
    }

    // ...

    @IBAction func savePressed(_ sender: Any) {
        proceedInWorkflow(emailTextField.text)
    }
}
```

Now when they press the button their email gets passed as data. Let's modify our original workflow launcher to do something with that data:

```swift
class ViewController: UIViewController {
    @IBAction func launchWorkflow() {
        let workflow = Workflow(FirstViewController.self)
        launchInto(workflow, args: "Some Name") { passedArgs in
            workflow.abandon()
            print(String(describing: passedArgs.extractArgs(defaultValue: nil)))
        }
    }
}
```

Now after the user hits the button their email will be printed to the console. Congratulations, you now know how to pass data!

Things to notice:
- Because `FirstViewController` was also the last view in the workflow it passes data back to the closure we specified when we called `launchInto`.  Also, the data is in the form of a [AnyWorkflow.PassedArgs](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Classes/AnyWorkflow/PassedArgs.html) which we have to extract the data from.
- We extracted our workflow to a variable so that we could call `abandon` on it after the last view calls our callback. This lets us remove all views in the workflow from the screen

## Refactors and improvements
### StoryboardLoadable
Up to this point we have been conforming `FirstViewController` to the [StoryboardLoadable](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/StoryboardLoadable.html) protocol, but we can refactor out a more convenient protocol to help us group our controllers together within a storyboard.  We'll continue to use `Main` as our storyboard, but let's create a more specialized protocol, like the example in [StoryboardLoadable](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/StoryboardLoadable.html).

```swift
extension StoryboardLoadable {
    static var storyboardId: String { String(describing: Self.self) }
}

protocol MainStoryboardLoadable: StoryboardLoadable {}
extension MainStoryboardLoadable {
    static var storyboard: UIStoryboard { UIStoryboard(name: "Main", bundle: Bundle(for: Self.self)) }
}
```

Then update FirstViewController to use the new specialized protocol.  With that change the view controller will look like this:

```swift
class FirstViewController: UIWorkflowItem<String, String>, MainStoryboardLoadable {
    var name: String

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var welcomeLabel: UILabel! {
        willSet(this) {
            this.text = ["Welcome", name].compactMap { $0 }.joined(separator: " ") + "!"
        }
    }

    required init?(coder: NSCoder, with name: String) {
        self.name = name
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @IBAction func savePressed(_ sender: Any) {
        proceedInWorkflow(emailTextField.text)
    }
}
```

### Extracting arguments
You probably noticed earlier on that the onFinish closure printed out an `Optional(Optional("Texfield text"))`.  We can improve this by changing out how we extract the argument.  Let's change the closure to: 
```swift
launchInto(workflow, args: "Some Name") { passedArgs in
    workflow.abandon()
    guard case .args(let emailAddress as String) = passedArgs else {
        print("No email address supplied")
        return
    }
    print(emailAddress)
}
```
Now when the print statement runs, it will print `"Texfield text"`.

## Make a second screen without UIWorkflowItem
We're setup very nicely to make [FlowRepresentable](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/FlowRepresentable.html)s quickly by using the convenience class [UIWorkflowItem](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Classes/UIWorkflowItem.html) and our specialized convenience protocol `MainStoryboardLoadable`. [UIWorkflowItem](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Classes/UIWorkflowItem.html) is not *necessary* for a [FlowRepresentable](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/FlowRepresentable.html).

Let's make another view controller without [UIWorkflowItem](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Classes/UIWorkflowItem.html).

```swift
import UIKit
import Workflow

class SecondViewController: UIViewController, FlowRepresentable, MainStoryboardLoadable {
    typealias WorkflowInput = String?
    typealias WorkflowOutput = String?

    let email: String
    weak var _workflowPointer: AnyFlowRepresentable?

    @IBOutlet weak var emailLabel: UILabel! {
        willSet(this) {
            this.text = "You entered: \(email)"
        }
    }

    required init?(coder: NSCoder, with email: String) {
        self.email = email
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @IBAction func finishPressed(_ sender: Any) {
        proceedInWorkflow(email)
    }
}
```

Then update your workflow to add the new screen.
```swift
@IBAction func launchWorkflow() {
    let workflow = Workflow(FirstViewController.self)
                    .thenPresent(SecondViewController.self)
    // ...
}
```


## What type safety looks like in Workflow
```swift
super small example of code that will not compile for type safety
```

# Next steps
Try defining a `SecondViewController` that takes in a more complex object. Modify `FirstViewController` to pass that argument in the `proceedInWorkflow` call and you'll see how, as long as the type matches `SecondViewController`'s `Input Type` method is called with the data from the previous view.






* Getting started should be the minimum for getting started (not all the things about workflow)
* A tutorial is different than a Getting Started.
* In order to get started, you do need to know what the type safety looks like.