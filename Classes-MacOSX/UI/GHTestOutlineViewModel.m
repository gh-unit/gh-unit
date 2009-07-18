//
//  GHTestOutlineViewModel.m
//  GHUnit
//
//  Created by Gabriel Handford on 7/17/09.
//  Copyright 2009 Yelp. All rights reserved.
//

#import "GHTestOutlineViewModel.h"

@interface GHTestOutlineViewModel ()
@property (retain, nonatomic) GHTestViewModel *model;
@end

@implementation GHTestOutlineViewModel

@synthesize model=model_, delegate=delegate_;

- (void)dealloc {
	[model_ release];	
	[runner_ release];
	[super dealloc];
}

- (GHTestRunner *)loadTestSuite:(GHTestSuite *)suite {	
	self.model = nil;
	runner_.delegate = nil;
	[runner_ cancel];
	[runner_ release];
	
	if (suite) {
		self.model = [[[GHTestViewModel alloc] initWithRoot:suite] autorelease];	
		runner_ = [[GHTestRunner runnerForSuite:suite] retain];
		
		NSOperationQueue *operationQueue = [[[NSOperationQueue alloc] init] autorelease];
		operationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
		runner_.operationQueue = operationQueue;
	}
	return runner_;
}

- (void)run {
	[runner_ runInBackground];
}

- (GHTestNode *)findFailure {
	GHTestNode *node = [model_ root];
	return [self findFailureFromNode:node];
}

- (GHTestNode *)findFailureFromNode:(GHTestNode *)node {
	if (node.failed && [node.test exception]) return node;
	for(GHTestNode *childNode in node.children) {
		GHTestNode *foundNode = [self findFailureFromNode:childNode];
		if (foundNode) return foundNode;
	}
	return nil;
}

- (GHTestNode *)findTestNode:(id<GHTest>)test {
	return [model_ findTestNode:test];
}

#pragma mark DataSource (NSOutlineView)

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
	if (!item) {
		return [model_ root];
	} else {
		return [[item children] objectAtIndex:index];
	}
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {	
	return (!item) ? YES : ([[item children] count] > 0);
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
	return (!item) ? (model_ ? 1 : 0) : [[item children] count];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	if (!item) return nil;
	
	if (tableColumn == nil) {
		return [item nameWithStatus];
	} else if ([[tableColumn identifier] isEqual:@"name"]) {
		return [item name];
	} else if ([[tableColumn identifier] isEqual:@"status"]) {
		return [item statusString];
	} else if ([[tableColumn identifier] isEqual:@"enabled"]) {
		return [NSNumber numberWithBool:[item isSelected]];
	}
	return nil;
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	if ([[tableColumn identifier] isEqual:@"enabled"]) {
		[item setSelected:[object boolValue]];
		[item notifyChanged];
	}
}

// We can return a different cell for each row, if we want
- (NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	// If we return a cell for the 'nil' tableColumn, it will be used as a "full width" cell and span all the columns
	if (tableColumn == nil && [item hasChildren]) {
		// We want to use the cell for the name column, but we could construct a new cell if we wanted to, or return a different cell for each row.
		return [[outlineView tableColumnWithIdentifier:@"name"] dataCell];
	}
	return [tableColumn dataCell];
}

#pragma mark Delegates (NSOutlineView)

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	[delegate_ testOutlineViewModelDidChangeSelection:self];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
	NSInteger clickedCol = [outlineView clickedColumn];
	NSInteger clickedRow = [outlineView clickedRow];
	if (clickedRow >= 0 && clickedCol >= 0) {
		NSCell *cell = [outlineView preparedCellAtColumn:clickedCol row:clickedRow];
		if ([cell isKindOfClass:[NSButtonCell class]] && [cell isEnabled]) {
			return NO;
		}            
	}
	
	return (![item hasChildren]);
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
	return ([item hasChildren]);
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {	
	if ([[tableColumn identifier] isEqual:@"status"]) {
		[cell setTextColor:[NSColor lightGrayColor]];	
		
		if ([item status] == GHTestStatusErrored) {
			[cell setTextColor:[NSColor redColor]];
		} else if ([item status] == GHTestStatusSucceeded) {
			[cell setTextColor:[NSColor greenColor]];
		} else if ([item status] == GHTestStatusRunning) {
			[cell setTextColor:[NSColor blackColor]];
		}
	}	
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldTrackCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	// We want to allow tracking for all the button cells, even if we don't allow selecting that particular row. 
	if ([cell isKindOfClass:[NSButtonCell class]]) {
		// We can also take a peek and make sure that the part of the cell clicked is an area that is normally tracked. Otherwise, clicking outside of the checkbox may make it check the checkbox
		NSRect cellFrame = [outlineView frameOfCellAtColumn:[[outlineView tableColumns] indexOfObject:tableColumn] row:[outlineView rowForItem:item]];
		NSUInteger hitTestResult = [cell hitTestForEvent:[NSApp currentEvent] inRect:cellFrame ofView:outlineView];
		if (hitTestResult && NSCellHitTrackableArea != 0) {
			return YES;
		} else {
			return NO;
		}
	} else {
		// Only allow tracking on selected rows. This is what NSTableView does by default.
		return [outlineView isRowSelected:[outlineView rowForItem:item]];
	}
}

@end
