//
//  ASViewController.h
//  ASTextViewDemo
//
//  Created by Adil Soomro on 4/14/14.
//  Copyright (c) 2014 Adil Soomro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "dataHttpManager.h"
#import "SVProgressHUD.h"
#import "MyMD5.h"

@interface ASViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;

//cells
@property (strong, nonatomic) IBOutlet UITableViewCell *usernameCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *passwordCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *phoneCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *doneCell;

//fields
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *phoneField;
@property (strong, nonatomic) IBOutlet UITextView *messageView;
@property (strong, nonatomic) IBOutlet UIButton *backButton;

- (void)resignAllResponders;

- (IBAction)changeFieldBackground:(id)sender;
- (IBAction)letMeIn:(id)sender;
- (IBAction)letRegister:(id)sender;
- (IBAction)letRegisterIn:(id)sender;
- (IBAction)letPassword:(id)sender;
- (IBAction)letPasswordIn:(id)sender;
- (IBAction)doBack:(id)sender;
- (void)showMessageWithAlert:(NSString *)message;
@end
