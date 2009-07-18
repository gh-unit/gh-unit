//
//  GHUnitIPhoneTableViewDataSource.h
//  GHUnitIPhone
//
//  Created by Gabriel Handford on 5/5/09.
//  Copyright 2009 Yelp. All rights reserved.
//

#import "GHTestViewModel.h"

@interface GHUnitIPhoneTableViewDataSource : GHTestViewModel <UITableViewDataSource> {
	
	BOOL editing_;

}

@property (assign, nonatomic, getter=isEditing) BOOL editing;

- (GHTestNode *)nodeForIndexPath:(NSIndexPath *)indexPath;

- (void)setSelectedForAllNodes:(BOOL)selected;

@end
