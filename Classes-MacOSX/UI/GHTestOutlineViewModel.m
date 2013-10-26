//
//  GHTestOutlineViewModel.m
//  GHUnit
//
//  Created by Gabriel Handford on 7/17/09.
//  Copyright 2009. All rights reserved.
//

#import "GHTestOutlineViewModel.h"


@implementation GHTestOutlineViewModel

@synthesize delegate;

#pragma mark DataSource (NSOutlineView)

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
	if (!item) {
		return [self root];
	} else {
		return [item children][index];
	}
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {	
	return (!item) ? YES : ([[item children] count] > 0);
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
	return (!item) ? (self ? 1 : 0) : [[item children] count];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	if (!item) return nil;
	
	if (tableColumn == nil) {
		return [item nameWithStatus];
	} else if ([[tableColumn identifier] isEqual:@"status"] && ![item hasChildren]) {
		return [item statusString];
	}
	return nil;
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {	
	if (self.isEditing) {
		if ([[tableColumn identifier] isEqual:@"name"]) {
			[item setSelected:[object boolValue]];		
			[outlineView reloadData];
		}	
	}
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	
	GHTestNode *test = (GHTestNode *)item;
	
	if ([[tableColumn identifier] isEqual:@"name"]) {
		
		NSColor *textColor = test.isHidden || test.isDisabled ? NSColor.grayColor: NSColor.blackColor;
		if (self.isEditing) {
			[cell setState:				[item isSelected] ? NSOnState : NSOffState];
			[cell setAttributedTitle: 	[NSAttributedString.alloc initWithString:[item name] 
																						attributes:@{NSForegroundColorAttributeName: textColor, 
																													   NSFontAttributeName: [cell font]}]];
		} else {			
			[cell setTitle:[item name]];	
			[cell setTextColor:textColor];
		}
	}
	
	if ([tableColumn.identifier isEqual:@"status"]) { [cell setTextColor:[NSColor lightGrayColor]];	
		
		[cell setBackgroundColor:[test status] == GHTestStatusErrored 		? NSColor.redColor
										:[test status] == GHTestStatusSucceeded	? NSColor.greenColor
										:[test status] == GHTestStatusRunning     ? NSColor.blackColor : [cell textColor]];
	}		
}

// We can return a different cell for each row, if we want
- (NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	// If we return a cell for the 'nil' tableColumn, it will be used as a "full width" cell and span all the columns
	if (tableColumn == nil && [item hasChildren]) {
	// We want to use the cell for the name column, but we could construct a new cell if we wanted to, or return a different cell for each row.
			return [[outlineView tableColumnWithIdentifier:@"name"] dataCell];
	}
	NSLog(@"tablecol: %@", tableColumn.identifier);	
//	if ([tableColumn.identifier.lowercaseString isEqualToString:@"name"] && self.isEditing) {		
//		// TODO(gabe): Doesn't work if you try to re-use cells so making a new one;
//		//  Need help with this; This might explode if you have a lot of tests
//		id cell = [[NSClassFromString(@"AZDarkButtonCell") alloc]init];
////		NSButtonCell *cell = NSButtonCell.new;
////		cell.backgroundColor = [NSColor colorWithDeviceWhite:.9 alpha:1];
//		[cell setControlSize:NSSmallControlSize];
//		[cell setFont:[NSFont fontWithName:@"UbuntuMono-Bold" size:12]];
////		[cell setButtonType:NSSwitchButton];		
//		[cell setTitle:[item name]];
////		[cell setEditable:YES];
//		NSLog(@"made cell: %@ for item: %@", cell, item);
//		return cell;
//	}	
		id cell = [[NSClassFromString(@"AZColorCell") alloc]initTextCell:[item name]];
		NSLog(@"made cell: %@ for item: %@", cell, item);
		[cell setValue:^NSColor*(id objV){
		
			NSLog(@"Obj ect vlue:%@", objV); 
				
			return [(NSString*)objV rangeOfString:@"testOK"].location != NSNotFound ? NSColor.greenColor :
					 [(NSString*)objV rangeOfString:@"testFail"].location != NSNotFound ? NSColor.redColor : NSColor.whiteColor;
			
//			  :GHTest.class] ? obj.status == GHTestStatusRunning ? NSColor.orangeColor
//															:	obj.status ==  GHTestStatusCancelling  ? NSColor.grayColor
//															:	obj.status ==  GHTestStatusCancelled  ? NSColor.darkGrayColor
//															:	obj.status == GHTestStatusSucceeded ? NSColor.greenColor
//															:	obj.status ==  GHTestStatusErrored  ? NSColor.redColor : NSColor.whiteColor : NSColor.whiteColor;
		} forKey:@"colorForObjectValue"];
		
//		NSButtonCell *cell = NSButtonCell.new;
//		cell.backgroundColor = [NSColor colorWithDeviceWhite:.9 alpha:1];
//		[cell setControlSize:NSSmallControlSize];
//		[cell setFont:[NSFont fontWithName:@"UbuntuMono-Bold" size:12]];
//		[cell setButtonType:NSSwitchButton];		
//		[cell setTitle:[item name]];
//		[cell setEditable:YES];

		return cell;
	
	return cell;// [tableColumn dataCell];
}

#pragma mark Delegates (NSOutlineView)

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {	[self.delegate testOutlineViewModelDidChangeSelection:self]; }

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
	NSInteger clickedCol = outlineView.clickedColumn;
	NSInteger clickedRow = outlineView.clickedRow;
	
	if (clickedRow >= 0 && clickedCol >= 0) {
		NSCell *cell = [outlineView preparedCellAtColumn:clickedCol row:clickedRow];
		if ([cell isKindOfClass:NSButtonCell.class] && [cell isEnabled])  return NO;
	}
	return ![item hasChildren];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
	return ([item hasChildren]);
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldTrackCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	
	// We want to allow tracking for all the button cells, even if we don't allow selecting that particular row. 
	if (![cell isKindOfClass:NSButtonCell.class])
		// Only allow tracking on selected rows. This is what NSTableView does by default.
		return [outlineView isRowSelected:[outlineView rowForItem:item]];

	// We can also take a peek and make sure that the part of the cell clicked is an area that is normally tracked. Otherwise, clicking outside of the checkbox may make it check the checkbox
	NSRect cellFrame = [outlineView frameOfCellAtColumn:[outlineView.tableColumns indexOfObject:tableColumn] row:[outlineView rowForItem:item]];
	NSUInteger hitTestResult = [cell hitTestForEvent:[NSApp currentEvent] inRect:cellFrame ofView:outlineView];
	return hitTestResult && NSCellHitTrackableArea != 0;
}

@end
