//
//  QDEditViewController.m
//  qdzl
//
//  Created by xtturing on 14-9-28.
//
//

#import "QDEditViewController.h"
#import "cityManagerTableViewController.h"
#import "textInputViewController.h"
#import "MessagePhotoView.h"
#import "LCVoice.h"
#import "QDMapLocationViewController.h"
#import "XMLDictionary.h"
#import "ZipArchive.h"
#import "lame.h"
#import "dataHttpManager.h"
#import "MyMD5.h"


#define GET_POI @"http://27.223.74.180:6080/arcgis/rest/services/QD/getGQ/GPServer/getGQ"
#define MAP_SERVER @"http://27.223.74.180:6080/arcgis/rest/services/QD/POIHD/MapServer/0"

@interface QDEditViewController ()<UITableViewDelegate,cityManagerDelegate,textInputViewDelegate,MessagePhotoViewDelegate,mapLocationDelegate,AGSQueryTaskDelegate,AGSGeoprocessorDelegate,dataHttpDelegate,UIAlertViewDelegate>
@property(nonatomic,strong) LCVoice * voice;
@property (nonatomic,strong)  UIButton *rbutton;
@property (nonatomic,strong)  UIButton *lbutton;
@property (nonatomic,strong) AGSGeoprocessor *agp;
@property (nonatomic, strong) AGSQuery *query;
@property (nonatomic, strong) AGSQueryTask *queryTask;
@property (nonatomic,strong) NSString *mapLocationStr;
@property (nonatomic,strong) NSString *textMessage;
@property (nonatomic,strong) NSString *cityManagerName;
@property (nonatomic,strong) NSString *citytype;
@property (nonatomic,strong) NSString *uuidString;
@property (nonatomic,strong) MessagePhotoView *photoView;
@end

@implementation QDEditViewController

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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //创建文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //获取document路径,括号中属性为当前应用程序独享
        NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,      NSUserDomainMask, YES);
        NSString *documentDirectory = [directoryPaths objectAtIndex:0];
        [fileManager removeItemAtPath:[documentDirectory stringByAppendingPathComponent:@"uploadEvent"] error:nil];
    });
    self.uuidString = [self getUniqueStrByUUID];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.navigationItem.title = @"事件上报";
    UIBarButtonItem *right = [[UIBarButtonItem alloc]  initWithTitle:@"上传" style:UIBarButtonItemStylePlain target:self action:@selector(sendAction)];
    self.navigationItem.rightBarButtonItem = right;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.voice = [[LCVoice alloc] init];
    self.agp =  [AGSGeoprocessor geoprocessorWithURL:[NSURL URLWithString:GET_POI]];
    // set the delegate so we will be notified of delegate methods
    self.agp.delegate = self;
    self.agp.outputSpatialReference=[[AGSSpatialReference alloc] initWithWKID:4326 WKT:nil] ;
    self.agp.processSpatialReference = [[AGSSpatialReference alloc] initWithWKID:4326 WKT:nil] ;
    self.queryTask= [[AGSQueryTask alloc ] initWithURL:[NSURL URLWithString:MAP_SERVER]];
    self.queryTask.delegate =self;
    self.query = [AGSQuery query];
    self.query.outSpatialReference =[[AGSSpatialReference alloc] initWithWKID:4326 WKT:nil] ;
    self.query.outFields = [NSArray arrayWithObjects:@"*", nil];
    if(_gpsPoint){
        [self getMapLocationWithPoint:_gpsPoint];
    }else{
        [self performSelector:@selector(getLocation) withObject:nil afterDelay:1.0f];
    }
    _cityManagerName = @"城市管理";
    _textMessage = @"";
    _mapLocationStr =@"";
    // Do any additional setup after loading the view from its nib.
}
- (void)dealloc{
    _voice = nil;
    _photoView.delegate =nil;
    _photoView = nil;
    _queryTask.delegate = nil;
    _queryTask = nil;
    _agp.delegate =  nil;
    _agp = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [dataHttpManager getInstance].delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [dataHttpManager getInstance].delegate = nil;
}

