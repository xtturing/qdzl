//
//  NBSearch.h
//  tdtnb
//
//  Created by xtturing on 14-8-4.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionaryAdditions.h"

@interface NBSearch : NSObject<NSCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDictionary *location;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *street_id;
@property (nonatomic, strong) NSString *telephone;
@property (nonatomic, strong) NSString *uid;

- (NBSearch *)initWithJsonDictionary:(NSDictionary*)dic;

+ (NBSearch *)searchWithJsonDictionary:(NSDictionary*)dic;

@end
