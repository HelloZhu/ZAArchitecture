//
//  ZAError.h
//  ZAArchitecture
//
//  Created by ap2 on 16/1/8.
//  Copyright © 2016年 ap2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZAError : NSObject

@property (nonatomic, strong) NSError *error;
@property (nonatomic, assign) NSInteger errorCode;
@property (nonatomic, assign) NSInteger errorMsg;

@end
