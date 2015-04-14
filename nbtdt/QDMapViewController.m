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

@interface QDMapViewController ()<UISearchBarDelegate,UIActionSheetDelegate>{
    AGSGraphic *startGra;
    NSString *showViewId;
}

@property(nonatomic, strong) Reachability *reach;
@property (nonatomic,strong) UILabel *tipLabel;
@property (nonatomic,strong) UIView *showView;
@property (nonatomic,strong) UILabel *showTitle;
@property (nonatomic,strong) UILabel *showDetailTitle;

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
    self.mapView.callout.delegate=self;
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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(startGra){
        [self.graphicsLayer removeGraphic:startGra];
        startGra = nil;
        [self.graphicsLayer refresh];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.mapView = nil;
}
- (void)viewDidUnload {
    //Stop the GPS, undo the map rotation (if any)
    if([self.mapView.locationDisplay isDataSourceStarted]){
        [self.mapView.locationDisplay stopDataSource];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews{
//    [_editBtn setFrame:CGRectMake(137,( [UIScreen mainScreen].bounds.size.height> 480)?434:364, 48, 48)];
}

#pragma mark -IBAction

-(IBAction)gps:(id)sender{
//    if(self.mapView.gps.enabled){
        [self gpsLocation];
//    }else {
//        [self.mapView.gps start];
//        UIAlertView *alert;
//        alert = [[UIAlertView alloc]
//                 initWithTitle:@"黄岛治理"
//                 message:@"需要你的位置信息,请在设置－隐私－位置－黄岛治理 开启定位服务"
//                 delegate:nil cancelButtonTitle:nil
//                 otherButtonTitles:@"确定", nil];
//        [alert show];
//
//        return;
//    }
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
    [self openMenu];
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
    [self.graphicsLayer refresh];
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
        pointgra = [AGSGraphic graphicWithGeometry:point symbol:nil attributes:tips];
        dian.size = CGSizeMake(48,48);
        pointgra.symbol = dian;
        [self.graphicsLayer addGraphic:pointgra];
        [self.graphicsLayer refresh];
    }
}
#pragma mark AGSMapViewLayerDelegate methods

-(void) mapViewDidLoad:(AGSMapView*)mapView {
    [self.mapView.locationDisplay startDataSource];
    self.mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeDefault;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if([[ud objectForKey:@"SHOW_EVENT"] isEqualToString:@"1"]){
        [self ShowEventInMap];
    }
}
- (void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *)graphics{
    self.mapView.touchDelegate = nil;
    [self addStartPoint:mappoint];
    if(_tipLabel && !_tipLabel.hidden){
        _tipLabel.hidden = YES;
    }
    [self performSelector:@selector(goEditView:) withObject:(AGSPoint *)startGra.geometry afterDelay:0.7f];
}

- (UIView *)showView{
    if(!_showView){
        _showView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 130)];
        _showView.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showEvent:)];
        [_showView addGestureRecognizer:tapGesture];
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"b3"]];
        image.frame =CGRectMake(250, 10, 30, 30);
        [_showView addSubview:image];
    }
    [_showView addSubview:self.showTitle];
    [_showView addSubview:self.showDetailTitle];
    return _showView;
}

- (UILabel *)showTitle{
    if(!_showTitle){
        _showTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 240, 40)];
        _showTitle.textColor = [UIColor blackColor];
        _showTitle.backgroundColor = [UIColor clearColor];
        _showTitle.textAlignment = NSTextAlignmentLeft;
        _showTitle.font =[UIFont systemFontOfSize:16];
        _showTitle.numberOfLines = 2;
    }
    return _showTitle;
}

- (UILabel *)showDetailTitle{
    if(!_showDetailTitle){
        _showDetailTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 45, 260, 85)];
        _showDetailTitle.textColor = [UIColor lightGrayColor];
        _showDetailTitle.backgroundColor = [UIColor clearColor];
        _showDetailTitle.textAlignment = NSTextAlignmentLeft;
        _showDetailTitle.font =[UIFont systemFontOfSize:13];
        _showDetailTitle.numberOfLines = 4;
    }
    return _showDetailTitle;
}

- (void)showEvent:(UITapGestureRecognizer *)gesture{
    if(showViewId && showViewId.length > 0){
        QDSearchDetailViewController *searchDetailViewController = [[QDSearchDetailViewController alloc] initWithNibName:@"QDSearchDetailViewController" bundle:nil];
        searchDetailViewController.uid = showViewId;
        [self.navigationController pushViewController:searchDetailViewController animated:YES];
    }
}
#pragma mark - AGSMapViewCalloutDelegate

-(BOOL)callout:(AGSCallout*)callout willShowForFeature:(id<AGSFeature>)feature layer:(AGSLayer<AGSHitTestable>*)layer mapPoint:(AGSPoint *)mapPoint{
    AGSGraphic* graphic = (AGSGraphic*)feature;
    self.mapView.touchDelegate = nil;
    self.mapView.callout.customView =self.showView;
    showViewId = [graphic attributeForKey:@"uuid"];
    self.showTitle.text = [graphic attributeForKey:@"SJMS"];
    self.showDetailTitle.text = [NSString stringWithFormat:@"上报事件管区:%@\n%@",[graphic attributeForKey:@"SSGQ"],[graphic attributeForKey:@"SJWZ"]];
    return YES;
}

