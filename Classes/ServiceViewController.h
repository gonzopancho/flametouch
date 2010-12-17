/*
  ServiceViewController.h
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

#define LABEL_TAG 1


extern NSString * FTNameAndDetailsCellIdentifier;


@interface ServiceViewController : UITableViewController {
}

- (void) setCaption;
- (void) newServices: (id) sender;
- (UIViewController*)viewControllerForIndexPath:(NSIndexPath*)indexPath;
- (NSURL*)UrlForIndexPath:(NSIndexPath*)indexPath;

@end


@class Host;
@interface ServiceByHostViewController : ServiceViewController {
  Host *host;
}
@property (nonatomic, retain) Host* host;
- (id)initWithHost:(Host*)thehost;
@end


@class ServiceType;
@interface ServiceByTypeViewController : ServiceViewController {
	ServiceType * serviceType;
}
@property (nonatomic, retain) ServiceType * serviceType;
- (id)initWithServiceType:(ServiceType*) theServiceType;
@end

