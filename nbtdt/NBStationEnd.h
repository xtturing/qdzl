//
//  NBStationEnd.h
//  tdtnb
//
//  Created by xtturing on 14-8-17.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionaryAdditions.h"
@interface NBStationEnd : NSObject

@property (nonatomic, strong) NSString *lonlat;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *uuid;


- (NBStationEnd *)initWithJsonDictionary:(NSDictionary*)dic;

+ (NBStationEnd *)endWithJsonDictionary:(NSDictionary*)dic;
@end
