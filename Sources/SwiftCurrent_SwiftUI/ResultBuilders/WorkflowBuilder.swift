//
//  WorkflowBuilder.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 2/21/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  swiftlint:disable line_length
//  swiftlint:disable operator_usage_whitespace
//  swiftlint BUG: https://github.com/realm/SwiftLint/issues/3668

import Foundation

/**
 Used to build a `Workflow` in SwiftUI; Embed `WorkflowItem`s in a `WorkflowBuilder` to define your workflow.

 ### Discussion
 Typically, you'll use this when you use `WorkflowView`. Otherwise you might use it as a parameter attribute for child `WorkflowItem`-producing closure parameters.

 #### Example
 ```swift
 WorkflowView(isLaunched: $isLaunched.animation(), launchingWith: "String in") {
 WorkflowItem(FirstView.self)
 WorkflowItem(SecondView.self)
 }
 .onAbandon { print("isLaunched is now false") }
 .onFinish { args in print("Finished 1: \(args)") }
 .onFinish { print("Finished 2: \($0)") }
 .background(Color.green)
 ```

 #### NOTE
 There is a Swift-imposed limit on how many items we can have in a `WorkflowBuilder`. Similar to SwiftUI's ViewBuilder, `WorkflowBuilder` has a limit of 10 items.
 */
