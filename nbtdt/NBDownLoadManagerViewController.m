//
//  NBDownLoadManagerViewController.m
//  tdtnb
//
//  Created by xtturing on 14-7-31.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import "NBDownLoadManagerViewController.h"
#import "DownloadItem.h"
#import "DownloadManager.h"
#import "Utility.h"
#import "DowningCell.h"

@interface NBDownLoadManagerViewController (){
    NSMutableDictionary *_downlist;
}

@end

@implementation NBDownLoadManagerViewController

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
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"正在下载",@"已完成", nil]];
    segment.frame = CGRectMake(0, 7, 140, 30);
    segment.segmentedControlStyle = UISegmentedControlStyleBar;
    if(_segIndex){
        segment.selectedSegmentIndex = _segIndex;
    }else{
        
        segment.selectedSegmentIndex = 0;
    }
    if(segment.selectedSegmentIndex == 0){
        _downlist = [[DownloadManager sharedInstance]getDownloadingTask];
    }else{
        _downlist = [[DownloadManager sharedInstance]getFinishedTask];
    }
    [segment addTarget:self action:@selector(segmentAction:)forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.titleView = segment;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(downloadNotification:) name:kDownloadManagerNotification object:nil];
    // Do any additional setup after loading the view from its nib.
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)segmentAction:(UISegmentedControl *)Seg{
    if(Seg.selectedSegmentIndex == 0){
        _downlist = [[DownloadManager sharedInstance]getDownloadingTask];
    }else{
         _downlist = [[DownloadManager sharedInstance]getFinishedTask];
    }
    [self.table reloadData];
}
-(void)updateCell:(DowningCell *)cell withDownItem:(DownloadItem *)downItem
{
    
    DownloadItem *findItem=[_tpkList objectForKey:[downItem.url description]];
    if(findItem.tpk.title.length > 0 ){
        cell.lblTitle.text=[findItem.tpk.title description];
        cell.lblPercent.text=[NSString stringWithFormat:@"大小:%0.2fMB  进度:%0.2f%@",[findItem.tpk.size doubleValue]/(1024*1024),downItem.downloadPercent*100,@"%"];
        [cell.btnOperate setTitle:downItem.downloadStateDescription forState:UIControlStateNormal];
    }else{
        cell.lblTitle.text=[[[downItem.url description] componentsSeparatedByString:@"="] objectAtIndex:1];
        cell.lblPercent.text=[NSString stringWithFormat:@"大小:%0.2fMB  进度:%0.2f%@",downItem.totalLength/(1024*1024),downItem.downloadPercent*100,@"%"];
        [cell.btnOperate setTitle:downItem.downloadStateDescription forState:UIControlStateNormal];
    }
    
}
-(void)updateUIByDownloadItem:(DownloadItem *)downItem
{
    DownloadItem *findItem=[_downlist objectForKey:[downItem.url description]];
    
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
    
    
    NSInteger index=[_downlist.allKeys indexOfObject:[downItem.url description]];
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
    DownloadItem *downItem = [_downlist.allValues objectAtIndex:indexPath.row];

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
    return [_downlist count];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DowningCell *cell=(DowningCell *)[self.table cellForRowAtIndexPath:indexPath];
    DownloadItem *downItem = [_downlist.allValues objectAtIndex:indexPath.row];
    if([cell.btnOperate.titleLabel.text isEqualToString:@"下载完成"] && downItem.downloadPercent == 1){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addLocalTileLayer" object:nil userInfo:[NSDictionary dictionaryWithObject:[[[downItem.url description] componentsSeparatedByString:@"="] objectAtIndex:1] forKey:@"name"]];
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }
    if([cell.btnOperate.titleLabel.text isEqualToString:@"已加载"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"removeLocalTileLayer" object:nil userInfo:[NSDictionary dictionaryWithObject:[[[downItem.url description] componentsSeparatedByString:@"="] objectAtIndex:1] forKey:@"name"]];
        [self.table reloadData];
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
