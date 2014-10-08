//
//  textInputViewController.h
//  qdzl
//
//  Created by xtturing on 14-10-8.
//
//

#import <UIKit/UIKit.h>
@protocol textInputViewDelegate <NSObject>

@optional
- (void)didFinishTextInputView:(NSString *)textStr;

@end
@interface textInputViewController : UIViewController<UITextViewDelegate>

@property (nonatomic,assign) id<textInputViewDelegate> delegate;
@property (nonatomic,strong) NSString *textStr;

@property (nonatomic, strong) IBOutlet UITextView *textView;

@end
