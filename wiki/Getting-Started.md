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

For views you want to display from now on we're going to create them as [FlowRepresentable](). So create a new view.
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
- We're using the *optional* convenience class [UIWorkflowItem]() to describe this view takes in a `String` and outputs `Never`, ~~if no `String` is passed to it, the view will not load.~~
- We're using the *optional* convenience protocol [StoryboardLoadable]() to more easily integrate our [FlowRepresentable]() with our storyboard based UI.
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

Don't forget to hook everything up in storyboards.  And congratulations! You've created your first [FlowRepresentable]() and launched your first [Workflow]()! Pretty simple.

## Enhancing the first screen

On `FirstViewController` let's add a `UITextField` so the user can enter their email address, a `UILabel` to welcome them and a `UIButton` for them to save.

```swift
class FirstViewController: UIWorkflowItem<String, String?>, StoryboardLoadable {
   //...

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var welcomeLabel: UILabel! {
        willSet(this) {
            this.text = ["Welcome", name].compactMap { $0 }.joined(separator: " ") + "!"
        }
    }

    //...

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
- Because `FirstViewController` was also the last view in the workflow it passes data back to the closure we specified when we called `launchInto`
- We extracted our workflow to a variable so that we could call `abandon` on it after the last view calls our callback. This lets us remove all views in the workflow from the screen

### Next steps
Try defining a `SecondViewController` that takes in a more complex object. Modify `FirstViewController` to pass that argument in the `proceedInWorkflow` call and you'll see how, as long as the type matches `SecondViewController`'s `shouldLoad` method is called with the data from the previous view.