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
	
	UILabel *statusLabel_;
}

- (void)setGroup:(id<GHTestGroup>)group;

- (void)updateTest:(id<GHTest>)test;

- (void)scrollToTest:(id<GHTest>)test;

- (void)scrollToBottom;

- (void)setStatusText:(NSString *)message;

- (void)setTestStats:(GHTestStats)stats;

@end

