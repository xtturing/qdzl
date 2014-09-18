//
//  GoogleMapSchema.m
//  TestGoogleMap
//
//  Created by iphone4 on 10-12-16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GoogleMapSchema.h"
#import <ArcGIS/ArcGIS.h>

@implementation GoogleMapSchema

-(id) init
{
	[super init];
 	_spatialReference = [[AGSSpatialReference alloc] initWithWKID:4490 WKT:nil];
	_fullEnvelope = [[AGSEnvelope alloc] initWithXmin:-180
                                                     ymin:-90
                                                     xmax:180
                                                     ymax:90
                                         spatialReference:_spatialReference];
    
	NSMutableArray *lods = [NSMutableArray arrayWithObjects:
                            [[AGSLOD alloc] initWithLevel:0 resolution:0.7031250001548544 scale: 295497593.1238397],
                            [[AGSLOD alloc] initWithLevel:1 resolution:0.3515625000774272 scale: 147748796.5619199],
                            [[AGSLOD alloc] initWithLevel:2 resolution:0.1757812500387136 scale: 73874398.28095994],
                            [[AGSLOD alloc] initWithLevel:3 resolution:0.0878906250193568 scale: 36937199.14047997],
                            [[AGSLOD alloc] initWithLevel:4 resolution:0.0439453125096784 scale: 18468599.57023998],
                            [[AGSLOD alloc] initWithLevel:5 resolution:0.0219726562548392 scale: 9234299.785119992],
                            [[AGSLOD alloc] initWithLevel:6 resolution:0.0109863281274196 scale: 4617149.892559996],
                            [[AGSLOD alloc] initWithLevel:7 resolution:0.0054931640637098 scale: 2308574.946279998],
                            [[AGSLOD alloc] initWithLevel:8 resolution:0.0027465820318549957 scale: 1154287.4731399999],
                            [[AGSLOD alloc] initWithLevel:9 resolution:0.0013732910159274978 scale: 577143.73656999995],
                            [[AGSLOD alloc] initWithLevel:10 resolution:0.00068664549607834132 scale: 288571.86329000001],
                            [[AGSLOD alloc] initWithLevel:11 resolution:0.00034332275992416907 scale: 144285.936639828],
                            [[AGSLOD alloc] initWithLevel:12 resolution:0.00017166136807812298 scale: 72142.963325521763],
                            [[AGSLOD alloc] initWithLevel:13 resolution:8.5830684039061379e-005 scale: 36071.481662760838],
                            [[AGSLOD alloc] initWithLevel:14 resolution:4.2915342019530649e-005 scale:18035.740831380401],
                            [[AGSLOD alloc] initWithLevel:15 resolution:2.1457682893727977e-005 scale: 9017.8754100828901],
                            [[AGSLOD alloc] initWithLevel:16 resolution:1.0728841446864e-005 scale: 4508.937705041445],
                            [[AGSLOD alloc] initWithLevel:17 resolution:5.3644207234319882e-006 scale: 2254.468852520723],
                            [[AGSLOD alloc] initWithLevel:18 resolution:2.6822103617159941e-006 scale: 1127.234426260361],
                            [[AGSLOD alloc] initWithLevel:19 resolution:1.341105180858e-006 scale: 563.6172131301806],
                            nil ];
	_tileInfo = [[AGSTileInfo alloc]
                     initWithDpi:96 
                     format :@"image/png"
                     lods:lods
                     origin:[AGSPoint pointWithX:-180 y:90 spatialReference:_spatialReference]
                     spatialReference :_spatialReference
                     tileSize:CGSizeMake(256,256)
                     ];
	[_tileInfo computeTileBounds:_fullEnvelope ];
	return self;
}
- (void)dealloc {
	[_spatialReference release];_spatialReference = nil;
	[_fullEnvelope release];_fullEnvelope = nil;
	[_tileInfo release];_tileInfo = nil;

	[super dealloc];	
}
@end
