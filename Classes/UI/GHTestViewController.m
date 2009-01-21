//
//  GHTestViewController.m
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

#import "GHTestViewController.h"

@interface GHTestViewController (Private)
- (void)_updateStatus:(GHTestSuite *)testSuite;
@end

@implementation GHTestViewController

@synthesize splitView=splitView_, statusView=statusView_, detailsView=detailsView_;
@synthesize statusLabel=statusLabel_, progressIndicator=progressIndicator_, outlineView=outlineView_;
@synthesize detailsTextView=detailsTextView_, consoleTestView=consoleTestView_;

- (id)init {
	if ((self = [super initWithNibName:@"GHTestView" bundle:nil])) { }
	return self;
}

- (void)dealloc {
	[model_ release];
	
//	[splitView_ release];
//	[statusView_ release];
//	[detailsView_ release];
//	[statusLabel_ release];
//	[progressIndicator_ release];
//	[outlineView_ release];
	[super dealloc];
}

- (void)awakeFromNib {
	[detailsTextView_ setStringValue:@""];
	self.status = @"Loading tests...";
}

- (void)setStatus:(NSString *)status {
	[statusLabel_ setStringValue:[NSString stringWithFormat:@"Status: %@", status]];
}

- (NSString *)status {
	[NSException raise:NSGenericException format:@"Operation not supported"];
	return nil;
}

- (void)addTest:(GHTest *)test {
	GHAssertMainThread();
	if (!model_) {
		GHTestSuite *testSuite = test.testCase.testSuite;
		GTMLoggerDebug(@"testSuite=%@", testSuite);
		model_ = [[GHTestViewModel alloc] initWithTestSuite:testSuite];
		[outlineView_ expandItem:model_];
	}
	
	self.status = [NSString stringWithFormat:@"%@", test.name];
	
	GHTestCaseItem *testCaseItem = nil;
	BOOL refreshRoot = NO;
	if (![model_ isCurrentTestCase:test.testCase]) {
		testCaseItem = [GHTestCaseItem testCaseItemWithTestCase:test.testCase];
		[model_ addTestCaseItem:testCaseItem];
		refreshRoot = YES;
	} else {
		testCaseItem = model_.currentTestCaseItem;
	}

	[testCaseItem addTestItem:[GHTestItem testItemWithTest:test]];
	if (refreshRoot) {
		[outlineView_ reloadItem:nil];
	} else {
		[outlineView_ reloadItem:testCaseItem reloadChildren:YES];
	}
}

- (void)log:(NSString *)log {
	
}

- (void)testSuite:(GHTestSuite *)testSuite didUpdateTest:(GHTest *)test {	
	[progressIndicator_ setDoubleValue:((double)testSuite.runCount / (double)testSuite.totalCount) * 100.0];
	GHTestItem *testItem = [model_ findTestItem:test];
	[outlineView_ reloadItem:testItem];
	[outlineView_ expandItem:testItem expandChildren:YES];
	[self _updateStatus:testSuite];
}

- (void)testSuite:(GHTestSuite *)testSuite didUpdateTestCase:(GHTestCase *)testCase {	
	GHTestCaseItem *testCaseItem = [model_ findTestCaseItem:testCase];
	[outlineView_ reloadItem:testCaseItem];
	[outlineView_ expandItem:testCaseItem expandChildren:YES];
	[self _updateStatus:testSuite];
}

- (void)testSuiteDidFinish:(GHTestSuite *)testSuite {	
	[self _updateStatus:testSuite];
}

- (void)_updateStatus:(GHTestSuite *)testSuite {
	self.status = [NSString stringWithFormat:@"%@ %d/%d (%d failures)", 
								 testSuite.statusString, testSuite.runCount, testSuite.totalCount, testSuite.failedCount];
}

#pragma mark Delegates (NSOutlineView)

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	[detailsTextView_ setStringValue:@""];
	
	id item = [outlineView_ itemAtRow:[outlineView_ selectedRow]];
	if ([item isKindOfClass:[GHTestItem class]]) {
		GHTest *test = (GHTest *)[item test];
		if ([test exception])
			[detailsTextView_ setStringValue:[test backTrace]];
	}
	
}

#pragma mark DataSource (NSOutlineView)

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
	if (!item) {
		return model_;
	} else {
		return [item objectAtIndex:index];
	}
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
	return (!item) ? YES : ([item numberOfChildren] > 0);
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
	return (!item) ? (model_ ? 1 : 0) : [item numberOfChildren];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	if (!item) return nil;
	
	if ([[tableColumn identifier] isEqual:@"name"]) {
		return [item name];
	} else {
		return [item statusString];
	}
}

#pragma mark Delegates (NSOutlineView)

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {	
	[cell setTextColor:[NSColor blackColor]];
	
	if ([item status] == GHTestStatusFailed && [[tableColumn identifier] isEqual:@"status"]) {
		if ([item isKindOfClass:[GHTestItem class]]) {
			//[cell setDrawsBackground:YES];
			[cell setTextColor:[NSColor redColor]];
		} else {
			// Nothing yet
		}
	}
	
}

@end
