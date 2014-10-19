//
//  QDMapLocationViewController.h
//  qdzl
//
//  Created by xtturing on 14-10-19.
//
//

#import <UIKit/UIKit.h>

@interface QDMapLocationViewController : UIViewController<AGSMapViewLayerDelegate,AGSMapViewCalloutDelegate>
@property (nonatomic, strong) IBOutlet AGSMapView *mapView;
@end
