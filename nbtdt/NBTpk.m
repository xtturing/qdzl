//
//  NBTpk.m
//  nbtdt
//
//  Created by xtturing on 14-8-31.
//
//

#import "NBTpk.h"

@implementation NBTpk

- (NBTpk *)initWithJsonDictionary:(NSDictionary*)dic{
    if(self = [super init]){
        _name=[dic getStringValueForKey:@"name" defaultValue:@""];
        _lastupdatetime=[dic getStringValueForKey:@"lastupdatetime" defaultValue:@""];
        _range=[dic getStringValueForKey:@"range" defaultValue:@""];
        _size=[dic getStringValueForKey:@"size" defaultValue:@""];
        _title=[dic getStringValueForKey:@"title" defaultValue:@""];
        _type=[dic getStringValueForKey:@"type" defaultValue:@""];
    }
    return self;
}

+ (NBTpk *)tpkWithJsonDictionary:(NSDictionary*)dic{
    return [[NBTpk alloc ] initWithJsonDictionary:dic];
}

@end
