//
//  QDEditViewController.m
//  qdzl
//
//  Created by xtturing on 14-9-28.
//
//

#import "QDEditViewController.h"
#import "cityManagerTableViewController.h"
#import "MessagePhotoView.h"
@interface QDEditViewController ()<UITableViewDelegate,cityManagerDelegate,MessagePhotoViewDelegate>

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
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.navigationItem.title = @"事件上报";
    UIBarButtonItem *right = [[UIBarButtonItem alloc]  initWithTitle:@"上传" style:UIBarButtonItemStylePlain target:self action:@selector(sendAction)];
    self.navigationItem.rightBarButtonItem = right;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendAction{
    
}

- (void)getLocation{
    
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
        return @"问题类型:";
    }else if (section == 2){
        return @"问题描述:";
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
        cell.textLabel.text = @"事件位于青岛胶南市海滨街道办事处 下沟附近正西方向1210米";
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.detailTextLabel.text = @"";
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 100, 44);
        [button setTitle:@"获取位置" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button setImage:[UIImage imageNamed:@"qd_point"] forState:UIControlStateNormal];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, 5, 0, button.titleLabel.frame.size.width)];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -button.imageView.frame.size.width+30, 0, 5)];
        [button addTarget:self action:@selector(getLocation) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = button;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    }else if (indexPath.section == 1){
        cell.textLabel.text = @"城市管理";
        cell.detailTextLabel.text = @"社会治安";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }else if (indexPath.section == 2){
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake((CGRectGetWidth(self.view.frame)/2-100)/2, 0, 100, 44);
        [button setTitle:@"手动输入" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button setImage:[UIImage imageNamed:@"qd_pen"] forState:UIControlStateNormal];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, 5, 0, button.titleLabel.frame.size.width)];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -button.imageView.frame.size.width+30, 0, 5)];
        [button addTarget:self action:@selector(getLocation) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *rbutton = [UIButton buttonWithType:UIButtonTypeCustom];
        rbutton.frame = CGRectMake((CGRectGetWidth(self.view.frame)/2+(CGRectGetWidth(self.view.frame)/2-100)/2), 0, 100, 44);
        [rbutton setTitle:@"按住说话" forState:UIControlStateNormal];
        [rbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        rbutton.titleLabel.font = [UIFont systemFontOfSize:14];
        [rbutton setImage:[UIImage imageNamed:@"qd_mic"] forState:UIControlStateNormal];
        [rbutton setImageEdgeInsets:UIEdgeInsetsMake(0, 5, 0, button.titleLabel.frame.size.width)];
        [rbutton setTitleEdgeInsets:UIEdgeInsetsMake(0, -button.imageView.frame.size.width+30, 0, 5)];
        [rbutton addTarget:self action:@selector(getLocation) forControlEvents:UIControlEventTouchUpInside];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0,CGRectGetWidth(self.view.frame), 44)];
        [view addSubview:button];
        [view addSubview:rbutton];
        cell.accessoryView = view;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        MessagePhotoView *photoView = [[MessagePhotoView alloc]initWithFrame:CGRectMake(0.0f,0.0f,CGRectGetWidth(self.view.frame), 166)];
        photoView.delegate =self;
        
        cell.accessoryView = photoView;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        
    }else if (indexPath.section == 1){
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cityManagerTableViewController *tableViewController = [[cityManagerTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        tableViewController.delegate = self;
        tableViewController.cityManagerName = cell.detailTextLabel.text;
        [self.navigationController  pushViewController:tableViewController animated:YES];
    }else if (indexPath.section == 2){
        
    }else{
        
    }
    
}


- (void)didSelectedCityManager:(NSString *)cityManagerName{
     UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    cell.detailTextLabel.text = cityManagerName;
}

//实现代理方法
-(void)addPicker:(UIImagePickerController *)picker{
    
    [self presentViewController:picker animated:YES completion:nil];
}

@end
