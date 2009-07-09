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

@interface GHTestViewController ()
@property (assign, nonatomic, getter=isRunning) BOOL running;
@end

@interface GHTestViewController (Private)
- (void)_updateStatus:(id<GHTest>)test;
@end

@implementation GHTestViewController

@synthesize runButton=runButton_, collapseButton=collapseButton_;
@synthesize splitView=splitView_, statusView=statusView_, detailsView=detailsView_;
@synthesize statusLabel=statusLabel_, progressIndicator=progressIndicator_, outlineView=outlineView_;
@synthesize textSegmentedControl=textSegmentedControl_, textView=textView_, wrapInTextView=wrapInTextView_;

@synthesize suite=suite_, running=running_;

- (id)init {
	if ((self = [super initWithNibName:@"GHTestView" bundle:[NSBundle bundleForClass:[GHTestViewController class]]])) { }
	return self;
}

- (void)dealloc {
	[model_ release];	
	[runner_ release];
	[suite_ release];
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

	//[splitView_ setToggleCollapseButton:collapseButton_];
	[collapseButton_ setTarget:self];
	[collapseButton_ setAction:@selector(_toggleCollapse:)];
	[self loadTests];
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

- (void)loadTests {
	[runner_ release];
	
	GHTestSuite *suite = suite_;
	if (!suite) suite = [GHTestSuite suiteFromEnv];	
	runner_ = [[GHTestRunner runnerForSuite:suite] retain];
	runner_.delegate = self;
	[self setRoot:(id<GHTestGroup>)runner_.test];	
}

#pragma mark Running

- (IBAction)runTests:(id)sender {
	[self runTests];
}

- (void)runTests {
	if (self.isRunning) return;

	[self loadTests];
	self.running = YES;
	[NSThread detachNewThreadSelector:@selector(_runTests) toTarget:self withObject:nil];	
}

- (void)_runTests {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];		
	[runner_ run];
	[pool release];
	[self performSelectorOnMainThread:@selector(_afterRunTests) withObject:nil waitUntilDone:YES];
}

- (void)_afterRunTests {
	self.running = NO;
}

#pragma mark -

- (void)_toggleCollapse:(id)sender {
	CGFloat windowWidth = self.view.window.frame.size.width;
	CGFloat minWindowWidth = (splitView_.collapsibleSubviewCollapsed ? 600 : 0);
	if (windowWidth < minWindowWidth) {
		NSRect frame = self.view.window.frame;
		frame.size.width = 400;
		[self.view.window setFrame:frame display:YES animate:YES];
	}
	[splitView_ toggleCollapse:sender];
}

- (void)_setText:(NSInteger)row selector:(SEL)selector {
	if (row < 0) return;
	id item = [outlineView_ itemAtRow:row];
	NSString *text = [item performSelector:selector];
	if (text) text = [NSString stringWithFormat:@"%@\n", text]; // Newline important for when we append streaming text
	[textView_ setString:text ? text : @""];	
}

- (void)_textSegmentChanged:(id)sender {
	switch([sender selectedSegment]) {
		case 0:
			[self _setText:[outlineView_ selectedRow] selector:@selector(stackTrace)];
			break;
		case 1:			
			[self _setText:[outlineView_ selectedRow] selector:@selector(log)];
			break;
		case 2:
			// TODO
			break;
	}
}

- (void)setRoot:(id<GHTestGroup>)rootTest {
	[model_ release];
	model_ = nil;
	if (rootTest) {
		model_ = [[GHTestViewModel alloc] initWithRoot:rootTest];
		[outlineView_ reloadData];
		[outlineView_ reloadItem:nil reloadChildren:YES];
		[outlineView_ expandItem:nil expandChildren:YES];
		[self _updateStatus:rootTest];
	}
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
	[self _updateStatus:model_.root.test];
}

