//
//  textInputViewController.m
//  qdzl
//
//  Created by xtturing on 14-10-8.
//
//

#import "textInputViewController.h"

@interface textInputViewController ()

@end

@implementation textInputViewController

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
    self.title = @"事件描述";
    self.textView.text = _textStr;
    self.textView.delegate = self;
    [self.textView becomeFirstResponder];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self leaveEditMode];
        return NO;
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    UIBarButtonItem *done =    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(leaveEditMode)];
    
    self.navigationItem.rightBarButtonItem = done;
    
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    self.navigationItem.rightBarButtonItem = nil;
    
}

- (void)leaveEditMode {
    
    [self.textView resignFirstResponder];
    if(_delegate && [_delegate respondsToSelector:@selector(didFinishTextInputView:)]){
        [_delegate didFinishTextInputView:self.textView.text];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}
@end
