//
//  QDMapLocationViewController.h
//  qdzl
//
//  Created by xtturing on 14-10-19.
//
//

#import <UIKit/UIKit.h>
@protocol mapLocationDelegate <NSObject>

@optional
- (void)didSelectedMapLocation:(AGSPoint *)point;

@end
@interface QDMapLocationViewController : UIViewController<AGSMapViewLayerDelegate,AGSMapViewCalloutDelegate,AGSMapViewTouchDelegate>
@property (nonatomic, strong) IBOutlet AGSMapView *mapView;
@property (nonatomic, strong) AGSGraphicsLayer *graphicsLayer;
@property (nonatomic, strong) IBOutlet UIButton *editBtn;
@property (nonatomic,assign) id<mapLocationDelegate> delegate;
@end
