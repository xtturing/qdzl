//
//  NBNearSearchViewController.m
//  tdtnb
//
//  Created by xtturing on 14-7-27.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import "NBNearSearchViewController.h"
#import "NBSearchTableViewController.h"
#import "SVProgressHUD.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlyRecognizerView.h"

#define Duration 0.2
@interface NBNearSearchViewController ()<UISearchBarDelegate>{
    UITextField *fakeTextField;
    BOOL contain;
    CGPoint startPoint;
    CGPoint originPoint;
    BOOL isFirstWordToSearch;
    
}
@property (strong , nonatomic) NSMutableArray *itemArray;
@property (strong, nonatomic)NSArray *textArray;
@property (nonatomic,strong) UISearchBar *searchBar;
@property (nonatomic,strong) UIButton *hiddenBtn;
@end

@implementation NBNearSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //导航条的搜索条
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0.0f,0.0f,180.0f,44.0f)];
        _searchBar.delegate = self;
        [_searchBar setPlaceholder:@"宁波市政府"];
        float version = [[[ UIDevice currentDevice ] systemVersion ] floatValue ];
        if ([ _searchBar respondsToSelector : @selector (barTintColor)]) {
            float  iosversion7_1 = 7.1 ;
            if (version >= iosversion7_1)
            {//iOS7.1
                [[[[ _searchBar.subviews objectAtIndex : 0 ] subviews] objectAtIndex: 0 ] removeFromSuperview];
                
                [ _searchBar setBackgroundColor:[ UIColor clearColor]];
            }
            else
            {
                //iOS7.0
                [ _searchBar setBarTintColor :[ UIColor clearColor ]];
                [ _searchBar setBackgroundColor :[ UIColor clearColor ]];
            }
        }
        else
        {
            //iOS7.0 以下
            [[ _searchBar.subviews objectAtIndex: 0 ] removeFromSuperview ];
            [ _searchBar setBackgroundColor:[ UIColor clearColor ]];
        }
        
        //将搜索条放在一个UIView上
        UIView *searchView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
        searchView.backgroundColor = [UIColor clearColor];
        [searchView addSubview:_searchBar];
        
        self.navigationItem.titleView = searchView;
        
        UIButton *voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        voiceBtn.frame = CGRectMake(0, 0, 44, 40);
        [voiceBtn setImage:[UIImage imageNamed:@"icon_mircophone2"] forState:UIControlStateNormal];
        [voiceBtn addTarget:self action:@selector(speechToText) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:voiceBtn];
        self.navigationItem.rightBarButtonItem = right;
        
        for (NSInteger i = 0;i<16;i++)
        {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.backgroundColor = [UIColor clearColor];
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d",49+i]];
            btn.frame = CGRectMake(20+(i%4)*75, 60+(i/4)*75, image.size.width/2.5, image.size.height/2.5);
            btn.userInteractionEnabled = YES;
            btn.tag = i;
            [btn setImage:image forState:UIControlStateNormal];
            [self.imageView addSubview:btn];
            [btn addTarget:self action:@selector(nearSearch:) forControlEvents:UIControlEventTouchUpInside];
            UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(buttonLongPressed:)];
            [btn addGestureRecognizer:longGesture];
            [self.itemArray addObject:btn];
            
        }


    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     self.navigationItem.title = @"返回";
    _textArray = [NSArray arrayWithObjects:@"餐饮",@"酒店",@"KTV",@"公交站",@"加油站",@"电影院",@"咖啡厅",@"停车场",@"银行",@"ATM",@"超市",@"商场",@"药店",@"医院",@"公厕",nil];
    fakeTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    [fakeTextField setHidden:NO];
    fakeTextField.userInteractionEnabled =YES;
    [self.view addSubview:fakeTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.iflyRecognizerView= [[IFlyRecognizerView alloc] initWithCenter:self.view.center];
    _iflyRecognizerView.delegate = self;
    
    [_iflyRecognizerView setParameter: @"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    [_iflyRecognizerView setParameter: @"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    
    // | result_type   | 返回结果的数据格式，可设置为json，xml，plain，默认为json。
    [_iflyRecognizerView setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];

    isFirstWordToSearch = YES;
    // Do any additional setup after loading the view from its nib.
}
- (void)dealloc{
    _iflyRecognizerView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hiddenKeyBord{
    [_searchBar resignFirstResponder];
}
- (void)buttonLongPressed:(UILongPressGestureRecognizer *)sender
{
    
    UIButton *btn = (UIButton *)sender.view;
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        startPoint = [sender locationInView:sender.view];
        originPoint = btn.center;
        [UIView animateWithDuration:Duration animations:^{
            
            btn.transform = CGAffineTransformMakeScale(1.1, 1.1);
            btn.alpha = 0.7;
        }];
        
    }
    else if (sender.state == UIGestureRecognizerStateChanged)
    {
        
        CGPoint newPoint = [sender locationInView:sender.view];
        CGFloat deltaX = newPoint.x-startPoint.x;
        CGFloat deltaY = newPoint.y-startPoint.y;
        btn.center = CGPointMake(btn.center.x+deltaX,btn.center.y+deltaY);
        //NSLog(@"center = %@",NSStringFromCGPoint(btn.center));
        NSInteger index = [self indexOfPoint:btn.center withButton:btn];
        if (index<0)
        {
            contain = NO;
        }
        else
        {
            [UIView animateWithDuration:Duration animations:^{
                
                CGPoint temp = CGPointZero;
                UIButton *button = _itemArray[index];
                temp = button.center;
                button.center = originPoint;
                btn.center = temp;
                originPoint = btn.center;
                contain = YES;
                
            }];
        }
        
        
    }
    else if (sender.state == UIGestureRecognizerStateEnded)
    {
        [UIView animateWithDuration:Duration animations:^{
            
            btn.transform = CGAffineTransformIdentity;
            btn.alpha = 1.0;
            if (!contain)
            {
                btn.center = originPoint;
            }
        }];
    }
}


- (NSInteger)indexOfPoint:(CGPoint)point withButton:(UIButton *)btn
{
    for (NSInteger i = 0;i<_itemArray.count;i++)
    {
        UIButton *button = _itemArray[i];
        if (button != btn)
        {
            if (CGRectContainsPoint(button.frame, point))
            {
                return i;
            }
        }
    }
    return -1;
}
- (void)keyboardWillShow:(NSNotification *)notification {
    [self.view addSubview:self.hiddenBtn];
}


- (void)keyboardWillHide:(NSNotification *)notification {
    [_hiddenBtn removeFromSuperview];
    
}
-(UIButton *)hiddenBtn{
    if(!_hiddenBtn){
        _hiddenBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-200)];
        [_hiddenBtn setBackgroundColor:[UIColor clearColor]];
        [_hiddenBtn addTarget:self action:@selector(hiddenKeyBord) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hiddenBtn;
}
#pragma  mark -speechToText

-(void)speechToText{
    _searchBar.text = @"";
    [_searchBar resignFirstResponder];
    [_iflyRecognizerView start];
    isFirstWordToSearch = YES;
}


- (void)nearSearch:(id)sender{
    
    UIButton *btn = (UIButton *)sender;
    if(btn.tag < 15 && _location){
        NBSearchTableViewController *searchViewController = [[NBSearchTableViewController alloc] init];
        searchViewController.searchText = [_textArray objectAtIndex:btn.tag];
        searchViewController.searchType = AFRadiusSearch;
        searchViewController.location = [NSString stringWithFormat:@"%lf,%lf",_location.coordinate.latitude,_location.coordinate.longitude];
        _searchBar.text = [_textArray objectAtIndex:btn.tag];
        [self.navigationController pushViewController:searchViewController animated:YES];
    }    
}
#pragma mark -UISearchBarDelegate

//点击键盘上的search按钮时调用

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar

{
    [searchBar resignFirstResponder];
    [self doSearch];
}

- (void)doSearch{
    if(_searchBar.text.length>0){
        NBSearchTableViewController *searchViewController = [[NBSearchTableViewController alloc] init];
        searchViewController.searchText = _searchBar.text;
        searchViewController.searchType = AFKeySearch;
        [self.navigationController pushViewController:searchViewController animated:YES];
    }
}

//cancel按钮点击时调用

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar

{
    
    searchBar.text = @"";
    
    [searchBar resignFirstResponder];
    
}
#pragma mark IFlyRecognizerViewDelegate
/** 识别结果回调方法
 @param resultArray 结果列表
 @param isLast YES 表示最后一个，NO表示后面还有结果
 */
- (void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = [resultArray objectAtIndex:0];
    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
    }
    if(isFirstWordToSearch && result.length > 0){
        isFirstWordToSearch = NO;
        _searchBar.text = [NSString stringWithFormat:@"%@",result];
        [self performSelector:@selector(doSearch) withObject:nil afterDelay:1.0];
    }
}

/** 识别结束回调方法
 @param error 识别错误
 */
- (void)onError:(IFlySpeechError *)error
{
    NSLog(@"errorCode:%d",[error errorCode]);
}



@end
