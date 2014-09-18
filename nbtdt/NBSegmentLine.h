//
//  NBSegmentLine.h
//  tdtnb
//
//  Created by xtturing on 14-8-17.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionaryAdditions.h"
@interface NBSegmentLine : NSObject

@property (nonatomic, strong) NSString *segmentStationCount;
@property (nonatomic, strong) NSString *segmentTime;
@property (nonatomic, strong) NSString *segmentTransferTime;
@property (nonatomic, strong) NSString *segmentDistance;
@property (nonatomic, strong) NSString *direction;
@property (nonatomic, strong) NSString *SEndTime;
@property (nonatomic, strong) NSString *linePoint;
@property (nonatomic, strong) NSString *lineName;
@property (nonatomic, strong) NSString *byuuid;


- (NBSegmentLine *)initWithJsonDictionary:(NSDictionary*)dic;

+ (NBSegmentLine *)segmentLineWithJsonDictionary:(NSDictionary*)dic;
@end
