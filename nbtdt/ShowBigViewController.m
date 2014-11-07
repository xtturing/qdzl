//
//  ShowBigViewController.m
//  testKeywordDemo
//
//  Created by mei on 14-8-18.
//  Copyright (c) 2014年 Bluewave. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import "ShowBigViewController.h"
#define IOS7LATER  [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0
@interface ShowBigViewController ()

@end

@implementation ShowBigViewController

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
    if(_showButton){
        self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"完成", nil)
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(complete:)];
    }else{
        self.navigationItem.title = @"帮助";
        if(_showVersion){
            self.navigationItem.title = @"关于";
        }
    }
    [self layOut];
    
}

-(void)layOut{
    self.view.backgroundColor = [UIColor blackColor];
            //arrayOK里存放选中的图片
   
    //CGFloat YHeight=([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)?(64.0f):(44.0f);
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (IOS7LATER)
    {
        _scrollerview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - (_showButton?50:0))];
         _btnOK = [[UIButton alloc]initWithFrame:CGRectMake(244,  _scrollerview.frame.size.height + 9, 61, 32)];
    }
#endif
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
    }
    else
    {
        _scrollerview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height- (_showButton?100:0))];
         _btnOK = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 76,  _scrollerview.frame.size.height + 11, 61, 32)];
    }
    
    
    //显示选中的图片的大图
  
    _scrollerview.backgroundColor = [UIColor whiteColor];
    _scrollerview.delegate = self;
    NSLog(@"self.arrayOK.count is %d",self.arrayOK.count);
 
    for (int i=0; i<[self.arrayOK count]; i++) {
        UIImageView *imgview=[[UIImageView alloc] initWithFrame:CGRectMake(i*_scrollerview.frame.size.width, 0, _scrollerview.frame.size.width, _scrollerview.frame.size.height)];
        imgview.contentMode=UIViewContentModeScaleAspectFill;
        imgview.clipsToBounds=YES;
        if([self.arrayOK[i] isKindOfClass:[ALAsset class]]){
            ALAsset *asset=self.arrayOK[i];
            UIImage *tempImg=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
            [imgview setImage:tempImg];
        }else{
            [imgview setImage:(UIImage *)self.arrayOK[i]];
        }
        [_scrollerview addSubview:imgview];
    }
    
    _scrollerview.contentSize = CGSizeMake((self.arrayOK.count) * (self.view.frame.size.width),0);
    [self.view addSubview:_scrollerview];
    
    
    //点击按钮，回到主发布页面
    if(_showButton){
        [_btnOK setBackgroundImage:[UIImage imageNamed:@"complete.png"] forState:UIControlStateNormal];
        
        [_btnOK setTitle:[NSString stringWithFormat:@"完成(%d)",self.arrayOK.count] forState:UIControlStateNormal];
        _btnOK .titleLabel.font = [UIFont systemFontOfSize:10];
        [_btnOK addTarget:self action:@selector(complete:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_btnOK];
    }
    if(_showVersion){
        [_btnOK setTitle:[NSString stringWithFormat:@"版本:%@",[NSString stringWithFormat:@"V%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey]]] forState:UIControlStateNormal];
        _btnOK .titleLabel.font = [UIFont systemFontOfSize:15];
        _btnOK.frame = CGRectMake((CGRectGetWidth(self.view.frame)-100)/2, CGRectGetHeight(self.view.frame)*6/7, 100, 20);
        [self.view addSubview:_btnOK];
    }
}
-(void)complete:(UIButton *)sender{
    NSLog(@"完成了,跳到主发布页面");
    [self dismissViewControllerAnimated:YES completion:Nil];
}

-(void)OK:(UIButton *)sender{
    NSLog(@"点击了按钮，就取消选中这个图片");
    
}

-(void)dismiss{

    [self.navigationController popViewControllerAnimated:YES];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
