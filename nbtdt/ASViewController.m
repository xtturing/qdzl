//
//  ASViewController.m
//  ASTextViewDemo
//
//  Created by Adil Soomro on 4/14/14.
//  Copyright (c) 2014 Adil Soomro. All rights reserved.
//

#import "ASViewController.h"
#import "ASTextField.h"
#import "QDMapViewController.h"
#import "ASPasswordViewController.h"
#import "ASRegisterViewController.h"

@interface ASViewController ()<dataHttpDelegate>

@property (nonatomic,retain) NSMutableArray *cellArray;
@property (strong, nonatomic) QDMapViewController *mapViewController;
@property (strong, nonatomic) UINavigationController *navController;

@end

@implementation ASViewController

- (id)init
{
    self = [super initWithNibName:@"ASViewController" bundle:nil];
    if (self) {
        // Something.
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //bake a cellArray to contain all cells
    self.cellArray = [NSMutableArray arrayWithObjects: _usernameCell, _passwordCell, _doneCell, nil];
    //setup text field with respective icons
    [_usernameField setupTextFieldWithIconName:@"user_name_icon"];
    [_passwordField setupTextFieldWithIconName:@"password_icon"];
    _passwordField.secureTextEntry = YES;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self registerForKeyboardNotifications];
    [dataHttpManager getInstance].delegate = self;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if([ud objectForKey:@"USER_NAME"] && [ud objectForKey:@"USER_PASSWORD"]){
        _usernameField.text = [ud objectForKey:@"USER_NAME"];
        _passwordField.text = [ud objectForKey:@"USER_PASSWORD"];
        [self autoLoginIn];
    }
    [self resignAllResponders];
}

-(void)viewWillDisappear:(BOOL)animated{
    [dataHttpManager getInstance].delegate =  nil;
    self.navigationController.navigationBarHidden = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - keyboardHight

- (void)registerForKeyboardNotifications
{
    //使用NSNotificationCenter 鍵盤出現時
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWasShown:)
     
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    //使用NSNotificationCenter 鍵盤隐藏時
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWillBeHidden:)
     
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    
}



//实现当键盘出现的时候计算键盘的高度大小。用于输入框显示位置
- (void)keyboardWasShown:(NSNotification*)aNotification
{   //输入框位置动画加载
    CGRect curFrame=self.view.frame;
    curFrame.origin.y -= 90;
    [UIView animateWithDuration:0.3f animations:^{
        self.view.frame=curFrame;
    }];
}

//当键盘隐藏的时候
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    CGRect curFrame=self.view.frame;
    curFrame.origin.y += 90;
    [UIView animateWithDuration:0.3f animations:^{
        self.view.frame=curFrame;
    }];
    //do something
}
#pragma mark - tableview deleagate datasource stuff
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //return cell's height for particular row
    return ((UITableViewCell*)[self.cellArray objectAtIndex:indexPath.row]).frame.size.height;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return number of cells for the table
    return self.cellArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    //return cell for particular row
    cell = [self.cellArray objectAtIndex:indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //set clear color to cell.
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (IBAction)changeFieldBackground:(UISegmentedControl *)segment {
    if ([segment selectedSegmentIndex] == 0) {
        //setup text field with default respective icons
        [_usernameField setupTextFieldWithIconName:@"user_name_icon"];
        [_passwordField setupTextFieldWithIconName:@"password_icon"];
    }else{
        [_usernameField setupTextFieldWithType:ASTextFieldTypeRound withIconName:@"user_name_icon"];
        [_passwordField setupTextFieldWithType:ASTextFieldTypeRound withIconName:@"password_icon"];
    }
}

- (IBAction)letMeIn:(id)sender {
    [self autoLoginIn];
}

- (void)autoLoginIn{
    if(_usernameField.text.length > 0 && _passwordField.text.length > 0){
        [self resignAllResponders];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[dataHttpManager getInstance] letPublicUserLogin:_usernameField.text password:[MyMD5 md5:_passwordField.text]];
        });
    }else{
        [self showMessageWithAlert:@"请输入用户名密码！"];
    }
}

- (IBAction)letRegister:(id)sender{
    ASRegisterViewController *registerViewController = [[ASRegisterViewController alloc] initWithNibName:@"ASRegisterViewController" bundle:nil];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController pushViewController:registerViewController animated:YES];
}
- (IBAction)letPassword:(id)sender{
    ASPasswordViewController *passwordViewController = [[ASPasswordViewController alloc] initWithNibName:@"ASPasswordViewController" bundle:nil];
     self.navigationController.navigationBarHidden = NO;
    [self.navigationController pushViewController:passwordViewController animated:YES];
}

- (void)didGetPublicUserLogin:(BOOL)success{
    [SVProgressHUD dismiss];
    if(success){
        _mapViewController = [[QDMapViewController alloc] initWithNibName:@"QDMapViewController" bundle:nil];
        _navController = [[UINavigationController alloc] init];
        [_navController pushViewController:_mapViewController animated:YES];
        [self presentViewController:_navController animated:YES completion:^{
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            if([ud objectForKey:@"USER_NAME"] == nil && [ud objectForKey:@"USER_PASSWORD"] == nil){
                [ud setObject:_usernameField.text forKey:@"USER_NAME"];
                [ud setObject:_passwordField.text forKey:@"USER_PASSWORD"];
                [ud synchronize];
            }
            
        }];
    }else{
        [self showMessageWithAlert:@"用户登录失败"];
    }
}

- (void)didGetFailed{
    [SVProgressHUD dismiss];
    [self showMessageWithAlert:@"发生了网络异常"];
}

- (void)resignAllResponders{
    [_usernameField resignFirstResponder];
    [_passwordField resignFirstResponder];
}
- (void)showMessageWithAlert:(NSString *)message{
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"黄岛治理" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    [view show];
}
- (IBAction)letRegisterIn:(id)sender{
    if(_usernameField.text.length > 0 && _passwordField.text.length > 0){
        [self resignAllResponders];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[dataHttpManager getInstance] letPublicUserRegister:self.usernameField.text password:[MyMD5 md5:self.passwordField.text]];
        });
        
    }else{
        [self showMessageWithAlert:@"请输入注册用户名密码！"];
    }
}

- (void)didGetPublicUserRegister:(BOOL)success{
    [SVProgressHUD dismiss];
    if(success){
        [self showMessageWithAlert:@"用户注册成功"];
    }else{
        [self showMessageWithAlert:@"用户注册失败"];
    }
}
- (IBAction)letPasswordIn:(id)sender{
    if(_usernameField.text.length > 0 && _passwordField.text.length > 0){
        [self resignAllResponders];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[dataHttpManager getInstance] letChangePassword:self.usernameField.text password:[MyMD5 md5:self.passwordField.text]];
        });
    }else{
        [self showMessageWithAlert:@"请输入修改用户名新密码！"];
    }
    
}

- (void)didGetChangePassword:(BOOL)success{
    [SVProgressHUD dismiss];
    if(success){
        [self showMessageWithAlert:@"修改密码成功"];
    }else{
        [self showMessageWithAlert:@"修改密码失败"];
    }
}
@end
