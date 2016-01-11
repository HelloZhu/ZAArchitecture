//
//  AFHTTPRequestOperation+Tag.m
//  ZAArchitecture
//
//  Created by ap2 on 16/1/11.
//  Copyright © 2016年 ap2. All rights reserved.
//

#import "AFHTTPRequestOperation+Tag.h"
#import <objc/runtime.h>

const char tagKey;

@implementation AFHTTPRequestOperation (Tag)

- (void)setTag:(NSInteger)tag
{
    objc_setAssociatedObject(self, &tagKey, @(tag), OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)tag
{
    id object = objc_getAssociatedObject(self, &tagKey);
    return [object integerValue];
}

@end
