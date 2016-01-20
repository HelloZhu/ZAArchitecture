//
//  UserEntity.h
//  ZAArchitecture
//
//  Created by ap2 on 16/1/19.
//  Copyright © 2016年 ap2. All rights reserved.
//

#import "BaseEntity.h"
#import "BaseEntity+DataBase.h"

@interface UserEntity : BaseEntity

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, strong) NSNumber *houseCount;
@end
