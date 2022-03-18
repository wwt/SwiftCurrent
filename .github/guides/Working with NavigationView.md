### Presentation Types
When constructing a workflow, you can use `WorkflowItem.presentationType(_:)` along with a valid `LaunchStyle.SwiftUI.PresentationType` to control how a `FlowRepresentable` will be displayed. This is how you'll describe your navigation links and keep your view ignorant of the context it's displayed in.

#### Example
```swift
NavigationView {
    WorkflowView {
        WorkflowItem(FirstView.self)
            .presentationType(.navigationLink)
        WorkflowItem(SecondView.self)
    }
}
```

With that, you've described that `FirstView` should be wrapped in a `NavigationLink` when presented. When it calls `FlowRepresentable.proceedInWorkflow()`, it'll present `SecondView` using that `NavigationLink`.

> **NOTE:** The `NavigationLink` is in the background of the view to prevent your entire view from being tappable.

### Different NavigationView Styles
SwiftCurrent comes with a convenience function on `WorkflowView` that tries to pick the best `NavigationViewStyle` for a `Workflow`. Normally that's stack-based navigation.

#### Example
The earlier example could be rewritten as:
```swift
WorkflowView {
    WorkflowItem(FirstView.self)
        .presentationType(.navigationLink)
    WorkflowItem(SecondView.self)
}.embedInNavigationView()
```

This will select the stack-based navigation wherever it is available; otherwise it uses the default navigation style. 

If you want to use column-based navigation you can simply manage it yourself:

```swift
NavigationView {
    FirstColumn() // Could ALSO be a workflow
    WorkflowView {
        WorkflowItem(FirstView.self)
            .presentationType(.navigationLink)
        WorkflowItem(SecondView.self)
    } // don't call embedInNavigationView here
}
```
