//// Header file
// http://starterstep.wordpress.com/2009/03/05/changing-a-uinavigationcontroller’s-root-view-controller/

#import <UIKit/UIKit.h>

@interface TVNavigationController : UINavigationController {
  UIViewController *fakeRootViewController;
}

@property(nonatomic, retain) UIViewController *fakeRootViewController;

-(void)setRootViewController:(UIViewController *)rootViewController;

@end