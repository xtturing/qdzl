//
//  dataHttpManager.m
//  房伴
//
//  Created by tao xu on 13-8-12.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "dataHttpManager.h"
#import "ASINetworkQueue.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "XMLReader.h"
#import "NBTpk.h"
#import "DownloadItem.h"
#import "DownloadManager.h"

#define TIMEOUT 30

static dataHttpManager * instance=nil;

@implementation dataHttpManager

-(void)dealloc
{
    self.requestQueue = nil;
}
//单例
+(dataHttpManager*)getInstance{
    @synchronized(self) {
        if (instance==nil) {
            instance=[[dataHttpManager alloc] initWithDelegate];
            [instance start];
        }
    }
    return instance;
}
//初始化
- (id)initWithDelegate {
    self = [super init];
    if (self) {
        _requestQueue = [[ASINetworkQueue alloc] init];
        [_requestQueue setDelegate:self];
        [_requestQueue setRequestDidFailSelector:@selector(requestFailed:)];
        [_requestQueue setRequestDidFinishSelector:@selector(requestFinished:)];
        [_requestQueue setRequestWillRedirectSelector:@selector(request:willRedirectToURL:)];
		[_requestQueue setShouldCancelAllRequestsOnFailure:NO];
        [_requestQueue setShowAccurateProgress:YES];
        
    }
    
    return self;
}
#pragma mark - Methods
- (void)setGetUserInfo:(ASIHTTPRequest *)request withRequestType:(DataRequestType)requestType {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:requestType] forKey:REQUEST_TYPE];
    [request setUserInfo:dict];
}

- (void)setPostUserInfo:(ASIFormDataRequest *)request withRequestType:(DataRequestType)requestType {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:requestType] forKey:REQUEST_TYPE];
    [request setUserInfo:dict];
}

- (NSURL*)generateURL:(NSString*)baseURL params:(NSDictionary*)params {
	if (params) {
		NSMutableArray* pairs = [NSMutableArray array];
		for (NSString* key in params.keyEnumerator) {
			NSString* value = [params objectForKey:key];
			NSString* escaped_value = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
																						  kCFAllocatorDefault, /* allocator */
																						  (CFStringRef)value,
																						  NULL, /* charactersToLeaveUnescaped */
																						  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																						  kCFStringEncodingUTF8));
            
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
		}
		
		NSString* query = [pairs componentsJoinedByString:@"&"];
		NSString* url = [NSString stringWithFormat:@"%@?%@", baseURL, query];
		return [NSURL URLWithString:url];
	} else {
		return [NSURL URLWithString:baseURL];
	}
}
#pragma mark - Http Operate
- (void)letPublicUserRegister:(NSString *)userName password:(NSString *)pwd{
    NSString *baseUrl =[NSString  stringWithFormat:@"%@/publicUserRegister.htm?username=%@&password=%@",HTTP_LOGIN_URL,userName,pwd];
    NSURL  *url = [NSURL URLWithString:baseUrl];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setTimeOutSeconds:TIMEOUT];
    [request setResponseEncoding:NSUTF8StringEncoding];
    NSLog(@"url=%@",url);
    [self setGetUserInfo:request withRequestType:AAPublicUserRegister];
    [_requestQueue addOperation:request];
}

- (void)letPublicUserLogin:(NSString *)userName password:(NSString *)pwd{
    NSString *baseUrl =[NSString  stringWithFormat:@"%@/publicUserValidate.htm?username=%@&password=%@",HTTP_LOGIN_URL,userName,pwd];
    NSURL  *url = [NSURL URLWithString:baseUrl];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setTimeOutSeconds:TIMEOUT];
    [request setResponseEncoding:NSUTF8StringEncoding];
    NSLog(@"url=%@",url);
    [self setGetUserInfo:request withRequestType:AAPublicUserLogin];
    [_requestQueue addOperation:request];
}

- (void)letChangePassword:(NSString *)userName password:(NSString *)pwd{
    NSString *baseUrl =[NSString  stringWithFormat:@"%@/changePassword.htm?username=%@&password=%@",HTTP_LOGIN_URL,userName,pwd];
    NSURL  *url = [NSURL URLWithString:baseUrl];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setTimeOutSeconds:TIMEOUT];
    [request setResponseEncoding:NSUTF8StringEncoding];
    NSLog(@"url=%@",url);
    [self setGetUserInfo:request withRequestType:AAChangePassword];
    [_requestQueue addOperation:request];
}
//-(void)letDoHttpTypeQuery{
//    NSURL  *url = [NSURL URLWithString:HTTP_LOGIN_URL];
//    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
//    NSLog(@"url=%@",url);
//    [request setTimeOutSeconds:TIMEOUT];
//    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
//    [request setResponseEncoding:NSUTF8StringEncoding];
//    [self setGetUserInfo:request withRequestType:AAGetSearchList];
//    [_requestQueue addOperation:request];
//}


