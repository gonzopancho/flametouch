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

#import "QuartzCore/CAAnimation.h"

#import "RootViewController.h"
#import "ServiceViewController.h"
#import "FlameTouchAppDelegate.h"
#import "Host.h"
#import "ServiceType.h"
#import "HTMLViewController.h"
#import "CustomTableCell.h"

@implementation RootViewController

@synthesize white_arrow;

// utility, because we do it so much
-(FlameTouchAppDelegate *)appDelegate {
  return (FlameTouchAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void) awakeFromNib {
  self = [super initWithStyle:UITableViewStylePlain];

  if (self) {
    NSArray * segmentedControlItems = [NSArray arrayWithObjects:NSLocalizedString(@"Hosts", @"Title of Segmented Control item for selecting the Hosts list"), NSLocalizedString(@"Services", @"Title of Segmented Control item for selecting the Service list"), nil];
    UISegmentedControl * segmentedControl = [[[UISegmentedControl alloc] initWithItems:segmentedControlItems] autorelease];
    [segmentedControl addTarget:self action:@selector(changeDisplayMode:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.selectedSegmentIndex = [self appDelegate].displayMode;
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

/*
 action of the Hosts / Services segmented control
 sets the display mode in the app delegate and updates the view's title accordingly 
*/
-(void) changeDisplayMode:(id) sender {
  NSInteger selection = [(UISegmentedControl*) sender selectedSegmentIndex];

  // rather than snapping between the views, fade it nicely. LOOKS SO AWESOME.
  CATransition *transition = [CATransition animation];
  transition.duration = 0.25; // any slower than this and it's boring - any faster and it feels stuttery
  transition.type = kCATransitionFade;
  [self.view.layer addAnimation:transition forKey:nil];
  
  [self appDelegate].displayMode = selection;

	if (selection == SHOWSERVERS) {
    self.title = NSLocalizedString(@"Hosts", @"Title of Button to get back to the Hosts list");
  }
  else {
    self.title = NSLocalizedString(@"Services", @"Title of Button to get back to the Services list");
  }
}


-(void)showAboutPane {
  [[self appDelegate] displayViewController:nil asRoot:YES];
}

-(void)refreshList {
  [[self appDelegate] refreshList];
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
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", filterText];
    self.filteredHosts = [[self appDelegate].hosts filteredArrayUsingPredicate:predicate];
    predicate = [NSPredicate predicateWithFormat:@"(humanReadableType CONTAINS[cd] %@) or (type CONTAINS[cd] %@)", filterText, filterText];
    self.filteredServiceTypes = [[self appDelegate].serviceTypes filteredArrayUsingPredicate:predicate];    
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
  NSInteger result;
	
  if ([self appDelegate].displayMode == SHOWSERVERS) {
		result = [self.filteredHosts count];
	}
	else {
		result = [self.filteredServiceTypes count];
	}
  
  if (result == 0) {
    return 1; // the "there's nothing here!" case.
  }

	return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FTNameAndDetailsCellIdentifier];
  if (cell == nil) {
    // magic cell that looks different on the ipad
    cell = [[[CustomTableCell alloc] initWithReuseIdentifier:FTNameAndDetailsCellIdentifier] autorelease];
  }
  
  if ([self.filteredHosts count] == 0) {
    // haven't found anything
    cell.textLabel.text = @"searching.."; // FIXME - trasnlate
    cell.detailTextLabel.text = @"looking for hosts on the local network";
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;

  } else if ([self appDelegate].displayMode == SHOWSERVERS) {
		Host *host = (Host*)[self.filteredHosts objectAtIndex:indexPath.row];
		cell.textLabel.text = [host name];
		cell.detailTextLabel.text = [host details];

	} else {
		ServiceType * serviceType = (ServiceType*) [self.filteredServiceTypes objectAtIndex:indexPath.row];
		cell.textLabel.text = serviceType.humanReadableType;
		cell.detailTextLabel.text = [serviceType details];
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

  // iPad left-column needs a white accessory arrow so it shows up
  // against the background.
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    cell.accessoryView = [[[UIImageView alloc] initWithImage:self.white_arrow] autorelease];
  }
  return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  // Navigation logic may go here. Create and push another view controller.
  ServiceViewController * dlc = nil;

  if ([self.filteredHosts count] == 0) {
    // haven't found anything. this isn't a tapable thing.
    return;

  } else if ([self appDelegate].displayMode == SHOWSERVERS) {
		Host * host = (Host*)[self.filteredHosts objectAtIndex:indexPath.row];
		dlc = [[ServiceByHostViewController alloc] initWithHost:host];
	}
	else {
		ServiceType * serviceType = [self.filteredServiceTypes objectAtIndex:indexPath.row];
		dlc = [[ServiceByTypeViewController alloc] initWithServiceType: serviceType];
	}
  
  [[self appDelegate] displayViewController:dlc asRoot:YES];

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

