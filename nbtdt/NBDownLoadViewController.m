//
//  NBDownLoadViewController.m
//  tdtnb
//
//  Created by xtturing on 14-7-31.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import "NBDownLoadViewController.h"
#import "NBDownLoadManagerViewController.h"
#import "dataHttpManager.h"
#import "NBTpk.h"
#import "SVProgressHUD.h"
#import "Reachability.h"
#import "DownloadManager.h"
#import "DowningCell.h"
#import "Utility.h"

#define HTTP_TPK @"http://27.223.74.180:8089/HDZZ.tpk"

@interface NBDownLoadViewController ()<dataHttpDelegate>

@property (nonatomic ,strong) NSMutableDictionary *tpkList;

@end

@implementation NBDownLoadViewController

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
    self.navigationItem.title = @"离线地图";
    
//    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"下载管理" style:UIBarButtonItemStylePlain target:self action:@selector(downloadManager)];
//    self.navigationItem.rightBarButtonItem = right;
//    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.tpkList = [[NSMutableDictionary alloc] initWithCapacity:0];
    NBTpk *tpk = [[NBTpk alloc] init];
    tpk.name = @"HDZZ.tpk";
    tpk.title = @"黄岛区离线地图包";
    DownloadItem *downItem=[[DownloadItem alloc] init];
    downItem.tpk = tpk;
    NSURL  *url = [NSURL URLWithString:HTTP_TPK];
    downItem.url=url;
    DownloadItem *task=[[DownloadManager sharedInstance] getDownloadItemByUrl:[downItem.url description]];
    downItem.downloadPercent=task.downloadPercent;
    if(task)
    {
        downItem.downloadState=task.downloadState;
    }
    else
    {
        downItem.downloadState=DownloadNotStart;
    }
    [self.tpkList setObject:downItem forKey:[downItem.url description]];
//    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [[dataHttpManager getInstance] letDoTpkList];
//    });
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(downloadNotification:) name:kDownloadManagerNotification object:nil];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [dataHttpManager getInstance].delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated{
    [dataHttpManager getInstance].delegate =  nil;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)downloadManager{
    NBDownLoadManagerViewController *manager = [[NBDownLoadManagerViewController alloc]initWithNibName:@"NBDownLoadManagerViewController" bundle:nil];
     manager.tpkList = _tpkList;
    manager.layers =self.layers;
    [self.navigationController pushViewController:manager animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didGetFailed{
    [SVProgressHUD dismiss];
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"黄岛治理" message:@"离线下载发生异常" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [view show];
}

-(void)didgetTpkList:(NSMutableDictionary *)tokList{
    [SVProgressHUD dismiss];
    _tpkList = tokList;
    if(_tpkList.count > 0){
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    [self.table reloadData];
}

-(void)updateCell:(DowningCell *)cell withDownItem:(DownloadItem *)downItem
{
    DownloadItem *findItem=[_tpkList objectForKey:[downItem.url description]];
    cell.lblTitle.text=[findItem.tpk.title description];
    cell.lblPercent.text=[NSString stringWithFormat:@"大小:%0.2fMB  进度:%0.2f%@",[findItem.tpk.size doubleValue]/(1024*1024),downItem.downloadPercent*100,@"%"];
    [cell.btnOperate setTitle:downItem.downloadStateDescription forState:UIControlStateNormal];
}
-(void)updateUIByDownloadItem:(DownloadItem *)downItem
{
    DownloadItem *findItem=[_tpkList objectForKey:[downItem.url description]];
    if(findItem==nil)
    {
        return;
    }
    findItem.downloadStateDescription=downItem.downloadStateDescription;
    findItem.downloadPercent=downItem.downloadPercent;
    findItem.downloadState=downItem.downloadState;
    switch (downItem.downloadState) {
        case DownloadFinished:
        {
            
        }
            break;
        case DownloadFailed:
        {
            
        }
            break;
            
        default:
            break;
    }
    
    
    int index=[_tpkList.allKeys indexOfObject:[downItem.url description]];
    DowningCell *cell=(DowningCell *)[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [self updateCell:cell withDownItem:downItem];
}

-(void)downloadNotification:(NSNotification *)notif
{
    DownloadItem *notifItem=notif.object;
    //    NSLog(@"%@,%d,%f",notifItem.url,notifItem.downloadState,notifItem.downloadPercent);
    [self updateUIByDownloadItem:notifItem];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 66;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DownloadItem *downItem = [_tpkList.allValues objectAtIndex:indexPath.row];
    NSString *url=[downItem.url description];
    NSString *name = [downItem.tpk.name description];
    static NSString *cellIdentity=@"DowningCell";
    DowningCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentity];
    if(cell==nil)
    {
        cell=[[[NSBundle mainBundle]loadNibNamed:@"DowningCell" owner:self options:nil] lastObject];
        cell.DowningCellOperateClick=^(DowningCell *cell){
            
            if([[DownloadManager sharedInstance]isExistInDowningQueue:url])
            {
                [[DownloadManager sharedInstance]pauseDownload:url];
                return;
            }
            NSString *desPath=[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:name];
            [[DownloadManager sharedInstance]startDownload:url withLocalPath:desPath];
        };
        cell.DowningCellCancelClick=^(DowningCell *cell)
        {
            [[DownloadManager sharedInstance]cancelDownload:url];
        };
    }
    [self updateCell:cell withDownItem:downItem];
    if([cell.btnOperate.titleLabel.text isEqualToString:@"下载完成"] && [self hasAddLocalLayer:[name stringByDeletingPathExtension]]){
        [cell.btnOperate setTitle:@"已加载" forState:UIControlStateNormal];
    }
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_tpkList count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DowningCell *cell=(DowningCell *)[self.table cellForRowAtIndexPath:indexPath];
    DownloadItem *downItem = [_tpkList.allValues objectAtIndex:indexPath.row];
    if([cell.btnOperate.titleLabel.text isEqualToString:@"下载完成"] && downItem.downloadPercent == 1){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addLocalTileLayer" object:nil userInfo:[NSDictionary dictionaryWithObject:[[[downItem.url description] componentsSeparatedByString:@"="] objectAtIndex:1] forKey:@"name"]];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else if([cell.btnOperate.titleLabel.text isEqualToString:@"已加载"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"removeLocalTileLayer" object:nil userInfo:[NSDictionary dictionaryWithObject:[[[downItem.url description] componentsSeparatedByString:@"="] objectAtIndex:1] forKey:@"name"]];
        [self.table reloadData];
    }else{
        [self downloadManager];
    }
}

- (BOOL)hasAddLocalLayer:(NSString *)name{
    if(self.layers == nil || self.layers.count == 0){
        return NO;
    }
    for(AGSTiledLayer *layer in self.layers){
        if([layer isKindOfClass:[AGSLocalTiledLayer class]] && [layer.name isEqualToString:name]){
            return YES;
        }
    }
    return NO;
}


@end
