//
//  GHUnitIPhoneTableViewDataSource.m
//  GHUnitIPhone
//
//  Created by Gabriel Handford on 5/5/09.
//  Copyright 2009 Yelp. All rights reserved.
//

#import "GHUnitIPhoneTableViewDataSource.h"

@implementation GHUnitIPhoneTableViewDataSource

@synthesize model=model_, editing=editing_;

- (GHTestNode *)nodeForIndexPath:(NSIndexPath *)indexPath {
	if (!model_) return nil;
	GHTestNode *sectionNode = [[[model_ root] children] objectAtIndex:indexPath.section];
	return [[sectionNode children] objectAtIndex:indexPath.row];
}

- (void)setSelectedForAllNodes:(BOOL)selected {
	for(GHTestNode *sectionNode in [[model_ root] children]) {
		for(GHTestNode *node in [sectionNode children]) {
			node.selected = selected;
			[node notifyChanged];
		}
	}
}

#pragma mark Data Source (UITableView)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (model_) {
		NSInteger numberOfSections = [model_ numberOfGroups];
		if (numberOfSections > 0) return numberOfSections;
	}
	return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	if (!model_) return 0;
	return [model_ numberOfTestsInGroup:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (!model_) return nil;
	NSArray *children = [[model_ root] children];
	if ([children count] == 0) return nil;
	GHTestNode *sectionNode = [children objectAtIndex:section];
	return sectionNode.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	GHTestNode *sectionNode = [[[model_ root] children] objectAtIndex:indexPath.section];
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
		if (node.isRunning) {
			cell.textColor = [UIColor blackColor];
		} else if (node.isFinished) {
			if (node.failed) {
				cell.textColor = [UIColor redColor];
			} else {
				cell.textColor = [UIColor darkGrayColor];
			}
		}
	}
	
	return cell;	
}

@end
