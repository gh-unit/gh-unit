//
//  GHUnitIOSTableViewDataSource.m
//  GHUnitIOS
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

#import "GHUnitIOSTableViewDataSource.h"

@implementation GHUnitIOSTableViewDataSource

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
  if (!cell)
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];   
  
  if (editing_) {
    cell.textLabel.text = node.name;
  } else {
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", node.name, node.statusString];
  }

  cell.textLabel.textColor = [UIColor lightGrayColor];
  cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
  
  if (editing_) {
    if (node.isSelected) cell.textLabel.textColor = [UIColor blackColor];
  } else {
    if ([node status] == GHTestStatusRunning) {
      cell.textLabel.textColor = [UIColor blackColor];
    } else if ([node status] == GHTestStatusErrored) {
      if ([node.test.exception.name isEqualToString:@"GHViewUnavailableException"]) {
        cell.textLabel.textColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.0f alpha:1.0f];
      } else {
        cell.textLabel.textColor = [UIColor redColor];
      }
    } else if ([node status] == GHTestStatusSucceeded) {
      cell.textLabel.textColor = [UIColor blackColor];
    } else if (node.isSelected) {
      if (node.isSelected) cell.textLabel.textColor = [UIColor darkGrayColor];
    }
  }
  
  UITableViewCellAccessoryType accessoryType = UITableViewCellAccessoryNone;
  if (self.isEditing && node.isSelected) accessoryType = UITableViewCellAccessoryCheckmark;
  else if (node.isEnded) accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
  cell.accessoryType = accessoryType; 
  
  return cell;  
}

@end
