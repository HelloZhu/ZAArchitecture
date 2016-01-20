//
//  ZAError.m
//  ZAArchitecture
//
//  Created by ap2 on 16/1/8.
//  Copyright © 2016年 ap2. All rights reserved.
//

#import "ZAError.h"

@implementation ZAError

+ (instancetype)errorWithError:(NSError *)error code:(NSInteger)code msg:(NSString *)msg
{
    ZAError *myError = [[ZAError alloc] init];
    myError.error = error;
    myError.errorCode = code;
    myError.errorMsg = msg;
    
    return myError;
}

@end
