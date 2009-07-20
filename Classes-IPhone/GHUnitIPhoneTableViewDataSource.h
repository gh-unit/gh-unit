//
//  GHUnitIPhoneTableViewDataSource.h
//  GHUnitIPhone
//
//  Created by Gabriel Handford on 5/5/09.
//  Copyright 2009. All rights reserved.
//

#import "GHTestViewModel.h"

@interface GHUnitIPhoneTableViewDataSource : GHTestViewModel <UITableViewDataSource> {
	
}

- (GHTestNode *)nodeForIndexPath:(NSIndexPath *)indexPath;

- (void)setSelectedForAllNodes:(BOOL)selected;

@end
