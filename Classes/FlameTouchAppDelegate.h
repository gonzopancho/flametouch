/*
  FlameTouchAppDelegate.h
  FlameTouch

  Created by Tom Insam on 24/11/2008.
 
  
  Copyright (c) 2009-2010 Sven-S. Porst, Tom Insam
  
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:
  
  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.
  
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.

  Email flame@jerakeen.org or visit http://jerakeen.org/code/flame-iphone/
  for support.
*/

#import <UIKit/UIKit.h>
#import "Host.h"

// to detect network reachability
#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"

#define SHOWSERVERS 0
#define SHOWSERVICES 1


@interface FlameTouchAppDelegate : NSObject <UIApplicationDelegate,NSNetServiceBrowserDelegate,NSNetServiceDelegate> {
  
  UIWindow *window;
  UINavigationController *navigationController;
  UIViewController *splitViewController; // weak linked!

  NSNetServiceBrowser *metaBrowser;
  NSMutableArray *serviceBrowsers;
  NSMutableArray *hosts;
  NSMutableArray *serviceTypes;
  
  NSDictionary *serviceURLs;
  
  BOOL displayingExplanation;
}

- (void)refreshList;
- (Host*) hostForService: (NSNetService*) service;
-(void)displayViewController:(UIViewController*) vc asRoot:(BOOL)asRoot;
-(void)displayMainSubview;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet UIViewController *splitViewController;
@property (nonatomic, retain) NSMutableArray* hosts;
@property (nonatomic, retain) NSMutableArray* serviceTypes;
@property (nonatomic, retain) NSMutableArray* serviceBrowsers;
@property (nonatomic, retain) NSDictionary* serviceURLs;
@property NSInteger displayMode;
@end

