//
//  QDMapViewController.h
//  qdzl
//
//  Created by xtturing on 14-9-19.
//
//

#import <UIKit/UIKit.h>

@interface QDMapViewController : UIViewController<AGSMapViewLayerDelegate,AGSCalloutDelegate,AGSMapViewTouchDelegate>

@property (nonatomic, strong) IBOutlet AGSMapView *mapView;
@property (nonatomic, strong) IBOutlet UIButton *editBtn;
@property (nonatomic, strong) AGSGraphicsLayer *graphicsLayer;

-(IBAction)gps:(id)sender;
-(IBAction)zoomIn:(id)sender;
-(IBAction)zoomOut:(id)sender;
-(IBAction)edit:(id)sender;
@end
