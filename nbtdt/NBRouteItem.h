//
//  NBRouteItem.h
//  tdtnb
//
//  Created by xtturing on 14-8-19.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionaryAdditions.h"
@interface NBRouteItem : NSObject

@property(nonatomic, strong) NSString *rid;
@property(nonatomic, strong) NSString *strguide;
@property(nonatomic, strong) NSString *streetName;
@property(nonatomic, strong) NSString *nextStreetName;
@property(nonatomic, strong) NSString *turnlatlon;

- (NBRouteItem *)initWithJsonDictionary:(NSDictionary*)dic;

+ (NBRouteItem *)routeItemWithJsonDictionary:(NSDictionary*)dic;

@end
