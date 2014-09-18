//
//  DownloadStoreManager.h
//  DownloadDemo
//
//  Created by Peter Yuen on 7/1/14.
//  Copyright (c) 2014 CocoaRush. All rights reserved.
//

//交互对象是Model，不是Entity
#import <Foundation/Foundation.h>

@interface DownloadStoreManager : NSObject

+(DownloadStoreManager *)sharedInstance;

-(NSMutableArray *)getAllStoreDownloadTask;
-(BOOL)isExistDownloadTask:(NSString *)url;
-(void)insertDownloadTask:(DownloadItem *)item;
-(void)deleteDownloadTask:(NSString *)url;
-(void)updateDownloadTask:(DownloadItem *)item;

@end
