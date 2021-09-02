//
//  TestEnumerations.swift
//  SwiftUIExample
//
//  Created by Richard Gist on 9/1/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import SwiftCurrent
import SwiftCurrent_SwiftUI

enum Environment {
    enum Keys {
        static let xcuiTest = "xcuiTest"
        static let testingView = "testingView"
        static let persistence = "persistence"
        static let presentationType = "presentationType"
    }
    case xcuiTest(Bool = true)
    case testingView(TestingView)
    case persistence(FR, FlowPersistence = .default)
    case presentationType(FR, LaunchStyle.SwiftUI.PresentationType = .default)

    var dictionaryValue: [String: String] {
        switch self {
            case .xcuiTest(let shouldTest): return [Keys.xcuiTest: "\(shouldTest)"]
            case .testingView(let testingView): return [Keys.testingView: testingView.rawValue]
            case .persistence(let fr, let persistence): return ["\(Keys.persistence)-\(fr.rawValue)": "\(persistence)"]
            case .presentationType(let fr, let presentationType): return ["\(Keys.presentationType)-\(fr.rawValue)": "\(presentationType)"]
        }
    }

    static var shouldTest: Bool {
        ProcessInfo.processInfo.environment.contains { key, value in
            Self.xcuiTest(true).dictionaryValue[key] == value
        }
    }

    static var viewToTest: TestingView? {
        for (key, value) in ProcessInfo.processInfo.environment where key == Keys.testingView {
            return TestingView(rawValue: value)
        }
        return nil
    }

    static func persistence<F>(for: F.Type) -> Environment? {
        if let fr = FR(rawValue: String(describing: F.self)), let persistenceString = ProcessInfo.processInfo.environment["persistence-\(String(describing: F.self))"] {
            switch persistenceString.lowercased() {
                case "\(FlowPersistence.persistWhenSkipped)": return .persistence(fr, .persistWhenSkipped)
                case "\(FlowPersistence.removedAfterProceeding)": return .persistence(fr, .removedAfterProceeding)
                default: return .persistence(fr, .default)
            }
        }
        return nil
    }

    static func presentationType<F>(for: F.Type) -> Environment? {
        if let fr = FR(rawValue: String(describing: F.self)), let presentationTypeString = ProcessInfo.processInfo.environment["presentationType-\(String(describing: F.self))"] {
            switch presentationTypeString.lowercased() {
                case "\(LaunchStyle.SwiftUI.PresentationType.navigationLink)": return .presentationType(fr, .navigationLink)
                case "\(LaunchStyle.SwiftUI.PresentationType.modal())": return .presentationType(fr, .modal)
                case "\(LaunchStyle.SwiftUI.PresentationType.modal(.sheet))": return .presentationType(fr, .modal(.sheet))
                case "\(LaunchStyle.SwiftUI.PresentationType.modal(.fullScreenCover))": return .presentationType(fr, .modal(.fullScreenCover))
                default: return .presentationType(fr, .default)
            }
        }
        return nil
    }
}

enum TestingView: String {
    case oneItemWorkflow

    case twoItemWorkflow

    case threeItemWorkflow

    case fourItemWorkflow
}

enum FR: String {
    case FR1
    case FR2
    case FR3
    case FR4
}
