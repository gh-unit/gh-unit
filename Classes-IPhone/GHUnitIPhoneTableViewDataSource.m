//
//  GHUnitIPhoneTableViewDataSource.m
//  GHUnitIPhone
//
//  Created by Gabriel Handford on 5/5/09.
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

#import "GHUnitIPhoneTableViewDataSource.h"
#import "GHUnitIPhoneBarView.h"
#import "GHUnitIPhoneGradientView.h"


@implementation GHUnitIPhoneTableViewDataSource

- (GHTestNode *)nodeForIndexPath:(NSIndexPath *)indexPath {
  GHTestNode *sectionNode = [[[self root] children] objectAtIndex:indexPath.section];
  return [[sectionNode children] objectAtIndex:indexPath.row];
}

- (void)setSelectedForAllNodes:(BOOL)selected {
  for(GHTestNode *sectionNode in [[self root] children]) {
    for(GHTestNode *node in [sectionNode children]) {
      [node setSelected:selected];
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
  if (!cell) {
    cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];   
  }
	for (UIView* sub in cell.contentView.subviews) {
		[sub removeFromSuperview];
	}
  
  GHUnitIPhoneBarView* barView = [[[GHUnitIPhoneBarView alloc] initWithFrame:CGRectMake(10, 20, 250, 12)] autorelease];
	barView.status = [node status];
	GHUnitIPhoneGradientView* gradientView = [[[GHUnitIPhoneGradientView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)] autorelease];
	GHUnitIPhoneGradientView* selectedGradientView = [[[GHUnitIPhoneGradientView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)] autorelease];	
	gradientView.isSelected = NO;
	selectedGradientView.isSelected = YES;
	cell.backgroundView = gradientView;
	cell.selectedBackgroundView = selectedGradientView;
  [cell.contentView addSubview:barView];
	[cell.contentView setBackgroundColor:[UIColor clearColor]];
	
  UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(11, 1, 276, 22)]; 
  label.backgroundColor = [UIColor clearColor];
  label.font = [UIFont fontWithName:@"Helvetica-Bold" size:11];
  label.textColor = [UIColor colorWithWhite:0.25 alpha:1.0];
  label.highlightedTextColor = [UIColor whiteColor];
	
  if (editing_) {
    label.text = node.name;
  } 
	else {
    label.text = [NSString stringWithFormat:@"%@ %@", node.name, node.statusString];
  }
	[cell.contentView addSubview:label];
  
  UITableViewCellAccessoryType accessoryType = UITableViewCellAccessoryNone;
  if (self.isEditing && node.isSelected) accessoryType = UITableViewCellAccessoryCheckmark;
  else if (node.isEnded) accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
  cell.accessoryType = accessoryType; 
  
  return cell;  
}


@end
