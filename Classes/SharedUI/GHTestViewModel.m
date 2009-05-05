//
//  GHTestViewModel.m
//  GHKit
//
//  Created by Gabriel Handford on 1/17/09.
//  Copyright 2009. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "GHTestViewModel.h"
#import "GTMStackTrace.h"

@implementation GHTestViewModel

@synthesize root=root_;

- (id)initWithRoot:(id<GHTestGroup>)root {
	if ((self = [super init])) {		
		settingsKey_ = [[NSString stringWithFormat:@"GHUnit-%@", [root name]] copy];
		settings_ = [[[NSUserDefaults standardUserDefaults] objectForKey:settingsKey_] retain];		
		if (!settings_) settings_ = [[NSMutableDictionary dictionary] retain];
		GHUDebug(@"Settings: %@", settings_);
		
		root_ = [[GHTestNode alloc] initWithTest:root children:[root children] source:self];
		map_ = [[NSMutableDictionary dictionary] retain];
	}
	return self;
}

- (void)dealloc {
	// Clear delegates
	for(NSString *identifier in map_) 
		[[map_ objectForKey:identifier] setDelegate:nil];
	
	[root_ release];
	[map_ release];
	[settingsKey_ release];
	[settings_ release];
	[super dealloc];
}

- (NSString *)name {
	return [root_ name];
}

- (NSString *)statusString {
	return [root_ statusString];
}

- (void)registerNode:(GHTestNode *)node {
	[map_ setObject:node forKey:node.identifier];
	node.delegate = self;
	
	// Apply settings
	id selectedValue = [settings_ objectForKey:[NSString stringWithFormat:@"%@-%@", node.identifier, @"selected"]];
	node.selected = (selectedValue ? [selectedValue boolValue] : YES); // Defaults to selected
}

- (GHTestNode *)findTestNode:(id<GHTest>)test {
	return [map_ objectForKey:[test identifier]];
}

- (NSInteger)numberOfGroups {
	return [[root_ children] count];
}

- (NSInteger)numberOfTestsInGroup:(NSInteger)group {
	NSArray *children = [root_ children];
	if ([children count] == 0) return 0;
	GHTestNode *groupNode = [children objectAtIndex:group];
	return [[groupNode children] count];
}

- (NSIndexPath *)indexPathToTest:(id<GHTest>)test {
	NSInteger section = 0;
	for(GHTestNode *node in [root_ children]) {
		NSInteger row = 0;		
		if ([node.test isEqual:test]) {
			NSUInteger pathIndexes[] = {section,row};
			return [NSIndexPath indexPathWithIndexes:pathIndexes length:2]; // Not user row:section: for compatibility with MacOSX
		}
		for(GHTestNode *childNode in [node children]) {
			if ([childNode.test isEqual:test]) {
				NSUInteger pathIndexes[] = {section,row};
				return [NSIndexPath indexPathWithIndexes:pathIndexes length:2];
			}
			row++;
		}
		section++;
	}
	return nil;
}

- (void)testNodeDidChange:(GHTestNode *)node {	
	if (![node hasChildren]) {
		GHUDebug(@"Node changed: %d", node.selected);
		[settings_ setObject:[NSNumber numberWithBool:node.selected] forKey:[NSString stringWithFormat:@"%@-%@", node.identifier, @"selected"]];
	}
}

- (void)saveSettings {
	GHUDebug(@"Saving settings: %@", settings_);
	[[NSUserDefaults standardUserDefaults] setObject:settings_ forKey:settingsKey_];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end

@implementation GHTestNode

@synthesize test=test_, identifier=identifier_, name=name_, children=children_, delegate=delegate_;

- (id)initWithTest:(id<GHTest>)test children:(NSArray *)children source:(GHTestViewModel *)source {
	if ((self = [super init])) {
		test_ = [test retain];
		
		NSMutableArray *nodeChildren = [NSMutableArray array];
		for(id<GHTest> test in children) {	
			
			GHTestNode *node = nil;
			if ([test conformsToProtocol:@protocol(GHTestGroup)]) {
				NSArray *testChildren = [(id<GHTestGroup>)test children];
				if ([testChildren count] > 0) 
					node = [GHTestNode nodeWithTest:test children:testChildren source:source];
			} else {
				node = [GHTestNode nodeWithTest:test children:nil source:source];
			}			
			if (node)
				[nodeChildren addObject:node];
		}
		children_ = [nodeChildren retain];
		[source registerNode:self];
	}
	return self;
}

- (void)dealloc {
	[test_ release];
	[children_ release];
	[super dealloc];
}

+ (GHTestNode *)nodeWithTest:(id<GHTest>)test children:(NSArray *)children source:(GHTestViewModel *)source {
	return [[[GHTestNode alloc] initWithTest:test children:children source:source] autorelease];
}

- (BOOL)hasChildren {
	return [children_ count] > 0;
}

- (void)notifyChanged {
	[delegate_ testNodeDidChange:self];
}

- (NSString *)name {
	return [test_ name];
}

- (NSString *)identifier {
	return [test_ identifier];
}

- (NSString *)statusString {
	// TODO(gabe): Some other special chars: ☐✖✗✘✓
	NSString *status = @"";
	NSString *interval = @"";
	if (self.isRunning) {
		status = @"✸";
		if (self.isGroupTest)
			interval = [NSString stringWithFormat:@"%0.2fs", [test_ interval]];
	} else if (self.isFinished) {
		if (self.failed) status = @"✘";
		else status = @"✔";
		interval = [NSString stringWithFormat:@"%0.2fs", [test_ interval]];
	} else if (!self.isSelected) {
		status = @"(off)";
	}

	if (self.isGroupTest) {
		return [NSString stringWithFormat:@"%@ %@ %@", status, NSStringFromGHTestStats([test_ stats]), interval];
	} else {
		return [NSString stringWithFormat:@"%@ %@", status, interval];
	}
}

- (NSString *)nameWithStatus {
	NSString *interval = @"";
	if (self.isFinished) interval = [NSString stringWithFormat:@" (%0.2fs)", [test_ interval]];
	return [NSString stringWithFormat:@"%@%@", self.name, interval];
}

- (BOOL)isGroupTest {
	return ([test_ conformsToProtocol:@protocol(GHTestGroup)]);
}

- (BOOL)failed {
	return ([test_ stats].failureCount > 0);
}
	
- (BOOL)isRunning {
	return ([test_ status] == GHTestStatusRunning);
}

- (BOOL)isFinished {
	return ([test_ status] == GHTestStatusFinished);
}

- (GHTestStatus)status {
	return [test_ status];
}

- (NSString *)stackTrace {
	if (![test_ exception]) return nil;

	return [[NSString stringWithFormat:@"%@ - %@\n%@", 
					 [[test_ exception] name],
					 [[test_ exception] reason], 
					 GHU_GTMStackTraceFromException([test_ exception])] retain];
}

- (NSString *)log {
	return [[test_ log] componentsJoinedByString:@"\n"]; // TODO(gabe): This isn't very performant
}

- (NSString *)description {
	return [test_ description];
}

- (BOOL)isSelected {
	return ![test_ ignore];
}

- (void)setSelected:(BOOL)selected {
	[test_ setIgnore:!selected];
}

@end
