//
//  ZANetWorkClient.m
//  ZAArchitecture
//
//  Created by ap2 on 16/1/8.
//  Copyright © 2016年 ap2. All rights reserved.
//

#import "ZANetWorkClient.h"
#import "AFHTTPRequestOperation+Tag.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFURLSessionManager.h"

NSString *const Msg_key       = @"msg";
NSString *const Data_key      = @"data";
NSString *const ErrorCode_key = @"errorCode";

#define BLOCK_SAFE_RUN(block, ...)    block ? block(__VA_ARGS__) : nil;

@implementation ZANetWorkClient {
    NSMutableDictionary * _requestsRecord;
}

+ (ZANetWorkClient *)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _requestsRecord = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (AFHTTPRequestOperationManager *)AFRequstManager {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // 请求超时设定
    //manager.requestSerializer.timeoutInterval = 10;
    //manager.securityPolicy.allowInvalidCertificates = YES;
    
    return manager;
}


- (void)GETRequest:(NSString *)url params:(NSDictionary *)params tag:(NSInteger)tag success:(RequestSuccessBlock)successHandler failure:(RequestFailureBlock)failureHandler
{
    AFHTTPRequestOperationManager *manager = [ZANetWorkClient AFRequstManager];
    
    AFHTTPRequestOperation *requestOperation = [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self handleRequestResult:operation responeObejct:responseObject success:successHandler failure:failureHandler];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleRequestResult:operation responeObejct:error success:successHandler failure:failureHandler];
    }];
    
    [self addOperation:requestOperation];
}

- (void)POSTRequest:(NSString *)url params:(NSDictionary *)params tag:(NSInteger)tag success:(RequestSuccessBlock)successHandler failure:(RequestFailureBlock)failureHandler
{
    AFHTTPRequestOperationManager *manager = [ZANetWorkClient AFRequstManager];
    
    AFHTTPRequestOperation *requestOperation = [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self handleRequestResult:operation responeObejct:responseObject success:successHandler failure:failureHandler];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleRequestResult:operation responeObejct:error success:successHandler failure:failureHandler];
    }];
    
    [self addOperation:requestOperation];
}

//初步处理
- (void)handleRequestResult:(AFHTTPRequestOperation *)operation responeObejct:(id)responeObejct success:(RequestSuccessBlock)successHandler failure:(RequestFailureBlock)failureHandler{
    
    if (operation) {
        
        NSInteger statusCode = operation.response.statusCode;
        BOOL succeed = [ZANetWorkClient statusCodeValidator:statusCode];
        if (succeed) {
            
            if ([responeObejct isKindOfClass:[NSDictionary class]]){
                
                NSDictionary *dic = (NSDictionary *)responeObejct;
                id            resultData = [dic objectForKey:Data_key];
                ZAReqCodeType resultCode = [[dic objectForKey:ErrorCode_key] integerValue];
                NSString      *resultMsg = [dic objectForKey:Msg_key];
                
                if (_delegate && [_delegate respondsToSelector:@selector(requestSuccess:error:tag:)]){
                    [_delegate requestSuccess:responeObejct error:nil tag:operation.tag];
                }
                BLOCK_SAFE_RUN(successHandler,resultData, resultMsg, resultCode);
                
            }else{
                
                if (_delegate && [_delegate respondsToSelector:@selector(requestSuccess:error:tag:)]){
                    [_delegate requestSuccess:responeObejct error:nil tag:operation.tag];
                }
                BLOCK_SAFE_RUN(successHandler,responeObejct, nil, ZAReqCode_Success);
            }
            
        }else {
            
            NSError *sError   = (NSError *)responeObejct;
            ZAError *myError  = [[ZAError alloc] init];
            myError.error     = responeObejct;
            myError.errorCode = sError.code;
            
            if (_delegate && [_delegate respondsToSelector:@selector(requestFail:tag:)]){
                [_delegate requestFail:myError tag:operation.tag];
            }
            BLOCK_SAFE_RUN(failureHandler, myError);
            
        }
        
    }else{
        
        if (_delegate && [_delegate respondsToSelector:@selector(requestFail:tag:)]){
            [_delegate requestFail:nil tag:operation.tag];
        }
        BLOCK_SAFE_RUN(failureHandler, nil);
    }
    
    [self removeOperation:operation];
}


