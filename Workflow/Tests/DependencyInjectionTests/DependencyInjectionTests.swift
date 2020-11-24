//
//  DependencyInjectionTests.swift
//  DependencyInjectionTests
//
//  Created by Tyler Thompson on 12/17/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import XCTest
import Swinject

import Workflow
@testable import WorkflowDI

protocol Vehicle { }
class Car:Vehicle { }
class Motorcycle:Vehicle { }

class DependencyInjectionTests: XCTestCase {

    override func tearDown() {
        AnyWorkflow.defaultContainer.removeAll()
    }
    
    func testPropertyWrapperInjectsFromDefaultContainer() {
        let car = Car()
        AnyWorkflow.defaultContainer.register(Vehicle.self) { _ in car }
        class Thing {
            @DependencyInjected var vehicle:Vehicle?
        }
        
        XCTAssertNotNil(Thing().vehicle)
        XCTAssert(Thing().vehicle is Car)
        XCTAssert((Thing().vehicle as? Car) === car)
    }

    func testPropertyWrapperWithSpecificName() {
        let car = Car()
        AnyWorkflow.defaultContainer.register(Vehicle.self, name: "car1") { _ in car }
        AnyWorkflow.defaultContainer.register(Vehicle.self, name: "car2") { _ in Car() }
        
        class Thing {
            @DependencyInjected(name: "car1") var vehicle:Vehicle?
        }
        
        XCTAssertNotNil(Thing().vehicle)
        XCTAssert(Thing().vehicle is Car)
        XCTAssert((Thing().vehicle as? Car) === car)
    }
    
    func testPropertyWrapperWithSpecificContainer() {
        AnyWorkflow.defaultContainer.register(Vehicle.self) { _ in Motorcycle() }
        Thing.container.register(Vehicle.self) { _ in Car() }
        
        class Thing {
            static var container:Container = Container()
            
            @DependencyInjected(container: Thing.container) var vehicle:Vehicle?
        }
        
        XCTAssert(Thing().vehicle is Car)
    }

    func testPropertyWrapperShouldBeLazy() {
        var callbackCalled = 0
        AnyWorkflow.defaultContainer.register(Vehicle.self) { _ in
            callbackCalled += 1
            return Car()
        }
        
        class Thing {
            @DependencyInjected var vehicle:Vehicle?
        }
        
        let thing = Thing()
        
        XCTAssertNotNil(thing.vehicle)
        XCTAssert(thing.vehicle is Car)
        XCTAssertEqual(callbackCalled, 1)
    }
    
}
