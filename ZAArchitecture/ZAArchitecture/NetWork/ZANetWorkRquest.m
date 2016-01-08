//
//  ZANetWorkRquest.m
//  ZAArchitecture
//
//  Created by ap2 on 16/1/7.
//  Copyright © 2016年 ap2. All rights reserved.
//

#import "ZANetWorkRquest.h"
#import "ZANetWorkClient.h"

@implementation ZANetWorkRquest

- (NSString *)responseString
{
    return self.requestOperation.responseString;
}
- (BOOL)statusCodeValidator {
    NSInteger statusCode = [self responseStatusCode];
    if (statusCode >= 200 && statusCode <= 299) {
        return YES;
    }else {
        return NO;
    }
}
- (NSInteger)responseStatusCode
{
    return self.requestOperation.response.statusCode;
}
- (void)clearCompletionBlock
{
    self.requestFailureBlock = nil;
    self.requestSuccessBlock = nil;
    self.responseBlock = nil;
    self.progressBlock = nil;
}
- (void)stop {
    [[ZANetWorkClient sharedInstance] cancelRequest:self.tag];
}

+ (ZANetWorkRquest *)ZARequestWith:(ZARequestMethod)method params:(NSDictionary *)params url:(NSString *)url
{
    ZANetWorkRquest *request = [[ZANetWorkRquest alloc] init];
    request.requestMethod = ZARequestMethodGet;
    request.requestUrl = url;
    request.requestParam = params;
    
    return request;
}

@end
