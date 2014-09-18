//
//  NBSearchDetailViewController.m
//  tdtnb
//
//  Created by xtturing on 14-7-30.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import "NBSearchDetailViewController.h"
#import "NBSearchTableViewController.h"
@interface NBSearchDetailViewController ()

@property (strong, nonatomic) UIView *viewCell;
@property (nonatomic,strong)  UIView *imageViewCell;
@property (strong, nonatomic)NSArray *textArray;
@end

@implementation NBSearchDetailViewController

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
    self.navigationItem.title = _detail.name;
    _textArray = [NSArray arrayWithObjects:@"餐饮",@"酒店",@"KTV",@"公交站",@"加油站",@"电影院",@"咖啡厅",@"停车场",@"银行",@"ATM",@"超市",@"商场",@"药店",@"医院",@"公厕",nil];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return  80;
    }else if (indexPath.section ==1)
    {
        return 44;
    }else{
        return 360;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuseIdetify = @"TableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdetify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdetify];
        cell.backgroundColor = [UIColor whiteColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.backgroundColor = [UIColor clearColor];
    if(indexPath.section == 0){
        cell.textLabel.text = _detail.name;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"地址：%@\t\n联系电话：%@",_detail.address,_detail.telephone];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.numberOfLines = 0;
        cell.accessoryView = nil;
    }else if (indexPath.section ==1)
    {
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = nil;
        cell.accessoryView.frame= CGRectMake(0, 0, CGRectGetWidth(cell.frame), CGRectGetHeight(cell.frame));
        cell.accessoryView = self.viewCell;
       
    }else{
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = nil;
        cell.accessoryView.frame= CGRectMake(0, 0, CGRectGetWidth(cell.frame), CGRectGetHeight(cell.frame));
        cell.accessoryView = self.imageViewCell;
        
    }
    return cell;
}

-(UIView *)viewCell{
    if(!_viewCell){
        _viewCell = [[UIView alloc ] initWithFrame:CGRectMake(0, 0, 300, 44)];
        UIButton *btn1 = [self addButton:@"gpsPoint" title:@"定位"];
        btn1.frame = CGRectMake(0, 0, 100, 44);
        [btn1 addTarget:self action:@selector(gpsPoint:) forControlEvents:UIControlEventTouchUpInside];
        [_viewCell addSubview:btn1];
        UIButton *btn2 = nil;
        if([self hasFavoritePoint]){
           btn2 = [self addButton:@"favPoint" title:@"已收藏"];
           btn2.enabled = NO;
        }else{
            btn2 = [self addButton:@"favPoint" title:@"收藏"];
        }
        btn2.frame = CGRectMake(100, 0, 100, 44);
        [btn2 addTarget:self action:@selector(favPoint:) forControlEvents:UIControlEventTouchUpInside];
        [_viewCell addSubview:btn2];
        UIButton *btn3 = [self addButton:@"sharePoint" title:@"分享"];
        btn3.enabled = NO;
        btn3.frame = CGRectMake(200, 0, 100, 44);
        [btn3 addTarget:self action:@selector(sharePoint:) forControlEvents:UIControlEventTouchUpInside];
        [_viewCell addSubview:btn3];
    }
    return _viewCell;
}

- (UIView *)imageViewCell{
    if(!_imageViewCell){
        _imageViewCell = [[UIView alloc ] initWithFrame:CGRectMake(0, 0, 300, 360)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 20)];
        label.text = @"在周边找";
        [_imageViewCell addSubview:label];
        for (NSInteger i = 0;i<16;i++)
        {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.backgroundColor = [UIColor clearColor];
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d",49+i]];
            btn.frame = CGRectMake(20+(i%4)*75, 60+(i/4)*75, image.size.width/2.5, image.size.height/2.5);
            btn.userInteractionEnabled = YES;
            btn.tag = i;
            [btn setImage:image forState:UIControlStateNormal];
            [self.imageViewCell addSubview:btn];
            [btn addTarget:self action:@selector(nearSearch:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return _imageViewCell;
}

-(UIButton *)addButton:(NSString *)imageName title:(NSString *)titleName{
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn1.imageView setContentMode:UIViewContentModeCenter];
    [btn1 setImageEdgeInsets:UIEdgeInsetsMake(14,
                                              7,
                                              14,
                                              7)];
    [btn1 setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    
    [btn1.titleLabel setContentMode:UIViewContentModeCenter];
    [btn1.titleLabel setBackgroundColor:[UIColor clearColor]];
    [btn1.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [btn1 setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];

    [btn1 setTitleEdgeInsets:UIEdgeInsetsMake(0.0,
                                              30.0,
                                              0.0,
                                              0.0)];
    [btn1 setTitle:titleName forState:UIControlStateNormal];
    return btn1;
}

- (void)gpsPoint:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SearchDetailGPSPoint" object:nil userInfo:[NSDictionary dictionaryWithObject:_detail forKey:@"detail"]];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)favPoint:(id)sender{
    UIButton *btn = (UIButton *)sender;
    [btn setTitle:@"已收藏" forState:UIControlStateNormal];
    btn.enabled = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *array = [defaults objectForKey:@"FAVORITES_POINT"];
        if(array == nil){
            array = [[NSMutableArray alloc] init];
        }
        NSMutableArray *mArray = [NSMutableArray arrayWithArray:array];
        NSData *object = [NSKeyedArchiver archivedDataWithRootObject:_detail];
        [mArray addObject:object];
        [defaults setObject:(NSArray *)mArray forKey:@"FAVORITES_POINT" ];
        [defaults synchronize];
    });
}
- (void)sharePoint:(id)sender{}

- (void)nearSearch:(id)sender{
    
    UIButton *btn = (UIButton *)sender;
    if(btn.tag < 15){
        NBSearchTableViewController *searchViewController = [[NBSearchTableViewController alloc] init];
        searchViewController.searchText = [_textArray objectAtIndex:btn.tag];
        searchViewController.searchType = AFRadiusSearch;
        searchViewController.location = [NSString stringWithFormat:@"%lf,%lf",[[_detail.location objectForKey:@"lat"] doubleValue],[[_detail.location objectForKey:@"lng"] doubleValue]];
        [self.navigationController pushViewController:searchViewController animated:YES];
    }
}

- (BOOL)hasFavoritePoint{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *array = [defaults objectForKey:@"FAVORITES_POINT"];
    if(array == nil){
        return NO;
    }
    for(NSData *data in array){
        NBSearch *detail = [NSKeyedUnarchiver unarchiveObjectWithData:data ];
        if([detail.uid isEqualToString:_detail.uid] && [detail.name isEqualToString:_detail.name] ){
            return YES;
        }
    }
    return NO;
}
@end
