//
//  DowningCell.m
//  DownloadDemo
//
//  Created by Peter Yuen on 6/27/14.
//  Copyright (c) 2014 CocoaRush. All rights reserved.
//

#import "DowningCell.h"

@implementation DowningCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)operateClick:(id)sender {
    if(self.DowningCellOperateClick)
    {
        self.DowningCellOperateClick(self);
    }
}

- (IBAction)cancelClick:(id)sender {
    if(self.DowningCellCancelClick)
    {
        self.DowningCellCancelClick(self);
    }
}
@end
