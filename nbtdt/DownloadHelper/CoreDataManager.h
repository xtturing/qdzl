//
//  CoreDataManager.h
//  DownloadDemo
//
//  Created by Peter Yuen on 7/1/14.
//  Copyright (c) 2014 CocoaRush. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataManager : NSObject

+(CoreDataManager *)sharedInstance;
@property(nonatomic,retain)NSManagedObjectContext *managedObjectContext;

-(void)saveChanged;

@end
