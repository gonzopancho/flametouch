/*
  ServiceDetailViewController.h
  FlameTouch

  Created by Tom Insam on 26/06/2009.
 
  
  Copyright (c) 2009 Sven-S. Porst, Tom Insam
  
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

@interface ServiceDetailViewController : UITableViewController {
  Host *host;
  NSNetService *service;
  NSArray * TXTRecordKeys;
  NSArray * TXTRecordValues;  
  BOOL hasOpenServiceButton;
}

@property (nonatomic, retain) Host* host;
@property (nonatomic, retain) NSNetService* service;
@property (nonatomic, retain) NSArray* TXTRecordKeys;
@property (nonatomic, retain) NSArray* TXTRecordValues;
@property BOOL hasOpenServiceButton;

-(id)initWithHost:(Host*)host service:(NSNetService*)service;

-(UITableViewCell *)propertyCellWithLabel:(NSString*) label andValue:(NSString*) value;
-(UITableViewCell*) standardPropertyCellForRow: (int) row;
-(UITableViewCell*) TXTRecordPropertyCellForRow: (int) row;
-(UITableViewCell *)actionCellForRow:(int)r;

@end
