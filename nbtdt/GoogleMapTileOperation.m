//
//  GoogleMapTileOperation.m
//  TestGoogleMap
//
//  Created by iphone4 on 10-12-16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GoogleMapTileOperation.h"

int tn(int n)//计算2的n次方
{
	int num = 1;
	int i = 0;
	for (i=0; i<n; i++) {
		num = num *2;
	}
	return num;
}
@implementation GoogleMapTileOperation

- (id)initWithTile:(AGSTile *)tile dataFramePath:(NSString *)path tdPath:(NSString *)tdPath envelope:(AGSEnvelope *)envelope  level:(NSString *)level target:(id)target action:(SEL)action {
	
	if (self = [super init]) {
		self.target = target;
        self.allLayersPath =path;
        self.tiandiPath=tdPath;
        self.envelope=envelope;
		self.action = action;
		self.tile = tile;
        self.level = level;
	}
	return self;
}

-(void)main {
	//Fetch the tile for the requested Level, Row, Column
	@try {
        NSString *baseUrl = @"";
        if(self.tile.level < [self.level intValue]){
           baseUrl = [NSString stringWithFormat:self.tiandiPath,(self.tile.level+1),self.tile.row,self.tile.column]; 
            NSURL* aURL = [NSURL URLWithString:baseUrl];
            NSData* data = [[NSData alloc] initWithContentsOfURL:aURL];
            _tile.image = [UIImage imageWithData:data];
            [data release];
            NSLog(@"天地图%@",baseUrl);
        }else{
            if ((self.tile.envelope.xmax<self.envelope.xmin)||(self.tile.envelope.xmin>self.envelope.xmax)||(self.tile.envelope.ymax<self.envelope.ymin)||(self.tile.envelope.ymin>self.envelope.ymax)) {
                baseUrl = [NSString stringWithFormat:self.tiandiPath,(self.tile.level+1),self.tile.row,self.tile.column];
                NSLog(@"补充天地图%@",baseUrl);
                NSURL* aURL = [NSURL URLWithString:baseUrl];
                NSData* data = [[NSData alloc] initWithContentsOfURL:aURL];
                _tile.image = [UIImage imageWithData:data];
                [data release];
            }else if((self.tile.envelope.xmin<self.envelope.xmin&&self.tile.envelope.xmax>self.envelope.xmin)||(self.envelope.xmax>self.tile.envelope.xmin&&self.envelope.xmax<self.tile.envelope.xmax)||(self.envelope.ymin>self.tile.envelope.ymin&&self.envelope.ymin<self.tile.envelope.ymax)||(self.envelope.ymax>self.tile.envelope.ymin&&self.envelope.ymax<self.tile.envelope.ymax)){
                baseUrl = [NSString stringWithFormat:self.tiandiPath,(self.tile.level+1),self.tile.row,self.tile.column];
                NSLog(@"补充天地图%@",baseUrl);
                NSURL* aURL = [NSURL URLWithString:baseUrl];
                NSData* adata = [[NSData alloc] initWithContentsOfURL:aURL];
                baseUrl = [NSString stringWithFormat:self.allLayersPath,(self.tile.level+1),self.tile.row,self.tile.column];
                NSLog(@"自己地图%@",baseUrl);
                NSURL* bURL = [NSURL URLWithString:baseUrl];
                NSData* bdata = [[NSData alloc] initWithContentsOfURL:bURL];
                _tile.image=[self addImage:[UIImage imageWithData:bdata] toImage:[UIImage imageWithData:adata]];
                [adata release];
                [bdata release];
            }else{
                baseUrl = [NSString stringWithFormat:self.allLayersPath,(self.tile.level+1),self.tile.row,self.tile.column];
                NSLog(@"自己地图%@",baseUrl);
                NSURL* aURL = [NSURL URLWithString:baseUrl];
                NSData* data = [[NSData alloc] initWithContentsOfURL:aURL];
                _tile.image = [UIImage imageWithData:data];
                [data release];                
            }
            
        }
		
	}
	@catch (NSException *exception) {
	//	NSLog(@"main: Caught Exception %@: %@", [exception name], [exception reason]);
	}
	@finally {
		//Invoke the layer's action method
		[_target performSelector:_action withObject:self];
	}
}
-(UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2
{
    UIGraphicsBeginImageContext(image2.size);
    
    //Draw image2
    [image2 drawInRect:CGRectMake(0, 0,256, 256)];
    
    //Draw image1
    [image1 drawInRect:CGRectMake(0, 0,256, 256)];
    
    UIImage *resultImage=UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultImage;
}
- (void)dealloc {
	[_target release];_target = nil;
    _action = nil;
	[_tile release];_tile = nil;
    [_allLayersPath release];_allLayersPath = nil;
    [_envelope release];_envelope = nil;
    [_tiandiPath release];_tiandiPath = nil;
    [_level release];_level = nil;
	[super dealloc];	
}

@end
