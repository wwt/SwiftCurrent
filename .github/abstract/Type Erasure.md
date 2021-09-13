Sometimes it may be desireable to explicitly remove type information. Often times this is when you want to pass around types with complicated generic signatures. SwiftCurrent, much like many of Apple's standard libraries, ships with several type erasers for your convenience. 

### `AnyWorkflow.PassedArgs`
The type `AnyWorkflow.PassedArgs` is worth calling out separately. It's very similar to Swift's standard `Optional` type, but with a crucial difference. Consumers of SwiftCurrent need to be able to clearly differentiate between `nil` being passed in a `workflow` that proceeded and no arguments at all being passed. So if a `FlowRepresentable.WorkflowInput` is `Any?` that means it can accept any kind of data, even if that data is optional, but data *must* be passed to it. If a `FlowRepresentable.WorkflowInput` is `AnyWorkflow.PassedArgs` it means that it can take any kind of data, including nil data, OR it can take no data at all. 