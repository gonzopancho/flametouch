/*
  RootViewController.m
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

#import "RootViewController.h"
#import "ServiceViewController.h"
#import "FlameTouchAppDelegate.h"
#import "Host.h"
#import "ServiceType.h"
#import "AboutViewController.h"
#import "CustomTableCell.h"

@implementation RootViewController

@synthesize displayThingy, white_arrow;

- (void) awakeFromNib {
  self = [super initWithStyle:UITableViewStylePlain];

  if (self) {
    self.displayThingy = nil;

    NSArray * segmentedControlItems = [NSArray arrayWithObjects:NSLocalizedString(@"Hosts", @"Title of Segmented Control item for selecting the Hosts list"), NSLocalizedString(@"Services", @"Title of Segmented Control item for selecting the Service list"), nil];
    UISegmentedControl * segmentedControl = [[[UISegmentedControl alloc] initWithItems:segmentedControlItems] autorelease];
    [segmentedControl addTarget:self action:@selector(changeDisplayMode:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.selectedSegmentIndex = ((FlameTouchAppDelegate*)[[UIApplication sharedApplication] delegate]).displayMode;
    self.navigationItem.titleView = segmentedControl;

    UIBarButtonItem *refreshButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshList)] autorelease];
    self.navigationItem.leftBarButtonItem = refreshButton;
    
    UIButton * myAboutButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    myAboutButton.frame = CGRectMake(0.0,0.0,20.0,20.0);
    [myAboutButton addTarget:self action:@selector(showAboutPane) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * aboutButton = [[[UIBarButtonItem alloc] initWithCustomView:myAboutButton] autorelease];
    [myAboutButton setTitle:NSLocalizedString(@"About Flame", @"Label for About Button (not visible on screen, but used for Accessibility)") forState:0];
    self.navigationItem.rightBarButtonItem = aboutButton;
    
    
    CGRect searchBarRect = CGRectMake(0, 0, 100, 44);
    UISearchBar * searchBar = [[[UISearchBar alloc] initWithFrame:searchBarRect] autorelease];
    searchBar.delegate = self;
    searchBar.showsCancelButton = YES;
    self.tableView.tableHeaderView = searchBar;
    [self.tableView setContentOffset:CGPointMake(0, 44)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newServices:) name:@"newServices" object:nil ];
    
    [self.tableView setRowHeight:[CustomTableCell height]];
    
    // this has to be here and not in the custom cell because I need to set the
    // background colour even for bits of the table without cells.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      self.tableView.separatorColor = [UIColor lightGrayColor];
      self.tableView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1];
      self.white_arrow = [UIImage imageNamed:@"white_arrow.png"];
    }
  }

}

-(void)setDisplayThingy:(RootSplitViewController*)newController;
{
  NSLog(@"setter");
  if (newController != displayThingy) {
    [displayThingy release];
    displayThingy = [newController retain];
  }

  // if we're setting a nav controller, and we still have our 'about'
  // button, give it to the splitViewController.
  if (newController && self.navigationItem.rightBarButtonItem) {
    newController.rightBarButtonItem = self.navigationItem.rightBarButtonItem;
    self.navigationItem.rightBarButtonItem = nil;
  }
}


/*
 action of the Hosts / Services segmented control
 sets the display mode in the app delegate and updates the view's title accordingly 
*/
-(void) changeDisplayMode:(id) sender {
  NSInteger selection = [(UISegmentedControl*) sender selectedSegmentIndex];

  ((FlameTouchAppDelegate *)[[UIApplication sharedApplication] delegate]).displayMode = selection;

	if (selection == SHOWSERVERS) {
    self.title = NSLocalizedString(@"Hosts", @"Title of Button to get back to the Hosts list");
  }
  else {
    self.title = NSLocalizedString(@"Services", @"Title of Button to get back to the Services list");
  }
}


-(void)showAboutPane {
  AboutViewController *avc = [[AboutViewController alloc] init];
  if (self.displayThingy) {
    [self.displayThingy setViewController:avc];
  } else {
    [self.navigationController pushViewController:avc animated:TRUE];
  }
  [avc release];
}

-(void)refreshList {
  FlameTouchAppDelegate *delegate = (FlameTouchAppDelegate *)[[UIApplication sharedApplication] delegate];
  [delegate refreshList];
  [self runFilter];
}

-(void) newServices:(id)whatever {
  [self runFilter];
  [self.tableView reloadData];
}


