//
//  NBStationStart.h
//  tdtnb
//
//  Created by xtturing on 14-8-17.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionaryAdditions.h"
@interface NBStationStart : NSObject

@property (nonatomic, strong) NSString *lonlat;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *uuid;


- (NBStationStart *)initWithJsonDictionary:(NSDictionary*)dic;

+ (NBStationStart *)startWithJsonDictionary:(NSDictionary*)dic;
@end
