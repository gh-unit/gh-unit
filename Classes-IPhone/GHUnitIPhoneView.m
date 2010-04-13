//
//  GHUnitIPhoneView.m
//  GHUnitIPhone
//
//  Created by Gabriel Handford on 4/12/10.
//  Copyright 2010. All rights reserved.
//

#import "GHUnitIPhoneView.h"


@implementation GHUnitIPhoneView

@synthesize statusLabel=statusLabel_, filterControl=filterControl_, searchBar=searchBar_, tableView=tableView_;

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | 
      UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    
    searchBar_ = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    searchBar_.showsCancelButton = NO;
    searchBar_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:searchBar_];
    [searchBar_ release];
    
    // Table view
    tableView_ = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView_.sectionIndexMinimumDisplayRowCount = 5;
    [self addSubview:tableView_];
    [tableView_ release];	
    
    footerView_ = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 36)];
    footerView_.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    
    // Status label
    statusLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 310, 36)];
    statusLabel_.text = @"Select 'Run' to start tests";
    statusLabel_.backgroundColor = [UIColor clearColor];
    statusLabel_.font = [UIFont systemFontOfSize:12];
    statusLabel_.numberOfLines = 2;
    statusLabel_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [footerView_ addSubview:statusLabel_];
    [statusLabel_ release];
    
    [self addSubview:footerView_];
    [footerView_ release];
    
    runToolbar_ = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 36)];
    filterControl_ = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"All", @"Failed", nil]];
    filterControl_.frame = CGRectMake(20, 6, 280, 24);
    filterControl_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    filterControl_.segmentedControlStyle = UISegmentedControlStyleBar;
    [runToolbar_ addSubview:filterControl_];
    [filterControl_ release];
    [self addSubview:runToolbar_];
    [runToolbar_ release];    
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  CGSize size = self.frame.size;
  CGFloat y = 0;  
  CGFloat contentHeight = size.height - 44 - 36 - 36;
  
  searchBar_.frame = CGRectMake(0, y, size.width, 44);
  y += 44;
  
  tableView_.frame = CGRectMake(0, y, size.width, contentHeight);
  y += contentHeight;
  
  footerView_.frame = CGRectMake(0, y, size.width, 36);
  y += 36;
  
  runToolbar_.frame = CGRectMake(0, y, size.width, 36);      
}

@end
