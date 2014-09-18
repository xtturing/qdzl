//
//  NBSegment.m
//  tdtnb
//
//  Created by xtturing on 14-8-17.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import "NBSegment.h"

@implementation NBSegment
- (NBSegment *)initWithJsonDictionary:(NSDictionary*)dic{
    if (self = [super init]) {
        _segmentType=[dic getStringValueForKey:@"segmentType" defaultValue:@""];
        _stationStart = [NBStationStart startWithJsonDictionary:[dic objectForKey:@"stationStart"]];
        _stationEnd = [NBStationEnd endWithJsonDictionary:[dic objectForKey:@"stationEnd"]];
        _segmentLines = [[NSMutableArray alloc] initWithCapacity:0];
        NSArray *arr = [dic objectForKey:@"segmentLine"];
        if(arr){
            for (NSDictionary *item in arr) {
                if(item){
                    
                    NBSegmentLine *segmentLine = [NBSegmentLine segmentLineWithJsonDictionary:item];
                    [_segmentLines addObject:segmentLine];
                }
            }
        }        
    }
	return self;
}

+ (NBSegment *)segmentWithJsonDictionary:(NSDictionary*)dic{
    return [[NBSegment alloc] initWithJsonDictionary:dic];
}
@end
