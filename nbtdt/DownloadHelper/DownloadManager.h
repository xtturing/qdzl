//
//  DownloadManager.h
//  DownloadDemo
//
//  Created by Peter Yuen on 6/26/14.
//  Copyright (c) 2014 CocoaRush. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadItem.h"

#define kDownloadManagerNotification @"DownloadManagerNotification"

@interface DownloadManager : NSObject

+(DownloadManager *)sharedInstance;

//已在下载队列中,不进行二次下载
//已下载完成的,重新下载
//默认不重新下载已下载的
-(void)startDownload:(NSString*)resourceUrl withLocalPath:(NSString *)localPath;
-(void)startDownload:(NSString*)resourceUrl withLocalPath:(NSString *)localPath reStartFinished:(BOOL)restart;
-(void)pauseDownload:(NSString *)resourceUrl;
-(void)pauseAllDownloadTask;
-(void)cancelDownload:(NSString *)resourceUrl;
-(void)cancelAllDownloadTask;

//是否正在下载
-(BOOL)isExistInDowningQueue:(NSString *)url;
//是否下载完成
-(BOOL)isExistInFinshQueue:(NSString *)url;

-(DownloadItem *)getDownloadItemByUrl:(NSString *)url;

-(NSMutableDictionary *)getDownloadingTask;
-(NSMutableDictionary *)getFinishedTask;


@end
