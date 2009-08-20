//
//  NSNetService+FlameExtras.m
//  FlameTouch
//
//  Created by Tom Insam on 26/11/2008.
//  Copyright 2008 jerakeen.org. All rights reserved.
//

#import "NSNetService+FlameExtras.h"
#include <netinet/in.h>
#include <arpa/inet.h>

@implementation NSNetService (FlameExtras)

-(NSComparisonResult) compareByType:(NSNetService*)service {
	NSString* myName = self.humanReadableType;
	if ([myName rangeOfString:@"_" options:NSLiteralSearch | NSAnchoredSearch].location == 0) {
		myName = [myName substringFromIndex:1];
	}
	NSString* theirName = service.humanReadableType;
	if ([theirName rangeOfString:@"_" options:NSLiteralSearch | NSAnchoredSearch].location == 0) {
		theirName = [theirName substringFromIndex:1];
	}
	
	return [myName localizedCaseInsensitiveCompare:theirName];
}


-(NSComparisonResult) compareByTypeAndName:(NSNetService*)service {
  NSComparisonResult result = [self compareByType:service];
  if (result == NSOrderedSame) {
    result = [[self name] localizedCaseInsensitiveCompare:[service name]];
  }
  return result;
}


-(NSComparisonResult) compareByHostAndTitle: (NSNetService*) service {
  NSComparisonResult result = [self.hostnamePlus compare:service.hostnamePlus options:NSLiteralSearch];
  if (result == NSOrderedSame) {
    result = [self.name localizedCaseInsensitiveCompare:service.name];
  }
  return result;
}


-(NSString*) humanReadableType {
	NSString * result = [[NSBundle mainBundle] localizedStringForKey:[self type] value:nil table:@"ServiceNames"];
	return result;
}


-(BOOL) humanReadableTypeIsDistinct {
	return ![self.humanReadableType isEqualToString: [self type]];
}


-(NSString*) hostnamePlus {
	NSString * result = [self hostName];
	if (result == nil) {
		struct sockaddr_in* sock = (struct sockaddr_in*)[((NSData*)[[self addresses] objectAtIndex:0]) bytes];
		result = [NSString stringWithFormat:@"%s", inet_ntoa(sock->sin_addr)];
	}
	return result;
}


/*
 Returns all-caps protocol type, e.g. TCP in most cases.
*/
- (NSString*) protocolType {
  NSRange protocolRange = NSMakeRange([self.type length] - 4 , 3);
	NSString* protocolType = [[self.type substringWithRange:protocolRange] uppercaseString];
  return protocolType;
}


/*
 Returns a string with the port number for TCP ports.
 Returns a string with the protocol and the port number for non-TCP ports.
*/
- (NSString*) portInfo {
	NSString* portInfo;
  if ([self.protocolType isEqualToString:@"TCP"]) {
    // don't mention the TCP protocol
    portInfo = [NSString stringWithFormat:NSLocalizedString(@"%i", @"format for printing the port number"), [self port]];
  }
  else {
    portInfo = [NSString stringWithFormat:NSLocalizedString(@"%@ %i", @"format for printing the protocol type and port number"), self.protocolType, [self port]];
  }
	return portInfo;
}

@end
