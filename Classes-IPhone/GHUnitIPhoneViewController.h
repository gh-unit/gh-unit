//
//  GHUnitIPhoneViewController.h
//  GHUnitIPhone
//
//  Created by Gabriel Handford on 1/25/09.
//  Copyright 2009. All rights reserved.
//

#import "GHTestViewModel.h"

#import "GHUnitIPhoneTableViewDataSource.h"

extern NSString *const GHUnitAutoRunKey;

@interface GHUnitIPhoneViewController : UIViewController <UITableViewDelegate, GHTestRunnerDelegate, UISearchBarDelegate> {
	
	UISearchBar	*searchBar_;
	
	UITableView *tableView_;
	
	//! Status label at bottom of the view
	UILabel *statusLabel_;
	
	//! Data source for table view
	GHUnitIPhoneTableViewDataSource *dataSource_;
	GHTestSuite *suite_;
	
	//! Edit/Save toggle button
	UIBarButtonItem *editButton_;
	UIBarButtonItem *runButton_;
	
	//! If set then we will no longer auto scroll as tests are run
	BOOL userDidDrag_;
	
	//! Toolbar
	UIToolbar *toolbar_;
	NSArray *editToolbarItems_;
	
	// Search
	NSString *prefix_;
}

@property (readonly, nonatomic) UITableView *tableView;
@property (assign, nonatomic, getter=isAutoRun) BOOL autoRun;

@property (retain, nonatomic) GHTestSuite *suite;

- (void)reloadTest:(id<GHTest>)test;

- (void)scrollToTest:(id<GHTest>)test;
- (void)scrollToBottom;

- (void)setStatusText:(NSString *)message;

- (void)setEditing:(BOOL)editing;

- (void)runTests;

- (void)reset;
- (void)cancel;

- (void)reload;

- (void)loadDefaults;

@end

