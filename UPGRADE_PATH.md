### Upgrade Paths:
Use this document to help you understand how to update between major versions of the library. We test upgrade paths when we ramp major versions and do our best to have the compiler help make a useful upgrade experience.

<details>
  <summary><b>V3 -> V3</b></summary>
  update imports and pod or SPM

</details>

<details>
  <summary><b>V2 -> V3</b></summary>
  
  #### Package Management:
  NOTE: We support both SwiftPM and CocoaPods now, pick whichever suits your needs best. The primary difference is that SwiftPM has different `import` statements for `import Workflow` and `import WorkflowUIKit`, CocoaPods just uses `import Workflow`.
  #### Update Pods
  1. Update Podfile to:
      ```ruby
      pod 'DynamicWorkflow/UIKit'
      ```
  1. run a `pod install`
  1. Your import statements will change from `import DynamicWorkflow` to `import Workflow`

  #### IF YOU USE STORYBOARDS
  There is now a protocol for those using Storyboards called StoryboardLoadable.  See [the docs](https://gitcdn.link/repo/wwt/Workflow/main/docs/Protocols/StoryboardLoadable.html) for more info.
  
  **IMPORTANT**: `StoryboardLoadable` has a minimum requirement of iOS 13. Be a little cautious of the Xcode fix-it here, it'll encourage you to add an `@available` attribute, or it may tell you to implement `_factory` methods. This is not correct, instead if you plan on using `StoryboardLoadable` you should just set your minimum iOS target to 13, otherwise you've gotta hand roll something. The implementation of `StoryboardLoadable` may help with hand rolling if that is what you decide to do.

  #### FlowRepresentable has Changed
  Please review [the FlowRepresentable docs](https://gitcdn.link/repo/wwt/Workflow/main/docs/Protocols/FlowRepresentable.html) to see the changes made there.
  The static `instance()` method is no longer required, instead a `FlowRepresentable` now has a dedicated initializer, if the `WorkflowInput` has a value you need `init(with args: WorkflowInput)`. If `WorkflowInput` is `Never` you simply need `init()`

  #### UIWorkflowItem has Changed
  If you were using `UIWorkflowItem<I>`, it has changed to `UIWorkflowItem<I, O>` where `I` is your input type and `O` is your output type.  See [the docs](https://gitcdn.link/repo/wwt/Workflow/main/docs/Classes/UIWorkflowItem.html) for more info.

  #### `shouldLoad` no Longer Takes Arguments
  Update shouldLoad methods as they are no longer mutating, nor do they take in parameters.  If you were doing any initializations during shouldLoad, that initialization should now happen in the initializer.  If you were requiring parameters to be passed into shouldLoad those should now be part of initialization and referenced on the object in shouldLoad.

  #### Type Safety Additions
  We no longer allow empty workflows, so if you instantiated a workflow like this:
  ```swift
  Workflow()
    .thenPresent(EnterAddressViewController.self)
  ```
  Then you will need to update it to this: 
  ```swift
  Workflow(EnterAddressViewController.self)
  ```
  This change was critical to allowing Type Safety within a Workflow.

  #### The `onFinish` Closure when Launching Workflows has Changed
  They now take an [`AnyWorkflow.PassedArgs`](https://gitcdn.link/repo/wwt/Workflow/main/docs/Classes/AnyWorkflow/PassedArgs.html) type to help consumers of the library differentiate between no arguments being passed, and nil being passed explicitly. So you go from this:
  ```swift
  // OLD
  let workflow = ...
  launchInto(Workflow(workflow) { [weak self] order in // order is an Any?
    workflow.abandon()
    self?.proceedInWorkflow(order)
  }
  ```
  To this:
  ```swift
  // NEW
  let workflow = ...
  launchInto(Workflow(EnterAddressViewController.self) { [weak self] passedArgs in // passedArgs is an AnyWorkflow.PassedArgs
    workflow.abandon()
    guard case .args(let order as Order) = passedArgs else { return } // type safety!
    self?.proceedInWorkflow(order)
  }
  ```
  
  #### The way you Test has Changed
  You used to be able to re-assign `proceedInWorkflow` to assert it was called with the args you expected, this has now slightly changed.
  To get the *exact* behavior as before use `_proceedInWorkflow` to re-assign that closure. 
  There's also `proceedInWorkflowStorage` which gives you the `AnyWorkflow.PassedArgs` used when `proceedInWorkflow` was called.
  
  If you were using some of the methods from our WorkflowExampleTests please look at how they're set up now, they're drastically different.
</details>

---

<details>
  <summary><b>V1 -> V2</b></summary>
  
  The biggest change here was a license change. We moved from MIT to Apache 2.0. Please assess and make sure you are willing to accept the new license.
</details>
