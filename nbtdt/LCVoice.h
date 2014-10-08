//
//  LCVoice.h
//  LCVoiceHud
//

#import <Foundation/Foundation.h>

@interface LCVoice : NSObject

@property(nonatomic,strong) NSString * recordPath;
@property(nonatomic) float recordTime;

-(void) startRecordWithPath:(NSString *)path;
-(void) stopRecordWithCompletionBlock:(void (^)())completion;
-(void) cancelled;

@end
