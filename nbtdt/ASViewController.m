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
#import "dataHttpManager.h"
#import "SVProgressHUD.h"
#import "MyMD5.h"

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
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [dataHttpManager getInstance].delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated{
    [dataHttpManager getInstance].delegate =  nil;
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
    [self resignAllResponders];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[dataHttpManager getInstance] letPublicUserLogin:_usernameField.text password:[MyMD5 md5:_passwordField.text]];
    });
    
}

- (void)didGetPublicUserLogin:(BOOL)success{
    [SVProgressHUD dismiss];
    if(success){
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
    [self showMessageWithAlert:@"用户登录异常"];
}

- (void)resignAllResponders{
    [_usernameField resignFirstResponder];
    [_passwordField resignFirstResponder];
}
- (void)showMessageWithAlert:(NSString *)message{
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"黄岛治理" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    [view show];
}
@end
