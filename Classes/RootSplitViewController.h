//
//  ServiceSplitViewController.h
//  FlameTouch
//
//  Created by Tom Insam on 05/07/2010.
//  Copyright 2010 jerakeen.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootSplitViewController : UISplitViewController {  
  UINavigationController *leftPane;
  UIViewController *rightPane;
}

@property (nonatomic, retain) UINavigationController *leftPane;
@property (nonatomic, retain) UIViewController *rightPane;

-(id)initWithLeftPane:(UINavigationController*)left;
-(void)fudgeFrames;
-(void)setViewController:(UIViewController*)vc;

@end
