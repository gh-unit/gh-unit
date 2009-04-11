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
@synthesize textSegmentedControl=textSegmentedControl_, textView=textView_, wrapInTextView=wrapInTextView_;

- (id)init {
	if ((self = [super initWithNibName:@"GHTestView" bundle:[NSBundle bundleForClass:[GHTestViewController class]]])) { }
	return self;
}

- (void)dealloc {
	[model_ release];	
	[super dealloc];
}

- (void)awakeFromNib {
	[textView_ setTextColor:[NSColor whiteColor]];
	[textView_ setFont:[NSFont fontWithName:@"Monaco" size:10.0]];
	[textView_ setString:@""];
	self.wrapInTextView = NO;
	
	[textSegmentedControl_ setTarget:self];
	[textSegmentedControl_ setAction:@selector(_textSegmentChanged:)];
	self.status = @"Loading tests...";
}

- (void)setWrapInTextView:(BOOL)wrapInTextView {
	wrapInTextView_ = wrapInTextView;
	if (wrapInTextView_) {
		// No horizontal scroll, word wrapping
		[[textView_ enclosingScrollView] setHasHorizontalScroller:NO];		
		[textView_ setHorizontallyResizable:NO];
		NSSize size = [[textView_ enclosingScrollView] frame].size;
		[[textView_ textContainer] setContainerSize:NSMakeSize(size.width, FLT_MAX)];	
		[[textView_ textContainer] setWidthTracksTextView:YES];
		NSRect frame = [textView_ frame];
		frame.size.width = size.width;
		[textView_ setFrame:frame];
	} else {
		// So we have horizontal scroll
		[[textView_ enclosingScrollView] setHasHorizontalScroller:YES];		
		[textView_ setHorizontallyResizable:YES];
		[[textView_ textContainer] setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];	
		[[textView_ textContainer] setWidthTracksTextView:NO];		
	}
	[textView_ setNeedsDisplay:YES];
}

- (IBAction)copy:(id)sender {
	[textView_ copy:sender];
}

- (void)_setText:(NSInteger)row selector:(SEL)selector {
	if (row < 0) return;
	id item = [outlineView_ itemAtRow:row];
	NSString *text = [item performSelector:selector];
	if (text) text = [NSString stringWithFormat:@"%@\n", text]; // Newline important for when we append streaming text
	[textView_ setString:text ? text : @""];	
}

- (void)_textSegmentChanged:(id)sender {
	if ([sender selectedSegment] == 0) {
		[self _setText:[outlineView_ selectedRow] selector:@selector(stackTrace)];
	} else {
		[self _setText:[outlineView_ selectedRow] selector:@selector(log)];
	}
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

- (id<GHTest>)selectedTest {
	NSInteger row = [outlineView_ selectedRow];
	if (row < 0) return nil;
	GHTestNode *node = [outlineView_ itemAtRow:row];
	return node.test;
}

- (void)log:(NSString *)log {
	
}

- (void)test:(id<GHTest>)test didLog:(NSString *)message {	
	id<GHTest> selectedTest = self.selectedTest;
	if ([textSegmentedControl_ selectedSegment] == 1 && [selectedTest isEqual:test]) {
		[textView_ replaceCharactersInRange:NSMakeRange([[textView_ string] length], 0) 
														 withString:[NSString stringWithFormat:@"%@\n", message]];
		// TODO(gabe): Scroll
	}
}

- (GHTestNode *)findFailure {
	GHTestNode *node = [model_ root];
	return [self findFailureFromNode:node];
}

- (GHTestNode *)findFailureFromNode:(GHTestNode *)node {
	if (node.failed && [node.test exception]) return node;
	for(GHTestNode *childNode in node.children) {
		GHTestNode *foundNode = [self findFailureFromNode:childNode];
		if (foundNode) return foundNode;
	}
	return nil;
}

- (void)selectFirstFailure {
	GHTestNode *failedNode = [self findFailure];
	NSInteger row = [outlineView_ rowForItem:failedNode];
	if (row >= 0) {
		[outlineView_ selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
		[textSegmentedControl_ setSelectedSegment:0];
		[self _textSegmentChanged:textSegmentedControl_];
	}
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
	[textView_ setString:@""];
	[self _textSegmentChanged:textSegmentedControl_];
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
