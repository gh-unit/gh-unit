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

@synthesize suite=suite_, running=running_, status=status_, statusProgress=statusProgress_, wrapInTextView=wrapInTextView_;

- (id)init {
	if ((self = [super initWithNibName:@"GHTestView" bundle:[NSBundle bundleForClass:[GHTestViewController class]]])) { 
		suite_ = [[GHTestSuite suiteFromEnv] retain];
		collapsed_ = YES;		
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
	[model_ release];
	model_ = [[GHTestOutlineViewModel alloc] initWithSuite:suite_];
	model_.delegate = self;
	_outlineView.delegate = model_;
	_outlineView.dataSource = model_;		
	
	[_textView setTextColor:[NSColor whiteColor]];
	[_textView setFont:[NSFont fontWithName:@"Monaco" size:10.0]];
	[_textView setString:@""];
	self.wrapInTextView = NO;
	
	[self loadDefaults];
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
	BOOL inParallel = [[NSUserDefaults standardUserDefaults] boolForKey:@"RunInParallel"];
	[model_ run:self inParallel:inParallel];
}

- (void)loadTestSuite {
	self.status = @"Loading tests...";
	[suite_ reset];
	[_outlineView reloadData];
	[_outlineView reloadItem:nil reloadChildren:YES];
	[_outlineView expandItem:nil expandChildren:YES];
	self.status = @"Select 'Run' to start tests";
}

#pragma mark -

- (void)setWrapInTextView:(BOOL)wrapInTextView {
	wrapInTextView_ = wrapInTextView;
	if (wrapInTextView_) {
		// No horizontal scroll, word wrapping
		[[_textView enclosingScrollView] setHasHorizontalScroller:NO];		
		[_textView setHorizontallyResizable:NO];
		NSSize size = [[_textView enclosingScrollView] frame].size;
		[[_textView textContainer] setContainerSize:NSMakeSize(size.width, FLT_MAX)];	
		[[_textView textContainer] setWidthTracksTextView:YES];
		NSRect frame = [_textView frame];
		frame.size.width = size.width;
		[_textView setFrame:frame];
	} else {
		// So we have horizontal scroll
		[[_textView enclosingScrollView] setHasHorizontalScroller:YES];		
		[_textView setHorizontallyResizable:YES];
		[[_textView textContainer] setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];	
		[[_textView textContainer] setWidthTracksTextView:NO];		
	}
	[_textView setNeedsDisplay:YES];
}

- (IBAction)copy:(id)sender {
	[_textView copy:sender];
}

- (IBAction)toggleDetails:(id)sender {	
	if (!collapsed_) {
		[_detailsView removeFromSuperview];
	} else {
		CGFloat windowWidth = self.view.window.frame.size.width;
		CGFloat minWindowWidth = 600;
		if (windowWidth < minWindowWidth) {
			NSRect frame = self.view.window.frame;
			frame.size.width = minWindowWidth;
			[self.view.window setFrame:frame display:YES animate:YES];
		}
		[_splitView addSubview:_detailsView];
	}
	collapsed_ = !collapsed_;
}

- (void)loadDefaults {
	// By default we are collapsed so expand if set
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ViewCollapsed"]) {
		[self toggleDetails:nil];
	
		CGFloat width = [[NSUserDefaults standardUserDefaults] doubleForKey:@"SplitWidth"];
		if (width > 200)
			[_splitView setPosition:width ofDividerAtIndex:0];
	}
}

- (void)saveDefaults {
	[[NSUserDefaults standardUserDefaults] setDouble:_statusView.frame.size.width forKey:@"SplitWidth"];
	[[NSUserDefaults standardUserDefaults] setBool:collapsed_ forKey:@"ViewCollapsed"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)_setText:(NSInteger)row selector:(SEL)selector {
	if (row < 0) return;
	id item = [_outlineView itemAtRow:row];
	NSString *text = [item performSelector:selector];
	if (text) text = [NSString stringWithFormat:@"%@\n", text]; // Newline important for when we append streaming text
	[_textView setString:text ? text : @""];	
}

- (IBAction)updateTextSegment:(id)sender {
	switch([sender selectedSegment]) {
		case 0:
			[self _setText:[_outlineView selectedRow] selector:@selector(stackTrace)];
			break;
		case 1:			
			[self _setText:[_outlineView selectedRow] selector:@selector(log)];
			break;
		case 2:
			// TODO
			break;
	}
}

- (id<GHTest>)selectedTest {
	NSInteger row = [_outlineView selectedRow];
	if (row < 0) return nil;
	GHTestNode *node = [_outlineView itemAtRow:row];
	return node.test;
}

- (void)selectFirstFailure {
	GHTestNode *failedNode = [model_ findFailure];
	NSInteger row = [_outlineView rowForItem:failedNode];
	if (row >= 0) {
		[_outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
		[_textSegmentedControl setSelectedSegment:0];
		[self updateTextSegment:_textSegmentedControl];
	}
}

- (void)_updateTest:(id<GHTest>)test {
	GHTestNode *testNode = [model_ findTestNode:test];
	[_outlineView reloadItem:testNode];	

	NSInteger runCount = [suite_ stats].succeedCount + [suite_ stats].failureCount;
	NSInteger totalRunCount = [suite_ stats].testCount - ([suite_ stats].disabledCount + [suite_ stats].cancelCount);
	self.statusProgress = ((double)runCount/(double)totalRunCount) * 100.0;

	NSString *statusInterval = [NSString stringWithFormat:@"%@ %0.3fs", (running_ ? @"Running" : @"Took"), [suite_ interval]];
	self.status = [NSString stringWithFormat:@"Status: %@ %d/%d (%d failures)", statusInterval,
								 [suite_ stats].succeedCount, totalRunCount, [suite_ stats].failureCount];
}

#pragma mark Delegates (GHTestOutlineViewModel)

- (void)testOutlineViewModelDidChangeSelection:(GHTestOutlineViewModel *)testOutlineViewModel {
	[_textView setString:@""];
	[self updateTextSegment:_textSegmentedControl];
}

#pragma mark Delegates (GHTestRunner)

- (void)testRunner:(GHTestRunner *)runner didLog:(NSString *)message {
	
}

- (void)testRunner:(GHTestRunner *)runner test:(id<GHTest>)test didLog:(NSString *)message {
	id<GHTest> selectedTest = self.selectedTest;
	if ([_textSegmentedControl selectedSegment] == 1 && [selectedTest isEqual:test]) {
		[_textView replaceCharactersInRange:NSMakeRange([[_textView string] length], 0) 
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
