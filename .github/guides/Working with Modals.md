### Presentation Types
When you are constructing a workflow you can use `WorkflowItem.presentationType(_:)` along with a valid `LaunchStyle.SwiftUI.PresentationType` to control how a `FlowRepresentable` will be displayed. This is how you'll describe your modals and keep your view ignorant of the context it's displayed in.

#### Example:
```swift
NavigationView {
    WorkflowLauncher(isLaunched: .constant(true)) {
        thenProceed(with: FirstView.self) {
            thenProceed(with: SecondView.self).presentationType(.modal)
        }
    }
}
```

With that you've described that `FirstView` should be presented normally. When it calls `FlowRepresentable.proceedInWorkflow()` it'll present `SecondView` using the default SwiftUI modal (sheet).

> NOTE: Unlike `LaunchStyle.SwiftUI.PresentationType.navigationLink` you apply `LaunchStyle.SwiftUI.PresentationType.modal` to a view that should be launched modally.

### Different Modal Styles
As of right now presenting modals with sheets is the only supported modal style by SwiftCurrent. If you need a workaround you'll have to split your workflow into 2 sub-workflows and use `fullScreenCover` yourself. [Issue: #119](https://github.com/wwt/SwiftCurrent/issues/119) is tracking a feature request to add support for `fullScreenCover`. 