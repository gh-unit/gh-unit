//
//  GHUnitIPhoneViewController.m
//  GHUnitIPhone
//
//  Created by Gabriel Handford on 1/25/09.
//  Copyright 2009. All rights reserved.
//

#import "GHUnitIPhoneViewController.h"

NSString *const GHUnitPrefixKey = @"Prefix";
NSString *const GHUnitFilterKey = @"Filter";

@interface GHUnitIPhoneViewController (Private)
- (NSString *)_prefix;
- (void)_setPrefix:(NSString *)prefix;
- (void)_setFilterIndex:(NSInteger)index;
- (NSInteger)_filterIndex;
@end

@implementation GHUnitIPhoneViewController

@synthesize tableView=tableView_, suite=suite_;

- (void)dealloc {
	[dataSource_ release];	
	[suite_ release];
	searchBar_.delegate = nil;
	[searchBar_ release];
	[super dealloc];
}

- (void)loadDefaults { }

- (void)saveDefaults {
  [dataSource_ saveDefaults];
}

- (void)loadView {
  self.title = @"Tests";

	UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)] autorelease];
	view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

	// Search bar
	searchBar_ = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	searchBar_.delegate = self;
	searchBar_.showsCancelButton = NO;	
	searchBar_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  NSString *prefix = [self _prefix];
  if (prefix)
    searchBar_.text = prefix;
	[view addSubview:searchBar_];
	
	// Table view
	tableView_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, 300) style:UITableViewStylePlain];
	tableView_.delegate = self;
  tableView_.dataSource = self.dataSource;
	tableView_.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	tableView_.sectionIndexMinimumDisplayRowCount = 5;
	[view addSubview:tableView_];
	[tableView_ release];	
	
	UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 344, 320, 36)];
	footerView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
	footerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
	
	// Status label
	statusLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 310, 36)];
	statusLabel_.text = @"Select 'Run' to start tests";
	statusLabel_.backgroundColor = [UIColor clearColor];
	statusLabel_.font = [UIFont systemFontOfSize:12];
	statusLabel_.numberOfLines = 2;
	statusLabel_.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[footerView addSubview:statusLabel_];
	[statusLabel_ release];
	
  [view addSubview:footerView];
	[footerView release];
  	
  runToolbar_ = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 380, 320, 36)];
  filterControl_ = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"All", @"Failed", nil]];
  filterControl_.segmentedControlStyle = UISegmentedControlStyleBar;
  filterControl_.frame = CGRectMake(20, 6, 280, 24);
  filterControl_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  filterControl_.selectedSegmentIndex = [self _filterIndex];
  [filterControl_ addTarget:self action:@selector(_filterChanged:) forControlEvents:UIControlEventValueChanged];
  runToolbar_.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  [runToolbar_ addSubview:filterControl_];
  [filterControl_ release];
	[view addSubview:runToolbar_];
	[runToolbar_ release];
  
	runButton_ = [[UIBarButtonItem alloc] initWithTitle:@"Run" style:UIBarButtonItemStyleDone
																							 target:self action:@selector(_toggleTestsRunning)];
	self.navigationItem.rightBarButtonItem = runButton_;
	[runButton_ release];	
	
	self.view = view;
	[self reload];
}

- (GHUnitIPhoneTableViewDataSource *)dataSource {
  if (!dataSource_) {
    dataSource_ = [[GHUnitIPhoneTableViewDataSource alloc] initWithIdentifier:@"Tests" suite:[GHTestSuite suiteFromEnv]];  
    [dataSource_ loadDefaults];    
  }
  return dataSource_;
}

- (void)reload {
  [self.dataSource.root setTextFilter:[self _prefix]];	
  [self.dataSource.root setFilter:[self _filterIndex]];
	[self.tableView reloadData];	
}

#pragma mark Running

- (void)_toggleTestsRunning {
	if (self.dataSource.isRunning) [self cancel];
	else [self runTests];
}

- (void)runTests {
	if (self.dataSource.isRunning) return;
	
  self.view;
	runButton_.title = @"Cancel";
	userDidDrag_ = NO; // Reset drag status
	statusLabel_.textColor = [UIColor blackColor];
	statusLabel_.text = @"Starting tests...";
	[self.dataSource run:self inParallel:NO options:0];
}

- (void)cancel {
	statusLabel_.text = @"Cancelling...";
	[dataSource_ cancel];
}

- (void)_exit {
	exit(0);
}

#pragma mark Properties

- (NSString *)_prefix {
  return [[NSUserDefaults standardUserDefaults] objectForKey:GHUnitPrefixKey];
}