//- (void)letDoPostErrorWithMessage:(NSString *)message plottingScale:(NSString *)plottingScale point:(NSString *)point{
//    NSString *m = [NSString stringWithFormat:@"%@",message];
//    NSString *s = [NSString stringWithFormat:@"%@",plottingScale];
//    NSString *p = [NSString stringWithFormat:@"%@",point];
//    NSString *baseUrl =[NSString  stringWithFormat:@"%@",HTTP_LOGIN_URL];
//    NSURL  *url = [NSURL URLWithString:baseUrl];
//    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
//    [request setPostValue:@"admin" forKey:@"errorCorrector"];
//    [request setPostValue:s forKey:@"plottingScale"];
//    [request setPostValue:m forKey:@"errorCorrectInfo"];
//    [request setPostValue:@"0" forKey:@"errorcoreectObject"];
//    [request setPostValue:@"" forKey:@"telnum"];
//    [request setPostValue:p forKey:@"point"];
//    [request setPostValue:@"1" forKey:@"region"];
//    [request setTimeOutSeconds:TIMEOUT];
//    [request setDelegate:self];
//    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
//    [request setResponseEncoding:NSUTF8StringEncoding];
//    NSLog(@"url=%@",url);
//    [self setPostUserInfo:request withRequestType:AAGetSearchList];
//    [request startAsynchronous];
//}

//继续添加

#pragma mark - Operate queue
- (BOOL)isRunning
{
	return ![_requestQueue isSuspended];
}

- (void)start
{
	if( [_requestQueue isSuspended] )
		[_requestQueue go];
}

- (void)pause
{
	[_requestQueue setSuspended:YES];
}

- (void)resume
{
	[_requestQueue setSuspended:NO];
}

- (void)cancel
{
	[_requestQueue cancelAllOperations];
}
#pragma mark - ASINetworkQueueDelegate
//失败
- (void)requestFailed:(ASIHTTPRequest *)request{
    NSLog(@"请求失败:%@,%@,",request.responseString,[request.error localizedDescription]);
    if ([_delegate respondsToSelector:@selector(didGetFailed)]) {
        [_delegate didGetFailed];
    }
}

//成功
- (void)requestFinished:(ASIHTTPRequest *)request{
    NSDictionary *userInformation = [request userInfo];
    DataRequestType requestType = [[userInformation objectForKey:REQUEST_TYPE] intValue];
    NSString * responseString = [request responseString];
    SBJsonParser *parser = [[SBJsonParser alloc] init];    
    id  returnObject = [parser objectWithString:responseString];
    if(!returnObject && responseString){
        NSError *parseError = nil;
        returnObject= [XMLReader dictionaryForXMLString:responseString error:&parseError];
    }
    NSDictionary *userInfo = nil;
    NSArray *userArr = nil;
    if ([returnObject isKindOfClass:[NSDictionary class]]) {
        userInfo = (NSDictionary*)returnObject;
    }
    else if ([returnObject isKindOfClass:[NSArray class]]) {
        userArr = (NSArray*)returnObject;
    }
    
    if(requestType == AAPublicUserRegister){
        BOOL success = NO;
        if([responseString isEqualToString:@"-1"]){
            success = NO;
        }else{
            success = YES;
        }
        if ([_delegate respondsToSelector:@selector(didGetPublicUserRegister:)]) {
            [_delegate didGetPublicUserRegister:success];
        }
    }
    if(requestType == AAPublicUserLogin){
        BOOL success = NO;
        if([responseString isEqualToString:@"-1"]){
            success = NO;
        }else{
            success = YES;
        }
        if ([_delegate respondsToSelector:@selector(didGetPublicUserLogin:)]) {
            [_delegate didGetPublicUserLogin:success];
        }
    }
    if(requestType == AAChangePassword){
        BOOL success = NO;
        if([responseString isEqualToString:@"-1"]){
            success = NO;
        }else{
            success = YES;
        }
        if ([_delegate respondsToSelector:@selector(didGetChangePassword:)]) {
            [_delegate didGetChangePassword:success];
        }
    }
    
    
    //继续添加
    
    
    
}

//跳转
- (void)request:(ASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL {
    NSLog(@"请求将要跳转");
}


@end
