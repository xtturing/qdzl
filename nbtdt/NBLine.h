//
//  NBLine.h
//  tdtnb
//
//  Created by xtturing on 14-8-17.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NBSegment.h"
#import "NSDictionaryAdditions.h"
@interface NBLine : NSObject

@property (nonatomic, strong) NSString *lineName;
@property (nonatomic, strong) NSMutableArray *segments;

- (NBLine *)initWithJsonDictionary:(NSDictionary*)dic;

+ (NBLine *)lineWithJsonDictionary:(NSDictionary*)dic;

@end
