//
//  NBSearch.m
//  tdtnb
//
//  Created by xtturing on 14-8-4.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import "NBSearch.h"

@implementation NBSearch

- (NBSearch *)initWithJsonDictionary:(NSDictionary*)dic {
	if (self = [super init]) {
        _name=[dic getStringValueForKey:@"name" defaultValue:@""];
        _location=[dic objectForKey:@"location"];
        _address=[dic getStringValueForKey:@"address" defaultValue:@""];
        _street_id=[dic getStringValueForKey:@"street_id" defaultValue:@""];
        _telephone=[dic getStringValueForKey:@"telephone" defaultValue:@""];
        _uid=[dic getStringValueForKey:@"uid" defaultValue:@""];
    }
	return self;
}

+ (NBSearch *)searchWithJsonDictionary:(NSDictionary*)dic
{
	return [[NBSearch alloc] initWithJsonDictionary:dic];
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_location forKey:@"location"];
    [aCoder encodeObject:_address forKey:@"address"];
    [aCoder encodeObject:_street_id forKey:@"street_id"];
    [aCoder encodeObject:_telephone forKey:@"telephone"];
    [aCoder encodeObject:_uid forKey:@"uid"];
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init])  {
         _name=[aDecoder decodeObjectForKey:@"name"];
         _location=[aDecoder decodeObjectForKey:@"location"];
         _address=[aDecoder decodeObjectForKey:@"address"];
         _street_id=[aDecoder decodeObjectForKey:@"street_id"];
         _telephone=[aDecoder decodeObjectForKey:@"telephone"];
         _uid=[aDecoder decodeObjectForKey:@"uid"];
    }
    return self;
}

@end
