//
//  QDMapViewController.m
//  qdzl
//
//  Created by xtturing on 14-9-19.
//
//

#import "QDMapViewController.h"
#import "Reachability.h"

#define BASE_MAP_URL @"http://218.58.61.50:6080/arcgis/rest/services/QD/SJDT/MapServer"

@interface QDMapViewController ()

@property(nonatomic, strong) Reachability *reach;

@end

@implementation QDMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    _reach= [Reachability reachabilityForInternetConnection];
    [_reach startNotifier];
    [self updateInterfaceWithReachability:_reach];
    self.mapView.layerDelegate = self;
    self.mapView.calloutDelegate=self;
    
    self.navigationItem.title = @"黄岛治理";
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setImage:[UIImage imageNamed:@"qd_search"] forState:UIControlStateNormal];
    leftBtn.frame = CGRectMake(0, 0, 32, 32);
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setImage:[UIImage imageNamed:@"qd_setting"] forState:UIControlStateNormal];
    rightBtn.frame = CGRectMake(0, 0, 32, 32);
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    // Do any additional setup after loading the view from its nib.
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.mapView = nil;
}
- (void)viewDidUnload {
    //Stop the GPS, undo the map rotation (if any)
    if(self.mapView.gps.enabled){
        [self.mapView.gps stop];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -IBAction

-(IBAction)gps:(id)sender{
    if(self.mapView.gps.enabled){
        [self.mapView centerAtPoint:self.mapView.gps.currentPoint animated:YES];
    }else {
        [self.mapView.gps start];
        return;
    }
}
-(IBAction)search:(id)sender{
    
}
-(IBAction)setting:(id)sender{
    
}
-(IBAction)zoomIn:(id)sender{
    [self.mapView zoomIn:YES];
}
-(IBAction)zoomOut:(id)sender{
    [self.mapView zoomOut:YES];
}
-(IBAction)edit:(id)sender{
    
}

- (void)zooMapToLevel:(int)level withCenter:(AGSPoint *)point{
    if(self.mapView.mapLayers.count > 0){
        AGSTiledLayer *tileLayer = [self.mapView.mapLayers objectAtIndex:0];
        if([tileLayer isKindOfClass:[AGSTiledMapServiceLayer class]]){
            AGSTiledMapServiceLayer *layer = (AGSTiledMapServiceLayer *)tileLayer;
            AGSLOD *lod = [layer.tileInfo.lods objectAtIndex:level];
            [self.mapView zoomToResolution:lod.resolution withCenterPoint:point animated:YES];
        }
    }
    
    
}

- (void)addLocalTileLayer:(NSNotification *)notification{
    NSString *fileName = [notification.userInfo objectForKey:@"name"];
    [self addLocalTileLayerWithName:fileName];
}

- (void)addLocalTileLayerWithName:(NSString *)fileName{
    NSString *name = [fileName stringByDeletingPathExtension];
    NSString *extension = @"tpk";
    if(![self hasAddLocalLayer:name] && [[fileName pathExtension] isEqualToString:extension]){
        AGSLocalTiledLayer *localTileLayer = [AGSLocalTiledLayer localTiledLayerWithName:fileName];
        if(localTileLayer != nil){
            [self.mapView addMapLayer:localTileLayer withName:name];
            [self zooMapToLevel:13 withCenter:[AGSPoint pointWithX:121.55629730245123 y:29.874820709509887 spatialReference:self.mapView.spatialReference]];
            [self.mapView zoomIn:YES];
            // Do any additional setup after loading the view from its nib.
            
        }
    }else{
        [self.mapView removeMapLayerWithName:name];
    }
}

- (void)removeLocalTileLayer:(NSNotification *)notification{
    NSString *fileName = [notification.userInfo objectForKey:@"name"];
    NSString *name = [fileName stringByDeletingPathExtension];
    [self.mapView removeMapLayerWithName:name];
    [self updateInterfaceWithReachability:_reach];
}

- (BOOL)hasAddLocalLayer:(NSString *)name{
    for(AGSTiledLayer *layer in self.mapView.mapLayers){
        if([layer isKindOfClass:[AGSLocalTiledLayer class]] && [layer.name isEqualToString:name]){
            return YES;
        }
    }
    return NO;
}
#pragma mark AGSMapViewLayerDelegate methods

-(void) mapViewDidLoad:(AGSMapView*)mapView {
    [self.mapView.gps start];
    
}

#pragma mark -reachability

-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    [self updateInterfaceWithReachability: curReach];
    
}
- (void) updateInterfaceWithReachability: (Reachability*) curReach{
    if([curReach isReachable])
    {
        if(![curReach isReachableViaWiFi]){
            [self showMessageWithAlert:@"使用2G/3G 网络,会产生运营商流量费用，请选择WIFI环境使用功能"];
        }
        AGSTiledMapServiceLayer *tileLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:[NSURL URLWithString:BASE_MAP_URL]];
        [self.mapView addMapLayer:tileLayer withName:@"tileLayer"];
    }
    else
    {
        [self showMessageWithAlert:@"网络链接断开"];
        
    }
}

#pragma mark - UIAlertView

- (void)showMessageWithAlert:(NSString *)message{
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"黄岛治理" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    [view show];
}
@end