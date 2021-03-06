//
//  QDSearchViewController.m
//  qdzl
//
//  Created by xtturing on 14-9-28.
//
//

#import "QDSearchViewController.h"
#import "QDSearchDetailViewController.h"
@interface QDSearchViewController ()

@property (nonatomic, strong) NSMutableArray *uids;
@property (nonatomic, strong) NSMutableArray *results;

@end

@implementation QDSearchViewController

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
    self.navigationItem.title = @"处置进度";
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    self.uids = [NSMutableArray arrayWithArray:[ud objectForKey:[ud objectForKey:@"USER_NAME"]]];
    self.results = [NSMutableArray arrayWithArray:_uids];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _results.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuseIdetifyPoint = @"TableViewCellPoint";
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:reuseIdetifyPoint];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdetifyPoint];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.numberOfLines = 1;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    cell.detailTextLabel.numberOfLines = 2;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.minimumScaleFactor = 0.5;
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    cell.detailTextLabel.minimumScaleFactor = 0.5;
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    //用[NSDate date]可以获取系统当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[_results objectAtIndex:indexPath.row] doubleValue]/1000]];
    cell.textLabel.text = [NSString stringWithFormat:@"%d、%@ (%@)",indexPath.row+1,currentDateStr,[_results objectAtIndex:indexPath.row]];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dic = [ud objectForKey:[_results objectAtIndex:indexPath.row]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"事件描述:%@",[dic objectForKey:@"SJMS"]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    QDSearchDetailViewController *searchDetailViewController = [[QDSearchDetailViewController alloc] initWithNibName:@"QDSearchDetailViewController" bundle:nil];
    searchDetailViewController.uid = [_results objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:searchDetailViewController animated:YES];
}
// UISearchBar得到焦点并开始编辑时，执行该方法
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    [self.searchBar setShowsCancelButton:YES animated:YES];
    return YES;
    
}

// 取消按钮被按下时，执行的方法
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    _results = [NSMutableArray arrayWithArray:_uids];
     [self.tableView reloadData];
}

// 键盘中，搜索按钮被按下，执行的方法
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"---%@",searchBar.text);
    [self.searchBar resignFirstResponder];// 放弃第一响应者
    [self searchFilter:searchBar.text];
}

// 当搜索内容变化时，执行该方法。很有用，可以实现时实搜索
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;{
    NSLog(@"textDidChange---%@",searchBar.text);
    [self searchFilter:searchBar.text];
}

- (void)searchFilter:(NSString *)str{
    if(str.length > 0){
        NSPredicate *inputPredicate=[NSPredicate predicateWithFormat:@"(SELF contains[cd] %@)",str];
        _results = [NSMutableArray arrayWithArray:[_uids filteredArrayUsingPredicate:inputPredicate]];
    }else{
       _results = [NSMutableArray arrayWithArray:_uids];
    }
    [self.tableView reloadData];
}
@end
