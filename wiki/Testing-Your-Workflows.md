We all know that no library would be complete without a description of how to test it!

### Install
Start by installing the XCTest helpers by adding this to your podfile in your test target:
```ruby
pod DynamicWorkflow/XCTest
```

### Testing launching a workflow
During test runs *only* workflow broadcasts a notification when it's launched. You can create a "listener" for this notification to make sure a workflow was launched.

Then you can use a function that feels like it's part of XCTest (XCTAssertWorkflowLaunched) to use the listener:

```swift
    func testLaunchingMultiLocationWorkflow() {
        let listener = WorkflowListener()
        
        testViewController.launchMultiLocationWorkflow()
        
        XCTAssertWorkflowLaunched(listener: listener, expectedFlowRepresentables: [
            LocationsViewController.self,
            PickupOrDeliveryViewController.self,
            MenuSelectionViewController.self,
            FoodSelectionViewController.self,
            ReviewOrderViewController.self,
        ])
    }
```

### Testing a workflow was abandoned
This one is a bit easier, we can use our own mock presenter and see whether it receives a request to abandon the workflow. Then in our test it's just a matter of checking what our presenter reported:

```swift
//slimmed down example from the example project.
    func testSelectingDeliveryLaunchesWorkflowAndSetsSelectionOnOrder() {
        let listener = WorkflowListener()
            
        testViewController.selectDelivery()
        
        XCTAssertWorkflowLaunched(listener: listener, expectedFlowRepresentables: [
            EnterAddressViewController.self
        ])
        
        let mock = MockPresenter()
        listener.workflow?.applyPresenter(mock)
        
        listener.onFinish?()
        
        XCTAssertEqual(mock.abandonCalled, 1)
    }
```