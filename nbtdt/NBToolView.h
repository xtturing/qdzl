//
//  NBToolView.h
//  tdtnb
//
//  Created by xtturing on 14-7-27.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol toolDelegate <NSObject>

- (void)toolButtonClick:(int)buttonTag;

@end

@interface NBToolView : UIView

@property (nonatomic,assign) id<toolDelegate> delegate;
@property (nonatomic, strong) UILabel *label;

@end