- (void)sendAction{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(![self creatXml]){
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [self showMessageWithAlert:@"生成上报事件XML异常"];
            });
            return ;
        }
        if([self saveImages]){
            if([self audio_PCMtoMP3]){
                if([self saveInZip]){
                    if (![self sendSave]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD dismiss];
                            [self showMessageWithAlert:@"上报事件文件异常"];
                        });
                        return ;
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                        [self showMessageWithAlert:@"压缩上报事件文件异常"];
                    });
                    return ;
                }
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    [self showMessageWithAlert:@"转码声音文件异常"];
                });
                return ;
            }
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                 [SVProgressHUD dismiss];
                [self showMessageWithAlert:@"生成上报事件图片异常"];
            });
            return ;
        }
    });
    
    
}

- (BOOL)saveImages{
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //获取document路径,括号中属性为当前应用程序独享
    NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,      NSUserDomainMask, YES);
    NSString *documentDirectory = [directoryPaths objectAtIndex:0];
    //定义记录文件全名以及路径的字符串filePath
    NSString *imageDir = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"uploadEvent/%@",self.uuidString]];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:nil];
    }else{
        NSDirectoryEnumerator *direnum = [fileManager enumeratorAtPath:imageDir];
        NSString *filename ;
        while (filename = [direnum nextObject]) {
            if([filename.pathExtension isEqualToString:@"JPG"]){
                [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@",imageDir,filename] error:nil];
            }
        }

    }
    for(int i=0;i<_photoView.photoMenuItems.count;i++){
        UIImage *tempImg= nil;
        NSData *data = nil;
        NSString *filePath = nil;
        if([_photoView.photoMenuItems[i] isKindOfClass:[ALAsset class]]){
            ALAsset *asset=_photoView.photoMenuItems[i];
            tempImg=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
            data = UIImageJPEGRepresentation(tempImg, 0.0);
            filePath = [NSString stringWithFormat:@"%@/%@.JPG",imageDir,[NSString stringWithFormat:@"%.lf",[[NSDate date] timeIntervalSince1970]*1000]];
           
        }else if ([_photoView.photoMenuItems[i] isKindOfClass:[UIImage class]]){
            tempImg = _photoView.photoMenuItems[i];
         
            data = UIImageJPEGRepresentation(tempImg, 0.0);
            filePath = [NSString stringWithFormat:@"%@/%@.JPG",imageDir,[NSString stringWithFormat:@"%.lf",[[NSDate date] timeIntervalSince1970]*1000]];
        }
        //查找文件，如果不存在，就创建一个文件
        if (![fileManager fileExistsAtPath:filePath]) {
            [fileManager createFileAtPath:filePath contents:data attributes:nil];
        }
    }
    return YES;
}
- (BOOL)saveInZip{
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //获取document路径,括号中属性为当前应用程序独享
    NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,      NSUserDomainMask, YES);
    NSString *documentDirectory = [directoryPaths objectAtIndex:0];
    //定义记录文件全名以及路径的字符串filePath
    NSString *imageDir = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"uploadEvent/%@",self.uuidString]];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        return NO;
    }
    NSString *filePath = [NSString stringWithFormat:@"%@/uploadEvent/%@.zip",documentDirectory,self.uuidString];
    ZipArchive *za = [[ZipArchive alloc] init];
    [za CreateZipFile2:filePath];
    NSDirectoryEnumerator *direnum = [fileManager enumeratorAtPath:imageDir];
    NSString *filename ;
    while (filename = [direnum nextObject]) {
         [za addFileToZip:[NSString stringWithFormat:@"%@/%@",imageDir,filename] newname:[NSString stringWithFormat:@"%@/%@",self.uuidString,filename]];
    }
    if([za CloseZipFile2]){
        return YES;
    }
    return NO;
}
- (BOOL)sendSave{
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //获取document路径,括号中属性为当前应用程序独享
    NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,      NSUserDomainMask, YES);
    NSString *documentDirectory = [directoryPaths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/uploadEvent/%@.zip",documentDirectory,self.uuidString];
    BOOL existed = [fileManager fileExistsAtPath:filePath];
    if(existed){
        [[dataHttpManager getInstance] letPostEvent:filePath fileName:[NSString stringWithFormat:@"%@.zip",self.uuidString]];
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)creatXml{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:self.uuidString forKey:@"UID"];
    [dic setObject:[ud objectForKey:@"USER_NAME"] forKey:@"YHM"];
    [dic setObject:self.mapLocationStr forKey:@"SJWZ"];
    [dic setObject:self.cityManagerName forKey:@"WTLX"];
    [dic setObject:self.textMessage forKey:@"SJMS"];
    [dic setObject:self.citytype forKey:@"SSGQ"];
    [dic setObject:@"" forKey:@"FJQY"];
    [dic setObject:[NSString stringWithFormat:@"%lf",self.gpsPoint.x] forKey:@"Y"];
    [dic setObject:[NSString stringWithFormat:@"%lf",self.gpsPoint.y] forKey:@"X"];
    NSMutableDictionary *row = [NSMutableDictionary dictionaryWithCapacity:0];
    [row setObject:dic forKey:@"ROW"];
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:0];
    [data setObject:row forKey:@"ROWDATA"];
    NSString *xmlStr = [NSString stringWithFormat:@"%@\n%@",@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>",[data XMLString]];
    NSLog(@"%@",xmlStr);
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //获取document路径,括号中属性为当前应用程序独享
    NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,      NSUserDomainMask, YES);
    NSString *documentDirectory = [directoryPaths objectAtIndex:0];
    //定义记录文件全名以及路径的字符串filePath
    NSString *imageDir = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"uploadEvent/%@",self.uuidString]];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *filePath = [NSString stringWithFormat:@"%@/Data.xml",imageDir];
    //查找文件，如果不存在，就创建一个文件
    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
    NSError *error;
    if([xmlStr writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error]){
        return YES;
    }
    return NO;
}

