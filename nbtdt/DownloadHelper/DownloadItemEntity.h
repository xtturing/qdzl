//
//  DownloadItemEntity.h
//  DownloadDemo
//
//  Created by Peter Yuen on 7/1/14.
//  Copyright (c) 2014 CocoaRush. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DownloadItemEntity : NSManagedObject

@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSNumber * currentSize;
@property (nonatomic, retain) NSNumber * downloadState;
@property (nonatomic, retain) NSString * downloadUrl;
@property (nonatomic, retain) NSNumber * totalSize;
@property (nonatomic, retain) NSNumber * downloadProgress;
@property (nonatomic, retain) NSString * downloadDestinationPath;
@property (nonatomic, retain) NSString * temporaryFileDownloadPath;

@end
