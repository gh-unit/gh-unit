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
	CGRect frame = CGRectMake(0, 20, 320, 460);
	tableView_ = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
	tableView_.delegate = self;
	tableView_.dataSource = self;
	self.view = tableView_;
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
}

#pragma mark Delegates / Data Source (UITableView)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (model_) {
		NSInteger numberOfSections = [[[model_ root] children] count];
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
	NSArray *children = [[model_ root] children];
	if ([children count] == 0) return 0;
	GHTestNode *sectionNode = [children objectAtIndex:section];
	return [[sectionNode children] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	GHTestNode *sectionNode = [[[model_ root] children] objectAtIndex:indexPath.section];
	GHTestNode *node = [[sectionNode children] objectAtIndex:indexPath.row];
	
	static NSString *CellIdentifier = @"ReviewFeedViewItem";	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell)
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];		
	cell.text = [NSString stringWithFormat:@"%@ %@", node.name, node.statusString];
	
	if (node.isRunning) {
		cell.textColor = [UIColor blackColor];
	} else if (node.isFinished) {
		if (node.failed) {
			cell.textColor = [UIColor redColor];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		} else {
			cell.textColor = [UIColor darkGrayColor];
		}
	} else {
		cell.textColor = [UIColor lightGrayColor];
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
