//
//  GHUnitIOSViewController.m
//  GHUnitIOS
//
//  Created by Gabriel Handford on 1/25/09.
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

#import "GHUnitIOSViewController.h"

NSString *const GHUnitTextFilterKey = @"TextFilter";
NSString *const GHUnitFilterKey = @"Filter";

@interface GHUnitIOSViewController ()
- (NSString *)_textFilter;
- (void)_setTextFilter:(NSString *)textFilter;
- (void)_setFilterIndex:(NSInteger)index;
- (NSInteger)_filterIndex;
@end

@implementation GHUnitIOSViewController

@synthesize suite=suite_;

- (id)init {
  if ((self = [super init])) {
    self.title = @"Tests";
  }
  return self;
}

- (void)dealloc {
  view_.tableView.delegate = nil;
  view_.searchBar.delegate = nil;
}

- (void)loadDefaults { }

- (void)saveDefaults {
  [dataSource_ saveDefaults];
}

- (void)loadView {
  [super loadView];

  runButton_ = [[UIBarButtonItem alloc] initWithTitle:@"Run" style:UIBarButtonItemStyleDone
                                               target:self action:@selector(_toggleTestsRunning)];
  self.navigationItem.rightBarButtonItem = runButton_;  

  // Clear view
  view_.tableView.delegate = nil;
  view_.searchBar.delegate = nil;
  
  view_ = [[GHUnitIOSView alloc] initWithFrame:CGRectMake(0, 0, 320, 344)];
  view_.searchBar.delegate = self;
  NSString *textFilter = [self _textFilter];
  if (textFilter) view_.searchBar.text = textFilter;  
  view_.filterControl.selectedSegmentIndex = [self _filterIndex];
  [view_.filterControl addTarget:self action:@selector(_filterChanged:) forControlEvents:UIControlEventValueChanged];
  view_.tableView.delegate = self;
  view_.tableView.dataSource = self.dataSource;
  self.view = view_;  
  [self reload];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self reload];
}

- (GHUnitIOSTableViewDataSource *)dataSource {
  if (!dataSource_) {
    dataSource_ = [[GHUnitIOSTableViewDataSource alloc] initWithIdentifier:@"Tests" suite:[GHTestSuite suiteFromEnv]];  
    [dataSource_ loadDefaults];    
  }
  return dataSource_;
}

- (void)reload {
  [self.dataSource.root setTextFilter:[self _textFilter]];  
  [self.dataSource.root setFilter:[self _filterIndex]];
  [view_.tableView reloadData]; 
}

#pragma mark Running

- (void)_toggleTestsRunning {
  if (self.dataSource.isRunning) [self cancel];
  else [self runTests];
}

- (void)runTests {
  if (self.dataSource.isRunning) return;
  
  [self view];
  runButton_.title = @"Cancel";
  userDidDrag_ = NO; // Reset drag status
  view_.statusLabel.textColor = [UIColor blackColor];
  view_.statusLabel.text = @"Starting tests...";
  [self.dataSource run:self inParallel:NO options:0];
}

- (void)cancel {
  view_.statusLabel.text = @"Cancelling...";
  [dataSource_ cancel];
}

- (void)_exit {
  exit(0);
}

#pragma mark Properties

- (NSString *)_textFilter {
  return [[NSUserDefaults standardUserDefaults] objectForKey:GHUnitTextFilterKey];
}

- (void)_setTextFilter:(NSString *)textFilter {
  [[NSUserDefaults standardUserDefaults] setObject:textFilter forKey:GHUnitTextFilterKey];
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
  [self _setFilterIndex:view_.filterControl.selectedSegmentIndex];
  [self reload];
}

- (void)reloadTest:(id<GHTest>)test {
  [view_.tableView reloadData];
  if (!userDidDrag_ && !dataSource_.isEditing && ![test isDisabled] 
      && [test status] == GHTestStatusRunning && ![test conformsToProtocol:@protocol(GHTestGroup)]) 
    [self scrollToTest:test];
}

- (void)scrollToTest:(id<GHTest>)test {
  NSIndexPath *path = [dataSource_ indexPathToTest:test];
  if (!path) return;
  [view_.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}

- (void)scrollToBottom {
  NSInteger lastGroupIndex = [dataSource_ numberOfGroups] - 1;
  if (lastGroupIndex < 0) return;
  NSInteger lastTestIndex = [dataSource_ numberOfTestsInGroup:lastGroupIndex] - 1;
  if (lastTestIndex < 0) return;
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastTestIndex inSection:lastGroupIndex];
  [view_.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)setStatusText:(NSString *)message {
  view_.statusLabel.text = message;
}

#pragma mark Delegates (UITableView)

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  GHTestNode *node = [dataSource_ nodeForIndexPath:indexPath];
  if (dataSource_.isEditing) {
    [node setSelected:![node isSelected]];
    [node notifyChanged];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [view_.tableView reloadData];
  } else {    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GHTestNode *sectionNode = [[[dataSource_ root] children] objectAtIndex:indexPath.section];
    GHTestNode *testNode = [[sectionNode children] objectAtIndex:indexPath.row];
    
    GHUnitIOSTestViewController *testViewController = [[GHUnitIOSTestViewController alloc] init]; 
    [testViewController setTest:testNode.test];
    [self.navigationController pushViewController:testViewController animated:YES];
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 36.0f;
}

#pragma mark Delegates (UIScrollView) 

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  userDidDrag_ = YES;
}

#pragma mark Delegates (GHTestRunner)

- (void)_setRunning:(BOOL)running runner:(GHTestRunner *)runner {
  if (running) {
    view_.filterControl.enabled = NO;
  } else {
    view_.filterControl.enabled = YES;
    GHTestStats stats = [runner.test stats];
    if (stats.failureCount > 0) {
      view_.statusLabel.textColor = [UIColor redColor];
    } else {
      view_.statusLabel.textColor = [UIColor blackColor];
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
  
  if (getenv("GHUNIT_AUTOEXIT")) {
    NSLog(@"Exiting (GHUNIT_AUTOEXIT)");
    exit(runner.test.stats.failureCount);
  }
}

#pragma mark Delegates (UISearchBar)

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
  [searchBar setShowsCancelButton:YES animated:YES];  
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
  NSString *textFilter = [self _textFilter];
  searchBar.text = (textFilter ? textFilter : @"");
  [searchBar resignFirstResponder];
  [searchBar setShowsCancelButton:NO animated:YES]; 
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  [searchBar resignFirstResponder];
  [searchBar setShowsCancelButton:NO animated:YES]; 
  
  [self _setTextFilter:searchBar.text];
  [self reload];
}

@end
