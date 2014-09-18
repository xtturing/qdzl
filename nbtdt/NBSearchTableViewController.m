//
//  NBSearchTableViewController.m
//  tdtnb
//
//  Created by xtturing on 14-8-5.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import "NBSearchTableViewController.h"
#import "NBSearch.h"
#import "dataHttpManager.h"
#import "SVProgressHUD.h"
#import "NBSearchDetailViewController.h"

#define REGION @"宁波"
#define RADIUS 3000
#define PAGESIZE 10
#define PAGENUM  0

@interface NBSearchTableViewController ()<dataHttpDelegate>
@property(nonatomic,strong) NSMutableArray *tableList;
@property(nonatomic,assign) int pageNum;
@property(nonatomic,assign) int pageSize;
@end

@implementation NBSearchTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [dataHttpManager getInstance].delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated{
    [dataHttpManager getInstance].delegate =  nil;
    [SVProgressHUD dismiss];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    _tableList = [[NSMutableArray alloc] initWithCapacity:10];
    _pageNum = PAGENUM;
    _pageSize = PAGESIZE;
    self.navigationItem.title = self.searchText;
    UIBarButtonItem *right = [[UIBarButtonItem alloc]  initWithTitle:@"全部定位" style:UIBarButtonItemStylePlain target:self action:@selector(pointsInMap)];
    self.navigationItem.rightBarButtonItem = right;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self doSearch];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NBSearch *searchItem = [_tableList objectAtIndex:indexPath.row];
    static NSString *reuseIdetify = @"TableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdetify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdetify];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.text = searchItem.name;
    cell.detailTextLabel.text = searchItem.address;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    cell.detailTextLabel.numberOfLines = 0;
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_tableList count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NBSearch *searchItem = [_tableList objectAtIndex:indexPath.row];
    if(searchItem){
        NBSearchDetailViewController *detailViewController = [[NBSearchDetailViewController alloc] initWithNibName:@"NBSearchDetailViewController" bundle:nil];
        detailViewController.detail = searchItem;
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

#pragma mark -dataHttpDelegate

-(void)doSearch{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(_searchType == AFKeySearch){
            [[dataHttpManager getInstance] letDoSearchWithQuery:self.searchText region:REGION searchType:1 pageSize:_pageSize pageNum:_pageNum];
        }
        if(_searchType == AFRadiusSearch){
            [[dataHttpManager getInstance] letDoRadiusSearchWithQuery:self.searchText location:self.location radius:RADIUS scope:1 pageSize:_pageSize pageNum:_pageNum];
        }
        
    });
}

- (void)didGetFailed{
   [SVProgressHUD dismiss];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"天地图宁波" message:@"查询发生异常" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [view show];
    
}

-(void)didGetSearchList:(NSArray *)searchList{
    [SVProgressHUD dismiss];
    [_tableList addObjectsFromArray:searchList];
    if([_tableList count]>0){
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    [self.tableView reloadData];
}

-(void)didGetRadiusSearchList:(NSArray *)radiusList{
    [SVProgressHUD dismiss];
    [_tableList addObjectsFromArray:radiusList];
    if([_tableList count]>0){
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    [self.tableView reloadData];
}

-(void)pointsInMap{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"searchPointsInMap" object:nil userInfo:[NSDictionary dictionaryWithObject:_tableList forKey:@"searchList"]];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)refresh {
    [self performSelector:@selector(addItem) withObject:nil afterDelay:2.0];
}

- (void)addItem {
    // Add a new time
    _pageNum +=1;
    [self doSearch];
    [self stopLoading];
}


@end
