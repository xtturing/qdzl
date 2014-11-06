//
//  QDMapLocationViewController.m
//  qdzl
//
//  Created by xtturing on 14-10-19.
//
//

#import "QDMapLocationViewController.h"
#import "Reachability.h"
#import "CLLocation+Sino.h"

#define BASE_MAP_URL @"http://27.223.74.180:6080/arcgis/rest/services/QD/SJDT/MapServer"

@interface QDMapLocationViewController (){
    AGSGraphic * startGra;
}
@property(nonatomic, strong) Reachability *reach;
@end

@implementation QDMapLocationViewController

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
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    UILabel *_tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 60)];
    _tipLabel.textColor = [UIColor orangeColor];
    _tipLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    _tipLabel.font =[UIFont systemFontOfSize:17];
    _tipLabel.numberOfLines = 2;
    _tipLabel.text = @"请在地图中\"点击\"选择你要上报事件的位置或者点击图标自动获取你当前的位置";
    [self.view addSubview:_tipLabel];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    _reach= [Reachability reachabilityForInternetConnection];
    [_reach startNotifier];
    [self updateInterfaceWithReachability:_reach];
    self.mapView.layerDelegate = self;
    self.mapView.touchDelegate = self;
    self.graphicsLayer = [AGSGraphicsLayer graphicsLayer];
	[self.mapView addMapLayer:self.graphicsLayer withName:@"graphicsLayer"];
    self.navigationItem.title = @"获取位置";
    UIBarButtonItem *right = [[UIBarButtonItem alloc]  initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(sendAction)];
    self.navigationItem.rightBarButtonItem = right;
    // Do any additional setup after loading the view from its nib.
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.mapView = nil;
    if(self.mapView.gps.enabled){
        [self.mapView.gps stop];
    }
}
- (void)viewDidUnload {
    //Stop the GPS, undo the map rotation (if any)
    if(self.mapView.gps.enabled){
        [self.mapView.gps stop];
    }
}

-(void)viewDidLayoutSubviews{
    [_editBtn setFrame:CGRectMake(137,( [UIScreen mainScreen].bounds.size.height> 480)?434:364, 48, 48)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)sendAction{
    
    [self.navigationController popViewControllerAnimated:YES];
    if(startGra){
        if(_delegate && [_delegate respondsToSelector:@selector(didSelectedMapLocation:)]){
            [_delegate didSelectedMapLocation:(AGSPoint *)startGra.geometry];
        }
    }else{
        if(_delegate && [_delegate respondsToSelector:@selector(didSelectedMapLocation:)]){
            [_delegate didSelectedMapLocation:[self.mapView toMapPoint:self.mapView.center]];
        }
    }
    
}


-(void)addStartPoint:(AGSPoint *)mappoint{
    if(startGra){
        [self.graphicsLayer removeGraphic:startGra];
        startGra = nil;
    }
    AGSPictureMarkerSymbol * dian = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"qidian"];
    dian.size = CGSizeMake(32,47);
    if(mappoint.x == 0 || mappoint.y == 0 ){
        return;
    }
    startGra = [AGSGraphic graphicWithGeometry:mappoint symbol:nil attributes:nil infoTemplateDelegate:nil];
    dian.yoffset=24;
    startGra.symbol = dian;
    [self.graphicsLayer addGraphic:startGra];
    [self.graphicsLayer dataChanged];
}
-(IBAction)gps:(id)sender{
    [self getGPS];
}

-(void)getGPS{
    if(self.mapView.gps.enabled){
        [self.mapView centerAtPoint:self.mapView.gps.currentPoint animated:YES];
        CLLocation *loc = [self.mapView.gps.currentLocation locationMarsFromEarth];
        if(loc.coordinate.longitude >0 && loc.coordinate.latitude > 0){
            AGSPoint *mappoint = [[AGSPoint alloc] initWithX:loc.coordinate.longitude y:loc.coordinate.latitude spatialReference:self.mapView.spatialReference];
            [self addStartPoint:mappoint];
        }
    }else{
        [self.mapView.gps start];
        UIAlertView *alert;
        alert = [[UIAlertView alloc]
                 initWithTitle:@"黄岛治理"
                 message:@"需要你的位置信息,请在设置－隐私－位置－黄岛治理 开启定位服务"
                 delegate:nil cancelButtonTitle:nil
                 otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
}
#pragma mark AGSMapViewLayerDelegate methods

-(void) mapViewDidLoad:(AGSMapView*)mapView {
    [self performSelector:@selector(getGPS) withObject:nil afterDelay:2.0f];
}
- (void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *)graphics{
    [self addStartPoint:mappoint];
}
- (void)addLocalTileLayerWithName:(NSString *)fileName{
    NSString *name = [fileName stringByDeletingPathExtension];
    NSString *extension = @"tpk";
    if(![self hasAddLocalLayer:name] && [[fileName pathExtension] isEqualToString:extension]){
        AGSLocalTiledLayer *localTileLayer = [AGSLocalTiledLayer localTiledLayerWithName:fileName];
        if(localTileLayer != nil){
            [self.mapView addMapLayer:localTileLayer withName:name];
            // Do any additional setup after loading the view from its nib.
            
        }
    }else{
        [self.mapView removeMapLayerWithName:name];
    }
}
- (BOOL)hasAddLocalLayer:(NSString *)name{
    for(AGSTiledLayer *layer in self.mapView.mapLayers){
        if([layer isKindOfClass:[AGSLocalTiledLayer class]] && [layer.name isEqualToString:name]){
            return YES;
        }
    }
    return NO;
}

#pragma mark -reachability

-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    [self updateInterfaceWithReachability: curReach];
    
}
- (void) updateInterfaceWithReachability: (Reachability*) curReach{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if([[ud objectForKey:@"SHOW_DOWNLOAD"] isEqualToString:@"1"]){
        [self addLocalTileLayerWithName:@"HDZZ.tpk"];
        [self.mapView.gps start];
        return;
    }
    if([curReach isReachable])
    {
        if(![curReach isReachableViaWiFi]){
            [self showMessageWithAlert:@"使用2G/3G 网络,会产生运营商流量费用，请选择WIFI环境使用功能"];
        }
        AGSTiledMapServiceLayer *tileLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:[NSURL URLWithString:BASE_MAP_URL]];
        [self.mapView addMapLayer:tileLayer withName:@"tileLayer"];
        [self.mapView.gps start];
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