- (void)_setPrefix:(NSString *)prefix {
  [[NSUserDefaults standardUserDefaults] setObject:prefix forKey:GHUnitPrefixKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)_setFilterIndex:(NSInteger)index {
  [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:index] forKey:GHUnitFilterKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)_filterIndex {
  return [[[NSUserDefaults standardUserDefaults] objectForKey:GHUnitFilterKey] integerValue];
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)_filterChanged:(id)sender {
  [self _setFilterIndex:filterControl_.selectedSegmentIndex];
  [self reload];
}

- (void)reloadTest:(id<GHTest>)test {
	[self.tableView reloadData];
	if (!userDidDrag_ && !dataSource_.isEditing && ![test isDisabled] 
			&& [test status] == GHTestStatusRunning && ![test conformsToProtocol:@protocol(GHTestGroup)]) 
		[self scrollToTest:test];
}

- (void)scrollToTest:(id<GHTest>)test {
	NSIndexPath *path = [dataSource_ indexPathToTest:test];
	if (!path) return;
	[self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}

- (void)scrollToBottom {
	NSInteger lastGroupIndex = [dataSource_ numberOfGroups] - 1;
	if (lastGroupIndex < 0) return;
	NSInteger lastTestIndex = [dataSource_ numberOfTestsInGroup:lastGroupIndex] - 1;
	if (lastTestIndex < 0) return;
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastTestIndex inSection:lastGroupIndex];
	[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)setStatusText:(NSString *)message {
	statusLabel_.text = message;
}

#pragma mark Delegates (UITableView)

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	GHTestNode *node = [dataSource_ nodeForIndexPath:indexPath];
	if (dataSource_.isEditing) {
		[node setSelected:![node isSelected]];
		[node notifyChanged];
		[tableView deselectRowAtIndexPath:indexPath animated:NO];
		[self.tableView reloadData];
	} else {		
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		GHTestNode *sectionNode = [[[dataSource_ root] children] objectAtIndex:indexPath.section];
		GHTestNode *testNode = [[sectionNode children] objectAtIndex:indexPath.row];
		
    GHUnitIPhoneTestViewController *testViewController = [[GHUnitIPhoneTestViewController alloc] init];	
    [testViewController setTest:testNode.test];
    [self.navigationController pushViewController:testViewController animated:YES];
    [testViewController release];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 36.0;
}

#pragma mark Delegates (UIScrollView) 

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	userDidDrag_ = YES;
}

#pragma mark Delegates (GHTestRunner)

- (void)_setRunning:(BOOL)running runner:(GHTestRunner *)runner {
  if (running) {
    filterControl_.enabled = NO;
  } else {
    filterControl_.enabled = YES;
    GHTestStats stats = [runner.test stats];
    if (stats.failureCount > 0) {
      statusLabel_.textColor = [UIColor redColor];
    } else {
      statusLabel_.textColor = [UIColor blackColor];
    }

    runButton_.title = @"Run";
  }
}

- (void)testRunner:(GHTestRunner *)runner didLog:(NSString *)message {
	[self setStatusText:message];
}

- (void)testRunner:(GHTestRunner *)runner test:(id<GHTest>)test didLog:(NSString *)message {
	
}

- (void)testRunner:(GHTestRunner *)runner didStartTest:(id<GHTest>)test {
	[self setStatusText:[NSString stringWithFormat:@"Test '%@' started.", [test identifier]]];
	[self reloadTest:test];
}

- (void)testRunner:(GHTestRunner *)runner didUpdateTest:(id<GHTest>)test {
	[self reloadTest:test];
}

- (void)testRunner:(GHTestRunner *)runner didEndTest:(id<GHTest>)test {	
	[self reloadTest:test];
}

- (void)testRunnerDidStart:(GHTestRunner *)runner { 
  [self _setRunning:YES runner:runner];
}

- (void)testRunnerDidCancel:(GHTestRunner *)runner { 
	[self _setRunning:NO runner:runner];
  [self setStatusText:@"Cancelled..."];
}

- (void)testRunnerDidEnd:(GHTestRunner *)runner {
	[self _setRunning:NO runner:runner];
  [self setStatusText:[dataSource_ statusString:@"Tests finished. "]];
  
  // Save defaults after test run
  [self saveDefaults];
}

#pragma mark Delegates (UISearchBar)

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	[searchBar_ setShowsCancelButton:YES animated:YES];	
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
  return ![dataSource_ isRunning];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	// Workaround for clearing search
	if ([searchBar.text isEqualToString:@""]) {
		[self searchBarSearchButtonClicked:searchBar];
		return;
	}
  NSString *prefix = [self _prefix];
	searchBar.text = (prefix ? prefix : @"");
	[searchBar resignFirstResponder];
	[searchBar setShowsCancelButton:NO animated:YES];	
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	[searchBar setShowsCancelButton:NO animated:YES];	
	
  [self _setPrefix:searchBar.text];
	[self reload];
}

@end
