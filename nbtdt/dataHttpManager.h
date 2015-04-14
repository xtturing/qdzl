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

#define HTTP_LOGIN_URL              @"http://27.223.74.180:8080/esys/plugin/urbanadmin"
#define HTTP_POSTEVENT_URL          @"http://27.223.74.180:8080/esys/plugin/urbanadmin/publicUserSubmitEvent.htm"
#define HTTP_SEARCH_HISTORY         @"http://27.223.74.180:8080/esys/plugin/urbanadmin/getHistory.htm"
#define HTTP_APP_RAISE              @"http://27.223.74.180:8080/esys/plugin/urbanadmin/publicUserAppraise.htm"

#define REQUEST_TYPE          @"requestType"

typedef enum {
    AAPublicUserRegister = 0,
    AAPublicUserLogin,
    AAChangePassword,
    AAPostEvent,
    AASearchEventHistory,
    AAAppRaise,
    //继续添加
    
}DataRequestType;


@class ASINetworkQueue;


//Delegate
@protocol dataHttpDelegate <NSObject>
@optional

- (void)didGetFailed;

- (void)didGetPublicUserRegister:(BOOL)success;

- (void)didGetPublicUserLogin:(BOOL)success;

- (void)didGetChangePassword:(BOOL)success;

- (void)didPostEvent:(BOOL)success;

- (void)didSearchEventHistory:(NSDictionary *)list;

- (void)didGetAppRaise:(BOOL)success;

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

- (void)letPublicUserRegister:(NSString *)userName password:(NSString *)pwd;

- (void)letPublicUserLogin:(NSString *)userName password:(NSString *)pwd;

- (void)letChangePassword:(NSString *)userName password:(NSString *)pwd;

- (void)letPostEvent:(NSString *)filePath fileName:(NSString *)fileName;

- (void)letSearchEventHistory:(NSString *)uid;

- (void)letAppRaise:(NSString *)uid withRaise:(NSString *)raise;

//继续添加
@end
