//
//  GHTeamCityTestRunnerDelegate.m
//  GHUnitIPhone
//
//  Created by Aaron Dargel on 6/5/11.
//  Copyright 2011 None. All rights reserved.
//

#import "GHTeamCityTestRunnerDelegate.h"

@implementation GHTeamCityTestRunnerDelegate


- (NSString *)escapeText:(NSString *)text{
  NSString *tmp = text;
  tmp = [text stringByReplacingOccurrencesOfString:@"|" withString:@"||"];
  tmp = [tmp stringByReplacingOccurrencesOfString:@"'" withString:@"|'"];
  tmp = [tmp stringByReplacingOccurrencesOfString:@"\n" withString:@"|n"];
  tmp = [tmp stringByReplacingOccurrencesOfString:@"\r" withString:@"|r"];
  tmp = [tmp stringByReplacingOccurrencesOfString:@"[" withString:@"|["];
  tmp = [tmp stringByReplacingOccurrencesOfString:@"]" withString:@"|]"];
  
  return tmp;
}

- (NSString *)intervalStringFrom:(NSTimeInterval)interval{
  int milli = [[NSNumber numberWithDouble:interval * 1000] intValue];
  return [[NSNumber numberWithInt:milli] stringValue];
}

- (void)logMessage:(NSString *)message{
  fputs([message UTF8String], stdout);
  fflush(stdout);
}

- (void)testRunnerDidStart:(GHTestRunner *)runner{
  [self logMessage:[NSString stringWithFormat:@"##teamcity[testSuiteStarted name='%@']\n", [self escapeText:runner.test.name]]];
}

- (void)testRunner:(GHTestRunner *)runner didStartTest:(id<GHTest>)test{
  [self logMessage:[NSString stringWithFormat:@"##teamcity[testStarted name='%@']\n", [self escapeText:test.name]]];
}

- (void)testRunner:(GHTestRunner *)runner didEndTest:(id<GHTest>)test{
  if (test.status == GHTestStatusErrored && test.exception){
    [self logMessage:[NSString stringWithFormat:@"##teamcity[testFailed name='%@' message='%@' details='%@']\n", 
                      [self escapeText:test.name], 
                      [self escapeText:test.exception.reason], 
                      [GHTesting descriptionForException:test.exception]]];  
  }
  
  [self logMessage:[NSString stringWithFormat:@"##teamcity[testFinished name='%@' duration='%@']\n", 
                    [self escapeText:test.name], [self intervalStringFrom:test.interval]]];
}

@end
