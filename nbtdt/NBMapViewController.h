//
//  NBMapViewController.h
//  tdtnb
//
//  Created by xtturing on 14-7-27.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGSGoogleMapLayer.h"
#import "iflyMSC/IFlyRecognizerViewDelegate.h"
@class IFlyRecognizerView;
@interface NBMapViewController : UIViewController<UITabBarDelegate,AGSMapViewLayerDelegate,AGSMapViewCalloutDelegate,UITextViewDelegate,IFlyRecognizerViewDelegate>

@property (nonatomic, strong) IBOutlet UITabBar *bar;
@property (nonatomic, strong) IBOutlet AGSMapView *mapView;
@property (nonatomic, strong) AGSGoogleMapLayer *tileMapLayer;
@property (nonatomic, strong) AGSGoogleMapLayer *wmsMapLayer;
@property (nonatomic, strong) AGSDynamicMapServiceLayer *dynamicMapLayer;
@property (nonatomic, strong) AGSSketchGraphicsLayer *sketchLayer;
@property (nonatomic, strong) AGSGraphicsLayer *graphicsLayer;
@property (nonatomic,strong) IFlyRecognizerView *iflyRecognizerView;

-(IBAction)gps:(id)sender;
-(IBAction)list:(id)sender;
-(IBAction)prev:(id)sender;
-(IBAction)next:(id)sender;
-(IBAction)changeMap:(id)sender;
-(IBAction)singleLine:(id)sender;
-(IBAction)zoomIn:(id)sender;
-(IBAction)zoomOut:(id)sender;



@end
