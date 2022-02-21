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

@resultBuilder
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public enum WorkflowBuilder {
    static func buildBlock<F, V>(_ component: WorkflowItem<F, Never, V>) -> WorkflowItem<F, Never, V> {
        component
    }

    public static func buildBlock<F0, V0,
                                  F1, V1>(_ f0: WorkflowItem<F0, Never, V0>,
                                          _ f1: WorkflowItem<F1, Never, V1>) -> WorkflowItem<F0, WorkflowItem<F1, Never, V1>, V0> {
        WorkflowItem(F0.self) {
            WorkflowItem(F1.self)
        }
    }

    public static func buildBlock<F0, V0,
                                  F1, V1,
                                  F2, V2>(_ f0: WorkflowItem<F0, Never, V0>,
                                          _ f1: WorkflowItem<F1, Never, V1>,
                                          _ f2: WorkflowItem<F2, Never, V2>) -> WorkflowItem<F0, WorkflowItem<F1, WorkflowItem<F2, Never, V2>, V1>, V0> {
        WorkflowItem(F0.self) {
            WorkflowItem(F1.self) {
                WorkflowItem(F2.self)
            }
        }
    }

    public static func buildBlock<F0, V0,
                                  F1, V1,
                                  F2, V2,
                                  F3, V3>(_ f0: WorkflowItem<F0, Never, V0>,
                                          _ f1: WorkflowItem<F1, Never, V1>,
                                          _ f2: WorkflowItem<F2, Never, V2>,
                                          _ f3: WorkflowItem<F3, Never, V3>) -> WorkflowItem<F0, WorkflowItem<F1, WorkflowItem<F2, WorkflowItem<F3, Never, V3>, V2>, V1>, V0> {
        WorkflowItem(F0.self) {
            WorkflowItem(F1.self) {
                WorkflowItem(F2.self) {
                    WorkflowItem(F3.self)
                }
            }
        }
    }

    public static func buildBlock<F0, V0,
                                  F1, V1,
                                  F2, V2,
                                  F3, V3,
                                  F4, V4>(_ f0: WorkflowItem<F0, Never, V0>,
                                          _ f1: WorkflowItem<F1, Never, V1>,
                                          _ f2: WorkflowItem<F2, Never, V2>,
                                          _ f3: WorkflowItem<F3, Never, V3>,
                                          _ f4: WorkflowItem<F4, Never, V4>) -> WorkflowItem<F0, WorkflowItem<F1, WorkflowItem<F2, WorkflowItem<F3, WorkflowItem<F4, Never, V4>, V3>, V2>, V1>, V0> {
        WorkflowItem(F0.self) {
            WorkflowItem(F1.self) {
                WorkflowItem(F2.self) {
                    WorkflowItem(F3.self) {
                        WorkflowItem(F4.self)
                    }
                }
            }
        }
    }

    public static func buildBlock<F0, V0,
                                  F1, V1,
                                  F2, V2,
                                  F3, V3,
                                  F4, V4,
                                  F5, V5>(_ f0: WorkflowItem<F0, Never, V0>,
                                          _ f1: WorkflowItem<F1, Never, V1>,
                                          _ f2: WorkflowItem<F2, Never, V2>,
                                          _ f3: WorkflowItem<F3, Never, V3>,
                                          _ f4: WorkflowItem<F4, Never, V4>,
                                          _ f5: WorkflowItem<F5, Never, V5>) -> WorkflowItem<F0, WorkflowItem<F1, WorkflowItem<F2, WorkflowItem<F3, WorkflowItem<F4, WorkflowItem<F5, Never, V5>, V4>, V3>, V2>, V1>, V0> {
        WorkflowItem(F0.self) {
            WorkflowItem(F1.self) {
                WorkflowItem(F2.self) {
                    WorkflowItem(F3.self) {
                        WorkflowItem(F4.self) {
                            WorkflowItem(F5.self)
                        }
                    }
                }
            }
        }
    }

    public static func buildBlock<F0, V0,
                                  F1, V1,
                                  F2, V2,
                                  F3, V3,
                                  F4, V4,
                                  F5, V5,
                                  F6, V6>(_ f0: WorkflowItem<F0, Never, V0>,
                                          _ f1: WorkflowItem<F1, Never, V1>,
                                          _ f2: WorkflowItem<F2, Never, V2>,
                                          _ f3: WorkflowItem<F3, Never, V3>,
                                          _ f4: WorkflowItem<F4, Never, V4>,
                                          _ f5: WorkflowItem<F5, Never, V5>,
                                          _ f6: WorkflowItem<F6, Never, V6>) -> WorkflowItem<F0, WorkflowItem<F1, WorkflowItem<F2, WorkflowItem<F3, WorkflowItem<F4, WorkflowItem<F5, WorkflowItem<F6, Never, V6>, V5>, V4>, V3>, V2>, V1>, V0> {
        WorkflowItem(F0.self) {
            WorkflowItem(F1.self) {
                WorkflowItem(F2.self) {
                    WorkflowItem(F3.self) {
                        WorkflowItem(F4.self) {
                            WorkflowItem(F5.self) {
                                WorkflowItem(F6.self)
                            }
                        }
                    }
                }
            }
        }
    }

    public static func buildBlock<F0, V0,
                                  F1, V1,
                                  F2, V2,
                                  F3, V3,
                                  F4, V4,
                                  F5, V5,
                                  F6, V6,
                                  F7, V7>(_ f0: WorkflowItem<F0, Never, V0>,
                                          _ f1: WorkflowItem<F1, Never, V1>,
                                          _ f2: WorkflowItem<F2, Never, V2>,
                                          _ f3: WorkflowItem<F3, Never, V3>,
                                          _ f4: WorkflowItem<F4, Never, V4>,
                                          _ f5: WorkflowItem<F5, Never, V5>,
                                          _ f6: WorkflowItem<F6, Never, V6>,
                                          _ f7: WorkflowItem<F7, Never, V7>) -> WorkflowItem<F0, WorkflowItem<F1, WorkflowItem<F2, WorkflowItem<F3, WorkflowItem<F4, WorkflowItem<F5, WorkflowItem<F6, WorkflowItem<F7, Never, V7>, V6>, V5>, V4>, V3>, V2>, V1>, V0> {
        WorkflowItem(F0.self) {
            WorkflowItem(F1.self) {
                WorkflowItem(F2.self) {
                    WorkflowItem(F3.self) {
                        WorkflowItem(F4.self) {
                            WorkflowItem(F5.self) {
                                WorkflowItem(F6.self) {
                                    WorkflowItem(F7.self)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    public static func buildBlock<F0, V0,
                                  F1, V1,
                                  F2, V2,
                                  F3, V3,
                                  F4, V4,
                                  F5, V5,
                                  F6, V6,
                                  F7, V7,
                                  F8, V8>(_ f0: WorkflowItem<F0, Never, V0>,
                                          _ f1: WorkflowItem<F1, Never, V1>,
                                          _ f2: WorkflowItem<F2, Never, V2>,
                                          _ f3: WorkflowItem<F3, Never, V3>,
                                          _ f4: WorkflowItem<F4, Never, V4>,
                                          _ f5: WorkflowItem<F5, Never, V5>,
                                          _ f6: WorkflowItem<F6, Never, V6>,
                                          _ f7: WorkflowItem<F7, Never, V7>,
                                          _ f8: WorkflowItem<F8, Never, V8>) -> WorkflowItem<F0, WorkflowItem<F1, WorkflowItem<F2, WorkflowItem<F3, WorkflowItem<F4, WorkflowItem<F5, WorkflowItem<F6, WorkflowItem<F7, WorkflowItem<F8, Never, V8>, V7>, V6>, V5>, V4>, V3>, V2>, V1>, V0> {
        WorkflowItem(F0.self) {
            WorkflowItem(F1.self) {
                WorkflowItem(F2.self) {
                    WorkflowItem(F3.self) {
                        WorkflowItem(F4.self) {
                            WorkflowItem(F5.self) {
                                WorkflowItem(F6.self) {
                                    WorkflowItem(F7.self) {
                                        WorkflowItem(F8.self)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    public static func buildBlock<F0, V0,
                                  F1, V1,
                                  F2, V2,
                                  F3, V3,
                                  F4, V4,
                                  F5, V5,
                                  F6, V6,
                                  F7, V7,
                                  F8, V8,
                                  F9, V9>(_ f0: WorkflowItem<F0, Never, V0>,
                                          _ f1: WorkflowItem<F1, Never, V1>,
                                          _ f2: WorkflowItem<F2, Never, V2>,
                                          _ f3: WorkflowItem<F3, Never, V3>,
                                          _ f4: WorkflowItem<F4, Never, V4>,
                                          _ f5: WorkflowItem<F5, Never, V5>,
                                          _ f6: WorkflowItem<F6, Never, V6>,
                                          _ f7: WorkflowItem<F7, Never, V7>,
                                          _ f8: WorkflowItem<F8, Never, V8>,
                                          _ f9: WorkflowItem<F9, Never, V9>) -> WorkflowItem<F0, WorkflowItem<F1, WorkflowItem<F2, WorkflowItem<F3, WorkflowItem<F4, WorkflowItem<F5, WorkflowItem<F6, WorkflowItem<F7, WorkflowItem<F8, WorkflowItem<F9, Never, V9>, V8>, V7>, V6>, V5>, V4>, V3>, V2>, V1>, V0> {
        WorkflowItem(F0.self) {
            WorkflowItem(F1.self) {
                WorkflowItem(F2.self) {
                    WorkflowItem(F3.self) {
                        WorkflowItem(F4.self) {
                            WorkflowItem(F5.self) {
                                WorkflowItem(F6.self) {
                                    WorkflowItem(F7.self) {
                                        WorkflowItem(F8.self) {
                                            WorkflowItem(F9.self)
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