/*
 Update our filtered copies of the services and host arrays.
*/
- (void) runFilter {
  NSString * filterText = ((UISearchBar *)self.tableView.tableHeaderView).text;
  if ( !filterText || [filterText isEqualToString:@""] ) {
    self.filteredHosts = nil;
    self.filteredServiceTypes = nil;
  }
  else {
    FlameTouchAppDelegate *delegate = (FlameTouchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", filterText];
    self.filteredHosts = [delegate.hosts filteredArrayUsingPredicate:predicate];
    predicate = [NSPredicate predicateWithFormat:@"(humanReadableType CONTAINS[cd] %@) or (type CONTAINS[cd] %@)", filterText, filterText];
    self.filteredServiceTypes = [delegate.serviceTypes filteredArrayUsingPredicate:predicate];    
  }
  
  [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
  // Release anything that's not essential, such as cached data
}




#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  FlameTouchAppDelegate *delegate = (FlameTouchAppDelegate *)[[UIApplication sharedApplication] delegate];
  NSInteger result;
	
  if (delegate.displayMode == SHOWSERVERS) {
		result = [self.filteredHosts count];
	}
	else {
		result = [self.filteredServiceTypes count];
	}

	return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FTNameAndDetailsCellIdentifier];
  if (cell == nil) {
    // magic cell that looks different on the ipad
    cell = [[[CustomTableCell alloc] initWithReuseIdentifier:FTNameAndDetailsCellIdentifier] autorelease];
  }
  
  FlameTouchAppDelegate *delegate = (FlameTouchAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (delegate.displayMode == SHOWSERVERS) {
		Host *host = (Host*)[self.filteredHosts objectAtIndex:indexPath.row];
		cell.textLabel.text = [host name];
		cell.detailTextLabel.text = [host details];
	}
	else {
		ServiceType * serviceType = (ServiceType*) [self.filteredServiceTypes objectAtIndex:indexPath.row];
		cell.textLabel.text = serviceType.humanReadableType;
		cell.detailTextLabel.text = [serviceType details];
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

  // iPad left-column needs a white accessory arrow so it shows up
  // against the background.
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    cell.accessoryView = [[[UIImageView alloc] initWithImage:white_arrow] autorelease];
  }
  return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  // Navigation logic may go here. Create and push another view controller.
  FlameTouchAppDelegate *delegate = (FlameTouchAppDelegate *)[[UIApplication sharedApplication] delegate];
  
  ServiceViewController * dlc = nil;
	if (delegate.displayMode == SHOWSERVERS) {
		Host * host = (Host*)[self.filteredHosts objectAtIndex:indexPath.row];
		dlc = [[ServiceByHostViewController alloc] initWithHost:host];
	}
	else {
		ServiceType * serviceType = [self.filteredServiceTypes objectAtIndex:indexPath.row];
		dlc = [[ServiceByTypeViewController alloc] initWithServiceType: serviceType];
	}

  if (self.displayThingy) {
    [self.displayThingy setViewController:dlc];
  } else {
    [self.navigationController pushViewController:dlc animated:TRUE];
  }

  [dlc release];
}





#pragma mark UISearchBarDelegate

- (void) searchBar: (UISearchBar *) searchBar textDidChange: (NSString *) searchText {
  [self runFilter];
}

- (void) searchBarCancelButtonClicked: (UISearchBar *) searchBar {
  ((UISearchBar*)self.tableView.tableHeaderView).text = @"";
  [((UISearchBar*)self.tableView.tableHeaderView) resignFirstResponder];
  [self.tableView setContentOffset:CGPointMake(0, 44) animated: YES];
}






#pragma mark Accessors


@dynamic filteredHosts;
@dynamic filteredServiceTypes;

- (NSArray *) filteredHosts {
  NSArray * result = filteredHosts;
  if (!result) {
    result = ((FlameTouchAppDelegate *)[[UIApplication sharedApplication] delegate]).hosts;
  }
  return result;
}

- (void) setFilteredHosts: (NSArray *) newFilteredHosts {
  if ( newFilteredHosts != filteredHosts) {
    [filteredHosts release];
    filteredHosts = [newFilteredHosts retain];
  }
}


- (NSArray *) filteredServiceTypes {
  NSArray * result = filteredServiceTypes;
  if (!result) {
    result = ((FlameTouchAppDelegate *)[[UIApplication sharedApplication] delegate]).serviceTypes;
  }
  return result;
}

- (void) setFilteredServiceTypes: (NSArray *) newFilteredServiceTypes {
  if ( newFilteredServiceTypes != filteredServiceTypes) {
    [filteredServiceTypes release];
    filteredServiceTypes = [newFilteredServiceTypes retain];
  }
}





#pragma mark Override


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES; 
}


- (void) dealloc {
  [filteredHosts release];
  [filteredServiceTypes release];
  [super dealloc];
}


@end

