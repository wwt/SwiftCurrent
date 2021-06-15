//
//  UIKitAssertions.swift
//  WorkflowUIKitTests
//
//  Created by Tyler Thompson on 5/1/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest
import UIKit

import UIUTest

func XCTAssertUIViewControllerDisplayed<T: UIViewController>(ofType viewControllerType: T.Type, file: StaticString = #file, line: UInt = #line) {
    waitUntil(UIApplication.topViewController() is T)
    waitUntil(UIApplication.topViewController()?.view.willRespondToUser == true)
    XCTAssert(UIApplication.topViewController() is T, "Expected top view controller to be \(T.self) but was: \(String(describing: UIApplication.topViewController()))", file: file, line: line)
}

func XCTAssertUIViewControllerDisplayed<T: UIViewController>(isInstance viewController: T, file: StaticString = #file, line: UInt = #line) {
    waitUntil(UIApplication.topViewController() is T)
    waitUntil(UIApplication.topViewController()?.view.willRespondToUser == true)
    XCTAssert(UIApplication.topViewController() is T, "Expected top view controller to be \(T.self) but was: \(String(describing: UIApplication.topViewController()))", file: file, line: line)
    XCTAssert(UIApplication.topViewController() === viewController, "Expected top view controller to be instance \(viewController) but was: \(String(describing: UIApplication.topViewController()))", file: file, line: line)
}
