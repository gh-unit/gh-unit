//
//  GHTestMain.m
//  GHUnit
//
//  Created by Gabriel Handford on 1/20/09.
//  Copyright 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSDebug.h>

#import "GTMStackTrace.h"
#import "GHLogger.h"

#import <GHUnit/GHUnit.h>
#import <GHUnit/GHTestApp.h>

void exceptionHandler(NSException *exception) {
	NSLog(@"%@", GTMStackTraceFromException(exception));
}

int main(int argc, char *argv[]) {
	
	NSDebugEnabled = YES;
	NSZombieEnabled = YES;
	NSDeallocateZombies = NO;
	NSHangOnUncaughtException = YES;
	[NSAutoreleasePool enableFreedObjectCheck:YES];
	NSSetUncaughtExceptionHandler(&exceptionHandler);
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
#ifdef DEBUG
	[GHLogger setLogLevel:kGTMLoggerLevelDebug];
#endif
	
	GHTestApp *app = [[GHTestApp alloc] init];
	[NSApp run];
	[app release];
	[pool release];
}

