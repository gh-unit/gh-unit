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

@synthesize tableView=tableView_;

- (void)loadView {
	GHUDebug(@"Loading view");
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 320, 460)];
	view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
	
	CGRect frame = CGRectMake(0, 0, 320, 380);
	tableView_ = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
	tableView_.delegate = self;
	[view addSubview:tableView_];
	[tableView_ release];	
	
	statusLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(5, 380, 310, 36)];
	statusLabel_.backgroundColor = [UIColor clearColor];
	statusLabel_.text = @"Loading...";
	statusLabel_.font = [UIFont systemFontOfSize:12];
	statusLabel_.numberOfLines = 2;	
	[view addSubview:statusLabel_];
	[statusLabel_ release];
	
	editToolbar_ = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 380, 320, 36)];
	UIBarButtonItem *selectItem = [[UIBarButtonItem alloc] initWithTitle:@"Select All" style:UIBarButtonItemStyleBordered target:self action:@selector(_selectAll)];
	UIBarButtonItem *deselectItem = [[UIBarButtonItem alloc] initWithTitle:@"Deselect All" style:UIBarButtonItemStyleBordered target:self action:@selector(_deselectAll)];	
	[editToolbar_ setItems:[NSArray arrayWithObjects:selectItem, deselectItem, nil] animated:NO];
	editToolbar_.hidden = YES;
	[view addSubview:editToolbar_];
	[selectItem release];
	[deselectItem release];
		
	editButton_ = [[UIBarButtonItem alloc] initWithTitle:@"-" style:UIBarButtonItemStylePlain 
																									target:self action:@selector(_edit)];
	self.navigationItem.rightBarButtonItem = editButton_;
	[editButton_ release];	

	UIBarButtonItem *quitButton = [[UIBarButtonItem alloc] initWithTitle:@"Quit" style:UIBarButtonItemStylePlain 
																																target:self action:@selector(_quit)];
	self.navigationItem.leftBarButtonItem = quitButton;
	[quitButton release];	
	
	
	self.view = view;
	[self setEditing:NO];
}

- (void)dealloc {
	[dataSource_ release];
	[editToolbar_ release];
	[super dealloc];
}

- (void)setEditing:(BOOL)editing {
	// If we were editing, then we are toggling back, and we need to save
	if (dataSource_.isEditing) {
		[dataSource_.model saveSettings];
	}

	dataSource_.editing = editing;
	
	if (editing) {
		self.title = @"Edit";
		editButton_.title = @"Save";
		statusLabel_.hidden = YES;
		editToolbar_.hidden = NO;
	} else {
		self.title = @"Tests";
		editButton_.title = @"Edit";
		statusLabel_.hidden = NO;
		editToolbar_.hidden = YES;		
	}
	[self.tableView reloadData];
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

- (void)_quit {
	exit(0);
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)setGroup:(id<GHTestGroup>)group {
	[dataSource_ release];
	dataSource_ = [[GHUnitIPhoneTableViewDataSource alloc] init];
	GHTestViewModel *model = [[GHTestViewModel alloc] initWithRoot:group];
	dataSource_.model = model;
	[model release];
	self.tableView.dataSource = dataSource_;
	[self.tableView reloadData];
}

- (void)updateTest:(id<GHTest>)test {
	[self.tableView reloadData];
	if (!userDidDrag_ && !dataSource_.isEditing)
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
	NSIndexPath *path = [dataSource_.model indexPathToTest:test];
	if (!path) return;
	[self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)scrollToBottom {
	NSInteger lastGroupIndex = [dataSource_.model numberOfGroups] - 1;
	if (lastGroupIndex < 0) return;
	NSInteger lastTestIndex = [dataSource_.model numberOfTestsInGroup:lastGroupIndex] - 1;
	if (lastTestIndex < 0) return;
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastTestIndex inSection:lastGroupIndex];
	[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)setStatusText:(NSString *)message {
	statusLabel_.text = message;
}

#pragma mark Delegates (UITableView)

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	GHTestNode *node = [dataSource_ nodeForIndexPath:indexPath];
	if (dataSource_.isEditing && node.isSelected) return UITableViewCellAccessoryCheckmark;
	else if (node.isFinished && node.failed) return UITableViewCellAccessoryDisclosureIndicator;
	return UITableViewCellAccessoryNone;
}	

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	GHTestNode *node = [dataSource_ nodeForIndexPath:indexPath];
	if (dataSource_.isEditing) {
		node.selected = !node.isSelected;
		[node notifyChanged];
		[tableView deselectRowAtIndexPath:indexPath animated:NO];
		[self.tableView reloadData];
	} else {		
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		GHTestNode *sectionNode = [[[dataSource_.model root] children] objectAtIndex:indexPath.section];
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

@end
