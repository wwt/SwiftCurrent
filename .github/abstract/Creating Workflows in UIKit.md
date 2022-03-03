### Step 1
To create workflows in UIKit, start with a `UIViewController` that should be part of a `Workflow`, then modify it to be `FlowRepresentable`.

#### Example
```swift
import UIKit
import SwiftCurrent
import SwiftCurrent_UIKit

// This screen shows an employee only screen
class FirstViewController: UIWorkflowItem<String, String>, FlowRepresentable { // SwiftCurrent
    private let email: String
    private let finishButton = UIButton()

    required init(with email: String) { // SwiftCurrent
        self.email = email
        super.init(nibName: nil, bundle: nil)
        // Configure your view programmatically or look at StoryboardLoadable to use storyboards.
    }

    required init?(coder: NSCoder) { nil }

    @objc private func finishPressed() {
        proceedInWorkflow(email) // SwiftCurrent
    }
}
```

> **Note:** Call `FlowRepresentable.proceedInWorkflow()` to have your view move forward to the next item in the `Workflow` it is part of.

### Step 2
Define your `Workflow` and launch it. This is what allows you to configure or reorder your workflow.

#### Example
```swift
// From the ViewController you'd like to launch the workflow
@objc private func didTapLaunchWorkflow() {
    let workflow = Workflow(FirstViewController.self) // SwiftCurrent
        .thenProceed(with: SecondViewController.self) // SwiftCurrent

    launchInto(workflow, args: "Some starting arguments")
}
```
