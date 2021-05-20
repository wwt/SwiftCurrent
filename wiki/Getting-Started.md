So you're interested in trying this out. Start by cloning the repo and checking out the 'WorkflowExample' scheme. This should give you a decent idea of how the library works conceptually.

### Installation
For all installation instructions, see the wiki on [installation](https://github.com/wwt/Workflow/wiki/Installation).  For this guide, we will use Cocoapods.  Add this to your Podfile:
```ruby
pod 'DynamicWorkflow/UIKit'
```
And run a `pod install`.

### How to build an app with Workflow
Start with your views. For the purposes of this document we'll assume you're using UIKit and not SwiftUI. When you start a new iOS project there's 1 view controller named "ViewController" with no logic in it. Let's keep that there, because we need a starting point.

For views you want to display from now on we're going to create them as FlowRepresentable. So create a new view.
```swift
class FirstViewController: UIWorkflowItem<String> {
    var name:String?
}

extension FirstViewController: FlowRepresentable {
    func shouldLoad(with name: String) -> Bool {
        self.name = name
        return true
    }
    static func instance() -> AnyFlowRepresentable {
        return UIStoryboard(name: "Main", bundle: Bundle(for: FirstViewController.self)).instantiateViewController(withIdentifier: "FirstViewController") as! FirstViewController
    }
}
```

Okay a couple things to notice. 
- We're using the *optional* convenience class `UIWorkflowItem` to describe this view takes in a `String`, if no `String` is passed to it, the view will not load. 
- We've slightly modified the method signature of `shouldLoad` to use `name` instead of `args`. 
- We're pointing to a storyboard that has a view controller with an identifier the same as our class name.

Now from `ViewController` we can create a new action
```swift
class ViewController: UIViewController {
    @IBAction func launchWorkflow() {
        launchInto([ FirstViewController.self ], args: "Some Name")
    }
}
```

Congratulations! You've created your first FlowRepresentable, not too hard eh?

On `FirstViewController` let's add a `UITextField` so the user can enter their email address, a `UILabel` to welcome them and a `UIButton` for them to save.

```swift
class FirstViewController: UIWorkflowItem<String> {
    //...
    @IBOutlet weak var welcomeLabel:UILabel! {
        willSet(this) {
            this.text = ["Welcome", name].compactMap { $0 }.joined(separator: " ") + "!"
        }
    }
    @IBOutlet weak var emailTextField:UITextField!

    @IBAction func savePressed() {
        proceedInWorkflow(emailTextField.text)
    }
}
```

Now when they press the button their email gets passed as data. Let's modify our original workflow launcher to do something with that data:

```swift
// back in ViewController.swift
@IBAction func launchWorkflow() {
    let workflow:Workflow = [ FirstViewController.self ]
    launchInto(workflow, args: "Some Name") { email in 
        workflow.abandon()
        print(String(describing: email))
    }
}
```

Now after the user hits the button their email will be printed to the console. Congratulations, you now know how to pass data!

Things to notice:
- Because `FirstViewController` was also the last view in the workflow it passes data back to the closure we specified when we called `launchInto`
- We extracted our workflow to a variable so that we could call `abandon` on it after the last view calls our callback. This lets us remove all views in the workflow from the screen

### Next steps
Try defining a `SecondViewController` that takes in a more complex object. Modify `FirstViewController` to pass that argument in the `proceedInWorkflow` call and you'll see how, as long as the type matches `SecondViewController`'s `shouldLoad` method is called with the data from the previous view.