- (void)downloadRequest:(NSString *)url successAndProgress:(ProgressBlock)progressHandler complete:(ResponseBlock)completionHandler
{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:sessionConfiguration];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSProgress *kProgress = nil;
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:&kProgress destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        NSURL *documentUrl = [[NSFileManager defaultManager] URLForDirectory :NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        
        return [documentUrl URLByAppendingPathComponent:[response suggestedFilename]];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nonnull filePath, NSError * _Nonnull error){
        
    }];
    
    [manager setDownloadTaskDidWriteDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        
        progressHandler(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
        
    }];
    [downloadTask resume];
}

/**
 *  发送一个POST请求
 *  @param fileConfig 文件相关参数模型
 *  @param success 请求成功后的回调
 *  @param failure 请求失败后的回调
 *  无上传进度监听
 */
- (void)uploadRequest:(NSString *)url params:(NSDictionary *)params fileConfig:(ZAFileConfig *)fileConfig success:(RequestSuccessBlock)successHandler failure:(RequestFailureBlock)failureHandler {
    
    AFHTTPRequestOperationManager *manager = [ZANetWorkClient AFRequstManager];
    
     AFHTTPRequestOperation *requestOperation = [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:fileConfig.fileData name:fileConfig.name fileName:fileConfig.fileName mimeType:fileConfig.mimeType];
        
    } success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        [self handleRequestResult:operation responeObejct:responseObject success:successHandler failure:failureHandler];
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
       
        [self handleRequestResult:operation responeObejct:error success:successHandler failure:failureHandler];
    }];
    
    [self removeOperation:requestOperation];
}


/**
 上传文件，监听上传进度
 */
- (void)updateRequest:(NSString *)url params:(NSDictionary *)params fileConfig:(ZAFileConfig *)fileConfig successAndProgress:(ProgressBlock)progressHandler complete:(ResponseBlock)completionHandler {
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:fileConfig.fileData name:fileConfig.name fileName:fileConfig.fileName mimeType:fileConfig.mimeType];
        
    } error:nil];
    
    //获取上传进度
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        
        progressHandler(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
        
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        BLOCK_SAFE_RUN(completionHandler, responseObject, nil);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
         BLOCK_SAFE_RUN(completionHandler, error, nil);
    }];
    
    [operation start];
}


- (void)cancelRequest:(NSInteger)tag {
    NSDictionary *copyRecord = [_requestsRecord copy];
    for (NSString *key in copyRecord) {
        AFHTTPRequestOperation *requestOperation = copyRecord[key];
        if (requestOperation.tag == tag) {
            [requestOperation cancel];
            [self removeOperation:requestOperation];
        }
    }
}
- (void)cancelAllRequests {
    NSDictionary *copyRecord = [_requestsRecord copy];
    for (NSString *key in copyRecord) {
        AFHTTPRequestOperation *requestOperation = copyRecord[key];
        [requestOperation cancel];
    }
}



- (void)addOperation:(AFHTTPRequestOperation *)requestOperation {
    if (requestOperation != nil) {
        NSString * key = [self requestHashKey:requestOperation];
        _requestsRecord[key] = requestOperation;
    }
}

- (NSString *)requestHashKey:(AFHTTPRequestOperation *)operation
{
    NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)[operation hash]];
    return key;
}

- (void)removeOperation:(AFHTTPRequestOperation *)operation {
    NSString * key = [self requestHashKey:operation];
    [_requestsRecord removeObjectForKey:key];
}

+ (BOOL)statusCodeValidator:(NSInteger)statusCode {
    if (statusCode >= 200 && statusCode <= 299) {
        return YES;
    }else {
        return NO;
    }
}

/**
 监控网络状态
 */
+ (BOOL)checkNetworkStatus {
    
    __block BOOL isNetworkUse = YES;
    
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusUnknown) {
            isNetworkUse = YES;
        } else if (status == AFNetworkReachabilityStatusReachableViaWiFi){
            isNetworkUse = YES;
        } else if (status == AFNetworkReachabilityStatusReachableViaWWAN){
            isNetworkUse = YES;
        } else if (status == AFNetworkReachabilityStatusNotReachable){
            // 网络异常操作
            isNetworkUse = NO;
            NSLog(@"网络异常,请检查网络是否可用！");
        }
    }];
    [reachabilityManager startMonitoring];
    return isNetworkUse;
}


@end
