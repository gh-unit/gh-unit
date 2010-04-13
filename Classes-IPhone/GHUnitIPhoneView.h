//
//  GHUnitIPhoneView.h
//  GHUnitIPhone
//
//  Created by Gabriel Handford on 4/12/10.
//  Copyright 2010. All rights reserved.
//


@interface GHUnitIPhoneView : UIView {
	UISearchBar	*searchBar_;
	
	UITableView *tableView_;
	
	//! Status label at bottom of the view
	UILabel *statusLabel_;
 
  UISegmentedControl *filterControl_;
	  
  UIToolbar *runToolbar_;  
  
  UIView *footerView_;
}

@property (readonly, nonatomic) UILabel *statusLabel;
@property (readonly, nonatomic) UISegmentedControl *filterControl;
@property (readonly, nonatomic) UISearchBar	*searchBar;
@property (readonly, nonatomic) UITableView *tableView;


@end
