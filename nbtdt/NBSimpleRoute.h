//
//  NBSimpleRoute.h
//  tdtnb
//
//  Created by xtturing on 14-8-19.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionaryAdditions.h"
@interface NBSimpleRoute : NSObject

@property(nonatomic, strong) NSString *rid;
@property(nonatomic, strong) NSString *strguide;
@property(nonatomic, strong) NSString *streetNames;
@property(nonatomic, strong) NSString *lastStreetName;
@property(nonatomic, strong) NSString *linkStreetName;
@property(nonatomic, strong) NSString *turnlatlon;
@property(nonatomic, strong) NSString *streetLatLon;
@property(nonatomic, strong) NSString *streetDistance;
@property(nonatomic, strong) NSString *segmentNumber;

- (NBSimpleRoute *)initWithJsonDictionary:(NSDictionary*)dic;

+ (NBSimpleRoute *)simpleRouteWithJsonDictionary:(NSDictionary*)dic;

@end
