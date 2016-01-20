//
//  ZADBHelper.h
//  ZAArchitecture
//
//  Created by ap2 on 16/1/19.
//  Copyright © 2016年 ap2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

/** SQLite五种数据类型 */
#define SQLTEXT     @"TEXT"
#define SQLINTEGER  @"INTEGER"
#define SQLREAL     @"REAL"
#define SQLBLOB     @"BLOB"
#define SQLNULL     @"NULL"
#define PrimaryKey  @"primary key NOT NULL"

#define primaryId   @"pk"

@interface ZADBHelper : NSObject

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

+ (NSString *)dbPath;
+ (instancetype)shareInstance;

@end
