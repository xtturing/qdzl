//
//  LCVoice.m
//  LCVoiceHud
//
//

#import "LCVoice.h"
#import "LCVoiceHud.h"
#import <AVFoundation/AVFoundation.h>

#pragma mark - <DEFINES>

#define WAVE_UPDATE_FREQUENCY   0.05

#pragma mark - <CLASS> LCVoice

@interface LCVoice () <AVAudioRecorderDelegate>
{
    NSTimer * timer_;
    
    LCVoiceHud * voiceHud_;    
}

@property(nonatomic,strong) AVAudioRecorder * recorder;

@end

@implementation LCVoice

-(void) dealloc{
    
    if (self.recorder.isRecording) {
        [self.recorder stop];
    }
    
    self.recorder = nil;
    self.recordPath = nil;
    
}

#pragma mark - Publick Function

-(void)startRecordWithPath:(NSString *)path
{    
    NSError * err = nil;
    
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	[audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    
	if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
	}
    
	[audioSession setActive:YES error:&err];
    
	err = nil;
	if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
	}
	
	NSMutableDictionary * recordSetting = [NSMutableDictionary dictionary];
	
//	[recordSetting setValue :[NSNumber numberWithInt:kAudioFormatAppleIMA4] forKey:AVFormatIDKey];
//	[recordSetting setValue:[NSNumber numberWithFloat:16000.0] forKey:AVSampleRateKey];
//	[recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    //录音格式 无法使用
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey: AVFormatIDKey];
    //采样率
    [recordSetting setValue :[NSNumber numberWithFloat:11025.0] forKey: AVSampleRateKey];//44100.0
    //通道数
    [recordSetting setValue :[NSNumber numberWithInt:2] forKey: AVNumberOfChannelsKey];
    //线性采样位数
    //[recordSettings setValue :[NSNumber numberWithInt:16] forKey: AVLinearPCMBitDepthKey];
    //音频质量,采样质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    
	
/*
	[recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
	[recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
	[recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
*/
     
	self.recordPath = path;
	NSURL * url = [NSURL fileURLWithPath:self.recordPath];
	
	err = nil;
	
	NSData * audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&err];
    
	if(audioData)
	{
		NSFileManager *fm = [NSFileManager defaultManager];
		[fm removeItemAtPath:[url path] error:&err];
	}
	
	err = nil;
    
    if(self.recorder){[self.recorder stop];self.recorder = nil;}
    
	self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err] ;
    
	if(!_recorder){
        NSLog(@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"警告"
								   message: [err localizedDescription]
								  delegate: nil
						 cancelButtonTitle:@"确定"
						 otherButtonTitles:nil];
        [alert show];
        return;
	}
	
	[_recorder setDelegate:self];
	[_recorder prepareToRecord];
	_recorder.meteringEnabled = YES;
	
	BOOL audioHWAvailable = audioSession.inputIsAvailable;
	if (! audioHWAvailable) {
        UIAlertView *cantRecordAlert =
        [[UIAlertView alloc] initWithTitle: @"警告"
								   message: @"音频输入故障"
								  delegate: nil
						 cancelButtonTitle:@"确定"
						 otherButtonTitles:nil];
        [cantRecordAlert show];
        return;
	}
	
	[_recorder recordForDuration:(NSTimeInterval) 60];
    
    self.recordTime = 0;
    [self resetTimer];
    
	timer_ = [NSTimer scheduledTimerWithTimeInterval:WAVE_UPDATE_FREQUENCY target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
    
    [self showVoiceHudOrHide:YES];

}

-(void) stopRecordWithCompletionBlock:(void (^)())completion
{    
    dispatch_async(dispatch_get_main_queue(),completion);

    [self resetTimer];
    [self showVoiceHudOrHide:NO];
}

#pragma mark - Timer Update

- (void)updateMeters {
    
    self.recordTime += WAVE_UPDATE_FREQUENCY;
    
    if (voiceHud_)
    {
        /*  发送updateMeters消息来刷新平均和峰值功率。
         *  此计数是以对数刻度计量的，-160表示完全安静，
         *  0表示最大输入值
         */
        
        if (_recorder) {
            [_recorder updateMeters];
        }
    
        float peakPower = [_recorder averagePowerForChannel:0];
        double ALPHA = 0.05;
        double peakPowerForChannel = pow(10, (ALPHA * peakPower));
    
        [voiceHud_ setProgress:peakPowerForChannel];
    }
}

#pragma mark - Helper Function

-(void) showVoiceHudOrHide:(BOOL)yesOrNo{
    
    if (voiceHud_) {
        [voiceHud_ hide];
        voiceHud_ = nil;
    }
    
    if (yesOrNo) {
        
        voiceHud_ = [[LCVoiceHud alloc] init];
        [voiceHud_ show];
        
    }else{
        
    }
}

-(void) resetTimer
{    
    if (timer_) {
        [timer_ invalidate];
        timer_ = nil;
    }
}

-(void) cancelRecording
{
    if (self.recorder.isRecording) {
        [self.recorder stop];
    }
    
    self.recorder = nil;    
}

- (void)cancelled {
    
    [self showVoiceHudOrHide:NO];
    [self resetTimer];
    [self cancelRecording];
}

#pragma mark - LCVoiceHud Delegate

-(void) LCVoiceHudCancelAction
{
    [self cancelled];
}

@end
