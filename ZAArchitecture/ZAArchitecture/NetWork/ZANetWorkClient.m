//
//  ZANetWorkClient.m
//  ZAArchitecture
//
//  Created by ap2 on 16/1/8.
//  Copyright © 2016年 ap2. All rights reserved.
//

#import "ZANetWorkClient.h"

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

- (void)GETRequest:(NSString *)url params:(NSDictionary *)params tag:(NSInteger)tag success:(RequestSuccessBlock)successHandler failure:(RequestFailureBlock)failureHandler
{
    ZANetWorkRquest *request = [ZANetWorkRquest ZARequestWith:ZARequestMethodGet params:params url:url];
    request.requestFailureBlock = failureHandler;
    request.requestSuccessBlock = successHandler;
    request.tag = tag;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    request.requestOperation = [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self handleRequestResult:operation responeObejct:responseObject success:successHandler failure:failureHandler];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleRequestResult:operation responeObejct:error success:successHandler failure:failureHandler];
    }];
    
    [self addOperation:request];
}

- (void)POSTRequest:(NSString *)url params:(NSDictionary *)params tag:(NSInteger)tag success:(RequestSuccessBlock)successHandler failure:(RequestFailureBlock)failureHandler
{
    ZANetWorkRquest *request = [ZANetWorkRquest ZARequestWith:GRRequestMethodPost params:params url:url];
    request.requestFailureBlock = failureHandler;
    request.requestSuccessBlock = successHandler;
    request.tag = tag;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    request.requestOperation = [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self handleRequestResult:operation responeObejct:responseObject success:successHandler failure:failureHandler];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleRequestResult:operation responeObejct:error success:successHandler failure:failureHandler];
    }];
    
    [self addOperation:request];
}

- (void)downloadRequest:(NSString *)url tag:(NSInteger)tag successAndProgress:(ProgressBlock)progressHandler complete:(ResponseBlock)completionHandler
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
                BLOCK_SAFE_RUN(successHandler,resultData, resultMsg, resultCode);
                
            }else{
                
                BLOCK_SAFE_RUN(successHandler,responeObejct, nil, ZAReqCode_Success);
            }
            
        }else {
            
            NSError *sError   = (NSError *)responeObejct;
            ZAError *myError  = [[ZAError alloc] init];
            myError.error     = responeObejct;
            myError.errorCode = sError.code;
            BLOCK_SAFE_RUN(failureHandler, myError);
        }
        
    }else{
        BLOCK_SAFE_RUN(failureHandler, nil);
    }
    
    [self removeOperation:operation];
}


- (void)cancelRequest:(NSInteger)tag {
    NSDictionary *copyRecord = [_requestsRecord copy];
    for (NSString *key in copyRecord) {
        ZANetWorkRquest *request = copyRecord[key];
        if (request.tag == tag) {
            [request.requestOperation cancel];
            [self removeOperation:request.requestOperation];
            //[request clearCompletionBlock];
        }
    }
}
- (void)cancelAllRequests {
    NSDictionary *copyRecord = [_requestsRecord copy];
    for (NSString *key in copyRecord) {
        ZANetWorkRquest *request = copyRecord[key];
        [request stop];
    }
}

- (BOOL)checkResult:(ZANetWorkRquest *)request
{
    BOOL result = [request statusCodeValidator];
    return result;
}

- (void)addOperation:(ZANetWorkRquest *)request {
    if (request.requestOperation != nil) {
        NSString * key = [self requestHashKey:request.requestOperation];
        _requestsRecord[key] = request;
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
