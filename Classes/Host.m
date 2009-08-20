//
//  Host.m
//  FlameTouch
//
//  Created by Tom Insam on 24/11/2008.
//  Copyright 2008 jerakeen.org. All rights reserved.
//

#import "Host.h"
#import "NSNetService+FlameExtras.h"
#import "ServiceType.h"

@implementation Host

@synthesize hostname;
@synthesize ip;
@synthesize services;

-(id)initWithHostname:(NSString*)hn ipAddress:(NSString*)ipAddress {
  if ([super init] == nil) return nil;
  self.hostname = hn;
  self.ip = ipAddress;
  self.services = [NSMutableArray arrayWithCapacity:10];
  return self;
}

-(int)serviceCount {
  return [self.services count];
}

-(NSString*)name {
  // TODO - strip everything after the last apostrophe to get username
  NSString* result = self.hostname;
  NSRange dotLocalRange = [self.hostname rangeOfString:@".local." options:NSAnchoredSearch | NSBackwardsSearch];
  if (dotLocalRange.location != NSNotFound) {
    result = [self.hostname substringToIndex:dotLocalRange.location];
  }
  return result;
}

-(NSString*) details {
  NSString * result;
  if (self.services.count == 1) {
    NSString * serviceName = ((ServiceType*)[self.services objectAtIndex:0]).humanReadableType;
    result = [NSString stringWithFormat:@"%@ (%@) – %@", self.hostname, self.ip, serviceName];
  }
  else {
    result = [self detailsWithCount];
  }
  
  return result;
  
}

-(NSString*) detailsWithCount {
	NSUInteger serviceCount = self.services.count;
	NSString * serviceCountString = @"";
  if (serviceCount == 0) {
    serviceCountString = NSLocalizedString(@"No Services", @"String indicating that no service is advertised on the Host");
  }
	if (serviceCount == 1) {
		serviceCountString = NSLocalizedString(@"1 Service", @"String indicating that single service is advertised on the Host");
	}
	else if (serviceCount > 1) {
		serviceCountString = [NSString stringWithFormat:NSLocalizedString(@"%i Services", @"String indicating that %i (with %i > 1) services are advertised on Host"), serviceCount];
	}
	NSString* details = [NSString stringWithFormat:@"%@ (%@) – %@", self.hostname, self.ip, serviceCountString];
	return details;
}

-(NSNetService*)serviceAtIndex:(int)i {
  return (NSNetService*)[self.services objectAtIndex:i];
}

-(BOOL)hasService:(NSNetService*)service {
  return [self.services containsObject:service];
}

-(void)addService:(NSNetService*)service {
	if (![self hasService:service]) {
		[self.services addObject:service];
		[self.services sortUsingSelector:@selector(compareByTypeAndName:)];
	}
}

-(void)removeService:(NSNetService*)service {
  // NSLog(@"removing %@ from %@", service, self.services);
  [self.services removeObject:service];
}


- (BOOL) isEqual: (id) otherObject {
  BOOL result = NO;
  if ([otherObject isKindOfClass:[self class]]) {
    result = [((Host*)otherObject).hostname isEqualToString:self.hostname];
  }
  return result;
}


-(int)compareByName:(Host*)host {
  return [[self name] localizedCaseInsensitiveCompare:[host name]];
}

-(void)dealloc {
  [hostname release];
  [ip release];
  [services release];
  [super dealloc];
}

@end
