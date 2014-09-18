//
//  DowningCell.h
//  DownloadDemo
//
//  Created by Peter Yuen on 6/27/14.
//  Copyright (c) 2014 CocoaRush. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DowningCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblPercent;
@property (weak, nonatomic) IBOutlet UIButton *btnOperate;
@property(nonatomic,copy)void(^DowningCellOperateClick)(DowningCell *cell);
@property(nonatomic,copy)void(^DowningCellCancelClick)(DowningCell *cell);

- (IBAction)operateClick:(id)sender;
- (IBAction)cancelClick:(id)sender;


@end
