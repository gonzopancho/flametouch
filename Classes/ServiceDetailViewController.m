/*
  ServiceDetailViewController.m
  FlameTouch

  Created by Tom Insam on 26/06/2009.
 
  
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

#import "ServiceDetailViewController.h"
#import "NSNetService+FlameExtras.h"
#import "FlameTouchAppDelegate.h"


@implementation ServiceDetailViewController

@synthesize host;
@synthesize service;
@synthesize TXTRecordKeys;
@synthesize TXTRecordValues;
@synthesize hasOpenServiceButton;


-(id)initWithHost:(Host*)hst service:(NSNetService*)srv {
  if ([super initWithStyle:UITableViewStyleGrouped] == nil) return nil;
  
  self.host = hst;
  self.service = srv;
  NSDictionary * TXTRecordDict = [NSNetService dictionaryFromTXTRecordData:[self.service TXTRecordData]];
  self.TXTRecordKeys = [[TXTRecordDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
  self.TXTRecordValues = [TXTRecordDict objectsForKeys:self.TXTRecordKeys notFoundMarker:@""];
  self.hasOpenServiceButton = (self.service.openableExternalURL != nil);
  
  self.tableView.delegate = self;

	if (((FlameTouchAppDelegate*)[[UIApplication sharedApplication] delegate]).displayMode == SHOWSERVERS) {
		self.title = self.service.humanReadableType;
	}
	else {
		self.title = self.service.name;
	}
  
  
  
  return self;
}



- (void)dealloc {
  self.host = nil;
  self.service = nil;
  self.TXTRecordKeys = nil;
  self.TXTRecordValues = nil;
  [super dealloc];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}





#pragma mark UITableViewDataSource

/*
 Split up table in three parts:
 1. General information in 3 or 4 rows: Host, Port, Type[, Human Readable Type]
 2. If available: Actionable button to open URL for the service
 3. TXT record keys and values
*/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSInteger result = 1;
	if (self.hasOpenServiceButton) result ++;
  if ([self.TXTRecordKeys count] != 0) result ++;
	return result;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger result = 0;
	
	if (section == 0) { // section for general information
		if (self.service.humanReadableTypeIsDistinct) result = 5;
		else result = 4;
  }
	else if (section == 1 && self.hasOpenServiceButton) { // section for URL button
    result = 1;
  }
	else  { // section for TXT record
		result = [self.TXTRecordKeys count];
	}

	return result;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell * cell = nil;
	
  if (indexPath.section == 0) {
		cell = [self standardPropertyCellForRow:indexPath.row];
	} else if (indexPath.section == 1 && self.hasOpenServiceButton) {
		cell = [self actionCellForRow:indexPath.row];
  } else {
		cell = [self TXTRecordPropertyCellForRow:indexPath.row];  
  }
	
	return cell;
}




#pragma mark UITableViewDelegate


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell * cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
  
  // Number of pixels of screen width not used for the data cell (i.e. for margins and labels). I can't figure this out automatically as the cell seems to have width 0 at this stage, so I measured it in the simulator (table width: 320, cell width 205).
  const CGFloat columnDelta = 115;
  // We need a maximum height, but it shouldn't impose a restriction on the text that is displayed because of the byte length restrictions in the TXTRecord.
  const CGFloat maximumHeight = 2048;
  
  CGSize maxSize = CGSizeMake(tableView.bounds.size.width - columnDelta, maximumHeight);
  
  // Our (system set-up) labels use a 15px bold font which doesn't seem to be a standard system font size.
  static const CGFloat FTTextLabelFontSize = 15;
  UIFont * myFont = [UIFont boldSystemFontOfSize:FTTextLabelFontSize];
  CGSize wantedSize = [cell.detailTextLabel.text sizeWithFont:myFont constrainedToSize:maxSize];
  
  // Standard iPhone table cells are 44 pixels tall.
  const CGFloat minimumHeight = 44;
  // The standard padding seems to be 13 pixels at the top and bottom. Making the height 44 pixels at the standard font size.
  const CGFloat padding = 26;
    
  return MAX(wantedSize.height + padding, minimumHeight);
}



/*
 Only allow selection for 'clickable' rows.
*/ 
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSIndexPath * selection = nil;
  
  if ((self.hasOpenServiceButton && indexPath.section == 2) || (!self.hasOpenServiceButton && indexPath.section == 1)) {
    // Pressed one of the TXT Record cells.
    NSString *value = [[[NSString alloc] initWithData:[self.TXTRecordValues objectAtIndex:indexPath.row] encoding:NSUTF8StringEncoding] autorelease];
    if (value != nil) {
      NSURL *url = [NSURL URLWithString:value];
      if (url && [url scheme] && [url host]) {
        selection = indexPath;
      }
    }
  }
  else if (self.hasOpenServiceButton && indexPath.section == 1) {
    // It's the Open Service button.
    selection = indexPath;
  }
  
  return selection;
}



- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if ((self.hasOpenServiceButton && indexPath.section == 2) || (!self.hasOpenServiceButton && indexPath.section == 1)) {
    // Pressed one of the TXT Record cells
    NSString *value = [[[NSString alloc] initWithData:[self.TXTRecordValues objectAtIndex:indexPath.row] encoding:NSUTF8StringEncoding] autorelease];
    if (value != nil) {
      NSURL *url = [NSURL URLWithString:value];
      if (url && [url scheme] && [url host]) {
        [[UIApplication sharedApplication] openURL:url];
      }
    }
  } else if (self.hasOpenServiceButton && indexPath.section == 1) {
    // Pressed the Open Service cell
    // NSLog(@"Opening URL %@", self.service.externalURL);
    // in a couple of seconds, report if we have no wifi
    [[UIApplication sharedApplication] openURL:self.service.externalURL];
  }
  [tableView cellForRowAtIndexPath:indexPath].selected = NO;
}



#pragma mark Cell Creation

-(UITableViewCell *)propertyCellWithLabel:(NSString*) label andValue:(NSString*) value {
  static NSString *CellIdentifier = @"PropertyCell";

  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];  
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.minimumFontSize = 10.0;
    cell.detailTextLabel.numberOfLines  = 0;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
  }
  
  NSString * myLabel = (nil != label) ? label : @"";
  NSString * myValue = (nil != value) ? value : @"";
  cell.textLabel.text = myLabel;
  cell.detailTextLabel.text = myValue;
      
  // try to parse the value as an url - if we can, then this cell is
  // clickable. Make it blue. I'd like it underlined as well, but that
  // seems to be lots harder.
  NSURL *url = [NSURL URLWithString:myValue];
  if (url && [url scheme] && [url host] && [[UIApplication sharedApplication] canOpenURL:url]) {
    cell.detailTextLabel.textColor = [UIColor blueColor];
  } else {
    cell.detailTextLabel.textColor = [UIColor blackColor];
  }

  return cell;
}



-(UITableViewCell*) standardPropertyCellForRow: (int) row {
	NSString *label = nil;
	NSString *value = nil;

	if (row == 0) {
		label = NSLocalizedString(@"Description", @"Service Details: Label for human readable description");
		value = self.service.humanReadableType;
	} else if (row == 1) {
		label = NSLocalizedString(@"Name", @"Service Details: Name of the service");
		value = [self.service name];
	} else if (row == 2) {
		label = NSLocalizedString(@"Type", @"Service Details: Label for type");
		value = self.service.type;
	} else if (row == 3) {
    if ([self.service.protocolType isEqualToString:@"TCP"]) {
      label = NSLocalizedString(@"Port", @"Service Details: Label for port number");
    }
    else {
      label = [NSString stringWithFormat:NSLocalizedString(@"%@ Port", @"Service Details: Label for port number. %@ indicates the protocol type, e.g. UDP."), self.service.protocolType];
    }
		value = [NSString stringWithFormat:@"%i", [self.service port]];
	} else if (row == 4) {
		label = NSLocalizedString(@"Host", @"Service Details: Label for host name");
		value = self.service.hostnamePlus;
	} 

	UITableViewCell * cell = [self propertyCellWithLabel: label andValue: value];
	return cell;
}



-(UITableViewCell*) TXTRecordPropertyCellForRow: (int) row {
	NSString * label = [self.TXTRecordKeys objectAtIndex:row];
	NSString * value = [[[NSString alloc] initWithData:[self.TXTRecordValues objectAtIndex:row] encoding:NSUTF8StringEncoding] autorelease];
	
	UITableViewCell * cell = [self propertyCellWithLabel: label andValue: value];
	return cell;
}



-(UITableViewCell *)actionCellForRow:(int)row {
  static NSString *CellIdentifier = @"ActionCell";
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    cell.textLabel.textAlignment = UITextAlignmentCenter;
  }
  cell.textLabel.text = NSLocalizedString(@"Open Service", @"Label of button to open the relevant service on Service Details page");
  return cell;
}



#pragma mark Copy Table Cells
/*
 Offer Copy menu item on everything but the Open Service button.
*/ 
- (BOOL) tableView:(UITableView*)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender {
  BOOL result = NO;
  
  if (action == @selector(copy:)) {
    result = YES;
    if (self.hasOpenServiceButton && indexPath.section == 1) {
      result = NO;
    }
  }
  
  return result;
}

- (BOOL) tableView:(UITableView*)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath*)indexPath {
  return YES;
}


- (void) tableView:(UITableView*)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender {
  if (action == @selector(copy:)) {
    UIPasteboard * pasteboard = [UIPasteboard generalPasteboard];
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    [pasteboard setString: cell.detailTextLabel.text];
  }
}


@end
