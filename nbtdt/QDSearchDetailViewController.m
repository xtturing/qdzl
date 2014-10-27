//
//  QDSearchDetailViewController.m
//  qdzl
//
//  Created by xtturing on 14-10-26.
//
//

#import "QDSearchDetailViewController.h"
#import "dataHttpManager.h"
#import "SVProgressHUD.h"

@interface QDSearchDetailViewController ()<dataHttpDelegate>

@property (nonatomic, strong) NSMutableArray *results;

@end

@implementation QDSearchDetailViewController

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
    self.navigationItem.title = @"事件处理流程";
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];;
    [dataHttpManager getInstance].delegate = self;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(_uid && _uid.length > 0){
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[dataHttpManager getInstance] letSearchEventHistory:_uid];
        });
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [dataHttpManager getInstance].delegate =  nil;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _results.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuseIdetifyPoint = @"TableViewCellPoint";
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:reuseIdetifyPoint];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdetifyPoint];
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
    NSMutableDictionary *dic = [_results objectAtIndex:indexPath.section];
    if(indexPath.row == 0){
        cell.textLabel.text = [NSString stringWithFormat:@"操作事件:%@",[dic objectForKey:@"CREATEDATE"]];
    }else if (indexPath.row == 1){
        cell.textLabel.text = [NSString stringWithFormat:@"操作人:%@",[dic objectForKey:@"PARTNAME"]];
    }else if (indexPath.row == 2){
        cell.textLabel.text = [NSString stringWithFormat:@"操作类型:%@",[dic objectForKey:@"TASKCNNAME"]];
    }else{
        cell.textLabel.text = [NSString stringWithFormat:@"操作内容:%@",[dic objectForKey:@"TASKDESC"]];
    }
    return cell;
}


- (void)didSearchEventHistory:(NSArray *)list{
    [SVProgressHUD dismiss];
    _results = [NSMutableArray arrayWithArray:list];
    [self.tableView reloadData];
}

- (void)didGetFailed{
    [SVProgressHUD dismiss];
    [self showMessageWithAlert:@"非常抱歉，发生了网络异常！"];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)showMessageWithAlert:(NSString *)message{
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"黄岛治理" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    [view show];
}
@end