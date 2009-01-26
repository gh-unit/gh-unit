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
- (void)_updateStatus:(id<GHTest>)test;
@end

@implementation GHTestViewController

@synthesize splitView=splitView_, statusView=statusView_, detailsView=detailsView_;
@synthesize statusLabel=statusLabel_, progressIndicator=progressIndicator_, outlineView=outlineView_;
@synthesize detailsTextView=detailsTextView_, consoleTestView=consoleTestView_;

- (id)init {
	if ((self = [super initWithNibName:@"GHTestView" bundle:[NSBundle bundleForClass:[GHTestViewController class]]])) { }
	return self;
}

- (void)dealloc {
	[model_ release];	
	[super dealloc];
}

- (void)awakeFromNib {
	[detailsTextView_ setTextColor:[NSColor whiteColor]];
	[detailsTextView_ setFont:[NSFont fontWithName:@"Monaco" size:9.0]];
	[detailsTextView_ setString:@""];
	self.status = @"Loading tests...";
	
}

- (void)setRoot:(id<GHTestGroup>)rootTest {
	[model_ release];
	model_ = [[GHTestViewModel alloc] initWithRoot:rootTest];
	[self _updateStatus:rootTest];
}

- (void)setStatus:(NSString *)status {
	[statusLabel_ setStringValue:[NSString stringWithFormat:@"Status: %@", status]];
}

- (NSString *)stringFromStatus:(GHTestStatus)status interval:(NSTimeInterval)interval {	
	return [NSString stringWithFormat:@"%@ (%0.3fs)", NSStringFromGHTestStatus(status), interval];
}

- (NSString *)status {
	[NSException raise:NSGenericException format:@"Operation not supported"];
	return nil;
}

- (void)log:(NSString *)log {
	
}

- (GHTestNode *)findFailure {
	GHTestNode *node = [model_ root];
	return [self findFailureFromNode:node];
}

- (GHTestNode *)findFailureFromNode:(GHTestNode *)node {
	if (node.failed && node.detail) return node;
	for(GHTestNode *childNode in node.children) {
		GHTestNode *foundNode = [self findFailureFromNode:childNode];
		if (foundNode) return foundNode;
	}
	return nil;
}

- (void)selectFirstFailure {
	GHTestNode *failedNode = [self findFailure];
	GHDebug(@"Failure node: %@", failedNode);
	NSInteger row = [outlineView_ rowForItem:failedNode];
	if (row >= 0)
		[outlineView_ selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
}

- (void)updateTest:(id<GHTest>)test {
	GHTestNode *testNode = [model_ findTestNode:test];
	[outlineView_ reloadItem:testNode];
	[outlineView_ expandItem:testNode expandChildren:YES];
	[self _updateStatus:model_.root.test];
}

- (void)_updateStatus:(id<GHTest>)test {
	if ([[test name] isEqual:@"Tests"]) {
		[progressIndicator_ setDoubleValue:((double)[test stats].runCount / (double)[test stats].testCount) * 100.0];

		self.status = [NSString stringWithFormat:@"%@ %d/%d (%d failures)", 
										 [self stringFromStatus:[test status] interval:[test interval]], 
										 [test stats].runCount, [test stats].testCount, [test stats].failureCount];
	}
}

#pragma mark DataSource (NSOutlineView)

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
	if (!item) {
		return [model_ root];
	} else {
		return [[item children] objectAtIndex:index];
	}
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
	return (!item) ? YES : ([[item children] count] > 0);
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
	return (!item) ? (model_ ? 1 : 0) : [[item children] count];
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

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	[detailsTextView_ setString:@""];
	
	id item = [outlineView_ itemAtRow:[outlineView_ selectedRow]];
	NSString *detail = [item detail];
	[detailsTextView_ setString:detail ? detail : @""];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
	return (![[item test] conformsToProtocol:@protocol(GHTestGroup)]);
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
	return ([[item test] conformsToProtocol:@protocol(GHTestGroup)]);
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {	
	if ([[tableColumn identifier] isEqual:@"status"]) {
		[cell setTextColor:[NSColor lightGrayColor]];	
		
		if ([item failed]) {
			[cell setTextColor:[NSColor redColor]];
		} else if ([item status] == GHTestStatusFinished) {
			[cell setTextColor:[NSColor greenColor]];
		} else if ([item status] == GHTestStatusRunning) {
			[cell setTextColor:[NSColor blackColor]];
		}
	}	
}

@end
