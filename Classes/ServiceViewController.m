/*
  ServiceViewController.m
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

#import "ServiceViewController.h"
#import "ServiceDetailViewController.h"
#import "NSNetService+FlameExtras.h"
#import "Host.h"
#import "ServiceType.h"
#import "FlameTouchAppDelegate.h"


NSString * FTNameAndDetailsCellIdentifier = @"NameAndDetails";

@implementation ServiceViewController

- (id) init {
	if ([super initWithStyle:UITableViewStylePlain] == nil) return nil;

	UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 25.0)];
  header.autoresizingMask = UIViewAutoresizingFlexibleWidth;

	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8.0, 3.0, self.tableView.frame.size.width -16.0, 18.0)];
	label.tag = LABEL_TAG;
	label.font = [UIFont systemFontOfSize:12.0];
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor grayColor];
	label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	label.numberOfLines = 2;
	[header addSubview:label];
	[label release];
	
	UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.0, header.frame.size.height - 1.0, self.tableView.frame.size.width, 1.0)];
	line.backgroundColor = [UIColor grayColor];
  line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[header addSubview:line];
	[line release];
	
	self.tableView.tableHeaderView = header;
	[header release];
  
	self.tableView.delegate = self;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newServices:) name:@"newServices" object:nil ];
	
	return self;
}


- (void) setCaption {}


- (void) newServices:(id) sender {
  [self.tableView reloadData];
	[self setCaption];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FTNameAndDetailsCellIdentifier];
	if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:FTNameAndDetailsCellIdentifier] autorelease];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
	}
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES; 
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
  UIViewController *vc = [self viewControllerForIndexPath:indexPath];
  [self.navigationController pushViewController:vc animated:TRUE];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;
{
  NSURL *URL = [self UrlForIndexPath:indexPath];
  [[UIApplication sharedApplication] openURL:URL];
}

- (UIViewController*)viewControllerForIndexPath:(NSIndexPath *)indexPath;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (NSURL*)UrlForIndexPath:(NSIndexPath *)indexPath;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}



@end




@implementation ServiceByHostViewController

@synthesize host;

- (id)initWithHost:(Host*)thehost {
	self = [super init];
	if (self) {
		self.host = thehost;
		self.title = [self.host name];
		[self setCaption];
	}
	
	return self;
}


-(void) setCaption {
	UILabel *label = (UILabel*)[self.view viewWithTag:LABEL_TAG];
	label.text = [host detailsWithCount];
}


-(void) newServices:(id) sender {
  if ([self.host.services count] == 0) {
    // this Host stopped existing, check whether new services of the same kind appeared and, if so, replace our ServiceType with the new instance
    FlameTouchAppDelegate * delegate = ((FlameTouchAppDelegate*)[[UIApplication sharedApplication] delegate]);
    
    for (Host * h in delegate.hosts) {
      if ([h isEqual:self.host]) {
        self.host = h;
        break;
      }
    }
    
  }
  
  [super newServices:sender];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.host serviceCount];
}


/*
 Sets text in the cell as follows: 
 If we have a human readable name for the service: title = human readable name / subtitle = service name + port + raw name
 without a pretty name: title = raw name / subtitle = service name + port
*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell * cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
  NSNetService *service = [self.host serviceAtIndex:indexPath.row];
	
  if ([service.humanReadableType isEqualToString:service.type]) {
    cell.textLabel.text = service.type;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ – [%i]", [service name], service.portInfo];
  } 
  else {
		NSRange firstDot = [service.type rangeOfString:@"." options:NSLiteralSearch];
		NSString * protocolName = service.type;
		if (firstDot.location != NSNotFound && firstDot.location > 0) {
			protocolName = [protocolName substringWithRange:NSMakeRange(1, firstDot.location - 1)];
		}
    
    cell.textLabel.text = service.humanReadableType;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ – [%@:%@]", [service name], service.portInfo, protocolName];
  }
  if (service.openableExternalURL == nil) {
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
  }
  else {
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
  }
  
	return cell;
}

- (UIViewController*)viewControllerForIndexPath:(NSIndexPath*)indexPath;
{
  NSNetService *service = [self.host serviceAtIndex:indexPath.row];
  ServiceDetailViewController *sdvc = [[ServiceDetailViewController alloc] initWithHost:self.host service:service];
  return [sdvc autorelease];
}

- (NSURL*)UrlForIndexPath:(NSIndexPath *)indexPath;
{
  NSNetService *service = [self.host serviceAtIndex:indexPath.row];
  return service.openableExternalURL;
}


- (void)dealloc {
  self.host = nil;
  [super dealloc];
}

@end






@implementation ServiceByTypeViewController

@synthesize serviceType;

- (id)initWithServiceType:(ServiceType*) theServiceType {
	self = [super init];
	if (self) {
		self.serviceType = theServiceType;
		self.title = self.serviceType.humanReadableType;
		[self setCaption];
	}
	
	return self;
}


-(void) setCaption {
	UILabel *label = (UILabel*)[self.view viewWithTag:LABEL_TAG];
	label.text = serviceType.summary;
}


-(void) newServices:(id) sender {
  if ([self.serviceType.services count] == 0) {
    // this ServiceType stopped existing, check whether new services of the same kind appeared and, if so, replace our ServiceType with the new instance
    FlameTouchAppDelegate * delegate = ((FlameTouchAppDelegate*)[[UIApplication sharedApplication] delegate]);
    
    for (ServiceType * sT in delegate.serviceTypes) {
      if ([sT isEqual:self.serviceType]) {
        self.serviceType = sT;
        break;
      }
    }
    
  }
  
  [super newServices:sender];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.serviceType.services count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell * cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	NSNetService *service = [self.serviceType.services objectAtIndex:indexPath.row];
	
  cell.textLabel.text = [service name];
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%@:%@", service.hostnamePlus, service.portInfo];
	
  if (service.openableExternalURL == nil) {
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
  }
  else {
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
  }  
  
	return cell;
}

- (UIViewController*)viewControllerForIndexPath:(NSIndexPath*)indexPath;
{
	NSNetService *service = [self.serviceType.services objectAtIndex:indexPath.row];
	Host * host = [((FlameTouchAppDelegate*)[[UIApplication sharedApplication] delegate]) hostForService:service];
	ServiceDetailViewController *sdvc = [[ServiceDetailViewController alloc] initWithHost:host service:service];
  return [sdvc autorelease];
}


- (NSURL*)UrlForIndexPath:(NSIndexPath *)indexPath;
{
  NSNetService * service = [self.serviceType.services objectAtIndex:indexPath.row];
  NSURL * URL = service.openableExternalURL;
  return URL;
}


- (void)dealloc {
	self.serviceType = nil;
	[super dealloc];
}

@end