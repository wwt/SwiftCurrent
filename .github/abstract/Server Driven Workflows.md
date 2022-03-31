### In SwiftUI
`WorkflowView` has an initializer that allows you to pass in an `AnyWorkflow`. `AnyWorkflow`s can be decoded from `Data` using either `JSONDecoder.decodeWorkflow(withAggregator:from:)`, or the `DecodeWorkflow` property wrapper.

You can use JSON, YAML, or any other key/value-based data formats to define a workflow with data provided you follow [our schema](https://github.com/wwt/WorkflowSchema).
> Our schema plays well with VSCode if you copy examples from the repo.

When using server driven workflows be aware that your views will all be wrapped in an `AnyView`. This is not true when you define workflows in Swift. This could affect certain animations and potentially have a performance impact on SwiftUI. 

NOTE: The APIs for SwiftCurrent all accept any form of `Data`. This means you are free to use your own data formats, but it also means that data does not necessarily have to come from a server. For example, you could feed it from a flat-file if you're writing a white-labeled application.

### What is an Aggregator?
`FlowRepresentableAggregator` is a simple protocol that identifies all types you wish to decode. It's how SwiftCurrent can take data and convert it into a `Workflow`. You can either create your own aggregator or [use our CLI utility](https://wwt.github.io/SwiftCurrent/generated-type-registry.html).

## Putting it all together

#### Step 1: Create your views
```swift
struct FirstView: View, FlowRepresentable, WorkflowDecodable {
    weak var _workflowPointer: AnyFlowRepresentable?

    var body: some View {
        Text("I am the first view!")
        Button("Proceed") { proceedInWorkflow() }
    }
}

struct SecondView: View, FlowRepresentable, WorkflowDecodable {
    weak var _workflowPointer: AnyFlowRepresentable?

    var body: some View {
        Text("I am the second view!")
        Button("Proceed") { proceedInWorkflow() }
    }
}

struct ThirdView: View, FlowRepresentable, WorkflowDecodable {
    weak var _workflowPointer: AnyFlowRepresentable?

    var body: some View {
        Text("I am the third view!")
    }
}
```

#### Step 2: Define your workflow
```json
{
    "$schema": "https://raw.githubusercontent.com/wwt/WorkflowSchema/main/workflow-schema.json",
    "schemaVersion": "v0.0.1",
    "sequence": [
        {
            "flowRepresentableName": "FirstView",
            "launchStyle": "navigationLink",
        },
        {
            "flowRepresentableName": "SecondView",
            "launchStyle": "navigationLink",
        },
        {
            "flowRepresentableName": "ThirdView",
            "launchStyle": "navigationLink",
        }
    ]
}
```

#### Step 3: Use your workflow definition
```swift
let aggregator = SwiftCurrentTypeRegistry() // If you use the CLI this will be generated, if not you'll need to create your own, see the docs for `FlowRepresentableAggregator` for more information.
let data: Data = getDefinedWorkflow() // from server or flat-file
let workflow = try JSONDecoder().decodeWorkflow(withAggregator: aggregator, from: data)

// In your view
WorkflowView(workflow: workflow).embedInNavigationView() // Our data specified navigation links, so we need to wrap this in a navigation view for them to work.
```