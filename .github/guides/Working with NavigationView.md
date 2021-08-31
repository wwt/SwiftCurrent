### Presentation Types
When you are constructing a workflow you can use `WorkflowItem.presentationType(_:)` along with a valid `LaunchStyle.SwiftUI.PresentationType` to control how a `FlowRepresentable` will be displayed. This is how you'll describe your navigation links and keep your view ignorant of the context it's displayed in.

#### Example:
```swift
NavigationView {
    WorkflowLauncher(isLaunched: .constant(true)) {
        thenProceed(with: FirstView.self) {
            thenProceed(with: SecondView.self)
        }.presentationType(.navigationLink)
    }
}
```

With that you've described that `FirstView` should be wrapped in a `NavigationLink` when presented. So when it calls `FlowRepresentable.proceedInWorkflow()` it'll present `SecondView` using that `NavigationLink`.

> NOTE: The `NavigationLink` is in the background of the view, to prevent your entire view from being tappable.

### Different NavigationView Styles
SwiftCurrent comes with a convenience function on `WorkflowLauncher` that tries to pick the best `NavigationViewStyle` for a `Workflow`. Normally that's stack based navigation.

#### Example:
The earlier example could be rewritten as
```swift
WorkflowLauncher(isLaunched: .constant(true)) {
    thenProceed(with: FirstView.self) {
        thenProceed(with: SecondView.self)
    }.presentationType(.navigationLink)
}.embedInNavigationView()
```

This will select the stack based navigation wherever it is available, otherwise it uses the default navigation style. 

If you want to use column based navigation you can simply manage it yourself:

```swift
NavigationView {
    FirstColumn() // Could ALSO be a workflow
    WorkflowLauncher(isLaunched: .constant(true)) {
        thenProceed(with: FirstView.self) {
            thenProceed(with: SecondView.self)
        }.presentationType(.navigationLink)
    } // don't call embedInNavigationView here
}
```