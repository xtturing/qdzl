//
//  QDMapViewController.m
//  qdzl
//
//  Created by xtturing on 14-9-19.
//
//

#import "QDMapViewController.h"
#import "Reachability.h"
#import "UINavigationBar+customBar.h"
#import "QDSearchViewController.h"
#import "QDSettingViewController.h"
#import "QDEditViewController.h"
#import "CLLocation+Sino.h"
#import "QDSearchDetailViewController.h"

#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#define BASE_MAP_URL @"http://27.223.74.180:6080/arcgis/rest/services/QD/SJDT/MapServer"

@interface QDMapViewController ()<UISearchBarDelegate>{
    AGSGraphic * startGra;
}

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
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    _reach= [Reachability reachabilityForInternetConnection];
    [_reach startNotifier];
    [self updateInterfaceWithReachability:_reach];
    self.mapView.layerDelegate = self;
    self.mapView.calloutDelegate=self;
    self.mapView.touchDelegate = self;
    self.graphicsLayer = [AGSGraphicsLayer graphicsLayer];
	[self.mapView addMapLayer:self.graphicsLayer withName:@"graphicsLayer"];
    self.title = @"返回";
    
    self.navigationItem.title = @"黄岛治理";
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setImage:[UIImage imageNamed:@"qd_search"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
    leftBtn.frame = CGRectMake(0, 0, 32, 32);
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setImage:[UIImage imageNamed:@"qd_setting"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(setting:) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.frame = CGRectMake(0, 0, 32, 32);
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ShowEventInMap:) name:@"ShowEventInMap" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RemoveEventInMap:) name:@"RemoveEventInMap" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addLocalTileLayer:) name:@"addLocalTileLayer" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLocalTileLayer:) name:@"removeLocalTileLayer" object:nil];
//    [self.navigationController.navigationBar customNavigationBar];
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

-(void)viewDidLayoutSubviews{
    [_editBtn setFrame:CGRectMake(137,( [UIScreen mainScreen].bounds.size.height> 480)?434:364, 48, 48)];
}

#pragma mark -IBAction

