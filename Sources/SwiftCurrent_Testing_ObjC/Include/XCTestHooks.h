//
//  XCTestHooks.h
//  CucumberSwift
//
//  Created by Tyler Thompson on 11/8/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TestLoader : NSNotificationCenter
    + (void) load;
@end

NS_ASSUME_NONNULL_END
