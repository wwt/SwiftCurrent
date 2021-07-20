#  About UIKitExample

## Overview
UIKitExample showcases the usage of SwiftCurrent for a restaurant ordering App.

The project is designed to give you an idea of SwiftCurrent functionality while keeping UI code to a minimum.

## Areas of Interest
Here is a list of things that are interesting to look at from a SwiftCurrent perspective.

### SetupViewController
This is the entry point of the App, which launches a `Workflow` for placing an order.

### PickupOrDeliveryViewController
This screen launches an interim `Workflow` when selecting Delivery.

### LocationsViewController
This screen uses conditional loading logic in its `shouldLoad` method, and it has distinct input and output types.

### StoryboardLoadable
This file configures SwiftCurrent to load our views from Storyboards.
