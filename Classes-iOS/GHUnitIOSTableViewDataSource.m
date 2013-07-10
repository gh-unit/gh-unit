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

- (void)setSelectedForAllNodesAndUpdateGHTestStatus:(BOOL)selected {
    for(GHTestNode *sectionNode in [[self root] children]) {
        for(GHTestNode *node in [sectionNode children]) {
            [node setSelected:selected];
            if(!selected)
               [node setStatus:GHTestStatusNone];
        }
    }
}

- (BOOL)isANodesSelected {
    for(GHTestNode *sectionNode in [[self root] children]) {
        for(GHTestNode *node in [sectionNode children]) {
            if(node.isSelected)
                return TRUE;
        }
    }
    return FALSE;
}

- (int)numberOfNode {
    int i = 0;
    for(GHTestNode *sectionNode in [[self root] children]) {
        for(GHTestNode *node in [sectionNode children]) {
            i++;
        }
    }
    NSLog(@"numberOfNode %d",i);
    return i;
}

- (int)numberOfSelectedNode{
    int i = 0;
    for(GHTestNode *sectionNode in [[self root] children]) {
        for(GHTestNode *node in [sectionNode children]) {
            if(node.isSelected)
                i++;
        }
    }
    NSLog(@"numberOfSelectedNode %d",i);
    return i;
}
/*
-(void) setMaxNodeSelected{
    int i = 0;
    GHTestNode *tmp;
    for(GHTestNode *sectionNode in [[self root] children]) {
        for(GHTestNode *node in [sectionNode children]) {
            i++;
            tmp = node;
        }
    }
    [tmp setSelected:YES];
}

-(void) setMaxNodeStatusNone{
    int i = 0;
    GHTestNode *tmp;
    for(GHTestNode *sectionNode in [[self root] children]) {
        for(GHTestNode *node in [sectionNode children]) {
            tmp = node;
        }
    }
    [tmp setStatus:GHTestStatusNone];
    [tmp setSelected:NO];
}
*/
- (GHTestNode *) endNode{
    GHTestNode *tmp;
    for(GHTestNode *sectionNode in [[self root] children]) {
        for(GHTestNode *node in [sectionNode children]) {
            tmp = node;
        }
    }
    return tmp;
}

#pragma mark Data Source (UITableView)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    //  NSLog(@"numberOfSectionsInTableView \n");
    if(myTableView == nil)
        myTableView = tableView;
    NSInteger numberOfSections = [self numberOfGroups];
    if (numberOfSections > 0) return numberOfSections;
    return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    return [self numberOfTestsInGroup:section];
}
/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *children = [[self root] children];
    if ([children count] == 0) return nil;
    GHTestNode *sectionNode = [children objectAtIndex:section];
    return sectionNode.name;
}
 */

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //GHTestNode *sectionNode = [[[self root] children] objectAtIndex:indexPath.section];
    GHTestNode *node = [self nodeForIndexPath:indexPath];
    // NSLog(@"indexPath.section %d \n", indexPath.section);
    static NSString *CellIdentifier = @"ReviewFeedViewItem";
    static NSInteger switchTag = 100;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(0.0f, 5.0f, 60.0f, 25.0f)];
        [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        switchView.tag = switchTag;
        [cell addSubview:switchView];
    }
    cell.textLabel.textAlignment = UITextAlignmentRight;

    UISwitch *switchView = (id)[cell viewWithTag:switchTag];
    [switchView setOn:node.isSelected animated:NO];

    //UITableViewCellAccessoryType accessoryType = UITableViewCellAccessoryNone;
    //if (self.isEditing && node.isSelected) accessoryType = UITableViewCellAccessoryCheckmark;
    //else if (node.isEnded)
        
    //accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    if (editing_) {
        cell.textLabel.text = node.name;
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", node.name, node.statusString];
    }
    
    cell.textLabel.textColor = [UIColor lightGrayColor];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    
    if (editing_) {
        if (node.isSelected) {
            cell.textLabel.textColor = [UIColor blackColor];
            [switchView setOn:YES];
        }
        
    } else {
        if ([node status] == GHTestStatusRunning) {
            //[switchView setOn:YES];
            cell.textLabel.textColor = [UIColor blackColor];
        } else if ([node status] == GHTestStatusErrored) {
            //[switchView setOn:YES];
            if ([node.test.exception.name isEqualToString:@"GHViewUnavailableException"]) {
                cell.textLabel.textColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.0f alpha:1.0f];
            } else {
                if([node isSelected])
                    cell.textLabel.textColor = [UIColor redColor];
                else
                    cell.textLabel.textColor = [UIColor lightGrayColor];
            }
        }else if ([node status] == GHTestStatusSucceeded) {
            //[switchView setOn:YES];
            if([node isSelected]){
                NSLog(@"%@", node.statusString);
                cell.textLabel.textColor = [UIColor blackColor];
            }
            else
                cell.textLabel.textColor = [UIColor lightGrayColor];
        } else if (node.isSelected) {
            cell.textLabel.textColor = [UIColor blackColor];
            [switchView setOn:YES];
        }else{
            cell.textLabel.textColor = [UIColor lightGrayColor];
        }
    }
    if (!node.isSelected) {
        cell.textLabel.textColor = [UIColor lightGrayColor];
    }
    return cell;
}

- (void) switchChanged:(id)sender {
    
    UISwitch *switchInCell = (UISwitch *)sender;
    UITableViewCell * cell = (UITableViewCell*) switchInCell.superview;
    
    NSIndexPath * indexPath = [myTableView indexPathForCell:cell];
    GHTestNode *sectionNode = [[[self root] children] objectAtIndex:indexPath.section];
    GHTestNode *node = [[sectionNode children] objectAtIndex:indexPath.row];
    NSLog(@"switchChanged %@ \n", switchInCell.on?@"YES":@"NO");
    if(node != nil){
        [node setSelected:switchInCell.on];
        
        //NSLog(node.isSelected?@"Selected YES": @"Selected NO");
        [node notifyChanged];
        if(!switchInCell.on){
            NSLog(@"Change Status");
            //cell.textLabel.textColor = [UIColor lightGrayColor];
            //node.status = GHTestStatusCancelling;
            //node.status = GHTestStatusNone;
            //cell.accessoryType = UITableViewCellAccessoryNone;
            
        }else{
            NSLog(@"Change Status");
            //cell.textLabel.textColor = [UIColor blackColor];// hack for the first time
            //node.status = GHTestStatusNone;
            //cell.accessoryType = UITableViewCellAccessoryNone;
        }
        if([self isANodesSelected])
            [self.delegate updateRunButtonState:YES];
        else
            [self.delegate updateRunButtonState:NO];
    }
}

@end