- (void)_updateStatus:(id<GHTest>)test {
	if ([[test name] isEqual:@"Tests"]) {
		NSInteger runTestCount = [test stats].testCount - [test stats].ignoreCount;
		[progressIndicator_ setDoubleValue:(((double)[test stats].runCount / (double)runTestCount)) * 100.0];

		self.status = [NSString stringWithFormat:@"%@ %d/%d (%d failures)", 
										 [self stringFromStatus:[test status] interval:[test interval]], 
										 [test stats].runCount, runTestCount, [test stats].failureCount];
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
	
	if (tableColumn == nil) {
		return [item nameWithStatus];
	} else if ([[tableColumn identifier] isEqual:@"name"]) {
		return [item name];
	} else if ([[tableColumn identifier] isEqual:@"status"]) {
		return [item statusString];
	} else if ([[tableColumn identifier] isEqual:@"enabled"]) {
		return [NSNumber numberWithBool:[item isSelected]];
	}
	return nil;
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	if ([[tableColumn identifier] isEqual:@"enabled"]) {
		[item setSelected:[object boolValue]];
		[item notifyChanged];
	}
}

// We can return a different cell for each row, if we want
- (NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	// If we return a cell for the 'nil' tableColumn, it will be used as a "full width" cell and span all the columns
	if (tableColumn == nil && [item hasChildren]) {
		// We want to use the cell for the name column, but we could construct a new cell if we wanted to, or return a different cell for each row.
		return [[outlineView tableColumnWithIdentifier:@"name"] dataCell];
	}
	return [tableColumn dataCell];
}

#pragma mark Delegates (NSOutlineView)

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	[textView_ setString:@""];
	[self _textSegmentChanged:textSegmentedControl_];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
	NSInteger clickedCol = [outlineView clickedColumn];
	NSInteger clickedRow = [outlineView clickedRow];
	if (clickedRow >= 0 && clickedCol >= 0) {
		NSCell *cell = [outlineView preparedCellAtColumn:clickedCol row:clickedRow];
		if ([cell isKindOfClass:[NSButtonCell class]] && [cell isEnabled]) {
			return NO;
		}            
	}

	return (![item hasChildren]);
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
	return ([item hasChildren]);
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

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldTrackCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	// We want to allow tracking for all the button cells, even if we don't allow selecting that particular row. 
	if ([cell isKindOfClass:[NSButtonCell class]]) {
		// We can also take a peek and make sure that the part of the cell clicked is an area that is normally tracked. Otherwise, clicking outside of the checkbox may make it check the checkbox
		NSRect cellFrame = [outlineView frameOfCellAtColumn:[[outlineView tableColumns] indexOfObject:tableColumn] row:[outlineView rowForItem:item]];
		NSUInteger hitTestResult = [cell hitTestForEvent:[NSApp currentEvent] inRect:cellFrame ofView:outlineView];
		if (hitTestResult && NSCellHitTrackableArea != 0) {
			return YES;
		} else {
			return NO;
		}
	} else {
		// Only allow tracking on selected rows. This is what NSTableView does by default.
		return [outlineView isRowSelected:[outlineView rowForItem:item]];
	}
}

#pragma mark Delegates (GHTestRunner)

- (void)testRunner:(GHTestRunner *)runner didLog:(NSString *)message {
	[self log:message];
}

- (void)testRunner:(GHTestRunner *)runner test:(id<GHTest>)test didLog:(NSString *)message {
	[self test:test didLog:message];
}

- (void)testRunner:(GHTestRunner *)runner didStartTest:(id<GHTest>)test {
	[self updateTest:test];
}

- (void)testRunner:(GHTestRunner *)runner didEndTest:(id<GHTest>)test {
	[self updateTest:test];
}

- (void)testRunnerDidStart:(GHTestRunner *)runner { 	
	[self updateTest:runner.test];
}

- (void)testRunnerDidEnd:(GHTestRunner *)runner {
	[self updateTest:runner.test];
	[self selectFirstFailure];
}


@end
