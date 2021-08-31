### Step 1:
To create workflows in SwiftUI you should start with a view that should be part of a `Workflow` and modify it to be `FlowRepresentable`

#### Example:
```swift
struct FirstView: View, FlowRepresentable {
    weak var _workflowPointer: AnyFlowRepresentable?

    var body: some View {
        VStack {
            Text("I am the first view!")
            Button("Proceed to the next item in the workflow") {
                proceedInWorkflow()
            }
        }
    }
}
```

> Note: The `_workflowPointer` is needed as an anchor point for your `Workflow`. You do not have to worry about setting it, you merely need space for it on your structs. SwiftUI actually does the exact same thing with a `_location` variable, it's just that Apple has secret compiler magic to hide that. Unfortunately, that compiler magic is not shared.

> Note: `Workflow.proceedInWorkflow()` is what you call to have your view move forward to the next item in the `Workflow` it is part of. 

### Step 2:
Define your `WorkflowLauncher`. This indicates whether the workflow is shown and describes what items are in it.

#### Example:
```swift
WorkflowLauncher(isLaunched: .constant(true)) { // Could also have been $someStateOrBindingBoolean
    thenProceed(with: FirstView.self) { // thenProceed is a function to create a `WorkflowItem`
        thenProceed(with: SecondView.self) { // Use closures to define what comes next
            thenProceed(with: ThirdView.self) // The final item needs no closures
        }
    }
}
```