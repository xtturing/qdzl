//
//  NBStationEnd.m
//  tdtnb
//
//  Created by xtturing on 14-8-17.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import "NBStationEnd.h"

@implementation NBStationEnd

- (NBStationEnd *)initWithJsonDictionary:(NSDictionary*)dic{
    if(self = [super init]){
        _name=[dic getStringValueForKey:@"name" defaultValue:@""];
        _uuid=[dic getStringValueForKey:@"uuid" defaultValue:@""];
        _lonlat=[dic getStringValueForKey:@"lonlat" defaultValue:@""];
    }
    return self;
}

+ (NBStationEnd *)endWithJsonDictionary:(NSDictionary*)dic{
    return [[NBStationEnd alloc] initWithJsonDictionary:dic];
}

@end
