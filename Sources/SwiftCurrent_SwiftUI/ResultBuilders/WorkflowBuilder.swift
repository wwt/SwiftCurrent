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
    public static func buildBlock<WI: _WorkflowItemProtocol>(_ component: WI) -> WorkflowItem<WI.F, Never, WI.Content> {
        WorkflowItem(WI.F.self)
    }

    // swiftlint:disable:next missing_docs
    public static func buildOptional<WI: _WorkflowItemProtocol>(_ component: WI?) -> _OptionalWorkflowItem<WI> {
        _OptionalWorkflowItem(workflowItem: component)
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock<W0: _WorkflowItemProtocol,
                                  W1: _WorkflowItemProtocol>(_ f0: W0,
                                                             _ f1: W1) -> WorkflowItem<W0.F, WorkflowItem<W1.F, Never, W1.Content>, W0.Content> {
        WorkflowItem(W0.F.self) {
            WorkflowItem(W1.F.self)
        }
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock<W0: _WorkflowItemProtocol,
                                  W1: _WorkflowItemProtocol,
                                  W2: _WorkflowItemProtocol>(_: W0,
                                                             _: W1,
                                                             _: W2) -> WorkflowItem<W0.F, WorkflowItem<W1.F, WorkflowItem<W2.F, Never, W2.Content>, W1.Content>, W0.Content> {
        WorkflowItem(W0.F.self) {
            WorkflowItem(W1.F.self) {
                WorkflowItem(W2.F.self)
            }
        }
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock<W0: _WorkflowItemProtocol,
                                  W1: _WorkflowItemProtocol,
                                  W2: _WorkflowItemProtocol,
                                  W3: _WorkflowItemProtocol>(_: W0,
                                                             _: W1,
                                                             _: W2,
                                                             _: W3) -> WorkflowItem<W0.F, WorkflowItem<W1.F, WorkflowItem<W2.F, WorkflowItem<W3.F, Never, W3.Content>, W2.Content>, W1.Content>, W0.Content> {
        WorkflowItem(W0.F.self) {
            WorkflowItem(W1.F.self) {
                WorkflowItem(W2.F.self) {
                    WorkflowItem(W3.F.self)
                }
            }
        }
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock<W0: _WorkflowItemProtocol,
                                  W1: _WorkflowItemProtocol,
                                  W2: _WorkflowItemProtocol,
                                  W3: _WorkflowItemProtocol,
                                  W4: _WorkflowItemProtocol>(_: W0,
                                                             _: W1,
                                                             _: W2,
                                                             _: W3,
                                                             _: W4) -> WorkflowItem<W0.F, WorkflowItem<W1.F, WorkflowItem<W2.F, WorkflowItem<W3.F, WorkflowItem<W4.F, Never, W4.Content>, W3.Content>, W2.Content>, W1.Content>, W0.Content> {
        WorkflowItem(W0.F.self) {
            WorkflowItem(W1.F.self) {
                WorkflowItem(W2.F.self) {
                    WorkflowItem(W3.F.self) {
                        WorkflowItem(W4.F.self)
                    }
                }
            }
        }
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock<W0: _WorkflowItemProtocol,
                                  W1: _WorkflowItemProtocol,
                                  W2: _WorkflowItemProtocol,
                                  W3: _WorkflowItemProtocol,
                                  W4: _WorkflowItemProtocol,
                                  W5: _WorkflowItemProtocol>(_: W0,
                                                             _: W1,
                                                             _: W2,
                                                             _: W3,
                                                             _: W4,
                                                             _: W5) -> WorkflowItem<W0.F, WorkflowItem<W1.F, WorkflowItem<W2.F, WorkflowItem<W3.F, WorkflowItem<W4.F, WorkflowItem<W5.F, Never, W5.Content>, W4.Content>, W3.Content>, W2.Content>, W1.Content>, W0.Content> {
        WorkflowItem(W0.F.self) {
            WorkflowItem(W1.F.self) {
                WorkflowItem(W2.F.self) {
                    WorkflowItem(W3.F.self) {
                        WorkflowItem(W4.F.self) {
                            WorkflowItem(W5.F.self)
                        }
                    }
                }
            }
        }
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock<W0: _WorkflowItemProtocol,
                                  W1: _WorkflowItemProtocol,
                                  W2: _WorkflowItemProtocol,
                                  W3: _WorkflowItemProtocol,
                                  W4: _WorkflowItemProtocol,
                                  W5: _WorkflowItemProtocol,
                                  W6: _WorkflowItemProtocol>(_: W0,
                                                             _: W1,
                                                             _: W2,
                                                             _: W3,
                                                             _: W4,
                                                             _: W5,
                                                             _: W6) -> WorkflowItem<W0.F, WorkflowItem<W1.F, WorkflowItem<W2.F, WorkflowItem<W3.F, WorkflowItem<W4.F, WorkflowItem<W5.F, WorkflowItem<W6.F, Never, W6.Content>, W5.Content>, W4.Content>, W3.Content>, W2.Content>, W1.Content>, W0.Content> {
        WorkflowItem(W0.F.self) {
            WorkflowItem(W1.F.self) {
                WorkflowItem(W2.F.self) {
                    WorkflowItem(W3.F.self) {
                        WorkflowItem(W4.F.self) {
                            WorkflowItem(W5.F.self) {
                                WorkflowItem(W6.F.self)
                            }
                        }
                    }
                }
            }
        }
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock<W0: _WorkflowItemProtocol,
                                  W1: _WorkflowItemProtocol,
                                  W2: _WorkflowItemProtocol,
                                  W3: _WorkflowItemProtocol,
                                  W4: _WorkflowItemProtocol,
                                  W5: _WorkflowItemProtocol,
                                  W6: _WorkflowItemProtocol,
                                  W7: _WorkflowItemProtocol>(_: W0,
                                                             _: W1,
                                                             _: W2,
                                                             _: W3,
                                                             _: W4,
                                                             _: W5,
                                                             _: W6,
                                                             _: W7) -> WorkflowItem<W0.F, WorkflowItem<W1.F, WorkflowItem<W2.F, WorkflowItem<W3.F, WorkflowItem<W4.F, WorkflowItem<W5.F, WorkflowItem<W6.F, WorkflowItem<W7.F, Never, W7.Content>, W6.Content>, W5.Content>, W4.Content>, W3.Content>, W2.Content>, W1.Content>, W0.Content> {
        WorkflowItem(W0.F.self) {
            WorkflowItem(W1.F.self) {
                WorkflowItem(W2.F.self) {
                    WorkflowItem(W3.F.self) {
                        WorkflowItem(W4.F.self) {
                            WorkflowItem(W5.F.self) {
                                WorkflowItem(W6.F.self) {
                                    WorkflowItem(W7.F.self)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock<W0: _WorkflowItemProtocol,
                                  W1: _WorkflowItemProtocol,
                                  W2: _WorkflowItemProtocol,
                                  W3: _WorkflowItemProtocol,
                                  W4: _WorkflowItemProtocol,
                                  W5: _WorkflowItemProtocol,
                                  W6: _WorkflowItemProtocol,
                                  W7: _WorkflowItemProtocol,
                                  W8: _WorkflowItemProtocol>(_: W0,
                                                             _: W1,
                                                             _: W2,
                                                             _: W3,
                                                             _: W4,
                                                             _: W5,
                                                             _: W6,
                                                             _: W7,
                                                             _: W8) -> WorkflowItem<W0.F, WorkflowItem<W1.F, WorkflowItem<W2.F, WorkflowItem<W3.F, WorkflowItem<W4.F, WorkflowItem<W5.F, WorkflowItem<W6.F, WorkflowItem<W7.F, WorkflowItem<W8.F, Never, W8.Content>, W7.Content>, W6.Content>, W5.Content>, W4.Content>, W3.Content>, W2.Content>, W1.Content>, W0.Content> {
        WorkflowItem(W0.F.self) {
            WorkflowItem(W1.F.self) {
                WorkflowItem(W2.F.self) {
                    WorkflowItem(W3.F.self) {
                        WorkflowItem(W4.F.self) {
                            WorkflowItem(W5.F.self) {
                                WorkflowItem(W6.F.self) {
                                    WorkflowItem(W7.F.self) {
                                        WorkflowItem(W8.F.self)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock<W0: _WorkflowItemProtocol,
                                  W1: _WorkflowItemProtocol,
                                  W2: _WorkflowItemProtocol,
                                  W3: _WorkflowItemProtocol,
                                  W4: _WorkflowItemProtocol,
                                  W5: _WorkflowItemProtocol,
                                  W6: _WorkflowItemProtocol,
                                  W7: _WorkflowItemProtocol,
                                  W8: _WorkflowItemProtocol,
                                  W9: _WorkflowItemProtocol>(_: W0,
                                                             _: W1,
                                                             _: W2,
                                                             _: W3,
                                                             _: W4,
                                                             _: W5,
                                                             _: W6,
                                                             _: W7,
                                                             _: W8,
                                                             _: W9) -> WorkflowItem<W0.F, WorkflowItem<W1.F, WorkflowItem<W2.F, WorkflowItem<W3.F, WorkflowItem<W4.F, WorkflowItem<W5.F, WorkflowItem<W6.F, WorkflowItem<W7.F, WorkflowItem<W8.F, WorkflowItem<W9.F, Never, W9.Content>, W8.Content>, W7.Content>, W6.Content>, W5.Content>, W4.Content>, W3.Content>, W2.Content>, W1.Content>, W0.Content> {
        WorkflowItem(W0.F.self) {
            WorkflowItem(W1.F.self) {
                WorkflowItem(W2.F.self) {
                    WorkflowItem(W3.F.self) {
                        WorkflowItem(W4.F.self) {
                            WorkflowItem(W5.F.self) {
                                WorkflowItem(W6.F.self) {
                                    WorkflowItem(W7.F.self) {
                                        WorkflowItem(W8.F.self) {
                                            WorkflowItem(W9.F.self)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
