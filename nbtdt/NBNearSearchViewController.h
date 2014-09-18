//
//  NBNearSearchViewController.h
//  tdtnb
//
//  Created by xtturing on 14-7-27.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iflyMSC/IFlyRecognizerViewDelegate.h"
@class IFlyRecognizerView;

@interface NBNearSearchViewController : UIViewController<IFlyRecognizerViewDelegate>

@property (nonatomic,strong) IBOutlet UIView *imageView;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic,strong) IFlyRecognizerView *iflyRecognizerView;

@end
