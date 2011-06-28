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

@interface GHTestViewModel (Private)
- (void)_loadTestNodes;
@end

@implementation GHTestViewModel

@synthesize root=root_, editing=editing_;

- (id)initWithSuite:(GHTestSuite *)suite {
	if ((self = [super init])) {		
		suite_ = [suite retain];		
		[self loadDefaults]; // Needs to load before test nodes get built
		root_ = [[GHTestNode alloc] initWithTest:suite_ children:[suite_ children] source:self];
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
	[suite_ release];
	[runner_ release];
	[super dealloc];
}

- (NSString *)name {
	return [root_ name];
}

- (NSString *)statusString:(NSString *)prefix {
	NSInteger totalRunCount = [suite_ stats].testCount - ([suite_ disabledCount] + [suite_ stats].cancelCount);
	NSString *statusInterval = [NSString stringWithFormat:@"%@ %0.3fs", (self.isRunning ? @"Running" : @"Took"), [suite_ interval]];
	return [NSString stringWithFormat:@"%@%@ %d/%d (%d failures)", prefix, statusInterval,
					[suite_ stats].succeedCount, totalRunCount, [suite_ stats].failureCount];	
}

- (void)registerNode:(GHTestNode *)node {
	[map_ setObject:node forKey:node.identifier];
	node.delegate = self;
	
	// Apply settings
	BOOL disabled = [[settings_ objectForKey:[NSString stringWithFormat:@"%@-disabled", node.identifier]] boolValue];
	if (disabled) [node setSelected:NO];
}

- (GHTestNode *)findTestNode:(id<GHTest>)test {
	return [map_ objectForKey:[test identifier]];
}

- (GHTestNode *)findFailure {
	return [self findFailureFromNode:root_];
}

- (GHTestNode *)findFailureFromNode:(GHTestNode *)node {
	if (node.failed && [node.test exception]) return node;
	for(GHTestNode *childNode in node.children) {
		GHTestNode *foundNode = [self findFailureFromNode:childNode];
		if (foundNode) return foundNode;
	}
	return nil;
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
		GHUDebug(@"Node %@ changed: %d", node.identifier, node.isSelected);
		NSString *key = [NSString stringWithFormat:@"%@-disabled", node.identifier];
		if (node.isSelected) [settings_ removeObjectForKey:key];
		else [settings_ setObject:[NSNumber numberWithBool:YES] forKey:key];
	}
}

- (void)loadDefaults {
	settingsKey_ = [[NSString stringWithFormat:@"GHUnit4-%@", [suite_ name]] copy];
	settings_ = [[[NSUserDefaults standardUserDefaults] objectForKey:settingsKey_] mutableCopy];		
	if (!settings_) settings_ = [[NSMutableDictionary dictionary] retain];
	GHUDebug(@"Settings: %@", settings_);	
}

- (void)saveDefaults {
	GHUDebug(@"Saving settings: %@", settings_);
	[[NSUserDefaults standardUserDefaults] setObject:settings_ forKey:settingsKey_];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)cancel {	
	[runner_ cancel];
}

- (void)run:(id<GHTestRunnerDelegate>)delegate inParallel:(BOOL)inParallel {
	if (!runner_) {
		runner_ = [[GHTestRunner runnerForSuite:suite_] retain];		
		runner_.delegate = delegate;
	}
	if (inParallel) {
		NSOperationQueue *operationQueue = [[[NSOperationQueue alloc] init] autorelease];
		operationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
		runner_.operationQueue = operationQueue;
	} else {
		runner_.operationQueue = nil;
	}
	
	[runner_ runInBackground];
}

- (BOOL)isRunning {
	return runner_.isRunning;
}

@end

@implementation GHTestNode

@synthesize test=test_, children=children_, delegate=delegate_;

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
	} else if (self.isEnded) {
		if ([test_ interval] >= 0)
			interval = [NSString stringWithFormat:@"%0.2fs", [test_ interval]];

		if ([test_ status] == GHTestStatusErrored) status = @"✘";
		else if ([test_ status] == GHTestStatusSucceeded) status = @"✔";
		else if ([test_ status] == GHTestStatusCancelled) {
			status = @"-";
			interval = @"";
		} else if ([test_ isDisabled]) {
			status = @"⊝";
			interval = @"";
		}
	} else if (!self.isSelected) {
		status = @"";
	}

	if (self.isGroupTest) {
		NSString *statsString = [NSString stringWithFormat:@"%d/%d (%d failed)", 
														 ([test_ stats].succeedCount+[test_ stats].failureCount), 
														 [test_ stats].testCount, [test_ stats].failureCount];
		return [NSString stringWithFormat:@"%@ %@ %@", status, statsString, interval];
	} else {
		return [NSString stringWithFormat:@"%@ %@", status, interval];
	}
}

- (NSString *)nameWithStatus {
	NSString *interval = @"";
	if (self.isEnded) interval = [NSString stringWithFormat:@" (%0.2fs)", [test_ interval]];
	return [NSString stringWithFormat:@"%@%@", self.name, interval];
}

- (BOOL)isGroupTest {
	return ([test_ conformsToProtocol:@protocol(GHTestGroup)]);
}

- (BOOL)failed {
	return [test_ status] == GHTestStatusErrored;
}
	
- (BOOL)isRunning {
	return GHTestStatusIsRunning([test_ status]);
}

- (BOOL)isDisabled {
	return [test_ isDisabled];
}

- (BOOL)isEnded {
	return GHTestStatusEnded([test_ status]);
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
	return ![test_ isDisabled];
}

- (void)setSelected:(BOOL)selected {
	[test_ setDisabled:!selected];
	for(GHTestNode *node in children_) 
		[node setSelected:selected];
	[self notifyChanged];
}

@end