-(IBAction)gps:(id)sender{
    if(self.mapView.gps.enabled){
        [self gpsLocation];
    }else {
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
-(void)search:(id)sender{
    QDSearchViewController *searchViewController = [[QDSearchViewController alloc] initWithNibName:@"QDSearchViewController" bundle:nil];
    [self.navigationController pushViewController:searchViewController animated:YES];
}
-(void)setting:(id)sender{
    QDSettingViewController *settingViewController = [[QDSettingViewController alloc] initWithNibName:@"QDSettingViewController" bundle:nil];
    [self.navigationController pushViewController:settingViewController animated:YES];
}
-(IBAction)zoomIn:(id)sender{
    [self.mapView zoomIn:YES];
}
-(IBAction)zoomOut:(id)sender{
    [self.mapView zoomOut:YES];
}
-(IBAction)edit:(id)sender{
    QDEditViewController *editViewController = [[QDEditViewController alloc] initWithNibName:@"QDEditViewController" bundle:nil];
    editViewController.gpsPoint =(AGSPoint *)startGra.geometry;
    [self.navigationController pushViewController:editViewController animated:YES];
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

- (void)ShowEventInMap:(NSNotification *)notification{
    [self ShowEventInMap];
}

- (void)RemoveEventInMap:(NSNotification *)notification{
    [self.graphicsLayer removeAllGraphics];
    [self.graphicsLayer dataChanged];
}

- (void)addLocalTileLayer:(NSNotification *)notification{
    NSString *fileName = [notification.userInfo objectForKey:@"name"];
    [self addLocalTileLayerWithName:fileName];
}

- (void)addLocalTileLayerWithName:(NSString *)fileName{
    NSString *name = @"LocalTiledLayer";
    NSString *extension = @"tpk";
    if(![self hasAddLocalLayer:name] && [[fileName pathExtension] isEqualToString:extension]){
        AGSLocalTiledLayer *localTileLayer = [AGSLocalTiledLayer localTiledLayerWithName:fileName];
        if(localTileLayer != nil){
            [self.mapView reset];
            [self.mapView addMapLayer:localTileLayer withName:name];
            [self.mapView zoomIn:YES];
            // Do any additional setup after loading the view from its nib.
            
        }
    }else{
        [self.mapView removeMapLayerWithName:name];
    }
}

- (void)removeLocalTileLayer:(NSNotification *)notification{
    NSString *name = @"LocalTiledLayer";
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

- (void)ShowEventInMap{
    [self.graphicsLayer removeAllGraphics];
    [self.mapView removeMapLayerWithName:@"graphicsLayer"];
    self.graphicsLayer = [AGSGraphicsLayer graphicsLayer];
	[self.mapView addMapLayer:self.graphicsLayer withName:@"graphicsLayer"];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSMutableArray *uids = [ud objectForKey:@"UID"];
    if(!uids){
        return;
    }
    for (NSString *uuid in uids) {
        NSMutableDictionary *dic = [ud objectForKey:uuid];
        if(!dic){
            return;
        }
        AGSGraphic * pointgra= nil;
        AGSPoint *point =	[AGSPoint pointWithX:[[dic objectForKey:@"Y"] floatValue]  y: [[dic objectForKey:@"X"] floatValue] spatialReference:nil];
        if(point.x == 0 || point.y == 0 ){
            continue;
        }
        NSArray *tipkey=[[NSArray alloc]initWithObjects:@"uuid",@"SJMS",@"SSGQ",@"SJWZ",nil];
        NSArray *tipvalue=[[NSArray alloc]initWithObjects:uuid,[dic objectForKey:@"SJMS"],[dic objectForKey:@"SSGQ"],[dic objectForKey:@"SJWZ"],nil];
        NSMutableDictionary * tips=[[NSMutableDictionary alloc]initWithObjects:tipvalue forKeys:tipkey];
        
        AGSPictureMarkerSymbol * dian = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"gps_red"];
        pointgra = [AGSGraphic graphicWithGeometry:point symbol:nil attributes:tips infoTemplateDelegate:self];
        dian.size = CGSizeMake(48,48);
        dian.yoffset = 24;
        pointgra.symbol = dian;
        [self.graphicsLayer addGraphic:pointgra];
        [self.graphicsLayer dataChanged];
    }
}
#pragma mark AGSMapViewLayerDelegate methods

-(void) mapViewDidLoad:(AGSMapView*)mapView {
    if(self.mapView.gps.enabled){
        [self performSelector:@selector(gpsLocation) withObject:nil afterDelay:2.0f];
    }else {
        [self.mapView.gps start];
        return;
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if([[ud objectForKey:@"SHOW_EVENT"] isEqualToString:@"1"]){
        [self ShowEventInMap];
    }
}
- (void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *)graphics{
    [self addStartPoint:mappoint];
}
#pragma mark - AGSMapViewCalloutDelegate

- (BOOL)mapView:(AGSMapView *)mapView shouldShowCalloutForGraphic:(AGSGraphic *)graphic{
    self.mapView.callout.customView = nil;
    self.mapView.callout.title = [graphic.attributes objectForKey:@"SSGQ"];
    self.mapView.callout.detail = [NSString stringWithFormat:@"%@:%@",[graphic.attributes objectForKey:@"SJMS"],[graphic.attributes objectForKey:@"SJWZ"]];
    self.mapView.callout.titleColor=[UIColor whiteColor];
    self.mapView.callout.autoAdjustWidth=NO;
    self.mapView.callout.cornerRadius=2;
    self.mapView.callout.accessoryButtonHidden = NO;
    self.mapView.callout.accessoryButtonImage = [UIImage imageNamed:@"b3.png"];
    return YES;
}
- (void)mapView:(AGSMapView *)mapView didClickCalloutAccessoryButtonForGraphic:(AGSGraphic *)graphic{
    if([[graphic.attributes objectForKey:@"uuid"] length] > 0){
        QDSearchDetailViewController *searchDetailViewController = [[QDSearchDetailViewController alloc] initWithNibName:@"QDSearchDetailViewController" bundle:nil];
        searchDetailViewController.uid = [graphic.attributes objectForKey:@"uuid"];
        [self.navigationController pushViewController:searchDetailViewController animated:YES];
    }
}

- (void)gpsLocation{
    [self.mapView centerAtPoint:self.mapView.gps.currentPoint animated:YES];
    [self.mapView centerAtPoint:self.mapView.gps.currentPoint animated:YES];
    CLLocation *loc = [self.mapView.gps.currentLocation locationMarsFromEarth];
    if(loc.coordinate.longitude >0 && loc.coordinate.latitude > 0){
        AGSPoint *mappoint = [[AGSPoint alloc] initWithX:loc.coordinate.longitude y:loc.coordinate.latitude spatialReference:self.mapView.spatialReference];
        [self addStartPoint:mappoint];
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
        [self.mapView reset];
        AGSTiledMapServiceLayer *tileLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:[NSURL URLWithString:BASE_MAP_URL]];
        [self.mapView addMapLayer:tileLayer withName:@"tileLayer"];
        [self.mapView zoomIn:YES];
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
