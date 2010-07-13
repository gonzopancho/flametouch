//
//  LargeTableCell.m
//  FlameTouch
//
//  Created by Tom Insam on 02/07/2010.
//  Copyright 2010 jerakeen.org. All rights reserved.
//

#import "CustomTableCell.h"


@implementation CustomTableCell

static CGFloat HEIGHT = 60;
static CGFloat LABELHEIGHT = 24;
static CGFloat XPADDING = 10;


+(CGFloat) height;
{
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    return HEIGHT;
  } else {
    return 50;
  }
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
{
  if ((self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier])) {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      self.frame = CGRectMake(0, 0, 0, HEIGHT);
    }
  }
  return self;
}

- (void)layoutSubviews;
{
  [super layoutSubviews];
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
  
    self.textLabel.frame = CGRectMake(XPADDING, 5, self.frame.size.width - 100, LABELHEIGHT);
    self.textLabel.textColor = [UIColor whiteColor];

    //self.textLabel.font = [UIFont systemFontOfSize:14]; //  fontWithName:@"Palatino" size:16];

    self.detailTextLabel.frame = CGRectMake(XPADDING, (HEIGHT / 2) + 1, self.frame.size.width - 20, LABELHEIGHT);
    self.detailTextLabel.textColor = [UIColor lightGrayColor];

    //self.detailTextLabel.font = [UIFont systemFontOfSize:12]; // [UIFont fontWithName:@"Palatino" size:12];
    
    //self.backgroundColor = [UIColor lightGrayColor];

  }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
  // Configure the view for the selected state
}


- (void)dealloc {
  [super dealloc];
}


@end
