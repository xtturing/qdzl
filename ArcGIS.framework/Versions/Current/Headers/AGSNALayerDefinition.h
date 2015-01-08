/*
 COPYRIGHT 2011 ESRI
 
 TRADE SECRETS: ESRI PROPRIETARY AND CONFIDENTIAL
 Unpublished material - all rights reserved under the
 Copyright Laws of the United States and applicable international
 laws, treaties, and conventions.
 
 For additional information, contact:
 Environmental Systems Research Institute, Inc.
 Attn: Contracts and Legal Services Department
 380 New York Street
 Redlands, California, 92373
 USA
 
 email: contracts@esri.com
 */

#import <Foundation/Foundation.h>

/** @file AGSNALayerDefinition.h */

@protocol AGSCoding;
@class AGSGeometry;
@class AGSSpatialReference;

/** @brief Possible input object for stops/facilities/incidents/barriers 
 
 Instances of this class represent possible inputs for the <code>stops/facilities/incidents/barriers</code> 
 properties of @c AGSRouteTaskParameters, @c AGSServiceAreaTaskParameters, 
 and @c AGSClosestFacilityTaskParameters. 
 
 A layer definition allows you to specify these inputs by-reference. 
 This is useful when you already have a set the inputs stored along with the Network Analyst service. 
 In such cases, the application does not need to know the actual details about each input. 
 All it needs to do is set up a layer definition specifiying which inputs should be included in the analysis.
 You can use SQL statements and/or Spatial relationships to specify which inputs should be used in the analysis
 @since 1.8
 */
@interface AGSNALayerDefinition : NSObject <AGSCoding> {
 @private
	AGSGeometry *_geometry;
	NSString *_layerName;
	AGSSpatialRelationship _spatialRelationship;;
	NSString *_where;
}

/** The geometry to apply to the spatial filter. The spatial relationship as 
 specified by #spatialRelationship is applied to this geometry while performing 
 the query.
 @since 1.8
 */
@property (nonatomic, retain) AGSGeometry *geometry;

/** The name of the data layer in the map service that is being referenced.
 @since 1.8
 */
@property (nonatomic, copy) NSString *layerName;

/** The spatial relationship to be applied on the input geometry while performing 
 the query. See the Constants Table for a list of valid values. The default spatial
 relationship is <code>AGSSpatialRelationshipIntersects</code>.
 @since 1.8
 */
@property (nonatomic, assign) AGSSpatialRelationship spatialRelationship;

/** A where clause for the query. Any legal SQL where clause operating on the 
 fields in the layer is allowed, for example: query.where = "POP2000 > 350000".
 @since 1.8
 */
@property (nonatomic, copy) NSString *where;

/** Initialize a new @c AGSNALayerDefinition.
 @param layerName The name of the data layer in the map service to reference.
 @param geometry The geometry to apply the spatial filter on.
 @param spatialRelationship The spatial relationship to apply to the #geometry.
 @param where The where clause for the query.
 @return An initialized @c AGSNALayerDefinition object.
 @since 1.8
 */
- (id)initWithLayerName:(NSString*)layerName 
			   geometry:(AGSGeometry*)geometry 
	spatialRelationship:(AGSSpatialRelationship)spatialRelationship 
				  where:(NSString*)where;

/** Initialize a new @c AGSNALayerDefinition.
 @param layerName The name of the data layer in the map service to reference.
 @param where The where clause for the query.
 @return An initialized @c AGSNALayerDefinition object.
 @since 1.8
 */
- (id)initWithLayerName:(NSString*)layerName where:(NSString*)where;
 

@end

