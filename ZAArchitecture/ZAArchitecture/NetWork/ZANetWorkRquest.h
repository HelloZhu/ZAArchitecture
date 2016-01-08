//
//  ZANetWorkRquest.h
//  ZAArchitecture
//
//  Created by ap2 on 16/1/7.
//  Copyright © 2016年 ap2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "ZAError.h"

typedef NS_ENUM(NSInteger, ZAReqCodeType) {
    
    ZAReqCode_Success = 0,
};

typedef NS_ENUM(NSInteger, ZARequestMethod) {
    ZARequestMethodGet = 0,
    GRRequestMethodPost,
};
typedef NS_ENUM(NSInteger, ZARequestSerializerType) {
    ZARequestSerializerTypeJSON = 0,
    ZARequestSerializerTypeHTTP,
};

/**
 请求成功block
 */
typedef void (^RequestSuccessBlock)(id responseObj, NSString *resultMsg, ZAReqCodeType code);

/**
 请求失败block
 */
typedef void (^RequestFailureBlock) (ZAError *error);

/**
 请求响应block
 */
typedef void (^ResponseBlock)(id dataObj, ZAError *error);

/**
 监听进度响应block
 */
typedef void (^ProgressBlock)(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);


@interface ZANetWorkRquest : NSObject

@property (nonatomic, strong) AFHTTPRequestOperation * requestOperation;

//HTTP请求的方法..
@property (nonatomic) ZARequestMethod requestMethod;

//请求的参数
@property (nonatomic, strong) NSDictionary * requestParam;

//请求的URL
@property (nonatomic, strong) NSString * requestUrl;

//返回的数据
@property (nonatomic, strong, readonly) NSString * responseString;

//请求的数据类型
@property (nonatomic) ZARequestSerializerType requestSerializerType;

@property (nonatomic) NSInteger tag;

@property (nonatomic, copy) RequestSuccessBlock requestSuccessBlock;
@property (nonatomic, copy) RequestFailureBlock requestFailureBlock;
@property (nonatomic, copy) ResponseBlock responseBlock;
@property (nonatomic, copy) ProgressBlock progressBlock;

+ (ZANetWorkRquest *)ZARequestWith:(ZARequestMethod)method params:(NSDictionary *)params url:(NSString *)url;

//状态码校验
- (BOOL)statusCodeValidator;

//把block置nil来打破循环引用
- (void)clearCompletionBlock;

- (void)stop;

@end


