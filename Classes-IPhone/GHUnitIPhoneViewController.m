//
//  GHUnitIPhoneViewController.m
//  GHUnitIPhone
//
//  Created by Gabriel Handford on 1/25/09.
//  Copyright 2009. All rights reserved.
//

#import "GHUnitIPhoneViewController.h"

#import "GHUnitIPhoneExceptionViewController.h"

@implementation GHUnitIPhoneViewController

- (void)loadView {
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 320, 460)];
	view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
	
	CGRect frame = CGRectMake(0, 0, 320, 380);
	tableView_ = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
	tableView_.delegate = self;
	tableView_.dataSource = self;
	[view addSubview:tableView_];
	[tableView_ release];
	
	statusLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(5, 380, 310, 36)];
	statusLabel_.backgroundColor = [UIColor clearColor];
	statusLabel_.text = @"Loading...";
	statusLabel_.font = [UIFont systemFontOfSize:12];
	statusLabel_.numberOfLines = 2;	
	[view addSubview:statusLabel_];
	[statusLabel_ release];
	
	self.view = view;
	self.title = @"Tests";
}

- (void)dealloc {
	[tableView_ release];
	[model_ release];
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)setGroup:(id<GHTestGroup>)group {
	[model_ release];
	model_ = [[GHTestViewModel alloc] initWithRoot:group];
	[tableView_ reloadData];
}

- (void)updateTest:(id<GHTest>)test {
	[tableView_ reloadData];
	[self scrollToTest:test];
}

- (void)setTestStats:(GHTestStats)stats {
	if (stats.failureCount > 0) {
		statusLabel_.textColor = [UIColor redColor];
	} else {
		statusLabel_.textColor = [UIColor blackColor];
	}
}

- (void)scrollToTest:(id<GHTest>)test {
	NSIndexPath *path = [model_ indexPathToTest:test];
	if (!path) return;
	[tableView_ scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)scrollToBottom {
	NSInteger lastGroupIndex = [model_ numberOfGroups] - 1;
	if (lastGroupIndex < 0) return;
	NSInteger lastTestIndex = [model_ numberOfTestsInGroup:lastGroupIndex] - 1;
	if (lastTestIndex < 0) return;
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastTestIndex inSection:lastGroupIndex];
	[tableView_ scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)setStatusText:(NSString *)message {
	statusLabel_.text = message;
}

#pragma mark Delegates / Data Source (UITableView)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (model_) {
		NSInteger numberOfSections = [model_ numberOfGroups];
		if (numberOfSections > 0) return numberOfSections;
	}
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (!model_) return nil;
	NSArray *children = [[model_ root] children];
	if ([children count] == 0) return nil;
	GHTestNode *sectionNode = [children objectAtIndex:section];
	return sectionNode.name;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	if (!model_) return 0;
	return [model_ numberOfTestsInGroup:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	GHTestNode *sectionNode = [[[model_ root] children] objectAtIndex:indexPath.section];
	GHTestNode *node = [[sectionNode children] objectAtIndex:indexPath.row];
	
	static NSString *CellIdentifier = @"ReviewFeedViewItem";	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell)
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];		
	cell.text = [NSString stringWithFormat:@"%@ %@", node.name, node.statusString];
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.textColor = [UIColor lightGrayColor];
	
	if (node.isRunning) {
		cell.textColor = [UIColor blackColor];
	} else if (node.isFinished) {
		if (node.failed) {
			cell.textColor = [UIColor redColor];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		} else {
			cell.textColor = [UIColor darkGrayColor];
		}
	}
	
	return cell;	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	GHTestNode *sectionNode = [[[model_ root] children] objectAtIndex:indexPath.section];
	GHTestNode *node = [[sectionNode children] objectAtIndex:indexPath.row];
	
	if (node.failed) {
		GHUnitIPhoneExceptionViewController *exceptionViewController = [[GHUnitIPhoneExceptionViewController alloc] init];	
		[self.navigationController pushViewController:exceptionViewController animated:YES];
		exceptionViewController.stackTrace = node.stackTrace;
		[exceptionViewController release];
	}	
}

@end
