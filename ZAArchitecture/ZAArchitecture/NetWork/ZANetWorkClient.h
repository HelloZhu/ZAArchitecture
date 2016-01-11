//
//  ZANetWorkClient.h
//  ZAArchitecture
//
//  Created by ap2 on 16/1/8.
//  Copyright © 2016年 ap2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZAFileConfig.h"
#import "ZAError.h"

typedef NS_ENUM(NSInteger, ZAReqCodeType) {
    
    ZAReqCode_Success = 0,
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

@protocol ZANetWorkClientDelegate <NSObject>

@optional
- (void)requestSuccess:(id)responObject error:(ZAError*)error tag:(NSInteger)tag;
- (void)requestFail:(ZAError *)error tag:(NSInteger)tag;
@end

@interface ZANetWorkClient : NSObject

@property (nonatomic, assign) id<ZANetWorkClientDelegate> delegate;

+ (instancetype)sharedInstance;

/**
 GET请求
 */
- (void)GETRequest:(NSString *)url params:(NSDictionary *)params tag:(NSInteger)tag success:(RequestSuccessBlock)successHandler failure:(RequestFailureBlock)failureHandler;

/**
 POST请求
 */
- (void)POSTRequest:(NSString *)url params:(NSDictionary *)params tag:(NSInteger)tag success:(RequestSuccessBlock)successHandler failure:(RequestFailureBlock)failureHandler;

/**
 下载文件，监听下载进度
 */
- (void)downloadRequest:(NSString *)url successAndProgress:(ProgressBlock)progressHandler complete:(ResponseBlock)completionHandler;

- (void)uploadRequest:(NSString *)url params:(NSDictionary *)params fileConfig:(ZAFileConfig *)fileConfig success:(RequestSuccessBlock)successHandler failure:(RequestFailureBlock)failureHandler;

- (void)updateRequest:(NSString *)url params:(NSDictionary *)params fileConfig:(ZAFileConfig *)fileConfig successAndProgress:(ProgressBlock)progressHandler complete:(ResponseBlock)completionHandler;


- (void)cancelRequest:(NSInteger)tag;
- (void)cancelAllRequests;

@end
