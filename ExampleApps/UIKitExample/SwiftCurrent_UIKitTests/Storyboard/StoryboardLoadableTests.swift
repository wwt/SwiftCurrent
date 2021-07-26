//
//  StoryboardLoadableTests.swift
//  
//  Created by Tyler Thompson on 5/3/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

import ExceptionCatcher

import SwiftCurrent
@testable import SwiftCurrent_UIKit

class StoryboardLoadableTests: XCTestCase {
    func testStoryboardLoadableThrowsErrorWhenYouCallDefaultInitImplementation() {
        class Test: UIWorkflowItem<String, Never>, StoryboardLoadable {
            static var storyboardId: String = ""
            static var storyboard: UIStoryboard = UIStoryboard()

            required init?(coder: NSCoder, with name: String) {
                super.init(coder: coder)
            }
            required init?(coder: NSCoder) { nil }
        }

        XCTAssertThrowsFatalError {
            _ = Test(with: "")
        }
    }

    func testStoryboardLoadableThrowsErrorWhenItIsOfADifferentTypeOnStoryboard() throws {
        class Test: UIWorkflowItem<Never, Never>, StoryboardLoadable {
            static var storyboardId: String = "TestNoInputViewController"
            static var storyboard: UIStoryboard {
                UIStoryboard(name: "TestStoryboard", bundle: Bundle(for: Self.self))
            }
        }

        XCTAssertThrowsError(try ExceptionCatcher.catch {
            AnyFlowRepresentable(Test.self, args: .args("some"))
        })
    }

    func testStoryboardLoadableThrowsErrorWhenItIsOfADifferentTypeOnStoryboard_ButInstantiationSucceeds() throws {
        class Test: UIWorkflowItem<Never, Never>, StoryboardLoadable {
            static var storyboardId: String = ""
            static var storyboard: UIStoryboard {
                UIStoryboard(name: "TestStoryboard", bundle: Bundle(for: Self.self))
            }
        }

        XCTAssertThrowsFatalError {
            _ = TestInputViewController._factory(Test.self, with: "some")
        }
    }

    func testStoryboardLoadable_WithInputOfNever_ThrowsErrorWhenItIsOfADifferentTypeOnStoryboard() throws {
        class Test: UIWorkflowItem<Never, Never>, StoryboardLoadable {
            static var storyboardId: String = "TestNoInputViewController"
            static var storyboard: UIStoryboard {
                UIStoryboard(name: "TestStoryboard", bundle: Bundle(for: Self.self))
            }
        }

        XCTAssertThrowsError(try ExceptionCatcher.catch {
            AnyFlowRepresentable(Test.self, args: .none)
        })
    }

    func testStoryboardLoadable_WithInputOfNever_ThrowsErrorWhenItIsOfADifferentTypeOnStoryboard_ButInstantiationSucceeds() throws {
        class Test: UIWorkflowItem<Never, Never>, StoryboardLoadable {
            static var storyboardId: String = ""
            static var storyboard: UIStoryboard {
                UIStoryboard(name: "TestStoryboard", bundle: Bundle(for: Self.self))
            }
        }

        XCTAssertThrowsFatalError {
            _ = TestNoInputViewController._factory(Test.self)
        }
    }

    func testStoryboardLoadable() {
        XCTAssertNoThrow(try ExceptionCatcher.catch {
            AnyFlowRepresentable(TestNoInputViewController.self, args: .none)
        })

        XCTAssertNoThrow(try ExceptionCatcher.catch {
            AnyFlowRepresentable(TestInputViewController.self, args: .args("some"))
        })
    }
}

class TestNoInputViewController: UIWorkflowItem<Never, Never>, StoryboardLoadable {
    static var storyboardId: String {
        String(describing: Self.self)
    }
    static var storyboard: UIStoryboard {
        UIStoryboard(name: "TestStoryboard", bundle: Bundle(for: Self.self))
    }
}

class TestInputViewController: UIWorkflowItem<String, Never>, StoryboardLoadable {
    static var storyboardId: String {
        String(describing: Self.self)
    }
    static var storyboard: UIStoryboard {
        UIStoryboard(name: "TestStoryboard", bundle: Bundle(for: Self.self))
    }

    required init?(coder: NSCoder, with name: String) {
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) { nil }
}

// Literally just make sure it compiles....
class PassthroughViewController: UIViewController, StoryboardLoadable, PassthroughFlowRepresentable {
    var _workflowPointer: AnyFlowRepresentable?

    static var storyboardId: String {
        String(describing: Self.self)
    }
    static var storyboard: UIStoryboard {
        UIStoryboard(name: "TestStoryboard", bundle: Bundle(for: Self.self))
    }
}
