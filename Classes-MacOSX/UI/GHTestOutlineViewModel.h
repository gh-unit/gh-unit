//
//  GHTestOutlineViewModel.h
//  GHUnit
//
//  Created by Gabriel Handford on 7/17/09.
//  Copyright 2009 Yelp. All rights reserved.
//

#import "GHTestOutlineViewModel.h"
#import "GHTestViewModel.h"

@class GHTestOutlineViewModel;

@protocol GHTestOutlineViewModelDelegate <NSObject>
- (void)testOutlineViewModelDidChangeSelection:(GHTestOutlineViewModel *)testOutlineViewModel;
@end


@interface GHTestOutlineViewModel : NSObject {
	GHTestViewModel *model_;
	
	GHTestRunner *runner_;
	
	id<GHTestOutlineViewModelDelegate> delegate_; // weak
}

@property (assign, nonatomic) id<GHTestOutlineViewModelDelegate> delegate;

- (GHTestNode *)findFailure;
- (GHTestNode *)findFailureFromNode:(GHTestNode *)node;
- (GHTestNode *)findTestNode:(id<GHTest>)test;

- (GHTestRunner *)loadTestSuite:(GHTestSuite *)suite;

- (void)run;

@end
