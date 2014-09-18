//
//  NBLine.m
//  tdtnb
//
//  Created by xtturing on 14-8-17.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import "NBLine.h"

@implementation NBLine

- (NBLine *)initWithJsonDictionary:(NSDictionary*)dic{
    if (self = [super init]) {
        _lineName=[dic getStringValueForKey:@"lineName" defaultValue:@""];
        _segments = [[NSMutableArray alloc] initWithCapacity:0];
        NSArray *arr = [dic objectForKey:@"segments"];
        if(arr){
            for (NSDictionary *item in arr) {
                if(item){
                    NBSegment *segment = [NBSegment segmentWithJsonDictionary:item];
                    [_segments addObject:segment];
                }
            }
        }
    }
	return self;
}

+ (NBLine *)lineWithJsonDictionary:(NSDictionary*)dic{
     return [[NBLine alloc] initWithJsonDictionary:dic];
}

@end
