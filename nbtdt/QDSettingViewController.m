//
//  QDSettingViewController.m
//  qdzl
//
//  Created by xtturing on 14-9-28.
//
//

#import "QDSettingViewController.h"
#import "NBDownLoadViewController.h"
#import "ShowBigViewController.h"
@interface QDSettingViewController ()<UIAlertViewDelegate>

@end

@implementation QDSettingViewController

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
    self.navigationItem.title = @"系统设置";
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 1;
    }
    return 2;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
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
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            cell.textLabel.text = @"帮助";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
    }else if (indexPath.section == 1){
        if(indexPath.row == 0){
            cell.textLabel.text = @"关于";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else{
            cell.textLabel.text = @"退出";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
    }else{
         NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if(indexPath.row == 0){
            cell.textLabel.text = @"离线地图";
            UISwitch *switchBtn = [[UISwitch alloc] init];
            if([[ud objectForKey:@"SHOW_DOWNLOAD"] isEqualToString:@"1"]){
                [switchBtn setOn:YES];
            }else{
                [switchBtn setOn:NO];
            }
            switchBtn.tag = 10001;
            [switchBtn addTarget:self action:@selector(showDownLoadInMap:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switchBtn;
        }else{
            cell.textLabel.text = @"地图显示事件上报记录";
            UISwitch *switchBtn = [[UISwitch alloc] init];
            switchBtn.tag = 10002;
            if([[ud objectForKey:@"SHOW_EVENT"] isEqualToString:@"1"]){
                [switchBtn setOn:YES];
            }else{
                [switchBtn setOn:NO];
            }
            [switchBtn addTarget:self action:@selector(showEventInMap:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switchBtn;
        }
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            ShowBigViewController *big = [[ShowBigViewController alloc] init];
            big.showButton = NO;
            big.arrayOK = [NSMutableArray arrayWithObjects:[UIImage imageNamed:@"1"],[UIImage imageNamed:@"2"],[UIImage imageNamed:@"3"],[UIImage imageNamed:@"4"], nil];
            [self.navigationController pushViewController:big animated:YES];
        }
    }else if (indexPath.section == 1){
        if(indexPath.row == 0){
            ShowBigViewController *big = [[ShowBigViewController alloc] init];
            big.showButton = NO;
            big.showVersion = YES;
            big.arrayOK = [NSMutableArray arrayWithObjects:[UIImage imageNamed:@"about"], nil];
            [self.navigationController pushViewController:big animated:YES];
        }else{
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"黄岛治理" message:@"确定退出当前用户账号" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            view.delegate = self;
            view.tag = 10002;
            [view show];
        }
        
    }else{
        if(indexPath.row == 0){
            NBDownLoadViewController *downViewController = [[NBDownLoadViewController alloc] initWithNibName:@"NBDownLoadViewController" bundle:nil];
            [self.navigationController pushViewController:downViewController animated:YES];
        }else{
            
        }
    }

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1 && alertView.tag == 10002) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if([ud objectForKey:@"USER_NAME"] && [ud objectForKey:@"USER_PASSWORD"]){
            [ud removeObjectForKey:@"USER_NAME"];
            [ud removeObjectForKey:@"USER_PASSWORD"];
            [ud synchronize];
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    }
}

- (void)showDownLoadInMap:(UISwitch *)sender{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    NSString *imageDir = [NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),@"HDZZ.tpk"];
    BOOL existed = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
    if(existed){
        if(sender.tag == 10001 && sender.isOn){
            [ud setObject:@"1" forKey:@"SHOW_DOWNLOAD"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"addLocalTileLayer" object:nil userInfo:[NSDictionary dictionaryWithObject:@"HDZZ.tpk" forKey:@"name"]];
        }else{
            [ud setObject:@"0" forKey:@"SHOW_DOWNLOAD"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"removeLocalTileLayer" object:nil userInfo:[NSDictionary dictionaryWithObject:@"HDZZ.tpk" forKey:@"name"]];
        }
        [ud synchronize];

    }else{
        [sender setOn:NO];
        [ud setObject:@"0" forKey:@"SHOW_DOWNLOAD"];
        [ud synchronize];
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"黄岛治理" message:@"请在WIFI环境下下载离线地图包" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        view.tag = 10001;
        [view show];
    }
}

- (void)showEventInMap:(UISwitch *)sender{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if(sender.tag == 10002 && sender.isOn){
        [ud setObject:@"1" forKey:@"SHOW_EVENT"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowEventInMap" object:nil userInfo:nil];
    }else{
        [ud setObject:@"0" forKey:@"SHOW_EVENT"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveEventInMap" object:nil userInfo:nil];
    }
    [ud synchronize];
}
- (void)showMessageWithAlert:(NSString *)message{
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"黄岛治理" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    [view show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 10001){
        NBDownLoadViewController *downViewController = [[NBDownLoadViewController alloc] initWithNibName:@"NBDownLoadViewController" bundle:nil];
        [self.navigationController pushViewController:downViewController animated:YES];
    }
}
@end