@resultBuilder
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public enum WorkflowBuilder {
    // swiftlint:disable:next missing_docs
    public static func buildBlock<W0: _WorkflowItemProtocol>(_ w0: W0) -> WorkflowItemWrapper<W0, Never> {
        WorkflowItemWrapper<W0, Never>(content: w0)
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock<W0: _WorkflowItemProtocol,
                                  W1: _WorkflowItemProtocol>(_ w0: W0, _ w1: W1) -> WorkflowItemWrapper<W0, WorkflowItemWrapper<W1, Never>> {
        WorkflowItemWrapper(content: w0) {
            WorkflowItemWrapper(content: w1)
        }
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock<W0: _WorkflowItemProtocol,
                                  W1: _WorkflowItemProtocol,
                                  W2: _WorkflowItemProtocol>(_ w0: W0, _ w1: W1, _ w2: W2) -> WorkflowItemWrapper<W0, WorkflowItemWrapper<W1, WorkflowItemWrapper<W2, Never>>> {
        WorkflowItemWrapper(content: w0) {
            WorkflowItemWrapper(content: w1) {
                WorkflowItemWrapper(content: w2)
            }
        }
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock<W0: _WorkflowItemProtocol,
                                  W1: _WorkflowItemProtocol,
                                  W2: _WorkflowItemProtocol,
                                  W3: _WorkflowItemProtocol>(_ w0: W0, _ w1: W1, _ w2: W2, _ w3: W3) -> WorkflowItemWrapper<W0, WorkflowItemWrapper<W1, WorkflowItemWrapper<W2, WorkflowItemWrapper<W3, Never>>>> {
        WorkflowItemWrapper(content: w0) {
            WorkflowItemWrapper(content: w1) {
                WorkflowItemWrapper(content: w2) {
                    WorkflowItemWrapper(content: w3)
                }
            }
        }
    }

//    // swiftlint:disable:next missing_docs
//    public static func buildBlock<F0, C0,
//                                  F1, C1,
//                                  F2, C2,
//                                  F3, C3,
//                                  F4, C4>(_ f0: WorkflowItem<F0, Never, C0>,
//                                          _ f1: WorkflowItem<F1, Never, C1>,
//                                          _ f2: WorkflowItem<F2, Never, C2>,
//                                          _ f3: WorkflowItem<F3, Never, C3>,
//                                          _ f4: WorkflowItem<F4, Never, C4>) -> WorkflowItem<F0, WorkflowItem<F1, WorkflowItem<F2, WorkflowItem<F3, WorkflowItem<F4, Never, C4>, C3>, C2>, C1>, C0> {
//        WorkflowItem(wrapping: f0) {
//            WorkflowItem(wrapping: f1) {
//                WorkflowItem(wrapping: f2) {
//                    WorkflowItem(wrapping: f3) {
//                        WorkflowItem(wrapping: f4)
//                    }
//                }
//            }
//        }
//    }
//
//    // swiftlint:disable:next missing_docs
//    public static func buildBlock<F0, C0,
//                                  F1, C1,
//                                  F2, C2,
//                                  F3, C3,
//                                  F4, C4,
//                                  F5, C5>(_ f0: WorkflowItem<F0, Never, C0>,
//                                          _ f1: WorkflowItem<F1, Never, C1>,
//                                          _ f2: WorkflowItem<F2, Never, C2>,
//                                          _ f3: WorkflowItem<F3, Never, C3>,
//                                          _ f4: WorkflowItem<F4, Never, C4>,
//                                          _ f5: WorkflowItem<F5, Never, C5>) -> WorkflowItem<F0, WorkflowItem<F1, WorkflowItem<F2, WorkflowItem<F3, WorkflowItem<F4, WorkflowItem<F5, Never, C5>, C4>, C3>, C2>, C1>, C0> {
//        WorkflowItem(wrapping: f0) {
//            WorkflowItem(wrapping: f1) {
//                WorkflowItem(wrapping: f2) {
//                    WorkflowItem(wrapping: f3) {
//                        WorkflowItem(wrapping: f4) {
//                            WorkflowItem(wrapping: f5)
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    // swiftlint:disable:next missing_docs
//    public static func buildBlock<F0, C0,
//                                  F1, C1,
//                                  F2, C2,
//                                  F3, C3,
//                                  F4, C4,
//                                  F5, C5,
//                                  F6, C6>(_ f0: WorkflowItem<F0, Never, C0>,
//                                          _ f1: WorkflowItem<F1, Never, C1>,
//                                          _ f2: WorkflowItem<F2, Never, C2>,
//                                          _ f3: WorkflowItem<F3, Never, C3>,
//                                          _ f4: WorkflowItem<F4, Never, C4>,
//                                          _ f5: WorkflowItem<F5, Never, C5>,
//                                          _ f6: WorkflowItem<F6, Never, C6>) -> WorkflowItem<F0, WorkflowItem<F1, WorkflowItem<F2, WorkflowItem<F3, WorkflowItem<F4, WorkflowItem<F5, WorkflowItem<F6, Never, C6>, C5>, C4>, C3>, C2>, C1>, C0> {
//        WorkflowItem(wrapping: f0) {
//            WorkflowItem(wrapping: f1) {
//                WorkflowItem(wrapping: f2) {
//                    WorkflowItem(wrapping: f3) {
//                        WorkflowItem(wrapping: f4) {
//                            WorkflowItem(wrapping: f5) {
//                                WorkflowItem(wrapping: f6)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    // swiftlint:disable:next missing_docs
//    public static func buildBlock<F0, C0,
//                                  F1, C1,
//                                  F2, C2,
//                                  F3, C3,
//                                  F4, C4,
//                                  F5, C5,
//                                  F6, C6,
//                                  F7, C7>(_ f0: WorkflowItem<F0, Never, C0>,
//                                          _ f1: WorkflowItem<F1, Never, C1>,
//                                          _ f2: WorkflowItem<F2, Never, C2>,
//                                          _ f3: WorkflowItem<F3, Never, C3>,
//                                          _ f4: WorkflowItem<F4, Never, C4>,
//                                          _ f5: WorkflowItem<F5, Never, C5>,
//                                          _ f6: WorkflowItem<F6, Never, C6>,
//                                          _ f7: WorkflowItem<F7, Never, C7>) -> WorkflowItem<F0, WorkflowItem<F1, WorkflowItem<F2, WorkflowItem<F3, WorkflowItem<F4, WorkflowItem<F5, WorkflowItem<F6, WorkflowItem<F7, Never, C7>, C6>, C5>, C4>, C3>, C2>, C1>, C0> {
//        WorkflowItem(wrapping: f0) {
//            WorkflowItem(wrapping: f1) {
//                WorkflowItem(wrapping: f2) {
//                    WorkflowItem(wrapping: f3) {
//                        WorkflowItem(wrapping: f4) {
//                            WorkflowItem(wrapping: f5) {
//                                WorkflowItem(wrapping: f6) {
//                                    WorkflowItem(wrapping: f7)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    // swiftlint:disable:next missing_docs
//    public static func buildBlock<F0, C0,
//                                  F1, C1,
//                                  F2, C2,
//                                  F3, C3,
//                                  F4, C4,
//                                  F5, C5,
//                                  F6, C6,
//                                  F7, C7,
//                                  F8, C8>(_ f0: WorkflowItem<F0, Never, C0>,
//                                          _ f1: WorkflowItem<F1, Never, C1>,
//                                          _ f2: WorkflowItem<F2, Never, C2>,
//                                          _ f3: WorkflowItem<F3, Never, C3>,
//                                          _ f4: WorkflowItem<F4, Never, C4>,
//                                          _ f5: WorkflowItem<F5, Never, C5>,
//                                          _ f6: WorkflowItem<F6, Never, C6>,
//                                          _ f7: WorkflowItem<F7, Never, C7>,
//                                          _ f8: WorkflowItem<F8, Never, C8>) -> WorkflowItem<F0, WorkflowItem<F1, WorkflowItem<F2, WorkflowItem<F3, WorkflowItem<F4, WorkflowItem<F5, WorkflowItem<F6, WorkflowItem<F7, WorkflowItem<F8, Never, C8>, C7>, C6>, C5>, C4>, C3>, C2>, C1>, C0> {
//        WorkflowItem(wrapping: f0) {
//            WorkflowItem(wrapping: f1) {
//                WorkflowItem(wrapping: f2) {
//                    WorkflowItem(wrapping: f3) {
//                        WorkflowItem(wrapping: f4) {
//                            WorkflowItem(wrapping: f5) {
//                                WorkflowItem(wrapping: f6) {
//                                    WorkflowItem(wrapping: f7) {
//                                        WorkflowItem(wrapping: f8)
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    // swiftlint:disable:next missing_docs
//    public static func buildBlock<F0, C0,
//                                  F1, C1,
//                                  F2, C2,
//                                  F3, C3,
//                                  F4, C4,
//                                  F5, C5,
//                                  F6, C6,
//                                  F7, C7,
//                                  F8, C8,
//                                  F9, C9>(_ f0: WorkflowItem<F0, Never, C0>,
//                                          _ f1: WorkflowItem<F1, Never, C1>,
//                                          _ f2: WorkflowItem<F2, Never, C2>,
//                                          _ f3: WorkflowItem<F3, Never, C3>,
//                                          _ f4: WorkflowItem<F4, Never, C4>,
//                                          _ f5: WorkflowItem<F5, Never, C5>,
//                                          _ f6: WorkflowItem<F6, Never, C6>,
//                                          _ f7: WorkflowItem<F7, Never, C7>,
//                                          _ f8: WorkflowItem<F8, Never, C8>,
//                                          _ f9: WorkflowItem<F9, Never, C9>) -> WorkflowItem<F0, WorkflowItem<F1, WorkflowItem<F2, WorkflowItem<F3, WorkflowItem<F4, WorkflowItem<F5, WorkflowItem<F6, WorkflowItem<F7, WorkflowItem<F8, WorkflowItem<F9, Never, C9>, C8>, C7>, C6>, C5>, C4>, C3>, C2>, C1>, C0> {
//        WorkflowItem(wrapping: f0) {
//            WorkflowItem(wrapping: f1) {
//                WorkflowItem(wrapping: f2) {
//                    WorkflowItem(wrapping: f3) {
//                        WorkflowItem(wrapping: f4) {
//                            WorkflowItem(wrapping: f5) {
//                                WorkflowItem(wrapping: f6) {
//                                    WorkflowItem(wrapping: f7) {
//                                        WorkflowItem(wrapping: f8) {
//                                            WorkflowItem(wrapping: f9)
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
}
