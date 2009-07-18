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
- (void)_updateTest:(id<GHTest>)test;
@end

@implementation GHTestViewController

@synthesize runButton=runButton_, collapseButton=collapseButton_;
@synthesize splitView=splitView_, statusView=statusView_, detailsView=detailsView_;
@synthesize statusLabel=statusLabel_, progressIndicator=progressIndicator_, outlineView=outlineView_;
@synthesize textSegmentedControl=textSegmentedControl_, textView=textView_, wrapInTextView=wrapInTextView_;

@synthesize suite=suite_, running=running_, status=status_;

- (id)init {
	if ((self = [super initWithNibName:@"GHTestView" bundle:[NSBundle bundleForClass:[GHTestViewController class]]])) { 
		suite_ = [[GHTestSuite suiteFromEnv] retain];
	}
	return self;
}

- (void)dealloc {
	model_.delegate = nil;
	[model_ release];
	[suite_ release];
	[status_ release];
	[super dealloc];
}

- (void)awakeFromNib {
	model_ = [[GHTestOutlineViewModel alloc] init];
	model_.delegate = self;
	outlineView_.delegate = model_;
	outlineView_.dataSource = model_;
	
	[textView_ setTextColor:[NSColor whiteColor]];
	[textView_ setFont:[NSFont fontWithName:@"Monaco" size:10.0]];
	[textView_ setString:@""];
	self.wrapInTextView = NO;
	
	[textSegmentedControl_ setTarget:self];
	[textSegmentedControl_ setAction:@selector(_textSegmentChanged:)];

	[collapseButton_ setTarget:self];
	[collapseButton_ setAction:@selector(_toggleCollapse:)];
	
	[self loadTestSuite];
}

#pragma mark Running

- (IBAction)runTests:(id)sender {
	[self runTests];
}

- (void)runTests {
	if (self.isRunning) return;

	NSAssert(suite_, @"Must set test suite");
	[self loadTestSuite];
	self.status = @"Starting tests...";
	self.running = YES;
	[model_ run];
}

- (void)loadTestSuite {
	self.status = @"Loading tests...";
	GHTestRunner *runner = [model_ loadTestSuite:suite_];	
	runner.delegate = self;
	
	[outlineView_ reloadData];
	[outlineView_ reloadItem:nil reloadChildren:YES];
	[outlineView_ expandItem:nil expandChildren:YES];
	self.status = @"Select 'Run' to start tests";
}

#pragma mark -

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

- (void)_toggleCollapse:(id)sender {
	BOOL collapsed = [splitView_ isSubviewCollapsed:detailsView_] || detailsView_.frame.size.width == 0;
	
	if (!collapsed) {
		CGFloat splitWidth = [splitView_ bounds].size.width / 2;
		NSRect frame = self.view.window.frame;
		frame.size.width = splitWidth;
		[self.view.window setFrame:frame display:YES animate:YES];
		[splitView_ setPosition:splitWidth ofDividerAtIndex:0];
	} else {
		CGFloat windowWidth = self.view.window.frame.size.width;
		CGFloat minWindowWidth = 600;
		if (windowWidth < minWindowWidth) {
			NSRect frame = self.view.window.frame;
			frame.size.width = minWindowWidth;
			[self.view.window setFrame:frame display:YES animate:YES];
		}
		[splitView_ setPosition:round([splitView_ bounds].size.width/2.0) ofDividerAtIndex:0];
	}
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

- (id<GHTest>)selectedTest {
	NSInteger row = [outlineView_ selectedRow];
	if (row < 0) return nil;
	GHTestNode *node = [outlineView_ itemAtRow:row];
	return node.test;
}

- (void)selectFirstFailure {
	GHTestNode *failedNode = [model_ findFailure];
	NSInteger row = [outlineView_ rowForItem:failedNode];
	if (row >= 0) {
		[outlineView_ selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
		[textSegmentedControl_ setSelectedSegment:0];
		[self _textSegmentChanged:textSegmentedControl_];
	}
}

- (void)_updateTest:(id<GHTest>)test {
	GHTestNode *testNode = [model_ findTestNode:test];
	[outlineView_ reloadItem:testNode];	

	NSInteger runCount = [suite_ stats].succeedCount + [suite_ stats].failureCount;
	NSInteger totalRunCount = [suite_ stats].testCount - ([suite_ stats].disabledCount + [suite_ stats].cancelCount);
	[progressIndicator_ setDoubleValue:((double)runCount/(double)totalRunCount) * 100.0];

	NSString *statusInterval = [NSString stringWithFormat:@"%@ %0.3fs", (running_ ? @"Running" : @"Took"), [suite_ interval]];
	self.status = [NSString stringWithFormat:@"Status: %@ %d/%d (%d failures)", statusInterval,
								 [suite_ stats].succeedCount, totalRunCount, [suite_ stats].failureCount];
}

#pragma mark Delegates (GHTestOutlineViewModel)

- (void)testOutlineViewModelDidChangeSelection:(GHTestOutlineViewModel *)testOutlineViewModel {
	[textView_ setString:@""];
	[self _textSegmentChanged:textSegmentedControl_];
}

#pragma mark Delegates (GHTestRunner)

- (void)testRunner:(GHTestRunner *)runner didLog:(NSString *)message {
	
}

- (void)testRunner:(GHTestRunner *)runner test:(id<GHTest>)test didLog:(NSString *)message {
	id<GHTest> selectedTest = self.selectedTest;
	if ([textSegmentedControl_ selectedSegment] == 1 && [selectedTest isEqual:test]) {
		[textView_ replaceCharactersInRange:NSMakeRange([[textView_ string] length], 0) 
														 withString:[NSString stringWithFormat:@"%@\n", message]];
		// TODO(gabe): Scroll
	}	
}

- (void)testRunner:(GHTestRunner *)runner didStartTest:(id<GHTest>)test {
	[self _updateTest:test];
}

- (void)testRunner:(GHTestRunner *)runner didEndTest:(id<GHTest>)test {
	[self _updateTest:test];
}

- (void)testRunnerDidStart:(GHTestRunner *)runner { 	
	[self _updateTest:runner.test];
}

- (void)testRunnerDidEnd:(GHTestRunner *)runner {
	[self _updateTest:runner.test];
	[self selectFirstFailure];
	self.running = NO;
}


@end
