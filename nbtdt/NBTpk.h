//
//  NBTpk.h
//  nbtdt
//
//  Created by xtturing on 14-8-31.
//
//

#import <Foundation/Foundation.h>
#import "NSDictionaryAdditions.h"
@interface NBTpk : NSObject

@property (nonatomic, strong) NSString *lastupdatetime;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *range;
@property (nonatomic, strong) NSString *size;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *type;

- (NBTpk *)initWithJsonDictionary:(NSDictionary*)dic;

+ (NBTpk *)tpkWithJsonDictionary:(NSDictionary*)dic;

@end
