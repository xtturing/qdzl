//
//  DownloadItem.h
//  DownloadDemo
//
//  Created by Peter Yuen on 6/26/14.
//  Copyright (c) 2014 CocoaRush. All rights reserved.
//

#import "ASIHTTPRequest.h"
#import "NBTpk.h"
typedef enum  {
    DownloadNotStart=0,
    DownloadWait=1,
    Downloading,
    DownloadPaused,
    DownloadFailed,
    DownloadFinished,
}DownloadItemState;

#define kDownloadItemStateChanaged @"DownloadItemStateChanged"
#define kDownloadItemProgressChanged @"DownloadItemProgressChanged"

@interface DownloadItem : ASIHTTPRequest<ASIProgressDelegate,ASIHTTPRequestDelegate>
@property(nonatomic,retain)NBTpk *tpk;
@property(nonatomic,assign)DownloadItemState downloadState;
@property(nonatomic,retain)NSString *downloadStateDescription;
@property(nonatomic,retain)NSDate *createDate;
@property(nonatomic,assign)double receivedLength;
@property(nonatomic,assign)double totalLength;
@property(nonatomic,assign)double downloadPercent;
@property(nonatomic,copy)void(^DownloadItemStateChangedCallback)(DownloadItem *callbackItem);
@property(nonatomic,copy)void(^DownloadItemProgressChangedCallback)(DownloadItem *callbackItem);


-(void)startDownloadTask;
-(void)pauseDownloadTask;
-(void)cancelDownloadTask;
-(void)deleteDownloadTask;

+(NSString *)getDownloadStateDescriptionFromState:(DownloadItemState)state;

@end
