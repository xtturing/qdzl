//
//  QDEditViewController.h
//  qdzl
//
//  Created by xtturing on 14-9-28.
//
//

#import <UIKit/UIKit.h>
#import "SVProgressHUD.h"

@interface QDEditViewController : UIViewController

@property(nonatomic, strong) IBOutlet UITableView *tableView;
@property(nonatomic,strong)AGSPoint *gpsPoint;

@end
