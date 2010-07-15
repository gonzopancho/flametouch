//
//  ServiceSplitViewController.h
//  FlameTouch
//
//  Created by Tom Insam on 05/07/2010.
//  Copyright 2010 jerakeen.org. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TVNavigationController.h"

@interface RootSplitViewController : UISplitViewController {  
  UINavigationController *leftPane;
  TVNavigationController *rightPane;
  UIBarButtonItem *rightBarButtonItem;
  UIViewController *defaultView;
}

@property (nonatomic, retain) UINavigationController *leftPane;
@property (nonatomic, retain) TVNavigationController *rightPane;
@property (nonatomic, retain) UIBarButtonItem *rightBarButtonItem;
@property (nonatomic, retain) UIViewController *defaultView;

-(id)initWithLeftPane:(UINavigationController*)left defaultView:(UIViewController*)def;
-(void)fudgeFrames;
-(void)setViewController:(UIViewController*)vc;

@end
