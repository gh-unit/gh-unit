//
//  GHTestViewController.h
//  GHKit
//

#import "GHTestViewModel.h"
#import "GHTestGroup.h"
#import "GHTestOutlineViewModel.h"


@interface GHTestViewController : NSViewController 
											<GHTestRunnerDelegate, GHTestOutlineViewModelDelegate, NSSplitViewDelegate> 
{
	IBOutlet NSSplitView *_splitView;
	IBOutlet NSView *_statusView, *_detailsView;
	IBOutlet NSOutlineView *_outlineView;
	IBOutlet NSTextView *_textView;
	IBOutlet NSSegmentedControl *_textSegmentedControl, *_segmentedControl;
	IBOutlet NSSearchField *_searchField;
	IBOutlet NSButton *_detailsToggleButton;
}
@property (nonatomic) 						 BOOL   wrapInTextView,
															  reraiseExceptions,
															  runInParallel;
@property (nonatomic, getter=isRunning) BOOL   running;
@property  (readonly) 				 id<GHTest>   selectedTest;
@property  (readonly) GHTestOutlineViewModel * dataSource;
@property (nonatomic) 			   GHTestSuite * suite;
@property (nonatomic) 				   NSString * status, *runLabel, *exceptionFilename;
@property (nonatomic) 					  double   statusProgress;
@property (nonatomic) 				  NSInteger   exceptionLineNumber;



- 	  	  (void) selectRow:					(NSInteger)row;
-   (IBAction) copy:							(id)sender;
-   (IBAction) runTests:					(id)sender;
-   (IBAction) toggleDetails:				(id)sender;
-   (IBAction) updateTextSegment:		(id)sender;
-   (IBAction) updateMode:					(id)sender;
-   (IBAction) updateSearchFilter:		(id)sender;
-   (IBAction) openExceptionFilename:	(id)sender;
- 	 (IBAction) rerunTest:					(id)sender;
- (id<GHTest>) selectedTest;
-       (void) loadTestSuite;
- 		  (void) selectFirstFailure;
-  	  (void) runTests;
-		  (void) reload;
- 	  	  (void) loadDefaults;
- 	  	  (void) saveDefaults;
- 	  	  (BOOL) isShowingDetails;


@end
