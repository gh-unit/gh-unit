//
//  GHUnitIPhoneTableViewDataSource.m
//  GHUnitIPhone
//
//  Created by Gabriel Handford on 5/5/09.
//  Copyright 2009 Yelp. All rights reserved.
//

#import "GHUnitIPhoneTableViewDataSource.h"

@implementation GHUnitIPhoneTableViewDataSource

@synthesize editing=editing_;

- (GHTestNode *)nodeForIndexPath:(NSIndexPath *)indexPath {
	GHTestNode *sectionNode = [[[self root] children] objectAtIndex:indexPath.section];
	return [[sectionNode children] objectAtIndex:indexPath.row];
}

- (void)setSelectedForAllNodes:(BOOL)selected {
	for(GHTestNode *sectionNode in [[self root] children]) {
		for(GHTestNode *node in [sectionNode children]) {
			node.selected = selected;
			[node notifyChanged];
		}
	}
}

#pragma mark Data Source (UITableView)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSInteger numberOfSections = [self numberOfGroups];
	if (numberOfSections > 0) return numberOfSections;
	return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return [self numberOfTestsInGroup:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSArray *children = [[self root] children];
	if ([children count] == 0) return nil;
	GHTestNode *sectionNode = [children objectAtIndex:section];
	return sectionNode.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	GHTestNode *sectionNode = [[[self root] children] objectAtIndex:indexPath.section];
	GHTestNode *node = [[sectionNode children] objectAtIndex:indexPath.row];
	
	static NSString *CellIdentifier = @"ReviewFeedViewItem";	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell)
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];		
	
	if (editing_) {
		cell.text = node.name;
	} else {
		cell.text = [NSString stringWithFormat:@"%@ %@", node.name, node.statusString];
	}

	cell.textColor = [UIColor lightGrayColor];
	
	if (editing_) {
		if (node.isSelected) cell.textColor = [UIColor blackColor];
	} else {
		if ([node status] == GHTestStatusRunning) {
			cell.textColor = [UIColor blackColor];
		} else if ([node status] == GHTestStatusErrored) {
			cell.textColor = [UIColor redColor];
		} else if ([node status] == GHTestStatusSucceeded) {
			cell.textColor = [UIColor blackColor];
		} else if (node.isSelected) {
			if (node.isSelected) cell.textColor = [UIColor darkGrayColor];
		}
	}
	
	return cell;	
}

@end
