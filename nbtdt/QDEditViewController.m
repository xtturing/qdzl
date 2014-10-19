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

@interface QDEditViewController ()<UITableViewDelegate,cityManagerDelegate,textInputViewDelegate,MessagePhotoViewDelegate>
@property(nonatomic,strong) LCVoice * voice;
@property (nonatomic,strong)  UIButton *rbutton;
@property (nonatomic,strong)  UIButton *lbutton;
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
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.voice = [[LCVoice alloc] init];
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
    QDMapLocationViewController *mapLocationViewController = [[QDMapLocationViewController alloc] initWithNibName:@"QDMapLocationViewController" bundle:nil];
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
        [_lbutton setTitleEdgeInsets:UIEdgeInsetsMake(0, -_lbutton.imageView.frame.size.width+50, 0, 5)];
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
        [_rbutton setTitleEdgeInsets:UIEdgeInsetsMake(0, -_lbutton.imageView.frame.size.width+50, 0, 5)];
        [_rbutton addTarget:self action:@selector(getLocation) forControlEvents:UIControlEventTouchUpInside];
        _rbutton.titleLabel.numberOfLines = 1;
        _rbutton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _rbutton.titleLabel.minimumScaleFactor = 0.5;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0,CGRectGetWidth(self.view.frame), 44)];
        [view addSubview:_lbutton];
        [view addSubview:_rbutton];
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
        tableViewController.cityManagerName = cell.textLabel.text;
        [self.navigationController  pushViewController:tableViewController animated:YES];
    }else if (indexPath.section == 2){
        
    }else{
        
    }
    
}


- (void)didSelectedCityManager:(NSString *)cityManagerName{
     UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    cell.textLabel.text = cityManagerName;
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
    [self.voice startRecordWithPath:[NSString stringWithFormat:@"%@/Documents/MySound.caf", NSHomeDirectory()]];
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
    tableViewController.textStr = @"";
    [self.navigationController  pushViewController:tableViewController animated:YES];
}

- (void)didFinishTextInputView:(NSString *)textStr{
    if(textStr.length > 0){
        [_lbutton setTitle:textStr forState:UIControlStateNormal];
    }else{
        [_lbutton setTitle:@"手动输入" forState:UIControlStateNormal];
    }
}
@end
