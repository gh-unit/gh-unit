//
//  GHUnitIPhoneViewController.h
//  GHUnitIPhone
//
//  Created by Gabriel Handford on 1/25/09.
//  Copyright 2009. All rights reserved.
//

#import "GHUnitIPhoneView.h"

#import "GHUnitIPhoneTableViewDataSource.h"
#import "GHUnitIPhoneTestViewController.h"

@interface GHUnitIPhoneViewController : UIViewController <UITableViewDelegate, GHTestRunnerDelegate, UISearchBarDelegate> {
		
  GHUnitIPhoneView *view_;
  
	//! Data source for table view
	GHUnitIPhoneTableViewDataSource *dataSource_;
	GHTestSuite *suite_;
	
	UIBarButtonItem *runButton_;
  
	//! If set then we will no longer auto scroll as tests are run
	BOOL userDidDrag_;
	
}

@property (retain, nonatomic) GHTestSuite *suite;

- (void)reloadTest:(id<GHTest>)test;

- (void)scrollToTest:(id<GHTest>)test;
- (void)scrollToBottom;

- (void)setStatusText:(NSString *)message;

- (void)runTests;

- (void)cancel;

- (void)reload;

- (void)loadDefaults;
- (void)saveDefaults;

- (GHUnitIPhoneTableViewDataSource *)dataSource;

@end

