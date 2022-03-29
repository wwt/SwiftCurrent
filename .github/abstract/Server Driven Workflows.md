### In SwiftUI
`WorkflowView` has an initializer that allows you to pass in an `AnyWorkflow`. `AnyWorkflow`s can be decoded from `Data` using either `JSONDecoder.decodeWorkflow(withAggregator:from:)`, or the `DecodeWorkflow` property wrapper.

You can use either JSON, YAML, or any other key/value based data formats to define a workflow with data provided you follow [our schema](https://github.com/wwt/WorkflowSchema). NOTE: Our schema plays well with VSCode if you copy examples from the repo.

When using server driven workflows be aware that your views will all be wrapped in an `AnyView`. This is not true when you define workflows in Swift. This could affect certain animations and potentially have a performance impact on SwiftUI. 

NOTE: The APIs for SwiftCurrent all accept any form of `Data`. This means you are free to use your own data formats, but it also means that data does not necessarily have to come from a server. You could feed it from a flat-file if you're writing a white-labelled application, for example.