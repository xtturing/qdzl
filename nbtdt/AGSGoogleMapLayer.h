//
//  AGSGoogleMapLayer.h
//  TestGoogleMap
//
//  Created by iphone4 on 10-12-16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@interface AGSGoogleMapLayer : AGSTiledLayer{
    AGSTileInfo* _tileInfo;
	AGSEnvelope* _fullEnvelope;
    AGSUnits _units;
}

@property (nonatomic,retain,readwrite) NSString *dataFramePath;
@property (nonatomic,retain,readwrite) NSString *tdPath;
@property (nonatomic,retain,readwrite) NSString *level;
@property (nonatomic,retain) AGSEnvelope *envelope;

-(id)initWithGoogleMapSchema:(NSString *)path tdPath:(NSString *)tdPath envelope:(AGSEnvelope *)envelope;
-(id)initWithGoogleMapSchema:(NSString *)path tdPath:(NSString *)tdPath envelope:(AGSEnvelope *)envelope level:(NSString *)level;
@end
