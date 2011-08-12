//
//  main.m
//  Tests
//
//  Created by Gabriel Handford on 7/16/11.
//  Copyright 2011 rel.me. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[])
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  int retVal = UIApplicationMain(argc, argv, nil, @"GHUnitIOSAppDelegate");
  [pool release];
  return retVal;
}
