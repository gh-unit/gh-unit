//
//  GHViewAnimation.h
//

typedef enum {
	GHViewAnimationDissolve, 
  GHViewAnimationMoveIn, 
  GHViewAnimationPush, 
  GHViewAnimationReveal, 
  GHViewAnimationWipe
} GHViewAnimationType;

@interface GHViewAnimation : NSObject {

  NSView *container_;  
  NSView *view1_;
  NSView *view2_;
  
  NSView *toView_;
  NSView *fromView_;

}

- (id)initWithContainer:(NSView *)container view:(NSView *)view1 view:(NSView *)view2;

- (NSView *)wrapView:(NSView *)view container:(NSView *)container hide:(BOOL)hide;
- (void)prepareSubviewOfView:(NSView *)view;
- (void)resetSubviewOfView:(NSView *)view;

- (NSViewAnimation *)dissolve;
- (NSViewAnimation *)moveIn;
- (NSViewAnimation *)push;
- (NSViewAnimation *)reveal;
- (NSViewAnimation *)wipe;

- (void)animate:(GHViewAnimationType)animationType;

@end
