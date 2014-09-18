//
//  NBToolView.m
//  tdtnb
//
//  Created by xtturing on 14-7-27.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import "NBToolView.h"

@interface NBToolView()
    
@property (nonatomic, strong) UIView *labelView;

@end

@implementation NBToolView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews{
    self.backgroundColor = [UIColor clearColor];
    
    _labelView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 25)];
    [_labelView setBackgroundColor: [UIColor colorWithWhite:1.0f alpha:0.0f]];
    _labelView.hidden = YES;
    [self addSubview:_labelView];
    
    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_labelView.frame), CGRectGetWidth(self.frame), 45)];
    buttonView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    [self addSubview:buttonView];
    
    _label = [[UILabel alloc] initWithFrame:_labelView.bounds];
    _label.font = [UIFont systemFontOfSize:14];
    _label.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    _label.textColor = [UIColor whiteColor];
    [_labelView addSubview:_label];
    
    UIView *line0 = [[UIView alloc ] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 1)];
    line0.backgroundColor = [UIColor whiteColor];
    [buttonView addSubview:line0];
    
    UIButton *down = [UIButton buttonWithType:UIButtonTypeCustom];
    down.frame = CGRectMake(0, 1, 53, 44);
    down.backgroundColor = [UIColor clearColor];
    [down setTitle: @"离线" forState: UIControlStateNormal];
    [down setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [down setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    down.titleLabel.font = [UIFont systemFontOfSize:14];
    [down addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    down.tag = 100;
    [buttonView addSubview:down];
    
    UIView *line = [[UIView alloc ] initWithFrame:CGRectMake(CGRectGetMaxX(down.frame), 0, 1, 44)];
    line.backgroundColor = [UIColor whiteColor];
    [buttonView addSubview:line];
    
    UIButton *down1 = [UIButton buttonWithType:UIButtonTypeCustom];
    down1.frame = CGRectMake(CGRectGetMaxX(line.frame), 1, 53, 44);
    down1.backgroundColor = [UIColor clearColor];
    [down1 setTitle: @"测距" forState: UIControlStateNormal];
    [down1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [down1 setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    down1.titleLabel.font = [UIFont systemFontOfSize:14];
    [down1 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    down1.tag = 101;
    [buttonView addSubview:down1];
    
    UIView *line1 = [[UIView alloc ] initWithFrame:CGRectMake(CGRectGetMaxX(down1.frame), 0, 1, 44)];
    line1.backgroundColor = [UIColor whiteColor];
    [buttonView addSubview:line1];
    
    UIButton *down2 = [UIButton buttonWithType:UIButtonTypeCustom];
    down2.frame = CGRectMake(CGRectGetMaxX(line1.frame), 1, 53, 44);
    down2.backgroundColor = [UIColor clearColor];
    [down2 setTitle: @"测面" forState: UIControlStateNormal];
    [down2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [down2 setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    down2.titleLabel.font = [UIFont systemFontOfSize:14];
    [down2 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    down2.tag = 102;
    [buttonView addSubview:down2];
    
    UIView *line2 = [[UIView alloc ] initWithFrame:CGRectMake(CGRectGetMaxX(down2.frame), 0, 1, 44)];
    line2.backgroundColor = [UIColor whiteColor];
    [buttonView addSubview:line2];
    
    UIButton *down3 = [UIButton buttonWithType:UIButtonTypeCustom];
    down3.frame = CGRectMake(CGRectGetMaxX(line2.frame), 1, 52, 44);
    down3.backgroundColor = [UIColor clearColor];
    [down3 setTitle: @"截图" forState: UIControlStateNormal];
    [down3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [down3 setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    down3.titleLabel.font = [UIFont systemFontOfSize:14];
    [down3 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    down3.tag = 103;
    [buttonView addSubview:down3];
    
    UIView *line3 = [[UIView alloc ] initWithFrame:CGRectMake(CGRectGetMaxX(down3.frame), 0, 1, 44)];
    line3.backgroundColor = [UIColor whiteColor];
    [buttonView addSubview:line3];
    
    UIButton *down4 = [UIButton buttonWithType:UIButtonTypeCustom];
    down4.frame = CGRectMake(CGRectGetMaxX(line3.frame), 1, 52, 44);
    down4.backgroundColor = [UIColor clearColor];
    [down4 setTitle: @"纠错" forState: UIControlStateNormal];
    [down4 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [down4 setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    down4.titleLabel.font = [UIFont systemFontOfSize:14];
    [down4 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    down4.tag = 104;
    [buttonView addSubview:down4];
    
    UIView *line4 = [[UIView alloc ] initWithFrame:CGRectMake(CGRectGetMaxX(down4.frame), 0, 1, 44)];
    line4.backgroundColor = [UIColor whiteColor];
    [buttonView addSubview:line4];
    
    UIButton *down5 = [UIButton buttonWithType:UIButtonTypeCustom];
    down5.frame = CGRectMake(CGRectGetMaxX(line4.frame), 1, 52, 44);
    down5.backgroundColor = [UIColor clearColor];
    [down5 setTitle: @"清空" forState: UIControlStateNormal];
    [down5 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [down5 setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    down5.titleLabel.font = [UIFont systemFontOfSize:14];
    [down5 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    down5.tag = 105;
    [buttonView addSubview:down5];
}


-(void)buttonClick:(id)sender{
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case 100:
        {
            _labelView.hidden = YES;
            if(self.delegate && [self.delegate respondsToSelector:@selector(toolButtonClick:)]){
                [self.delegate toolButtonClick:100];
            }
        }
            break;
        case 101:
        {
            _labelView.hidden = NO;
            _label.text = @"请在地图上点击画线测量距离";
            if(self.delegate && [self.delegate respondsToSelector:@selector(toolButtonClick:)]){
                [self.delegate toolButtonClick:101];
            }
            
        }
            break;
            
        case 102:
        {
            _labelView.hidden = NO;
            _label.text = @"请在地图上点击画面测量面积";
            if(self.delegate && [self.delegate respondsToSelector:@selector(toolButtonClick:)]){
                [self.delegate toolButtonClick:102];
            }
            
        }
            break;
            
        case 103:
        {
            _labelView.hidden = YES;
            if(self.delegate && [self.delegate respondsToSelector:@selector(toolButtonClick:)]){
                [self.delegate toolButtonClick:103];
            }
            
        }
            break;
            
        case 104:
        {
            _labelView.hidden = NO;
            _label.text = @"请在地图上点击纠错";
            if(self.delegate && [self.delegate respondsToSelector:@selector(toolButtonClick:)]){
                [self.delegate toolButtonClick:104];
            }
            
        }
            break;
            
        case 105:
        {
            _labelView.hidden = YES;
            if(self.delegate && [self.delegate respondsToSelector:@selector(toolButtonClick:)]){
                [self.delegate toolButtonClick:105];
            }
            
        }
            break;
            
        default:
            break;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
