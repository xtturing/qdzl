//
//  dataHttpManager.h
//  房伴
//
//  Created by tao xu on 13-8-12.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "ASIHTTPRequestDelegate.h"
#import "StringUtil.h"
#import "NSStringAdditions.h"
#import "NBRoute.h"
#import "NBLine.h"

#define HTTP_URL              @"http://api.map.baidu.com/place/v2/search"
#define HTTP_SEARCH_URL       @"http://api.tianditu.com/api/api-new"
#define HTTP_ERRORURL         @"http://60.190.2.120:10087/mobile/new/"
#define HTTP_SEARCH           @"http://60.190.2.120:10087/baiduQuery"
#define HTTP_DOWNLOAD         @"http://www.nbmap.gov.cn/tpkService/"
#define HTTP_NBQUERY          @"http://60.190.2.120:10087/nbQuery"
#define REQUEST_TYPE          @"requestType"

typedef enum {
    AAGetSearchList = 0,           //获取当前区域列表
    AAGetRadiusList,
    AAPostError,
    AAGetLineSearch,
    AAGetBusSearch,
    AAGetTpkList,
    AAGetHttpType,
    //继续添加
    
}DataRequestType;


@class ASINetworkQueue;


//Delegate
@protocol dataHttpDelegate <NSObject>
@optional
//
-(void)didGetFailed;
//获取到当前区域列表
-(void)didGetSearchList:(NSArray*)searchList;
//
-(void)didGetRadiusSearchList:(NSArray *)radiusList;
//
- (void)didPostError:(NSString *)string;
//
-(void)didGetRoute:(NBRoute *)route;

//
-(void)didGetBusLines:(NSArray *)lineList;

//

-(void)didgetTpkList:(NSMutableDictionary *)tokList;

//继续添加
@end


@interface dataHttpManager : NSObject

@property (nonatomic,retain) ASINetworkQueue *requestQueue;
@property (nonatomic,strong) NSString *url;
@property (nonatomic,assign) int type;
@property (nonatomic,assign) id<dataHttpDelegate> delegate;
+(dataHttpManager*)getInstance;
- (id)initWithDelegate;

- (BOOL)isRunning;
- (void)start;
- (void)pause;
- (void)resume;
- (void)cancel;
//获取当前区域列表
-(void)letDoSearchWithQuery:(NSString *)query region:(NSString *)region searchType:(int)type pageSize:(int)size pageNum:(int)num;

//
-(void)letDoRadiusSearchWithQuery:(NSString *)query location:(NSString *)location  radius:(int)radius scope:(int)scope pageSize:(int)size pageNum:(int)num;

//
- (void)letDoPostErrorWithMessage:(NSString *)message plottingScale:(NSString *)plottingScale point:(NSString *)point;

//

-(void)letDoLineSearchWithOrig:(NSString *)orig dest:(NSString *)dest style:(NSString *)style;

//

-(void)letDoBusSearchWithStartposition:(NSString *)startposition endposition:(NSString *)endposition linetype:(NSString *)linetype;

//

-(void)letDoTpkList;

-(void)letDoHttpTypeQuery;
//继续添加
@end
