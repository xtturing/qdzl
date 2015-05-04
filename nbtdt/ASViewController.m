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
#import <QuartzCore/QuartzCore.h>

@interface ASViewController ()<dataHttpDelegate>{
    BOOL keybordWasShow;
}

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
    keybordWasShow = NO;
    //bake a cellArray to contain all cells
    if(_phoneCell){
       self.cellArray = [NSMutableArray arrayWithObjects: _usernameCell, _passwordCell, _phoneCell,_doneCell, nil];
    }else{
       self.cellArray = [NSMutableArray arrayWithObjects: _usernameCell, _passwordCell, _doneCell, nil];
    }
    
    //setup text field with respective icons
    [_usernameField setupTextFieldWithIconName:@"user_name_icon"];
    [_passwordField setupTextFieldWithIconName:@"password_icon"];
    if(_phoneField){
        [_phoneField setupTextFieldWithIconName:@"phone"];
    }
    _passwordField.secureTextEntry = YES;
    _messageView.layer.borderColor = [UIColor whiteColor].CGColor;
    _messageView.layer.borderWidth =1.0;
    _messageView.layer.cornerRadius =5.0;
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)doBack:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    if(!keybordWasShow){
        keybordWasShow = YES;
        CGRect curFrame=self.view.frame;
        curFrame.origin.y -= 90;
        [UIView animateWithDuration:0.3f animations:^{
            self.view.frame=curFrame;
        }];
    }
    
}

//当键盘隐藏的时候
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    if(keybordWasShow){
        keybordWasShow = NO;
        CGRect curFrame=self.view.frame;
        curFrame.origin.y += 90;
        [UIView animateWithDuration:0.3f animations:^{
            self.view.frame=curFrame;
        }];
    }
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
//    self.navigationController.navigationBarHidden = NO;
    [self presentViewController:registerViewController animated:YES completion:^{
        
    }];
}
- (IBAction)letPassword:(id)sender{
    ASPasswordViewController *passwordViewController = [[ASPasswordViewController alloc] initWithNibName:@"ASPasswordViewController" bundle:nil];
//     self.navigationController.navigationBarHidden = NO;
    [self presentViewController:passwordViewController animated:YES completion:^{
        
    }];
}

- (void)didGetPublicUserLogin:(BOOL)success{
    [SVProgressHUD dismiss];
    if(success){
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if([ud objectForKey:@"USER_NAME"] == nil && [ud objectForKey:@"USER_PASSWORD"] == nil){
            [ud setObject:_usernameField.text forKey:@"USER_NAME"];
            [ud setObject:_passwordField.text forKey:@"USER_PASSWORD"];
            [ud synchronize];
        }
        _mapViewController = [[QDMapViewController alloc] initWithNibName:@"QDMapViewController" bundle:nil];
        _navController = [[UINavigationController alloc] init];
        [_navController pushViewController:_mapViewController animated:YES];
        [self presentViewController:_navController animated:YES completion:^{
            
        }];
    }else{
        [self showMessageWithAlert:@"用户登录失败"];
    }
}

- (void)didGetFailed{
    [SVProgressHUD dismiss];
    [self showMessageWithAlert:@"非常抱歉，发生了网络异常！"];
}

- (void)resignAllResponders{
    [_usernameField resignFirstResponder];
    [_passwordField resignFirstResponder];
    if(_phoneField){
        [_phoneField resignFirstResponder];
    }
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
            [[dataHttpManager getInstance] letPublicUserRegister:self.usernameField.text password:[MyMD5 md5:self.passwordField.text] phone:self.phoneField.text];
        });
        
    }else{
        [self showMessageWithAlert:@"请输入注册用户名密码！"];
    }
}

- (void)didGetPublicUserRegister:(BOOL)success{
    [SVProgressHUD dismiss];
    if(success){
        [self showMessageWithAlert:@"用户注册成功"];
        if(_backButton){
            [_backButton setTitle:@"完成" forState:UIControlStateNormal];
        }
    }else{
        [self showMessageWithAlert:@"用户注册失败"];
        if(_backButton){
            [_backButton setTitle:@"取消" forState:UIControlStateNormal];
        }
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
        if(_backButton){
            [_backButton setTitle:@"完成" forState:UIControlStateNormal];
        }
    }else{
        [self showMessageWithAlert:@"修改密码失败"];
        if(_backButton){
            [_backButton setTitle:@"取消" forState:UIControlStateNormal];
        }
    }
}
@end
