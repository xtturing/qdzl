//
//  NBSimpleRoute.m
//  tdtnb
//
//  Created by xtturing on 14-8-19.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import "NBSimpleRoute.h"

@implementation NBSimpleRoute


- (NBSimpleRoute *)initWithJsonDictionary:(NSDictionary*)dic{
    if (self = [super init]) {
        if ([dic count] >1) {
            _rid=[dic getStringValueForKey:@"id" defaultValue:@""];
            if([dic objectForKey:@"strguide"] ){
                _strguide=[[dic objectForKey:@"strguide"] getStringValueForKey:@"text" defaultValue:@""];
            }
            if([dic objectForKey:@"streetNames"]){
                _streetNames=[[dic objectForKey:@"streetNames"] getStringValueForKey:@"text" defaultValue:@""];
            }
            if([dic objectForKey:@"lastStreetName"]){
                _lastStreetName=[[dic objectForKey:@"lastStreetName"] getStringValueForKey:@"text" defaultValue:@""];
            }
            if([dic objectForKey:@"linkStreetName"]){
                _linkStreetName=[[dic objectForKey:@"linkStreetName"] getStringValueForKey:@"text" defaultValue:@""];
            }
            if([dic objectForKey:@"turnlatlon"] ){
                _turnlatlon=[[dic objectForKey:@"turnlatlon"] getStringValueForKey:@"text" defaultValue:@""];
            }
            if([dic objectForKey:@"streetLatLon"]){
                
                _streetLatLon=[[dic objectForKey:@"streetLatLon"] getStringValueForKey:@"text" defaultValue:@""];
            }
            if([dic objectForKey:@"streetDistance"]){
                _streetDistance=[[dic objectForKey:@"streetDistance"] getStringValueForKey:@"text" defaultValue:@""];
            }
            if([dic objectForKey:@"segmentNumber"]){
                _segmentNumber=[[dic objectForKey:@"segmentNumber"] getStringValueForKey:@"text" defaultValue:@""];
            }
        }
        
    }
	return self;
}

+ (NBSimpleRoute *)simpleRouteWithJsonDictionary:(NSDictionary*)dic{
    
    return [[NBSimpleRoute alloc] initWithJsonDictionary:dic];
}

@end
