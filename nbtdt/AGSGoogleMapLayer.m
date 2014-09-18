//
//  AGSGoogleMapLayer.m
//  TestGoogleMap
//
//  Created by iphone4 on 10-12-16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AGSGoogleMapLayer.h"
#import "GoogleMapSchema.h"
#import "GoogleMapTileOperation.h"

@implementation AGSGoogleMapLayer

-(AGSUnits)units{
	return _units;
}

-(AGSSpatialReference *)spatialReference{
	return _fullEnvelope.spatialReference;
}

-(AGSEnvelope *)fullEnvelope{
	return _fullEnvelope;
}

-(AGSEnvelope *)initialEnvelope{
	//Assuming our initial extent is the same as the full extent
	return _fullEnvelope;
}

-(AGSTileInfo*) tileInfo{
	return _tileInfo;
}

-(id)initWithGoogleMapSchema:(NSString *)path tdPath:(NSString *)tdPath envelope:(AGSEnvelope *)envelope level:(NSString *)level
{
    GoogleMapSchema * shema = [[GoogleMapSchema alloc] init];
	_tileInfo = [shema.tileInfo retain];
	_fullEnvelope = [shema.fullEnvelope retain];
    self.dataFramePath = path;
    self.tdPath = tdPath;
    self.envelope = envelope;
    self.level = level;
	[self layerDidLoad];
	return self;
    
}
-(id)initWithGoogleMapSchema: (NSString *)path tdPath:(NSString *)tdPath envelope:(AGSEnvelope *)envelope
{
	GoogleMapSchema * shema = [[GoogleMapSchema alloc] init];
	_tileInfo = [shema.tileInfo retain];
	_fullEnvelope = [shema.fullEnvelope retain];
    self.dataFramePath = path;
    self.tdPath = tdPath;
    self.envelope = envelope;
    self.level = 0;
	[self layerDidLoad];
	return self;
	
}
- (NSOperation<AGSTileOperation>*) retrieveImageAsyncForTile:(AGSTile *) tile{
	//Create an operation to fetch tile from local cache
	GoogleMapTileOperation *operation = 
	[[GoogleMapTileOperation alloc] initWithTile:tile
                                        dataFramePath:self.dataFramePath
                                        tdPath:self.tdPath
                                        envelope:self.envelope
                                        level:self.level
										target:self 
										action:@selector(didFinishOperation:)];
	//Add the operation to the queue for execution
    [super.operationQueue addOperation:operation];
//	NSLog([NSString stringWithFormat:@"x=%d y=%d z=%d",tile.row,tile.column,tile.level]);
    return [operation autorelease];
}

- (void) didFinishOperation:(NSOperation<AGSTileOperation>*)op {
	//If tile was found ...
	if (op.tile.image!=nil) {
		//... notify tileDelegate of success
		[self.tileDelegate tiledLayer:self operationDidGetTile:op];
	}else {
		//... notify tileDelegate of failure
		[self.tileDelegate tiledLayer:self operationDidFailToGetTile:op];
//		NSLog([NSString stringWithFormat:@"faildop"]);
	}
}

#pragma mark -
- (void)dealloc {
    [_fullEnvelope release];_fullEnvelope = nil;
    [_tileInfo release];_tileInfo = nil;
	[_envelope release];_envelope = nil;
	[_fullEnvelope release];_tileInfo = nil;
    [_dataFramePath release];_dataFramePath = nil;
    [_tdPath release];_tdPath = nil;
    
    [super dealloc];
}

@end
