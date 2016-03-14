//
//  ZAResponse.h
//  ZAArchitecture
//
//  Created by ap2 on 16/3/14.
//  Copyright © 2016年 ap2. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ZAReqCodeType) {
    
    ZAReqCode_NetNotAvailable   = -1,
    ZAReqCode_Success = 0,
    ZAReqCode_UploadFail,
};

@interface ZAResponse : NSObject

@property (nonatomic, strong) id responseObject;
@property (nonatomic, strong) NSString *responseMessage;
@property (nonatomic, assign) ZAReqCodeType responseCode;
+ (ZAResponse *)responseWith:(id)object msg:(NSString *)msg code:(ZAReqCodeType)code;
@end
