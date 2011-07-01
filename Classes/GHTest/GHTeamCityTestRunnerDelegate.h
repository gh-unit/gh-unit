//
//  GHTeamCityTestRunnerDelegate.h
//  GHUnitIPhone
//
//  Created by Aaron Dargel on 6/5/11.
//  Copyright 2011 None. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GHTeamCityTestRunnerDelegate : NSObject<GHTestRunnerDelegate> {
    
}

- (void)testRunnerDidStart:(GHTestRunner *)runner;
- (void)testRunner:(GHTestRunner *)runner didStartTest:(id<GHTest>)test; // Test started
- (void)testRunner:(GHTestRunner *)runner didEndTest:(id<GHTest>)test; // Test finished
//- (void)testRunnerDidCancel:(GHTestRunner *)runner;
//- (void)testRunnerDidEnd:(GHTestRunner *)runner;

@end