- (void) didClickAccessoryButtonForCallout:(AGSCallout *)callout{
    AGSGraphic* graphic = (AGSGraphic*)callout.representedFeature;
    self.mapView.touchDelegate = nil;
    if([[graphic attributeForKey:@"uuid"] length] > 0){
        QDSearchDetailViewController *searchDetailViewController = [[QDSearchDetailViewController alloc] initWithNibName:@"QDSearchDetailViewController" bundle:nil];
        searchDetailViewController.uid = [graphic attributeForKey:@"uuid"];
        [self.navigationController pushViewController:searchDetailViewController animated:YES];
    }
}

- (void)gpsLocation{
    [self.mapView centerAtPoint:self.mapView.locationDisplay.mapLocation animated:YES];
//    CLLocation *loc = [self.mapView.gps.currentLocation locationMarsFromEarth];
//    if(loc.coordinate.longitude >0 && loc.coordinate.latitude > 0){
//        AGSPoint *mappoint = [[AGSPoint alloc] initWithX:loc.coordinate.longitude y:loc.coordinate.latitude spatialReference:self.mapView.spatialReference];
//        [self addStartPoint:mappoint];
//    }
}
-(void)addStartPoint:(AGSPoint *)mappoint{
    if(startGra){
        [self.graphicsLayer removeGraphic:startGra];
        startGra = nil;
    }
    AGSPictureMarkerSymbol * dian = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"qd_gps"];
    dian.size = CGSizeMake(32,32);
    if(mappoint.x == 0 || mappoint.y == 0 ){
        return;
    }
    startGra = [AGSGraphic graphicWithGeometry:mappoint symbol:nil attributes:nil];
    startGra.symbol = dian;
    [self.graphicsLayer addGraphic:startGra];
    [self.graphicsLayer refresh];
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
        [self.mapView.locationDisplay startDataSource];
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
        [self.mapView.locationDisplay startDataSource];
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
-(void)openMenu{
    //在这里呼出下方菜单按钮项
    UIActionSheet *_myActionSheet = [[UIActionSheet alloc]
                                     initWithTitle:nil
                                     delegate:self
                                     cancelButtonTitle:@"取消"
                                     destructiveButtonTitle:nil
                                     otherButtonTitles:@"GPS定位点",@"手动选点", nil];
    //刚才少写了这一句
    [_myActionSheet showInView:self.view.window];
    
    
}
//下拉菜单的点击响应事件
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex == actionSheet.cancelButtonIndex){
        NSLog(@"取消");
    }
    switch (buttonIndex) {
        case 0:
            [self takeEditGps];
            break;
        case 1:
            [self takeEdit];
            break;
        default:
            break;
    }
}

- (void)takeEditGps{
    if(self.mapView.locationDisplay.mapLocation){
//        CLLocation *loc = [self.mapView.locationDisplay.mapLocation locationMarsFromEarth];
//        if(loc.coordinate.longitude >0 && loc.coordinate.latitude > 0){
//            AGSPoint *mappoint = [[AGSPoint alloc] initWithX:loc.coordinate.longitude y:loc.coordinate.latitude spatialReference:self.mapView.spatialReference];
//            [self goEditView:mappoint];
//        }
        [self goEditView:self.mapView.locationDisplay.mapLocation];
    }
    else {
        [self.mapView.locationDisplay startDataSource];
//        UIAlertView *alert;
//        alert = [[UIAlertView alloc]
//                 initWithTitle:@"黄岛治理"
//                 message:@"需要你的位置信息,请在设置－隐私－位置－黄岛治理 开启定位服务"
//                 delegate:nil cancelButtonTitle:nil
//                 otherButtonTitles:@"确定", nil];
//        [alert show];
//        return;
    }
}


-(void)takeEdit{
    self.mapView.touchDelegate =self;
    [self showTipView];
}

- (void)showTipView{
    if(!_tipLabel){
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 60)];
        _tipLabel.textColor = [UIColor orangeColor];
        _tipLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.font =[UIFont systemFontOfSize:18];
        _tipLabel.numberOfLines = 2;
        _tipLabel.text = @"请用\"单个\"手指\"点击\"地图，选择你要上报的事件点位置！";
        [self.view addSubview:_tipLabel];
    }
    if(_tipLabel.hidden){
        _tipLabel.hidden = NO;
    }
}

- (void)goEditView:(AGSPoint *)point{
    if(point && fabs(point.x) > 0 && fabs(point.y) > 0){
        QDEditViewController *editViewController = [[QDEditViewController alloc] initWithNibName:@"QDEditViewController" bundle:nil];
        editViewController.gpsPoint = point;
        [self.navigationController pushViewController:editViewController animated:YES];
    }
}

@end
