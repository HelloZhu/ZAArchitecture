//
//  ZANetWorkClient.h
//  ZAArchitecture
//
//  Created by ap2 on 16/1/8.
//  Copyright © 2016年 ap2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZANetWorkRquest.h"
#import "ZAFileConfig.h"



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
- (void)downloadRequest:(NSString *)url tag:(NSInteger)tag successAndProgress:(ProgressBlock)progressHandler complete:(ResponseBlock)completionHandler;

/**
 文件上传
 */
- (void)updateRequest:(NSString *)url params:(NSDictionary *)params fileConfig:(ZAFileConfig *)fileConfig tag:(NSInteger)tag success:(RequestSuccessBlock)successHandler failure:(RequestFailureBlock)failureHandler;

/**
 文件上传，监听上传进度
 */
- (void)updateRequest:(NSString *)url params:(NSDictionary *)params fileConfig:(ZAFileConfig *)fileConfig successAndProgress:(ProgressBlock)progressHandler complete:(ResponseBlock)completionHandler;


- (void)addRequest:(ZANetWorkRquest *)request;
- (void)cancelRequest:(NSInteger)tag;
- (void)cancelAllRequests;

@end
