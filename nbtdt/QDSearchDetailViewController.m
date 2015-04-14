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

@interface QDSearchDetailViewController ()<dataHttpDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) NSMutableArray *results;
@property (nonatomic) NSInteger appRaise;

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
    if(section == _results.count+1){
        return 1;
    }
    return 4;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _results.count+2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0 && indexPath.row == 0){
        return 60;
    }
    return 44;
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
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    cell.detailTextLabel.numberOfLines = 3;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.minimumScaleFactor = 0.5;
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    cell.detailTextLabel.minimumScaleFactor = 0.5;
    if(indexPath.section == 0){
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *dic = [ud objectForKey:_uid];
        if(indexPath.row == 0){
            cell.textLabel.text = @"事件位置:";
            cell.detailTextLabel.text = [dic objectForKey:@"SJWZ"];
        }else if (indexPath.row == 1){
            cell.textLabel.text = @"事件类型:";
            cell.detailTextLabel.text = [dic objectForKey:@"WTLX"];
        }else if (indexPath.row == 2){
            cell.textLabel.text = @"事件描述:";
            cell.detailTextLabel.text = [dic objectForKey:@"SJMS"];
        }else{
            cell.textLabel.text = @"所属管区:";
            cell.detailTextLabel.text = [dic objectForKey:@"SSGQ"];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else if (indexPath.section == (_results.count+1)){
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        NSString *detailTitle = @"处置进度:";
        NSString *title = nil;
        if(self.appRaise == 1){
            cell.detailTextLabel.textColor = [UIColor orangeColor];
            title =  @"未办结！请耐心等待...";
            cell.accessoryType = UITableViewCellAccessoryNone;
        }else if (self.appRaise ==2){
            cell.detailTextLabel.textColor = [UIColor redColor];
            title = @"已办结！亲,点我给个好评吧！";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else if (self.appRaise == 3){
            cell.detailTextLabel.textColor = [UIColor blueColor];
            title = @"已办结！谢谢你的评价！";
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.textLabel.text = detailTitle;
        cell.detailTextLabel.text = title;
    }else{
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        NSMutableDictionary *dic = [_results objectAtIndex:(indexPath.section-1)];
        if(indexPath.row == 0){
            cell.textLabel.text = @"操作事件:";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"CREATEDATE"]];
        }else if (indexPath.row == 1){
            cell.textLabel.text = @"操作人:";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"PARTNAME"]];
        }else if (indexPath.row == 2){
            cell.textLabel.text = @"操作类型:";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"TASKCNNAME"]];
        }else{
            cell.textLabel.text = @"操作内容:";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"TASKDESC"]];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)didSearchEventHistory:(NSDictionary *)list{
    [SVProgressHUD dismiss];
    NSArray *historyArray = [list objectForKey:@"HISTORY"];
    self.appRaise = [[list objectForKey:@"PYZT"] integerValue];
    if(!historyArray || historyArray.count == 0){
        [self showMessageWithAlert:@"非常抱歉，事件正在处理中，请耐心等待！"];
    }
    _results = [NSMutableArray arrayWithArray:historyArray];
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == (_results.count+1) && self.appRaise ==2){
        [self openAppRaiseMenu];
    }
}

-(void)openAppRaiseMenu{
    //在这里呼出下方菜单按钮项
    UIActionSheet *_myActionSheet = [[UIActionSheet alloc]
                                     initWithTitle:nil
                                     delegate:self
                                     cancelButtonTitle:@"取消"
                                     destructiveButtonTitle:nil
                                     otherButtonTitles:@"满意",@"一般",@"不满意", nil];
    //刚才少写了这一句
    [_myActionSheet showInView:self.view.window];
    
    
}
//下拉菜单的点击响应事件
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex == actionSheet.cancelButtonIndex){
        NSLog(@"取消");
    }
    NSString *raise = nil;
    switch (buttonIndex) {
        case 0:
            raise = @"满意";
            break;
        case 1:
            raise = @"一般";
            break;
        case 2:
            raise = @"不满意";
            break;
        default:
            break;
    }
    if(_uid && raise && _uid.length > 0 && raise.length > 0){
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
             [[dataHttpManager getInstance] letAppRaise:_uid withRaise:raise];
        });
    }
}


- (void)didGetFailed{
    [SVProgressHUD dismiss];
    [self showMessageWithAlert:@"非常抱歉，发生了网络异常！"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didGetAppRaise:(BOOL)success{
    [SVProgressHUD dismiss];
    if(success){
        self.appRaise = 3;
        [self.tableView reloadData];
    }else{
        [self showMessageWithAlert:@"评价失败，请再试一次！"];
    }
}
- (void)showMessageWithAlert:(NSString *)message{
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"黄岛治理" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    [view show];
}
@end
