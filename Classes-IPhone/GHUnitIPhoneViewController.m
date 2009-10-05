//
//  GHUnitIPhoneViewController.m
//  GHUnitIPhone
//
//  Created by Gabriel Handford on 1/25/09.
//  Copyright 2009. All rights reserved.
//

#import "GHUnitIPhoneViewController.h"

#import "GHUnitIPhoneExceptionViewController.h"

NSString *const GHUnitAutoRunKey = @"GHUnit-Autorun";


@interface GHUnitIPhoneViewController ()
@property (retain, nonatomic) NSString *prefix;
@end


@implementation GHUnitIPhoneViewController

@synthesize tableView=tableView_, suite=suite_;
@synthesize prefix=prefix_; // Private properties

- (id)init {
	if ((self = [super init])) {
		[self loadDefaults];
	}
	return self;
}

- (void)dealloc {
	[dataSource_ release];	
	[suite_ release];
	[editToolbarItems_ release];
	searchBar_.delegate = nil;
	[searchBar_ release];
	[prefix_ release];
	[super dealloc];
}

- (void)loadDefaults {
	// Defaults
	[[NSUserDefaults standardUserDefaults] registerDefaults:
	 [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:GHUnitAutoRunKey]];

	self.prefix = [[NSUserDefaults standardUserDefaults] objectForKey:@"GHUnit4-Prefix"];	
}

- (void)loadView {
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
	view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

	// Search bar
	searchBar_ = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	searchBar_.delegate = self;
	searchBar_.showsCancelButton = NO;	
	searchBar_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	searchBar_.text = self.prefix;
	[view addSubview:searchBar_];
	
	// Table view
	tableView_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, 336) style:UITableViewStylePlain];
	tableView_.delegate = self;
	tableView_.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	tableView_.sectionIndexMinimumDisplayRowCount = 5;
	[view addSubview:tableView_];
	[tableView_ release];	
	
	UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 380, 320, 36)];
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
	
	toolbar_ = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 36)];
	[toolbar_ setItems:[NSArray array] animated:YES];
	toolbar_.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[footerView addSubview:toolbar_];
	[toolbar_ release];
	
	[view addSubview:footerView];
	[footerView release];
	
	// Edit toolbar
	UIBarButtonItem *selectItem = [[UIBarButtonItem alloc] initWithTitle:@"Enable All" style:UIBarButtonItemStyleBordered target:self action:@selector(_selectAll)];
	UIBarButtonItem *deselectItem = [[UIBarButtonItem alloc] initWithTitle:@"Disable All" style:UIBarButtonItemStyleBordered target:self action:@selector(_deselectAll)];
	UIBarButtonItem *autoRunItem = [[UIBarButtonItem alloc] initWithTitle:@"AutoRun ()" style:UIBarButtonItemStyleBordered target:self action:@selector(_toggleAutorun)];
	editToolbarItems_ = [[NSArray arrayWithObjects:selectItem, deselectItem, autoRunItem, nil] retain];
	[toolbar_ setItems:editToolbarItems_ animated:NO];
	autoRunItem.title = [NSString stringWithFormat:@"AutoRun (%@)", (self.isAutoRun ? @"ON" : @"OFF")];
	[selectItem release];
	[deselectItem release];
	[autoRunItem release];
	
	// Navigation button items
	editButton_ = [[UIBarButtonItem alloc] initWithTitle:@"-" style:UIBarButtonItemStylePlain 
																									target:self action:@selector(_edit)];
	self.navigationItem.rightBarButtonItem = editButton_;
	[editButton_ release];	

	runButton_ = [[UIBarButtonItem alloc] initWithTitle:@"Run" style:UIBarButtonItemStyleDone
																							 target:self action:@selector(_toggleTestsRunning)];
	self.navigationItem.leftBarButtonItem = runButton_;
	[runButton_ release];	
	
	self.view = view;
	[self setEditing:NO];
	
	[self reload];
}

- (void)viewDidAppear:(BOOL)animated {
	if (self.isAutoRun) [self runTests];
}

- (void)reload {
	if (self.prefix) {		
		self.suite = [GHTestSuite suiteWithPrefix:self.prefix options:NSCaseInsensitiveSearch];
		[[NSUserDefaults standardUserDefaults] setObject:self.prefix forKey:@"GHUnit4-Prefix"];
	} else {
		self.suite = [GHTestSuite suiteFromEnv];
	}
	
	[dataSource_ release];
	dataSource_ = [[GHUnitIPhoneTableViewDataSource alloc] initWithSuite:suite_];
	self.tableView.dataSource = dataSource_;
	[self.tableView reloadData];	
}