- (void)saveHistory{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:self.uuidString forKey:@"UID"];
    [dic setObject:[ud objectForKey:@"USER_NAME"]  forKey:@"YHM"];
    [dic setObject:self.mapLocationStr forKey:@"SJWZ"];
    [dic setObject:self.cityManagerName forKey:@"WTLX"];
    [dic setObject:self.textMessage forKey:@"SJMS"];
    [dic setObject:self.citytype forKey:@"SSGQ"];
    [dic setObject:@"" forKey:@"FJQY"];
    [dic setObject:[NSString stringWithFormat:@"%lf",self.gpsPoint.x] forKey:@"Y"];
    [dic setObject:[NSString stringWithFormat:@"%lf",self.gpsPoint.y] forKey:@"X"];
    [ud setObject:dic forKey:self.uuidString];
    NSMutableArray *uids = [ud objectForKey:@"UID"];
    if(!uids){
        uids = [NSMutableArray arrayWithCapacity:0];
    }
    [uids addObject:self.uuidString];
    [ud synchronize];
    [ud setObject:uids forKey:@"UID"];
    [ud synchronize];
}

- (void)getLocation{
    QDMapLocationViewController *mapLocationViewController = [[QDMapLocationViewController alloc] initWithNibName:@"QDMapLocationViewController" bundle:nil];
    mapLocationViewController.delegate = self;
    [self.navigationController pushViewController:mapLocationViewController animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 3){
        return 166;
    }else if (indexPath.section == 0){
        return 60;
    }else{
        return 44;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return @"事件位置描述:";
    }else if (section == 1){
        return @"事件类型:";
    }else if (section == 2){
        return @"事件描述:";
    }else{
        return @"图片上传:";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuseIdetifyPoint = @"TableViewCellPoint";
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:reuseIdetifyPoint];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdetifyPoint];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.numberOfLines = 3;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    cell.detailTextLabel.numberOfLines = 0;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.minimumScaleFactor = 0.5;
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    cell.detailTextLabel.minimumScaleFactor = 0.5;
    if(indexPath.section == 0){
        cell.textLabel.text = self.mapLocationStr;
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.detailTextLabel.text = @"";
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 120, 44);
        [button setTitle:@"获取位置" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button setImage:[UIImage imageNamed:@"qd_point"] forState:UIControlStateNormal];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, 5, 0, button.titleLabel.frame.size.width)];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -button.imageView.frame.size.width+50, 0, 5)];
        [button addTarget:self action:@selector(getLocation) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = button;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    }else if (indexPath.section == 1){
        cell.textLabel.text = _cityManagerName;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }else if (indexPath.section == 2){
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
        _lbutton = [UIButton buttonWithType:UIButtonTypeCustom];
        _lbutton.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame)/2, 44);
        [_lbutton setTitle:@"手动输入" forState:UIControlStateNormal];
        [_lbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _lbutton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_lbutton setImage:[UIImage imageNamed:@"qd_pen"] forState:UIControlStateNormal];
        [_lbutton setImageEdgeInsets:UIEdgeInsetsMake(0, 20, 0, _lbutton.titleLabel.frame.size.width)];
        [_lbutton setTitleEdgeInsets:UIEdgeInsetsMake(0, -_lbutton.imageView.frame.size.width+70, 0, 5)];
        [_lbutton addTarget:self action:@selector(startTextInput) forControlEvents:UIControlEventTouchUpInside];
        _lbutton.titleLabel.numberOfLines = 1;
        _lbutton.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        
        _rbutton= [UIButton buttonWithType:UIButtonTypeCustom];
        _rbutton.frame = CGRectMake((CGRectGetWidth(self.view.frame)/2), 0, CGRectGetWidth(self.view.frame)/2, 44);
        [_rbutton setTitle:@"按住说话" forState:UIControlStateNormal];
        [_rbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        // Set record start action for UIControlEventTouchDown
        [_rbutton addTarget:self action:@selector(recordStart) forControlEvents:UIControlEventTouchDown];
        // Set record end action for UIControlEventTouchUpInside
        [_rbutton addTarget:self action:@selector(recordEnd) forControlEvents:UIControlEventTouchUpInside];
        // Set record cancel action for UIControlEventTouchUpOutside
        [_rbutton addTarget:self action:@selector(recordCancel) forControlEvents:UIControlEventTouchUpOutside];
        _rbutton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_rbutton setImage:[UIImage imageNamed:@"qd_mic"] forState:UIControlStateNormal];
        [_rbutton setImageEdgeInsets:UIEdgeInsetsMake(0, 20, 0, _lbutton.titleLabel.frame.size.width)];
        [_rbutton setTitleEdgeInsets:UIEdgeInsetsMake(0, -_lbutton.imageView.frame.size.width+30, 0, 5)];
        _rbutton.titleLabel.numberOfLines = 1;
        _rbutton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _rbutton.titleLabel.minimumScaleFactor = 0.5;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0,CGRectGetWidth(self.view.frame), 44)];
        [view addSubview:_lbutton];
        [view addSubview:_rbutton];
        cell.accessoryView = view;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        if(!_photoView){
            _photoView= [[MessagePhotoView alloc]initWithFrame:CGRectMake(20.0f,0.0f,CGRectGetWidth(self.view.frame)-40, 166)];
            _photoView.delegate =self;
        }
        cell.accessoryView = _photoView;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        
    }else if (indexPath.section == 1){
        cityManagerTableViewController *tableViewController = [[cityManagerTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        tableViewController.delegate = self;
        tableViewController.cityManagerName = self.cityManagerName;
        [self.navigationController  pushViewController:tableViewController animated:YES];
    }else if (indexPath.section == 2){
        
    }else{
        
    }
    
}


- (void)didSelectedCityManager:(NSString *)cityManagerName{
     UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    cell.textLabel.text = cityManagerName;
    self.cityManagerName = cityManagerName;
    [self canUpload];
}

//实现代理方法
-(void)addPicker:(UIImagePickerController *)picker{
    
    [self presentViewController:picker animated:YES completion:nil];
}
-(void)addUIImagePicker:(UIImagePickerController *)picker{
    [self presentViewController:picker animated:YES completion:nil];
}
-(void) recordStart
{
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    NSString *imageDir = [NSString stringWithFormat:@"%@/Documents/uploadEvent/%@",NSHomeDirectory(),self.uuidString];
    BOOL existed = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [self.voice startRecordWithPath:[NSString stringWithFormat:@"%@/Sound.caf", imageDir]];
}
- (BOOL)audio_PCMtoMP3
{
    NSString *imageDir = [NSString stringWithFormat:@"%@/Documents/uploadEvent/%@",NSHomeDirectory(),self.uuidString];
    NSString *cafFilePath = [imageDir stringByAppendingPathComponent:@"/Sound.caf"];
    
    NSString *mp3FilePath = [imageDir stringByAppendingPathComponent:@"/Sound.mp3"];
    
    
    NSFileManager* fileManager=[NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:cafFilePath];
    if(existed){
        if([fileManager removeItemAtPath:mp3FilePath error:nil])
        {
            NSLog(@"删除");
        }
        
        @try {
            int read, write;
            
            FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
            fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
            FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
            
            const int PCM_SIZE = 8192;
            const int MP3_SIZE = 8192;
            short int pcm_buffer[PCM_SIZE*2];
            unsigned char mp3_buffer[MP3_SIZE];
            
            lame_t lame = lame_init();
            lame_set_in_samplerate(lame, 11025.0);
            lame_set_VBR(lame, vbr_default);
            lame_init_params(lame);
            
            do {
                read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
                if (read == 0)
                    write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
                else
                    write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                
                fwrite(mp3_buffer, write, 1, mp3);
                
            } while (read != 0);
            
            lame_close(lame);
            fclose(mp3);
            fclose(pcm);
        }
        @catch (NSException *exception) {
            NSLog(@"%@",[exception description]);
            return NO;
        }
        @finally {
            if([fileManager removeItemAtPath:cafFilePath error:nil])
            {
                NSLog(@"删除caf");
                return YES;
            }
        }
    }else{
        return YES;
    }
    
}
-(void) recordEnd
{
    [self.voice stopRecordWithCompletionBlock:^{
        
        if (self.voice.recordTime > 0.0f) {
            [_rbutton setTitle:[NSString stringWithFormat:@"录音时长:%0.1f秒",self.voice.recordTime] forState:UIControlStateNormal];
        }else{
            [_rbutton setTitle:@"按住说话" forState:UIControlStateNormal];
        }
    
    }];
}

-(void) recordCancel
{
    [self.voice cancelled];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"录音取消了" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    
}

- (void) startTextInput{
    textInputViewController *tableViewController = [[textInputViewController alloc] init];
    tableViewController.delegate = self;
    tableViewController.textStr = self.textMessage;
    [self.navigationController  pushViewController:tableViewController animated:YES];
}

- (void)didFinishTextInputView:(NSString *)textStr{
    if(textStr.length > 0){
        _textMessage = textStr;
        [self canUpload];
        [_lbutton setTitle:textStr forState:UIControlStateNormal];
    }else{
        [_lbutton setTitle:@"手动输入" forState:UIControlStateNormal];
    }
}
- (void)didSelectedMapLocation:(AGSPoint *)point{
    _gpsPoint = point;
    [self getMapLocationWithPoint:point];
}

- (void)getMapLocationWithPoint:(AGSPoint *)point{
    AGSGraphic  *gra = [[AGSGraphic  alloc] initWithGeometry:point symbol:nil attributes:nil infoTemplateDelegate:nil];
    AGSFeatureSet *featureSet = [[AGSFeatureSet alloc] init];
	featureSet.features = [NSArray arrayWithObjects:gra, nil];
	
    //create input parameter
	AGSGPParameterValue *param = [AGSGPParameterValue parameterWithName:@"InputPoint" type:AGSGPParameterTypeFeatureRecordSetLayer value:featureSet];
    NSArray *params=[NSArray arrayWithObjects:param,nil ];
    [self.agp executeWithParameters:params];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
}

- (void)canUpload{
    if(self.textMessage.length > 0 &&self.mapLocationStr.length > 0 && self.cityManagerName){
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }else{
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

#pragma mark AGSQueryTaskDelegate

//results are returned
- (void)queryTask:(AGSQueryTask *)queryTask operation:(NSOperation *)op didExecuteWithFeatureSetResult:(AGSFeatureSet *)featureSet {
    [SVProgressHUD dismiss];
    if(featureSet.features != nil && [featureSet.features count] > 0){
        AGSGraphic *graphic = (AGSGraphic*)[featureSet.features objectAtIndex:0];
        NSString *mc = [graphic attributeForKey:@"MC"];
        self.mapLocationStr = [NSString stringWithFormat:@"上报事件位于:%@附近,%@",mc,self.mapLocationStr];
        [self canUpload];
        [self.tableView reloadData];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"黄岛治理"
                                                            message:@"非常抱歉，获取事件位置失败！"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
        alertView.tag = 10001;
        [alertView show];
    }
}

//if there's an error with the query display it to the user
- (void)queryTask:(AGSQueryTask *)queryTask operation:(NSOperation *)op didFailWithError:(NSError *)error {
    [SVProgressHUD dismiss];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"黄岛治理"
														message:[error localizedDescription]
													   delegate:self
											  cancelButtonTitle:@"确定"
											  otherButtonTitles:nil];
    alertView.tag = 10001;
	[alertView show];
}


//该函数在GP服务提交成功后响应
- (void)geoprocessor:(AGSGeoprocessor *)geoprocessor operation:(NSOperation *)op didExecuteWithResults:(NSArray *)results messages:(NSArray *)messages{
    // 获取GP分析的结果
    [SVProgressHUD dismiss];
    if (results!=nil && [results count] == 2){
        AGSGPParameterValue *result = [results objectAtIndex:0];
		AGSFeatureSet *fs = result.value;
        if(fs.features != nil && [fs.features count] > 0){
            AGSGraphic *graphic = [fs.features objectAtIndex:0];
            self.citytype = [graphic attributeForKey:@"社区名称"];
        }
        result = [results objectAtIndex:1];
		fs = result.value;
        if(fs.features != nil && [fs.features count] > 0){
            AGSGraphic *graphic = [fs.features objectAtIndex:0];
            NSString *angle = [graphic attributeForKey:@"NEAR_ANGLE"];
            NSString *dist = [graphic attributeForKey:@"NEAR_DIST"];
            NSString *fid = [graphic attributeForKey:@"NEAR_FID"];
            
            self.query.objectIds = [NSArray arrayWithObjects:fid, nil];
            [self.queryTask executeWithQuery:self.query];
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
            NSString *direction= nil;
            if ([angle intValue] >= -20 && [angle intValue] < 20) {
                direction = @"正西方向";
            }
            if ([angle intValue] >= 20 && [angle intValue] < 70) {
                direction = @"西南方向";
            }
            if ([angle intValue] >= 70 && [angle intValue] < 110) {
                direction = @"正南方向";
            }
            if ([angle intValue] >= 110 && [angle intValue] < 160) {
                direction = @"西南方向";
            }
            if ([angle intValue] >= 160 && [angle intValue] <= 180) {
                direction = @"正东方向";
            }
            if ([angle intValue] >= -70 && [angle intValue] < -20) {
                direction = @"西北方向";
            }
            if ([angle intValue] >= -110 && [angle intValue] < -70) {
                direction = @"正北方向";
            }
            if ([angle intValue] >= -160 && [angle intValue] < -110) {
                direction = @"东北方向";
            }
            if ([angle intValue] >= -180 && [angle intValue] < -160) {
                direction = @"正东方向";
            }
            self.mapLocationStr = [NSString stringWithFormat:@"%@,距离大约%0.f米处",direction,[dist floatValue]*111000];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"黄岛治理"
                                                                message:@"非常抱歉，获取事件位置失败！"
                                                               delegate:self
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
            alertView.tag = 10001;
            [alertView show];
        }

        
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"黄岛治理"
                                                            message:@"非常抱歉，获取事件位置失败！"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
        alertView.tag = 10001;
        [alertView show];
    }
}

// 获取GP结果成功后，调用该函数，将结果符号虎吼添加到graphicsLayer中
- (void)geoprocessor:(AGSGeoprocessor *)geoprocessor operation:(NSOperation *)op didFailExecuteWithError:(NSError *)error{
    [SVProgressHUD dismiss];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"黄岛治理"
														message:[error localizedDescription]
													   delegate:self
											  cancelButtonTitle:@"确定"
											  otherButtonTitles:nil];
    alertView.tag = 10001;
	[alertView show];
}
- (void)showMessageWithAlert:(NSString *)message{
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"黄岛治理" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    [view show];
}
- (NSString *)getUniqueStrByUUID
{
    return [NSString stringWithFormat:@"%.lf",[[NSDate date] timeIntervalSince1970]*1000];
    
}

#pragma -mark dataManagerDelegate

- (void)didPostEvent:(BOOL)success{
    [SVProgressHUD dismiss];
    if(success){
        [self saveHistory];
         NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if([[ud objectForKey:@"SHOW_EVENT"] isEqualToString:@"1"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowEventInMap" object:nil userInfo:nil];
        }
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"黄岛治理" message:@"非常感谢，事件上报成功！我们会尽快处理！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        view.tag = 10001;
        [view show];
    }else{
        [self showMessageWithAlert:@"非常抱歉，事件上报失败！"];
    }
}

- (void)didGetFailed{
    [SVProgressHUD dismiss];
    [self showMessageWithAlert:@"非常抱歉，发生了网络异常！"];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 10001){
        [self doBack];
    }
}

- (void)doBack{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
