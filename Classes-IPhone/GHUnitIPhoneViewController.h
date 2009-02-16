//
//  GHUnitIPhoneViewController.h
//  GHUnitIPhone
//
//  Created by Gabriel Handford on 1/25/09.
//  Copyright 2009. All rights reserved.
//

#import "GHTestViewModel.h"

@interface GHUnitIPhoneViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	
	UITableView *tableView_;
	
	GHTestViewModel *model_;
	
}

- (void)setGroup:(id<GHTestGroup>)group;

- (void)updateTest:(id<GHTest>)test;

@end

