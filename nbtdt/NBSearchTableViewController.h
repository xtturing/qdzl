//
//  NBSearchTableViewController.h
//  tdtnb
//
//  Created by xtturing on 14-8-5.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import "PullRefreshTableViewController.h"
typedef enum {
    AFKeySearch = 0,
    AFRadiusSearch,
} AFSearchType;

@interface NBSearchTableViewController : PullRefreshTableViewController
@property(nonatomic, strong) NSString *searchText;
@property(nonatomic, assign) AFSearchType searchType;
@property(nonatomic, strong) NSString *location;
@end
