    //
//  ServiceSplitViewController.m
//  FlameTouch
//
//  Created by Tom Insam on 05/07/2010.
//  Copyright 2010 jerakeen.org. All rights reserved.
//

#import "QuartzCore/CAAnimation.h"

#import "RootSplitViewController.h"
#import "RootViewController.h"
#import "TVNavigationController.h"

@implementation RootSplitViewController

@synthesize defaultView, leftPane, rightPane, rightBarButtonItem;

-(id)initWithLeftPane:(UINavigationController*)left defaultView:(UIViewController*)def;
{
  NSLog(@"initWithLeftPane: %@", left);
  if (self = [super init]) {
    self.leftPane = left;
    self.defaultView = def;
  }
  return self;
}

-(void)viewDidLoad;
{
  NSLog(@"viewDidLoad");
  ((RootViewController*)leftPane.visibleViewController).displayThingy = self;

  self.rightPane = [[[TVNavigationController alloc] initWithRootViewController:self.defaultView] autorelease];
  self.viewControllers = [NSArray arrayWithObjects:leftPane, rightPane, nil];

  // force the view background to white, so the fades look better.
  rightPane.view.backgroundColor = [UIColor whiteColor];

  [self performSelector:@selector(fudgeFrames) withObject:nil afterDelay:1];
}

-(void)setViewController:(UIViewController*)vc;
{
  // Steal the right button from the main navigation controller.
  vc.navigationItem.rightBarButtonItem = self.rightBarButtonItem;

  CATransition *transition = [CATransition animation];
  transition.duration = 0.2;
  transition.type = kCATransitionFade;
  [self.rightPane.view.layer addAnimation:transition forKey:nil];
  
  [self.rightPane setRootViewController:vc];
  [self fudgeFrames];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
{
  // Overriden to allow any orientation.
  return YES;
}

// always display left pane, even in portrait mode.
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration;
{
  // explicitly don't let the automatic frame rearranger do anything.
  //[super willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
  [self fudgeFrames];
}

- (void)fudgeFrames;
{
  CGRect frame;
  if (self.interfaceOrientation == UIDeviceOrientationLandscapeLeft || self.interfaceOrientation == UIDeviceOrientationLandscapeRight) {
    frame = CGRectMake(0,0,1024,768);
  } else {
    frame = CGRectMake(0,0,768,1024);
  }

  //adjust master view
  CGRect leftFrame = leftPane.view.frame;
  leftFrame.size.width = 320;
  leftFrame.size.height = frame.size.height;
  leftFrame.origin.x = 0;
  leftFrame.origin.y = 0;
  [leftPane.view setFrame:leftFrame];
  
  //adjust detail view
  CGRect rightFrame = rightPane.view.frame;
  rightFrame.size.width = frame.size.width - 320;
  rightFrame.size.height = frame.size.height;
  rightFrame.origin.x = 320;
  rightFrame.origin.y = 0;
  [rightPane.view setFrame:rightFrame];
}


- (void)didReceiveMemoryWarning {
  NSLog(@"memory warning");
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
    
  // Release any cached data, images, etc that aren't in use.
  [rightPane release];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
  self.leftPane = nil;
  self.rightPane = nil;
  [super dealloc];
}


@end
