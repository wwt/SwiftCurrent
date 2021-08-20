//
//  XCTestHooks.m
//  CucumberSwift
//
//  Created by Tyler Thompson on 4/29/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XCTestHooks.h"
#import "NSObjectLoadable.h"

@implementation TestLoader

+ (void)load {
    [self beforeTestExecution];
}

@end
