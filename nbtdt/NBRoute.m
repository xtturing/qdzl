//
//  NBRoute.m
//  tdtnb
//
//  Created by xtturing on 14-8-19.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import "NBRoute.h"

@implementation NBRoute

- (NBRoute *)initWithJsonDictionary:(NSDictionary*)dic{
    if (self = [super init]) {
        _distance=[[dic objectForKey:@"distance"] getStringValueForKey:@"text" defaultValue:@""];
        _duration=[[dic objectForKey:@"duration"] getStringValueForKey:@"text" defaultValue:@""];
        _dest=[dic getStringValueForKey:@"dest" defaultValue:@""];
        _orig=[dic getStringValueForKey:@"orig" defaultValue:@""];
        _center=[[[dic objectForKey:@"mapinfo"] objectForKey:@"center"] getStringValueForKey:@"text" defaultValue:@""];
        _scale=[[[dic objectForKey:@"mapinfo"] objectForKey:@"scale"] getStringValueForKey:@"text" defaultValue:@""];
        _routelatlon=[[dic objectForKey:@"routelatlon"] getStringValueForKey:@"text" defaultValue:@""];
        NSArray *arr = nil;
        if([dic objectForKey:@"routes"] ){
            arr = [[dic objectForKey:@"routes"] objectForKey:@"item"];
            _routeItemList = [[NSMutableArray alloc] initWithCapacity:0];
            if(arr){
                for (id item in arr) {
                    if(item && [item isKindOfClass:[NSDictionary class]]){
                        NBRouteItem *routeItem = [NBRouteItem routeItemWithJsonDictionary:item];
                        [_routeItemList addObject:routeItem];
                    }
                }
            }
        }
        
        _simpleRouteList =  [[NSMutableArray alloc] initWithCapacity:0];
        if([dic objectForKey:@"simple"]){
            arr = [[dic objectForKey:@"simple"] objectForKey:@"item"];
            if(arr){
                for (id item in arr) {
                    if(item && [item isKindOfClass:[NSDictionary class]]){
                        NBSimpleRoute *simpleRoute = [NBSimpleRoute simpleRouteWithJsonDictionary:item];
                        [_simpleRouteList addObject:simpleRoute];
                    }
                    
                }
            }
        }
       
    }
	return self;
}

+ (NBRoute *)routeWithJsonDictionary:(NSDictionary*)dic{
    
    return [[NBRoute alloc] initWithJsonDictionary:dic];
}


@end
