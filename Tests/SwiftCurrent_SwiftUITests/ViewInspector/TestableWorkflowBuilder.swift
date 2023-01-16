import XCTest

@testable import SwiftCurrent_SwiftUI

@resultBuilder
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public enum TestableWorkflowBuilder {
    // swiftlint:disable:next missing_docs
    public static func buildOptional<W: _WorkflowItemProtocol>(_ component: W?) -> OptionalWorkflowItem<W> {
        let returnValue = OptionalWorkflowItem(content: component)
        let old = WorkflowBuilder.buildOptional(component)
        XCTAssert(type(of: returnValue) == type(of: old), "Testable builder not following production behavior. Expected: \(type(of: old)), got: \(type(of: returnValue))")
        return returnValue
    }

    // swiftlint:disable:next missing_docs
    public static func buildEither<TrueCondition: _WorkflowItemProtocol, FalseCondition: _WorkflowItemProtocol>(first component: TrueCondition) -> EitherWorkflowItem<TrueCondition, FalseCondition> {
        let returnValue = EitherWorkflowItem<TrueCondition, FalseCondition>(content: .first(component))
        let old = WorkflowBuilder.buildOptional(component)
        XCTAssert(type(of: returnValue) == type(of: old), "Testable builder not following production behavior. Expected: \(type(of: old)), got: \(type(of: returnValue))")
        return returnValue
    }

    // swiftlint:disable:next missing_docs
    public static func buildEither<TrueCondition: _WorkflowItemProtocol, FalseCondition: _WorkflowItemProtocol>(second component: FalseCondition) -> EitherWorkflowItem<TrueCondition, FalseCondition> {
        let returnValue = EitherWorkflowItem<TrueCondition, FalseCondition>(content: .second(component))
        let old = WorkflowBuilder.buildOptional(component)
        XCTAssert(type(of: returnValue) == type(of: old), "Testable builder not following production behavior. Expected: \(type(of: old)), got: \(type(of: returnValue))")
        return returnValue
    }

    public static func buildBlock<W0: _WorkflowItemProtocol>(_ w0: W0) -> WorkflowItemWrapper<W0, Never> {
        let returnValue = WorkflowItemWrapper<W0, Never>(content: w0)
        let old = WorkflowBuilder.buildBlock(w0)
        XCTAssert(type(of: returnValue) == type(of: old), "Testable builder not following production behavior. Expected: \(type(of: old)), got: \(type(of: returnValue))")
        return returnValue
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock<W0: _WorkflowItemProtocol,
                                  W1: _WorkflowItemProtocol>(_ w0: W0, _ w1: W1) -> WorkflowItemWrapper<W0, WorkflowItemWrapper<W1, Never>> {
        let returnValue = WorkflowItemWrapper(content: w0) {
            WorkflowItemWrapper(content: w1)
        }
        let old = WorkflowBuilder.buildBlock(w0, w1)
        XCTAssert(type(of: returnValue) == type(of: old), "Testable builder not following production behavior. Expected: \(type(of: old)), got: \(type(of: returnValue))")
        return returnValue
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock<W0: _WorkflowItemProtocol,
                                  W1: _WorkflowItemProtocol,
                                  W2: _WorkflowItemProtocol>(_ w0: W0, _ w1: W1, _ w2: W2) -> WorkflowItemWrapper<W0, WorkflowItemWrapper<W1, WorkflowItemWrapper<W2, Never>>> {
        let returnValue = WorkflowItemWrapper(content: w0) {
            WorkflowItemWrapper(content: w1) {
                WorkflowItemWrapper(content: w2)
            }
        }
        let old = WorkflowBuilder.buildBlock(w0, w1, w2)
        XCTAssert(type(of: returnValue) == type(of: old), "Testable builder not following production behavior. Expected: \(type(of: old)), got: \(type(of: returnValue))")
        return returnValue
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock<W0: _WorkflowItemProtocol,
                                  W1: _WorkflowItemProtocol,
                                  W2: _WorkflowItemProtocol,
                                  W3: _WorkflowItemProtocol>(_ w0: W0, _ w1: W1, _ w2: W2, _ w3: W3) -> WorkflowItemWrapper<W0, WorkflowItemWrapper<W1, WorkflowItemWrapper<W2, WorkflowItemWrapper<W3, Never>>>> {
        let returnValue = WorkflowItemWrapper(content: w0) {
            WorkflowItemWrapper(content: w1) {
                WorkflowItemWrapper(content: w2) {
                    WorkflowItemWrapper(content: w3)
                }
            }
        }
        let old = WorkflowBuilder.buildBlock(w0, w1, w2, w3)
        XCTAssert(type(of: returnValue) == type(of: old), "Testable builder not following production behavior. Expected: \(type(of: old)), got: \(type(of: returnValue))")
        return returnValue
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock<W0: _WorkflowItemProtocol,
                                  W1: _WorkflowItemProtocol,
                                  W2: _WorkflowItemProtocol,
                                  W3: _WorkflowItemProtocol,
                                  W4: _WorkflowItemProtocol>(_ w0: W0, _ w1: W1, _ w2: W2, _ w3: W3, _ w4: W4) -> WorkflowItemWrapper<W0, WorkflowItemWrapper<W1, WorkflowItemWrapper<W2, WorkflowItemWrapper<W3, WorkflowItemWrapper<W4, Never>>>>> {
        let returnValue = WorkflowItemWrapper(content: w0) {
            WorkflowItemWrapper(content: w1) {
                WorkflowItemWrapper(content: w2) {
                    WorkflowItemWrapper(content: w3) {
                        WorkflowItemWrapper(content: w4)
                    }
                }
            }
        }
        let old = WorkflowBuilder.buildBlock(w0, w1, w2, w3, w4)
        XCTAssert(type(of: returnValue) == type(of: old), "Testable builder not following production behavior. Expected: \(type(of: old)), got: \(type(of: returnValue))")
        return returnValue
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock<W0: _WorkflowItemProtocol,
                                  W1: _WorkflowItemProtocol,
                                  W2: _WorkflowItemProtocol,
                                  W3: _WorkflowItemProtocol,
                                  W4: _WorkflowItemProtocol,
                                  W5: _WorkflowItemProtocol>(_ w0: W0, _ w1: W1, _ w2: W2, _ w3: W3, _ w4: W4, _ w5: W5) -> WorkflowItemWrapper<W0, WorkflowItemWrapper<W1, WorkflowItemWrapper<W2, WorkflowItemWrapper<W3, WorkflowItemWrapper<W4, WorkflowItemWrapper<W5, Never>>>>>> {
        let returnValue = WorkflowItemWrapper(content: w0) {
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
        let old = WorkflowBuilder.buildBlock(w0, w1, w2, w3, w4, w5)
        XCTAssert(type(of: returnValue) == type(of: old), "Testable builder not following production behavior. Expected: \(type(of: old)), got: \(type(of: returnValue))")
        return returnValue
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock<W0: _WorkflowItemProtocol,
                                  W1: _WorkflowItemProtocol,
                                  W2: _WorkflowItemProtocol,
                                  W3: _WorkflowItemProtocol,
                                  W4: _WorkflowItemProtocol,
                                  W5: _WorkflowItemProtocol,
                                  W6: _WorkflowItemProtocol>(_ w0: W0, _ w1: W1, _ w2: W2, _ w3: W3, _ w4: W4, _ w5: W5, _ w6: W6) -> WorkflowItemWrapper<W0, WorkflowItemWrapper<W1, WorkflowItemWrapper<W2, WorkflowItemWrapper<W3, WorkflowItemWrapper<W4, WorkflowItemWrapper<W5, WorkflowItemWrapper<W6, Never>>>>>>> {
        let returnValue = WorkflowItemWrapper(content: w0) {
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
        let old = WorkflowBuilder.buildBlock(w0, w1, w2, w3, w4, w5, w6)
        XCTAssert(type(of: returnValue) == type(of: old), "Testable builder not following production behavior. Expected: \(type(of: old)), got: \(type(of: returnValue))")
        return returnValue
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
        let returnValue = WorkflowItemWrapper(content: w0) {
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
        let old = WorkflowBuilder.buildBlock(w0, w1, w2, w3, w4, w5, w6, w7)
        XCTAssert(type(of: returnValue) == type(of: old), "Testable builder not following production behavior. Expected: \(type(of: old)), got: \(type(of: returnValue))")
        return returnValue
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
        let returnValue = WorkflowItemWrapper(content: w0) {
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
        let old = WorkflowBuilder.buildBlock(w0, w1, w2, w3, w4, w5, w6, w7, w8)
        XCTAssert(type(of: returnValue) == type(of: old), "Testable builder not following production behavior. Expected: \(type(of: old)), got: \(type(of: returnValue))")
        return returnValue
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
        let returnValue = WorkflowItemWrapper(content: w0) {
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
        let old = WorkflowBuilder.buildBlock(w0, w1, w2, w3, w4, w5, w6, w7, w8, w9)
        XCTAssert(type(of: returnValue) == type(of: old), "Testable builder not following production behavior. Expected: \(type(of: old)), got: \(type(of: returnValue))")
        return returnValue
    }
}
