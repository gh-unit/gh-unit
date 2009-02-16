//
//  GHTestApp.m
//  GHUnit
//
//  Created by Gabriel Handford on 1/20/09.
//  Copyright 2009. All rights reserved.
//

#import "GHTestApp.h"

@implementation GHTestApp

- (id)init {
	if ((self = [super init])) {
		NSBundle *bundle = [NSBundle bundleForClass:[self class]];	
		topLevelObjects_ = [[NSMutableArray alloc] init]; 
		NSDictionary *externalNameTable = [NSDictionary dictionaryWithObjectsAndKeys:self, @"NSOwner", topLevelObjects_, @"NSTopLevelObjects", nil]; 
		[bundle loadNibFile:@"GHTestApp" externalNameTable:externalNameTable withZone:[self zone]];
	}
	return self;
}

- (void)dealloc {
	[topLevelObjects_ release];
	[super dealloc];
}

@end
