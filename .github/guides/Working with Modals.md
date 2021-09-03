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
When you use a presentation type of `LaunchStyle.SwiftUI.PresentationType.modal` you can optionally pass it a `LaunchStyle.SwiftUI.ModalPresentationStyle`.

#### Example:
The following will use a full screen cover:
```swift
NavigationView {
    WorkflowLauncher(isLaunched: .constant(true)) {
        thenProceed(with: FirstView.self) {
            thenProceed(with: SecondView.self).presentationType(.modal(.fullScreenCover))
        }
    }
}
```