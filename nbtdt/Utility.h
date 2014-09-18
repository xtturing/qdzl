//
//  FileManager.h
//  CoreDataTest
//
//  Created by  on 11/27/13.
//  Copyright (c) 2013 CocoaRush. All rights reserved.

/*
    some method tool
 */

#import <Foundation/Foundation.h>

@interface Utility : NSObject

+(Utility *)sharedInstance;


//number to 10:22
+(NSString *)formatTimeByNumber:(float)time;

//number transfer  B to (KB or GB)
+(NSString *)transferNumberToString:(double)number;



//file operator
-(NSString *) md5HexDigest :(NSString *)originString;
-(NSString *)applicationDocumentPath;//得到Document文件夹
-(BOOL)isExistFileAtPath:(NSString *)path;//是否存在指定文件
-(BOOL)removeFileAtPath:(NSString *)path;//删除path文件
+(double)getFileSizeAtPath:(NSString *)path;


@end