#pragma mark Running

- (void)_toggleTestsRunning {
	if (dataSource_.isRunning) [self cancel];
	else [self runTests];
}

- (void)runTests {
	if (dataSource_.isRunning) return;
	
	runButton_.title = @"Cancel";
	userDidDrag_ = NO; // Reset drag status
	[self reset];
	statusLabel_.text = @"Starting tests...";
	[dataSource_ run:self inParallel:NO];
}

- (void)reset {
	statusLabel_.text = @"Select 'Run' to start tests";
	statusLabel_.textColor = [UIColor blackColor];
	[suite_ reset];
}

- (void)cancel {
	statusLabel_.text = @"Cancelling...";
	[dataSource_ cancel];
}

- (void)_exit {
	exit(0);
}

#pragma mark Properties

- (void)setEditing:(BOOL)editing {
	// If we were editing, then we are toggling back, and we need to save
	if (dataSource_.isEditing) {
		[dataSource_ saveDefaults];
	}

	dataSource_.editing = editing;
	
	if (editing) {
		self.title = @"Enable/Disable";
		editButton_.title = @"Save";
		statusLabel_.hidden = YES;		
		toolbar_.hidden = NO;				
	} else {
		self.title = @"Tests";
		editButton_.title = @"Edit";
		statusLabel_.hidden = NO;		
		toolbar_.hidden = YES;
	}
	[self.tableView reloadData];
}

- (BOOL)isAutoRun {
	return [[[NSUserDefaults standardUserDefaults] objectForKey:GHUnitAutoRunKey] boolValue];
}

- (void)setAutoRun:(BOOL)autoRun {
	[[editToolbarItems_ objectAtIndex:2] setTitle:[NSString stringWithFormat:@"AutoRun (%@)", (autoRun ? @"ON" : @"OFF")]];	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:autoRun] forKey:GHUnitAutoRunKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark Actions

- (void)_edit {	
	[self setEditing:!dataSource_.isEditing];
}

- (void)_selectAll {
	[dataSource_ setSelectedForAllNodes:YES];
	[self.tableView reloadData];
}

- (void)_deselectAll {
	[dataSource_ setSelectedForAllNodes:NO];
	[self.tableView reloadData];
}

- (void)_enable:(id)sender {
	if ([sender selectedSegmentIndex] == 0) [self _selectAll];
	else [self _deselectAll];
}

- (void)_toggleAutorun {
	self.autoRun = !self.isAutoRun;
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
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
		GHTestNode *node = [[sectionNode children] objectAtIndex:indexPath.row];
		
		if (node.failed) {
			GHUnitIPhoneExceptionViewController *exceptionViewController = [[GHUnitIPhoneExceptionViewController alloc] init];	
			[self.navigationController pushViewController:exceptionViewController animated:YES];
			exceptionViewController.stackTrace = node.stackTrace;
			[exceptionViewController release];
		}	
	}
}

#pragma mark Delegates (UIScrollView) 

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	userDidDrag_ = YES;
}

#pragma mark Delegates (GHTestRunner)

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

- (void)testRunnerDidStart:(GHTestRunner *)runner { }

- (void)testRunnerDidCancel:(GHTestRunner *)runner { 
	runButton_.title = @"Run";
	statusLabel_.text = @"Cancelled...";
}

- (void)testRunnerDidEnd:(GHTestRunner *)runner {
	GHTestStats stats = [runner.test stats];

	if (stats.failureCount > 0) {
		statusLabel_.textColor = [UIColor redColor];
	} else {
		statusLabel_.textColor = [UIColor blackColor];
	}
	
	[self setStatusText:[dataSource_ statusString:@"Tests finished. "]];
	
	runButton_.title = @"Run";
}

#pragma mark Delegates (UISearchBar)

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	[searchBar_ setShowsCancelButton:YES animated:YES];	
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	// Workaround for clearing search
	if ([searchBar.text isEqualToString:@""]) {
		[self searchBarSearchButtonClicked:searchBar];
		return;
	}
	searchBar.text = self.prefix;
	[searchBar resignFirstResponder];
	[searchBar setShowsCancelButton:NO animated:YES];	
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	[searchBar setShowsCancelButton:NO animated:YES];	
	
	self.prefix = searchBar.text;
	[self reload];
}

@end
