//
//  WorkflowBuilder.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 2/21/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  swiftlint:disable line_length

import Foundation

/**
 Used to build a `Workflow` in SwiftUI; Embed `WorkflowItem`s in a `WorkflowBuilder` to define your workflow.

 ### Discussion
 Typically, you'll use this when you use `WorkflowView`. Otherwise you might use it as a way to build your own workflows in a wrapper type.

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
 There is a Swift-imposed limit on how many items we can have in a `WorkflowBuilder`. Similar to SwiftUI's ViewBuilder, `WorkflowBuilder` has a limit of 10 items. Just like you can use `Group` in SwiftUI you can use `WorkflowGroup` to get around that 10 item limit with SwiftCurrent.
 */
@resultBuilder
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public enum WorkflowBuilder {
    // swiftlint:disable:next missing_docs
    public static func buildOptional<W: _WorkflowItemProtocol>(_ component: W?) -> OptionalWorkflowItem<W> {
        OptionalWorkflowItem(content: component)
    }

    // swiftlint:disable:next missing_docs
    public static func buildEither<TrueCondition: _WorkflowItemProtocol, FalseCondition: _WorkflowItemProtocol>(first component: TrueCondition) -> EitherWorkflowItem<TrueCondition, FalseCondition> {
        .init(content: .first(component))
    }

    // swiftlint:disable:next missing_docs
    public static func buildEither<TrueCondition: _WorkflowItemProtocol, FalseCondition: _WorkflowItemProtocol>(second component: FalseCondition) -> EitherWorkflowItem<TrueCondition, FalseCondition> {
        .init(content: .second(component))
    }

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

    // swiftlint:disable:next missing_docs
    public static func buildBlock<W0: _WorkflowItemProtocol,
                                  W1: _WorkflowItemProtocol,
                                  W2: _WorkflowItemProtocol,
                                  W3: _WorkflowItemProtocol,
                                  W4: _WorkflowItemProtocol>(_ w0: W0, _ w1: W1, _ w2: W2, _ w3: W3, _ w4: W4) -> WorkflowItemWrapper<W0, WorkflowItemWrapper<W1, WorkflowItemWrapper<W2, WorkflowItemWrapper<W3, WorkflowItemWrapper<W4, Never>>>>> {
        WorkflowItemWrapper(content: w0) {
            WorkflowItemWrapper(content: w1) {
                WorkflowItemWrapper(content: w2) {
                    WorkflowItemWrapper(content: w3) {
                        WorkflowItemWrapper(content: w4)
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
                                  W5: _WorkflowItemProtocol>(_ w0: W0, _ w1: W1, _ w2: W2, _ w3: W3, _ w4: W4, _ w5: W5) -> WorkflowItemWrapper<W0, WorkflowItemWrapper<W1, WorkflowItemWrapper<W2, WorkflowItemWrapper<W3, WorkflowItemWrapper<W4, WorkflowItemWrapper<W5, Never>>>>>> {
        WorkflowItemWrapper(content: w0) {
            WorkflowItemWrapper(content: w1) {
                WorkflowItemWrapper(content: w2) {
                    WorkflowItemWrapper(content: w3) {
                        WorkflowItemWrapper(content: w4) {
                            WorkflowItemWrapper(content: w5)
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
                                  W6: _WorkflowItemProtocol>(_ w0: W0, _ w1: W1, _ w2: W2, _ w3: W3, _ w4: W4, _ w5: W5, _ w6: W6) -> WorkflowItemWrapper<W0, WorkflowItemWrapper<W1, WorkflowItemWrapper<W2, WorkflowItemWrapper<W3, WorkflowItemWrapper<W4, WorkflowItemWrapper<W5, WorkflowItemWrapper<W6, Never>>>>>>> {
        WorkflowItemWrapper(content: w0) {
            WorkflowItemWrapper(content: w1) {
                WorkflowItemWrapper(content: w2) {
                    WorkflowItemWrapper(content: w3) {
                        WorkflowItemWrapper(content: w4) {
                            WorkflowItemWrapper(content: w5) {
                                WorkflowItemWrapper(content: w6)
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
                                  W7: _WorkflowItemProtocol>(_ w0: W0, _ w1: W1, _ w2: W2, _ w3: W3, _ w4: W4, _ w5: W5, _ w6: W6, _ w7: W7) -> WorkflowItemWrapper<W0, WorkflowItemWrapper<W1, WorkflowItemWrapper<W2, WorkflowItemWrapper<W3, WorkflowItemWrapper<W4, WorkflowItemWrapper<W5, WorkflowItemWrapper<W6, WorkflowItemWrapper<W7, Never>>>>>>>> {
        WorkflowItemWrapper(content: w0) {
            WorkflowItemWrapper(content: w1) {
                WorkflowItemWrapper(content: w2) {
                    WorkflowItemWrapper(content: w3) {
                        WorkflowItemWrapper(content: w4) {
                            WorkflowItemWrapper(content: w5) {
                                WorkflowItemWrapper(content: w6) {
                                    WorkflowItemWrapper(content: w7)
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
                                  W8: _WorkflowItemProtocol>(_ w0: W0, _ w1: W1, _ w2: W2, _ w3: W3, _ w4: W4, _ w5: W5, _ w6: W6, _ w7: W7, _ w8: W8) -> WorkflowItemWrapper<W0, WorkflowItemWrapper<W1, WorkflowItemWrapper<W2, WorkflowItemWrapper<W3, WorkflowItemWrapper<W4, WorkflowItemWrapper<W5, WorkflowItemWrapper<W6, WorkflowItemWrapper<W7, WorkflowItemWrapper<W8, Never>>>>>>>>> {
        WorkflowItemWrapper(content: w0) {
            WorkflowItemWrapper(content: w1) {
                WorkflowItemWrapper(content: w2) {
                    WorkflowItemWrapper(content: w3) {
                        WorkflowItemWrapper(content: w4) {
                            WorkflowItemWrapper(content: w5) {
                                WorkflowItemWrapper(content: w6) {
                                    WorkflowItemWrapper(content: w7) {
                                        WorkflowItemWrapper(content: w8)
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
                                  W9: _WorkflowItemProtocol>(_ w0: W0, _ w1: W1, _ w2: W2, _ w3: W3, _ w4: W4, _ w5: W5, _ w6: W6, _ w7: W7, _ w8: W8, _ w9: W9) -> WorkflowItemWrapper<W0, WorkflowItemWrapper<W1, WorkflowItemWrapper<W2, WorkflowItemWrapper<W3, WorkflowItemWrapper<W4, WorkflowItemWrapper<W5, WorkflowItemWrapper<W6, WorkflowItemWrapper<W7, WorkflowItemWrapper<W8, WorkflowItemWrapper<W9, Never>>>>>>>>>> {
        WorkflowItemWrapper(content: w0) {
            WorkflowItemWrapper(content: w1) {
                WorkflowItemWrapper(content: w2) {
                    WorkflowItemWrapper(content: w3) {
                        WorkflowItemWrapper(content: w4) {
                            WorkflowItemWrapper(content: w5) {
                                WorkflowItemWrapper(content: w6) {
                                    WorkflowItemWrapper(content: w7) {
                                        WorkflowItemWrapper(content: w8) {
                                            WorkflowItemWrapper(content: w9)
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
