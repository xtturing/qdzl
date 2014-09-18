//
//  NBRoute.h
//  tdtnb
//
//  Created by xtturing on 14-8-19.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NBSimpleRoute.h"
#import "NBRouteItem.h"
#import "NSDictionaryAdditions.h"

@interface NBRoute : NSObject

@property(nonatomic, strong) NSMutableArray *routeItemList;
@property(nonatomic, strong) NSMutableArray *simpleRouteList;
@property(nonatomic, strong) NSString *distance;
@property(nonatomic, strong) NSString *duration;
@property(nonatomic, strong) NSString *dest;
@property(nonatomic, strong) NSString *orig;
@property(nonatomic, strong) NSString *routelatlon;
@property(nonatomic, strong) NSString *center;
@property(nonatomic, strong) NSString *scale;


- (NBRoute *)initWithJsonDictionary:(NSDictionary*)dic;

+ (NBRoute *)routeWithJsonDictionary:(NSDictionary*)dic;
@end
