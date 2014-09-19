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

-(IBAction)gps:(id)sender;
-(IBAction)search:(id)sender;
-(IBAction)setting:(id)sender;
-(IBAction)zoomIn:(id)sender;
-(IBAction)zoomOut:(id)sender;
-(IBAction)edit:(id)sender;
@end
