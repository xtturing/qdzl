//
//  QDMapViewController.h
//  qdzl
//
//  Created by xtturing on 14-9-19.
//
//

#import <UIKit/UIKit.h>

@interface QDMapViewController : UIViewController<AGSMapViewLayerDelegate,AGSMapViewCalloutDelegate>

@property (nonatomic, strong) IBOutlet AGSMapView *mapView;

@end
