//
//  NBSegmentLine.m
//  tdtnb
//
//  Created by xtturing on 14-8-17.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import "NBSegmentLine.h"

@implementation NBSegmentLine
- (NBSegmentLine *)initWithJsonDictionary:(NSDictionary*)dic{
    if(self = [super init]){
        _segmentTime=[dic getStringValueForKey:@"segmentTime" defaultValue:@""];
         _segmentStationCount=[dic getStringValueForKey:@"segmentStationCount" defaultValue:@""];
         _segmentTransferTime=[dic getStringValueForKey:@"segmentTransferTime" defaultValue:@""];
         _segmentDistance=[dic getStringValueForKey:@"segmentDistance" defaultValue:@""];
         _direction=[dic getStringValueForKey:@"direction" defaultValue:@""];
         _SEndTime=[dic getStringValueForKey:@"SEndTime" defaultValue:@""];
         _linePoint=[dic getStringValueForKey:@"linePoint" defaultValue:@""];
         _lineName=[dic getStringValueForKey:@"lineName" defaultValue:@""];
         _byuuid=[dic getStringValueForKey:@"byuuid" defaultValue:@""];
    }
    return self;
}

+ (NBSegmentLine *)segmentLineWithJsonDictionary:(NSDictionary*)dic{
    return [[NBSegmentLine alloc] initWithJsonDictionary:dic];
}
@end
