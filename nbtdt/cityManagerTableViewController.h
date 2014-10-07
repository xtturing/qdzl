//
//  cityManagerTableViewController.h
//  qdzl
//
//  Created by xtturing on 14-10-7.
//
//

#import <UIKit/UIKit.h>

@protocol cityManagerDelegate <NSObject>

@optional
- (void)didSelectedCityManager:(NSString *)cityManagerName;

@end

@interface cityManagerTableViewController : UITableViewController

@property (nonatomic,assign) id<cityManagerDelegate> delegate;
@property (nonatomic,strong) NSString *cityManagerName;

@end
